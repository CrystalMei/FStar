module Protocol

open FStar.Seq

open FStar.Preorder
open FStar.Heap
open FStar.ST

open FreezingArray

(* size of each message fragment sent over the network *)
assume val fragment_size:nat

type byte

type message  = s:seq byte{length s <= fragment_size}
type fragment = s:seq byte{length s = fragment_size}

(* random bytes for ideal cipher? *)
type randomness = nat -> fragment

assume val oplus: fragment -> fragment -> fragment

assume val lemma_oplus (a:fragment) (b:fragment)
  :Lemma (oplus (oplus a b) b == a)
   [SMTPat (oplus (oplus a b) b)]

(* a message sent on the network cannot be unsent *)
(* every fragment has a ref bool, that is initialized to false, and sending the fragment over the network sets it to true *)
let sent_pre :preorder bool = fun (b1:bool) (b2:bool) -> b1 ==> b2

assume val zeroes: n:nat -> (s:seq byte{length s = n})

let pad (m:message) :fragment = append m (zeroes (fragment_size - (length m)))

assume val unpad (s:fragment)
  :(r:(nat * message){length (snd r) = fst r /\ s == pad (snd r)})

(* an entry in the message log *)
noeq type entry (rand:randomness) =
  | E: i:nat -> msg:message -> cipher:fragment{oplus (pad msg) (rand i) == cipher} -> sent:mref bool sent_pre -> entry rand

(* sequence of messages *)
type entries (rand:randomness) = s:seq (entry rand){forall (i:nat). i < length s ==> E?.i (Seq.index s i) = i}

let is_prefix_of (#a:Type) (s1:seq a) (s2:seq a) :Type0
  = length s1 <= length s2 /\
    (forall (i:nat). i < length s1 ==> Seq.index s1 i == Seq.index s2 i)

(* entries are only appended to, typing entries_rel directly as `preorder (entries rand)` doesn't work *)
let entries_rel (rand:randomness) :relation (entries rand) =
  fun (es1:entries rand) (es2:entries rand) -> es1 `is_prefix_of` es2

let entries_pre (rand:randomness) :preorder (entries rand) = entries_rel rand

(* a single state stable predicate on the counter, saying that it is less than the length of the log *)
let counter_pred (#rand:randomness) (n:nat) (es_ref:mref (entries rand) (entries_rel rand)) :(p:heap_predicate{stable p})
  = fun h -> h `contains` es_ref /\ n <= length (sel h es_ref)

(* counter type is a nat, witnessed with counter_pred *)
type counter_t (#rand:randomness) (es_ref:mref (entries rand) (entries_rel rand))
  = n:nat{witnessed (counter_pred n es_ref)}

(* counter increases monotonically *)
let counter_rel (#rand:randomness) (es_ref:mref (entries rand) (entries_rel rand)) :relation (counter_t es_ref)
  = fun n1 n2 -> b2t (n1 <= n2)

let counter_pre (#rand:randomness) (es_ref:mref (entries rand) (entries_rel rand)) :preorder (counter_t es_ref)
  = counter_rel es_ref

noeq type connection =
  | S: rand:randomness -> entries:mref (entries rand) (entries_rel rand) -> connection
  | R: rand:randomness -> entries:mref (entries rand) (entries_rel rand)
       -> ctr:mref (counter_t entries) (counter_pre entries) -> connection

assume val seq_map:
  #a:Type -> #b:Type -> f:(a -> b) -> s:seq a
  -> (r:seq b{length s = length r /\ (forall (i:nat). i < length s ==> Seq.index r i == f (Seq.index s i))})

let rand_of (c:connection) :randomness =
  match c with
  | S r _
  | R r _ _ -> r

let entries_of (c:connection) :(mref (entries (rand_of c)) (entries_rel (rand_of c))) =
  match c with
  | S _ es   -> es
  | R _ es _ -> es

let contains_connection (h:heap) (c:connection) =
  match c with
  | S _ es_ref         -> h `contains` es_ref
  | R _ es_ref ctr_ref -> h `contains` es_ref /\ h `contains` ctr_ref

let recall_connection (c:connection) :ST unit (requires (fun h0 -> True)) (ensures (fun h0 _ h1 -> h0 == h1 /\ h0 `contains_connection` c))
  = match c with
    | S _ es_ref         -> ST.recall es_ref
    | R _ es_ref ctr_ref -> ST.recall es_ref; ST.recall ctr_ref

(* seq of plain messages sent so far on this connection *)
let log (c:connection) (h:heap{h `contains_connection` c}) :Tot (seq message) =
  seq_map (fun (E _ m _ _) -> m) (sel_tot h (entries_of c))

assume val lemma_prefix_entries_implies_prefix_log
  (c:connection) (h1:heap) (h2:heap{h1 `contains_connection` c /\ h2 `contains_connection` c})
  :Lemma (requires (sel h1 (entries_of c) `is_prefix_of` sel h2 (entries_of c)))
	 (ensures  (log c h1 `is_prefix_of` log c h2))
	 [SMTPat (log c h1); SMTPat (log c h2)]

(* current counter for the connection, consider adding the valid refinement? *)
let ctr (c:connection) (h:heap{h `contains_connection` c}) :Tot nat =
  match c with
  | S _ es_ref    -> length (sel_tot h es_ref)
  | R _ _ ctr_ref -> sel_tot h ctr_ref

let recall_counter (c:connection) :ST unit (requires (fun _ -> True)) (ensures (fun h0 _ h1 -> h0 == h1 /\ h0 `contains_connection` c /\ ctr c h0 <= Seq.length (log c h0)))
  = recall_connection c;
    match c with
    | S _ _              -> ()
    | R _ es_ref ctr_ref -> let n = !ctr_ref in gst_recall (counter_pred n es_ref)


(* stable predicate for counter *)
let connection_pred (c:connection) (h0:heap{h0 `contains_connection` c}) :(p:heap_predicate{stable p}) =
  fun h -> h `contains_connection` c /\
        ctr c h0 <= ctr  c h /\ ctr c h0 <= length (log c h) /\ log c h0 `is_prefix_of` log c h

let snap (c:connection) :ST unit (requires (fun _ -> True))
                                 (ensures  (fun h0 _ h1 -> h0 `contains_connection` c /\ witnessed (connection_pred c h0) /\ h0 == h1))
  = let h0 = ST.get () in
    recall_connection c;
    (match c with
     | S _ _              -> ()
     | R _ es_ref ctr_ref -> gst_recall (counter_pred (sel_tot h0 ctr_ref) es_ref));
    gst_witness (connection_pred c h0)

type iarray (a:Type0) (n:nat) = x:array a n{all_init x}

(* (\* these probably need some contains precondition? *\) *)
(* assume val as_seq_ghost: *)
(*   #n:nat -> #a:Type -> iarray n a -> i:nat -> j:nat{j >= i /\ j <= n} -> h:heap *)
(*   -> GTot (s:seq a{length s = j - i}) *)
(* assume val as_seq: *)
(*   #n:nat -> #a:Type -> arr:iarray n a -> i:nat -> j:nat{j >= i /\ j <= n} *)
(*   -> ST (s:seq a{length s = j - i}) *)
(*        (requires (fun h0 -> True)) *)
(*        (ensures  (fun h0 s h1 -> h0 == h1 /\ s == as_seq_ghost arr i j h0)) *)

let sender (c:connection) :Tot bool   = S? c
let receiver (c:connection) :Tot bool = R? c

let connection_footprint (c:connection) :GTot (Set.set nat)
  = match c with
    | S _ es_ref         -> Set.singleton (addr_of es_ref)
    | R _ es_ref ctr_ref -> Set.union (Set.singleton (addr_of es_ref)) (Set.singleton (addr_of ctr_ref))

assume val lemma_snoc_log
  (c:connection{sender c}) (i:nat) (cipher:fragment) (msg:message{oplus (pad msg) ((rand_of c) i) == cipher})
  (sent_ref:mref bool sent_pre)
  (h0:heap) (h1:heap{h0 `contains_connection` c /\ h1 `contains_connection` c})
  :Lemma (requires (let S _ es_ref = c in
                    sel h1 es_ref == snoc (sel h0 es_ref) (E i msg cipher sent_ref)))
	 (ensures  (log c h1 == snoc (log c h0) msg))

(* network send is called once log had been appended to etc. *)
assume val network_send
  (c:connection) (f:fragment)
  :ST unit (requires (fun h0 -> True))
           (ensures  (fun h0 _ h1 -> h0 == h1))  //TODO: this is wrong, it modifies the sent_ref

(* TODO: we need to give some more precise type that talks about sent_refs, they are not being used currently at all *)
#set-options "--z3rlimit 50"
let send (#n:nat) (buf:iarray byte n) (c:connection{sender c})
  :ST nat (requires (fun h0 -> True))
        (ensures  (fun h0 sent h1 -> modifies (connection_footprint c) h0 h1         /\
	                          h0 `contains_connection` c /\
				  h1 `contains_connection` c /\
	                          sent <= min n fragment_size /\
				  ctr c h1 = ctr c h0 + 1    /\
				  (forall (i:nat). i < n ==> Some? (Seq.index (as_seq buf h0) i)) /\
                                  log c h1 == snoc (log c h0) (as_initialized_subseq buf h0 0 sent)))
  = let h0 = ST.get () in

    recall_connection c;
    recall_all_init buf;

    let S rand es_ref = c in

    let msgs0 = ST.read es_ref in
    let i0 = length msgs0 in

    let sent = min n fragment_size in
    let msg = read_subseq_i_j buf 0 sent in
    let frag = append msg (zeroes (fragment_size - sent)) in
    let cipher = oplus frag (rand i0) in

    //TODO: call network send!

    let sent_ref :mref bool sent_pre = alloc false in
    let msgs1 = snoc msgs0 (E i0 msg cipher sent_ref) in

    ST.write es_ref msgs1;

    let h1 = ST.get () in
    lemma_snoc_log c i0 cipher msg sent_ref h0 h1;
    
    sent

(* seq of ciphers sent so far on this connection *)
let ciphers (c:connection) (h:heap) :GTot (seq fragment) =
  seq_map (fun (E _ _ cipher _) -> cipher) (sel h (entries_of c))

assume val network_receive
  (c:connection{receiver c})
  :ST (option fragment) (requires (fun h0          -> h0 `contains_connection` c))
                        (ensures  (fun h0 f_opt h1 -> h0 == h1                                           /\
			                           h0 `contains_connection` c                         /\
						   (Some? f_opt <==> ctr c h0 < length (ciphers c h0)) /\
						   (ctr c h0 < length (ciphers c h0) ==>
						    f_opt == Some (Seq.index (ciphers c h0) (ctr c h0)))))

let modifies_r (#n:nat) (c:connection{receiver c}) (arr:array byte n) (h0 h1:heap) :Type0
  = modifies (Set.union (connection_footprint c)
                        (array_footprint arr)) h0 h1

#set-options "--z3rlimit 50"
let receive (#n:nat{fragment_size <= n}) (buf:array byte n) (c:connection{receiver c})
  :ST (option nat) (requires (fun h0          -> Set.disjoint (connection_footprint c) (array_footprint buf)))
                 (ensures  (fun h0 r_opt h1 -> match r_opt with
					    | None   -> h0 == h1
					    | Some r ->
					      h0 `contains_connection` c   /\
					      h1 `contains_connection` c   /\
					      modifies_r c buf h0 h1       /\
					      disjoint_siblings_remain_same buf h0 h1 /\
					      r <= fragment_size            /\
					      all_init_i_j buf 0 r         /\
					      ctr c h1 = ctr c h0 + 1      /\
					      ctr c h0 < length (log c h0) /\
                                              log c h0 == log c h1 /\
					      (forall (i:nat). i < r ==> Some? (Seq.index (as_seq buf h1) i)) /\
					      Seq.index (log c h0) (ctr c h0) == as_initialized_subseq buf h1 0 r))
  = let h0 = ST.get () in
    let R rand es_ref ctr_ref = c in

    Set.lemma_disjoint_subset (connection_footprint c) (array_footprint buf) (Set.singleton (addr_of ctr_ref));

    recall_connection c;

    match network_receive c with
    | None        -> None
    | Some cipher ->
      let i0 = ST.read ctr_ref in
      let msg = oplus cipher (rand i0) in
      let len, m = unpad msg in

      assume (m == Seq.index (log c h0) (ctr c h0));

      gst_witness (counter_pred (i0 + 1) es_ref);
      recall_contains buf;
      ST.write ctr_ref (i0 + 1);
      let h1 = ST.get () in
      lemma_disjoint_sibling_remain_same_for_unrelated_mods buf (Set.singleton (addr_of (ctr_ref))) h0 h1;
      fill buf m;
      let h2 = ST.get () in
      lemma_disjoint_sibling_remain_same_transitive buf h0 h1 h2;
      Some len
#reset-options

(***** sender and receiver *****)

let lemma_is_prefix_of_slice
  (#a:Type0) (s1:seq a) (s2:seq a{s1 `is_prefix_of` s2}) (i:nat) (j:nat{j >= i /\ j <= Seq.length s1})
  :Lemma (requires True)
         (ensures  (Seq.slice s1 i j == Seq.slice s2 i j))
	 [SMTPat (s1 `is_prefix_of` s2); SMTPat (Seq.slice s1 i j); SMTPat (Seq.slice s2 i j)]
  = admit ()

assume val flatten (s:seq message) :Tot (seq byte)

assume val lemma_flatten_snoc (s:seq message) (m:message)
  :Lemma (requires True)
         (ensures  (flatten (snoc s m) == append (flatten s) m))

assume val flatten_empty (u:unit) : Lemma 
  (flatten Seq.createEmpty == Seq.createEmpty)
  
let sent_file_pred' (file:seq byte) (c:connection) (from:nat) (to:nat{from <= to}) :heap_predicate
  = fun h -> h `contains_connection` c /\ 
          (let log   = log c h in
           to <= Seq.length log /\ 
	   file == flatten (Seq.slice log from to))

let sent_file_pred (file:seq byte) (c:connection) (from:nat) (to:nat{from <= to}) :(p:heap_predicate{stable p})
  = sent_file_pred' file c from to

(* let sent_file_pred_init (file:seq byte) (c:connnection) (from:nat) (h:heap{h `contains_connection` c)} *)
(*   : Lemma (send_file_pred file c from from h) *)
(*   = assert  *)
let sent_file (file:seq byte) (c:connection) =
  exists (from:nat) (to:nat{from <= to}). witnessed (sent_file_pred file c from to)

let lemma_get_equivalent_append
  (#a:Type0) (s1:seq (option a){forall (i:nat). i < Seq.length s1 ==> Some? (Seq.index s1 i)})
  (s2:seq (option a)) (s3:seq (option a))
  :Lemma (requires (s1 == Seq.append s2 s3))
         (ensures  ((forall (i:nat). i < Seq.length s2 ==> Some? (Seq.index s2 i)) /\
	            (forall (i:nat). i < Seq.length s3 ==> Some? (Seq.index s3 i)) /\
	            get_some_equivalent s1 == Seq.append (get_some_equivalent s2) (get_some_equivalent s3)))
  = admit ()

#set-options "--z3rlimit 20"
let iarray_as_seq (#a:Type) (#n:nat) (x:iarray a n) : ST (seq a) 
  (requires (fun h -> True))
  (ensures (fun h0 s h1 ->  
              h0==h1 /\
              (forall (k:nat). k < n ==> Some? (Seq.index (as_seq x h0) k)) /\
              s == as_initialized_subseq x h0 0 n                    /\
	      s == as_initialized_seq x h0))
  = admit()              

let fully_initialized_in #a #n (x:array a n) (h:heap) = 
  h `contains_array` x /\
  (forall (k:nat). k < n ==> Some? (Seq.index (as_seq x h) k))

let subseq_suffix #a #n (f:iarray a n) (pos:nat) (until:nat{pos+until <= n}) 
    (h:heap{f `fully_initialized_in` h})
  : Lemma  (as_initialized_subseq (suffix f pos) h 0 until ==
            as_initialized_subseq f h pos (pos + until))
  = assert (as_initialized_subseq (suffix f pos) h 0 until `Seq.equal`
            as_initialized_subseq f h pos (pos + until))        

let slice_snoc #a (s:seq a) (x:a) (from:nat) (to:nat{from<=to /\ to<=Seq.length s})
  : Lemma (slice s from to == slice (snoc s x) from to)
  = assert (slice s from to `Seq.equal` slice (snoc s x) from to)

let slice_snoc2 #a (s:seq a) (x:a) (from:nat{from <= Seq.length s})
  : Lemma (slice (snoc s x) from (Seq.length s + 1) == snoc (slice s from (Seq.length s)) x)
  = assert (slice (snoc s x) from (Seq.length s + 1) `Seq.equal` snoc (slice s from (Seq.length s)) x)

#set-options "--z3rlimit 100"
let append_subseq #a #n (f:iarray a n) (pos:nat) (sent:nat{pos + sent <= n}) (h:heap{f `fully_initialized_in` h})
    : Lemma (let f0 = as_initialized_subseq f h 0 pos in
             let f1 = as_initialized_subseq f h 0 (pos + sent) in
             let sub_file = suffix f pos in
             let sent_frag = as_initialized_subseq sub_file h 0 sent in
             f1 == append f0 sent_frag)
    = admit ();
      let f0 = as_initialized_subseq f h 0 pos in
      let f1 = as_initialized_subseq f h 0 (pos + sent) in
      let sub_file = suffix f pos in
      let sent_frag = as_initialized_subseq sub_file h 0 sent in
      assert (Seq.equal f1 (append f0 sent_frag))

let lemma_sender_connection_ctr_equals_length_log
  (c:connection{sender c}) (h:heap{h `contains_connection` c})
  :Lemma (ctr c h == Seq.length (log c h))
  = ()

#reset-options "--z3rlimit 200 --max_fuel 0 --max_ifuel 0"
val send_aux 
          (#n:nat) 
          (file:iarray byte n) 
          (c:connection{sender c /\ Set.disjoint (connection_footprint c) (array_footprint file)})
          (from:nat)
          (pos:nat{pos <= n})
      : ST unit 
             (requires (fun h0 ->
                      file `fully_initialized_in` h0 /\
                      h0 `contains_connection` c /\
                      from <= ctr c h0 /\
                      sent_file_pred (as_initialized_subseq file h0 0 pos) c from (ctr c h0) h0))
             (ensures  (fun h0 _ h1 -> 
                      modifies (connection_footprint c) h0 h1 /\
                      h1 `contains_connection` c /\
                      from <= ctr c h1 /\
                      (forall (k:nat). k < n ==> Some? (Seq.index (as_seq file h0) k)) /\
                      sent_file_pred (as_initialized_seq file h0) c from (ctr c h1) h1))
#reset-options "--z3rlimit 500 --max_fuel 0 --max_ifuel 0"
let rec send_aux #n file c from pos
      = if pos = n then ()
        else
          let sub_file = suffix file pos in
          lemma_all_init_i_j_sub file pos (n - pos);
       
          let h0 = ST.get () in
          let file_bytes0 = iarray_as_seq file in
          let log0 = log c h0 in
          let sent = send sub_file c in
          let h1 = ST.get () in
          let log1 = log c h1 in
          let file_bytes1 = iarray_as_seq file in          
          assert (file_bytes0 == file_bytes1);
          recall_contains file; //strange that this is needed
          assert (from <= ctr c h1);
          assert (file `fully_initialized_in` h1);
          assert (h1 `contains_connection` c);
          let _ : unit = 
            let sent_frag = as_initialized_subseq sub_file h0 0 sent in
            let sent_frag' = as_initialized_subseq file h0 pos (pos + sent) in
            assert (log1 == snoc log0 sent_frag);
            subseq_suffix file pos sent h0; //sent_frag == sent_frag'
            slice_snoc log0 sent_frag from (ctr c h0); //slice log0 from (ctr c h0) == slice log1 from (ctr c h0)
            slice_snoc2 log0 sent_frag from; //Seq.slice log1 from (ctr c h1) == snoc (Seq.slice log0 from (ctr c h0)) sent_frag
            assert (ctr c h0 + 1 = ctr c h1);
	    lemma_sender_connection_ctr_equals_length_log c h0;
	    lemma_sender_connection_ctr_equals_length_log c h1;	    
	    assert (ctr c h0 = Seq.length log0);
            assert (ctr c h1 = Seq.length log1);
            let f0 = as_initialized_subseq file h1 0 pos in
            let f1 = as_initialized_subseq file h1 0 (pos + sent) in
            append_subseq file pos sent h1; //f1 == append f0 sent_frag
            assert (f1 == append f0 sent_frag);
            assert (f0 == flatten (Seq.slice log0 from (ctr c h0)));
            lemma_flatten_snoc (Seq.slice log0 from (ctr c h0)) sent_frag;
            assert (f1 == flatten (Seq.slice log1 from (ctr c h1)));
            // assert (f0 == flatten (Seq.slice log1 from (ctr c h0)));
            // assume (f1 == flatten (Seq.slice log1 from (ctr c h1)));
            assert (sent_file_pred f1 c from (ctr c h1) h1) 
         in
         send_aux file c from (pos + sent)

let send_file (#n:nat) (file:iarray byte n) (c:connection{sender c /\ Set.disjoint (connection_footprint c) (array_footprint file)})
  : ST unit 
       (requires (fun h -> True))
       (ensures (fun h0 _ h1 ->
                      modifies (connection_footprint c) h0 h1 /\
                      h1 `contains_connection` c /\
                      (forall (k:nat). k < n ==> Some? (Seq.index (as_seq file h0) k)) /\
                      sent_file (as_initialized_seq file h0) c))
  = let h0 = ST.get () in
    recall_all_init file;
    recall_contains file;
    recall_connection c;
    let file_bytes0 = iarray_as_seq file in
    let from = ctr c h0 in
    assert (Seq.equal (as_initialized_subseq file h0 0 0) Seq.createEmpty);
    flatten_empty();
    assert (Seq.equal (flatten (Seq.slice (log c h0) from from)) Seq.createEmpty);
    send_aux file c from 0;
    let h1 = ST.get () in
    let file_bytes1 = iarray_as_seq file in
    assert (file_bytes0 == file_bytes1);
    gst_witness (sent_file_pred file_bytes0 c from (ctr c h1));
    assert (sent_file file_bytes0 c)

let received (#n:nat) (file:iarray byte n) (c:connection) (h:heap) =
    file `fully_initialized_in` h /\
    sent_file (as_initialized_seq file h) c

val receive_aux
          (#n:nat)
          (file:array byte n)
          (c:connection{receiver c /\ Set.disjoint (connection_footprint c) (array_footprint file)})
          (h_init:heap{h_init `contains_connection` c})
          (from:nat{from = ctr c h_init})
          (pos:nat{fragment_size <= n - pos})
    : ST (option (r:nat{r <= n}))
        (requires (fun h0 ->
              let file_in = prefix file pos in
              all_init_i_j file_in 0 pos /\
              file_in `fully_initialized_in` h0 /\
              h0 `contains_connection` c /\
              from <= ctr c h0 /\
              sent_file_pred (as_initialized_seq file_in h0) c from (ctr c h0) h0))
        (ensures (fun h0 ropt h1 ->
                   modifies_r c file h0 h1 /\
                   h1 `contains_connection` c /\
                   (match ropt with
                    | None -> True
                    | Some r ->
                      let file_out = prefix file r in
                      all_init_i_j file_out 0 r /\
                      file_out `fully_initialized_in` h1 /\
                      from <= ctr c h1 /\
                      sent_file_pred (as_initialized_seq file_out h1) c from (ctr c h1) h1)))

let append_filled #a #n (f:array a n) (pos:nat) (next:nat{pos + next <= n}) (h:heap)
  : Lemma (let f0 = prefix f pos in
           let f1 = prefix f (pos + next) in
           f1 `fully_initialized_in` h ==> (
           let b0 = as_initialized_seq f0 h in
           let b1 = as_initialized_seq f1 h in
           let received_frag = as_initialized_subseq (suffix f pos) h 0 next in
           Seq.equal b1 (append b0 received_frag)))
   = ()            

let extend_initialization #a #n (f:array a n) (pos:nat) (next:nat{pos+next <= n}) (h:heap)
  : Lemma (requires (let f0 = prefix f pos in
                     let f_next = prefix (suffix f pos) next in
                     f0 `fully_initialized_in` h /\
                     f_next `fully_initialized_in` h))
          (ensures (prefix f (pos + next) `fully_initialized_in` h))
  = let f0 = as_seq (prefix f pos) h in
    let f_next = as_seq (prefix (suffix f pos) next) h in
    let f1 = as_seq (prefix f (pos + next)) h in
    let aux (i:nat{i < pos + next}) : Lemma (Some? (Seq.index (as_seq (prefix f (pos + next)) h) i)) =
        if i < pos then assert (Seq.index f1 i == Seq.index f0 i)
        else assert (Seq.index f1 i == Seq.index f_next (i - pos))
    in
    FStar.Classical.forall_intro aux

let rec receive_aux #n file c h_init from pos
   = let h0 = ST.get() in
     let filled0 = prefix file pos in
     let filled_bytes0 = iarray_as_seq filled0 in
     let sub_file = suffix file pos in
     lemma_sub_footprint file pos (n - pos);
     assert (array_footprint sub_file == array_footprint file);
     match receive sub_file c with
       | None -> None
       | Some k -> 
         let h1 = ST.get () in
         let filled_bytes0' = iarray_as_seq filled0 in
	 lemma_disjoint_sibling_suffix_prefix file pos;
         assert (filled_bytes0 == filled_bytes0');
         let filled = prefix file (pos + k) in
         recall_all_init_i_j sub_file 0 k;
         recall_contains filled;
         extend_initialization file pos k h1;
         witness_all_init filled;
         let filled_bytes1 = iarray_as_seq filled in
	 let received_frag = read_subseq_i_j sub_file 0 k in
	 let h2 = ST.get () in
	 assert (h2 == h1);
         assert (log c h0 == log c h1);
         assert (sent_file_pred filled_bytes0 c from (ctr c h0) h0);
         assert (filled_bytes0 == flatten (Seq.slice (log c h0) from (ctr c h0)));
         append_filled file pos k h1; //(filled_bytes1 == append filled_bytes0 received_frag);
         assert (Seq.index (log c h0) (ctr c h0) == received_frag);
         lemma_flatten_snoc (Seq.slice (log c h0) from (ctr c h0)) received_frag;
         assert (filled_bytes1 == flatten (Seq.slice (log c h0) from (ctr c h1)));
         assert (sent_file_pred filled_bytes1 c from (ctr c h1) h1);
         if k < fragment_size 
         || pos + k = n
         then Some (pos + k)
         else if pos + k + fragment_size <= n
         then receive_aux file c h_init from (pos + k)
         else None

val receive_file (#n:nat{fragment_size <= n})
            (file:array byte n)
            (c:connection{receiver c /\ Set.disjoint (connection_footprint c) (array_footprint file)})
    : ST (option nat)
    (requires (fun h -> True))
    (ensures (fun h0 ropt h1 -> 
                modifies_r c file h0 h1 /\
                (match ropt with 
                 | None -> True 
                 | Some r ->
                   r <= n /\
                   all_init_i_j (prefix file r) 0 r /\
                   received (prefix file r) c h1)))
let receive_file #n file c = 
  let h_init = ST.get () in
  recall_contains file;
  recall_connection c;
  let R _ es ctr_ref = c in
  let from = !ctr_ref in 
  gst_recall (counter_pred from es);
  assert (from <= Seq.length (log c h_init));
  let file_in = prefix file 0 in
  let file_bytes0 = iarray_as_seq file_in in
  flatten_empty();
  assert (Seq.equal (flatten (Seq.slice (log c h_init) from from)) file_bytes0);
  match receive_aux #n file c h_init from 0 with
  | None -> None
  | Some r -> 
    let file_bytes1 = iarray_as_seq (prefix file r) in
    let h1 = ST.get() in
    gst_witness (sent_file_pred file_bytes1 c from (ctr c h1));
    assert (sent_file file_bytes1 c);
    Some r
