open Prims
let pruneNones:
  'a . 'a FStar_Pervasives_Native.option Prims.list -> 'a Prims.list =
  fun l  ->
    FStar_List.fold_right
      (fun x  ->
         fun ll  ->
           match x with
           | FStar_Pervasives_Native.Some xs -> xs :: ll
           | FStar_Pervasives_Native.None  -> ll) l []
let mk_range_mle: FStar_Extraction_ML_Syntax.mlexpr =
  FStar_All.pipe_left
    (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top)
    (FStar_Extraction_ML_Syntax.MLE_Name (["Prims"], "mk_range"))
let mlconst_of_const':
  FStar_Const.sconst -> FStar_Extraction_ML_Syntax.mlconstant =
  fun sctt  ->
    match sctt with
    | FStar_Const.Const_effect  -> failwith "Unsupported constant"
    | FStar_Const.Const_range uu____39 -> FStar_Extraction_ML_Syntax.MLC_Unit
    | FStar_Const.Const_unit  -> FStar_Extraction_ML_Syntax.MLC_Unit
    | FStar_Const.Const_char c -> FStar_Extraction_ML_Syntax.MLC_Char c
    | FStar_Const.Const_int (s,i) ->
        FStar_Extraction_ML_Syntax.MLC_Int (s, i)
    | FStar_Const.Const_bool b -> FStar_Extraction_ML_Syntax.MLC_Bool b
    | FStar_Const.Const_float d -> FStar_Extraction_ML_Syntax.MLC_Float d
    | FStar_Const.Const_bytearray (bytes,uu____64) ->
        FStar_Extraction_ML_Syntax.MLC_Bytes bytes
    | FStar_Const.Const_string (s,uu____70) ->
        FStar_Extraction_ML_Syntax.MLC_String s
    | FStar_Const.Const_range_of  ->
        failwith "Unhandled constant: range_of/set_range_of"
    | FStar_Const.Const_set_range_of  ->
        failwith "Unhandled constant: range_of/set_range_of"
    | FStar_Const.Const_reify  ->
        failwith "Unhandled constant: reify/reflect"
    | FStar_Const.Const_reflect uu____71 ->
        failwith "Unhandled constant: reify/reflect"
let mlconst_of_const:
  FStar_Range.range ->
    FStar_Const.sconst -> FStar_Extraction_ML_Syntax.mlconstant
  =
  fun p  ->
    fun c  ->
      try mlconst_of_const' c
      with
      | uu____84 ->
          let uu____85 =
            let uu____86 = FStar_Range.string_of_range p in
            let uu____87 = FStar_Syntax_Print.const_to_string c in
            FStar_Util.format2 "(%s) Failed to translate constant %s "
              uu____86 uu____87 in
          failwith uu____85
let mlexpr_of_range: FStar_Range.range -> FStar_Extraction_ML_Syntax.mlexpr'
  =
  fun r  ->
    let cint i =
      let uu____95 =
        let uu____96 =
          let uu____97 =
            let uu____108 = FStar_Util.string_of_int i in
            (uu____108, FStar_Pervasives_Native.None) in
          FStar_Extraction_ML_Syntax.MLC_Int uu____97 in
        FStar_All.pipe_right uu____96
          (fun _0_41  -> FStar_Extraction_ML_Syntax.MLE_Const _0_41) in
      FStar_All.pipe_right uu____95
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.ml_int_ty) in
    let cstr s =
      let uu____123 =
        FStar_All.pipe_right (FStar_Extraction_ML_Syntax.MLC_String s)
          (fun _0_42  -> FStar_Extraction_ML_Syntax.MLE_Const _0_42) in
      FStar_All.pipe_right uu____123
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.ml_string_ty) in
    let uu____124 =
      let uu____131 =
        let uu____134 =
          let uu____135 = FStar_Range.file_of_range r in
          FStar_All.pipe_right uu____135 cstr in
        let uu____136 =
          let uu____139 =
            let uu____140 =
              let uu____141 = FStar_Range.start_of_range r in
              FStar_All.pipe_right uu____141 FStar_Range.line_of_pos in
            FStar_All.pipe_right uu____140 cint in
          let uu____142 =
            let uu____145 =
              let uu____146 =
                let uu____147 = FStar_Range.start_of_range r in
                FStar_All.pipe_right uu____147 FStar_Range.col_of_pos in
              FStar_All.pipe_right uu____146 cint in
            let uu____148 =
              let uu____151 =
                let uu____152 =
                  let uu____153 = FStar_Range.end_of_range r in
                  FStar_All.pipe_right uu____153 FStar_Range.line_of_pos in
                FStar_All.pipe_right uu____152 cint in
              let uu____154 =
                let uu____157 =
                  let uu____158 =
                    let uu____159 = FStar_Range.end_of_range r in
                    FStar_All.pipe_right uu____159 FStar_Range.col_of_pos in
                  FStar_All.pipe_right uu____158 cint in
                [uu____157] in
              uu____151 :: uu____154 in
            uu____145 :: uu____148 in
          uu____139 :: uu____142 in
        uu____134 :: uu____136 in
      (mk_range_mle, uu____131) in
    FStar_Extraction_ML_Syntax.MLE_App uu____124
let mlexpr_of_const:
  FStar_Range.range ->
    FStar_Const.sconst -> FStar_Extraction_ML_Syntax.mlexpr'
  =
  fun p  ->
    fun c  ->
      match c with
      | FStar_Const.Const_range r -> mlexpr_of_range r
      | uu____169 ->
          let uu____170 = mlconst_of_const p c in
          FStar_Extraction_ML_Syntax.MLE_Const uu____170
let rec subst_aux:
  (FStar_Extraction_ML_Syntax.mlident,FStar_Extraction_ML_Syntax.mlty)
    FStar_Pervasives_Native.tuple2 Prims.list ->
    FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty
  =
  fun subst1  ->
    fun t  ->
      match t with
      | FStar_Extraction_ML_Syntax.MLTY_Var x ->
          let uu____190 =
            FStar_Util.find_opt
              (fun uu____204  ->
                 match uu____204 with | (y,uu____210) -> y = x) subst1 in
          (match uu____190 with
           | FStar_Pervasives_Native.Some ts ->
               FStar_Pervasives_Native.snd ts
           | FStar_Pervasives_Native.None  -> t)
      | FStar_Extraction_ML_Syntax.MLTY_Fun (t1,f,t2) ->
          let uu____227 =
            let uu____234 = subst_aux subst1 t1 in
            let uu____235 = subst_aux subst1 t2 in (uu____234, f, uu____235) in
          FStar_Extraction_ML_Syntax.MLTY_Fun uu____227
      | FStar_Extraction_ML_Syntax.MLTY_Named (args,path) ->
          let uu____242 =
            let uu____249 = FStar_List.map (subst_aux subst1) args in
            (uu____249, path) in
          FStar_Extraction_ML_Syntax.MLTY_Named uu____242
      | FStar_Extraction_ML_Syntax.MLTY_Tuple ts ->
          let uu____257 = FStar_List.map (subst_aux subst1) ts in
          FStar_Extraction_ML_Syntax.MLTY_Tuple uu____257
      | FStar_Extraction_ML_Syntax.MLTY_Top  ->
          FStar_Extraction_ML_Syntax.MLTY_Top
let try_subst:
  FStar_Extraction_ML_Syntax.mltyscheme ->
    FStar_Extraction_ML_Syntax.mlty Prims.list ->
      FStar_Extraction_ML_Syntax.mlty FStar_Pervasives_Native.option
  =
  fun uu____268  ->
    fun args  ->
      match uu____268 with
      | (formals,t) ->
          if (FStar_List.length formals) <> (FStar_List.length args)
          then FStar_Pervasives_Native.None
          else
            (let uu____279 =
               let uu____280 = FStar_List.zip formals args in
               subst_aux uu____280 t in
             FStar_Pervasives_Native.Some uu____279)
let subst:
  FStar_Extraction_ML_Syntax.mltyscheme ->
    FStar_Extraction_ML_Syntax.mlty Prims.list ->
      FStar_Extraction_ML_Syntax.mlty
  =
  fun ts  ->
    fun args  ->
      let uu____297 = try_subst ts args in
      match uu____297 with
      | FStar_Pervasives_Native.None  ->
          failwith
            "Substitution must be fully applied (see GitHub issue #490)"
      | FStar_Pervasives_Native.Some t -> t
let udelta_unfold:
  FStar_Extraction_ML_UEnv.env ->
    FStar_Extraction_ML_Syntax.mlty ->
      FStar_Extraction_ML_Syntax.mlty FStar_Pervasives_Native.option
  =
  fun g  ->
    fun uu___180_308  ->
      match uu___180_308 with
      | FStar_Extraction_ML_Syntax.MLTY_Named (args,n1) ->
          let uu____317 = FStar_Extraction_ML_UEnv.lookup_ty_const g n1 in
          (match uu____317 with
           | FStar_Pervasives_Native.Some ts ->
               let uu____323 = try_subst ts args in
               (match uu____323 with
                | FStar_Pervasives_Native.None  ->
                    let uu____328 =
                      let uu____329 =
                        FStar_Extraction_ML_Syntax.string_of_mlpath n1 in
                      let uu____330 =
                        FStar_Util.string_of_int (FStar_List.length args) in
                      let uu____331 =
                        FStar_Util.string_of_int
                          (FStar_List.length (FStar_Pervasives_Native.fst ts)) in
                      FStar_Util.format3
                        "Substitution must be fully applied; got an application of %s with %s args whereas %s were expected (see GitHub issue #490)"
                        uu____329 uu____330 uu____331 in
                    failwith uu____328
                | FStar_Pervasives_Native.Some r ->
                    FStar_Pervasives_Native.Some r)
           | uu____335 -> FStar_Pervasives_Native.None)
      | uu____338 -> FStar_Pervasives_Native.None
let eff_leq:
  FStar_Extraction_ML_Syntax.e_tag ->
    FStar_Extraction_ML_Syntax.e_tag -> Prims.bool
  =
  fun f  ->
    fun f'  ->
      match (f, f') with
      | (FStar_Extraction_ML_Syntax.E_PURE ,uu____345) -> true
      | (FStar_Extraction_ML_Syntax.E_GHOST
         ,FStar_Extraction_ML_Syntax.E_GHOST ) -> true
      | (FStar_Extraction_ML_Syntax.E_IMPURE
         ,FStar_Extraction_ML_Syntax.E_IMPURE ) -> true
      | uu____346 -> false
let eff_to_string: FStar_Extraction_ML_Syntax.e_tag -> Prims.string =
  fun uu___181_353  ->
    match uu___181_353 with
    | FStar_Extraction_ML_Syntax.E_PURE  -> "Pure"
    | FStar_Extraction_ML_Syntax.E_GHOST  -> "Ghost"
    | FStar_Extraction_ML_Syntax.E_IMPURE  -> "Impure"
let join:
  FStar_Range.range ->
    FStar_Extraction_ML_Syntax.e_tag ->
      FStar_Extraction_ML_Syntax.e_tag -> FStar_Extraction_ML_Syntax.e_tag
  =
  fun r  ->
    fun f  ->
      fun f'  ->
        match (f, f') with
        | (FStar_Extraction_ML_Syntax.E_IMPURE
           ,FStar_Extraction_ML_Syntax.E_PURE ) ->
            FStar_Extraction_ML_Syntax.E_IMPURE
        | (FStar_Extraction_ML_Syntax.E_PURE
           ,FStar_Extraction_ML_Syntax.E_IMPURE ) ->
            FStar_Extraction_ML_Syntax.E_IMPURE
        | (FStar_Extraction_ML_Syntax.E_IMPURE
           ,FStar_Extraction_ML_Syntax.E_IMPURE ) ->
            FStar_Extraction_ML_Syntax.E_IMPURE
        | (FStar_Extraction_ML_Syntax.E_GHOST
           ,FStar_Extraction_ML_Syntax.E_GHOST ) ->
            FStar_Extraction_ML_Syntax.E_GHOST
        | (FStar_Extraction_ML_Syntax.E_PURE
           ,FStar_Extraction_ML_Syntax.E_GHOST ) ->
            FStar_Extraction_ML_Syntax.E_GHOST
        | (FStar_Extraction_ML_Syntax.E_GHOST
           ,FStar_Extraction_ML_Syntax.E_PURE ) ->
            FStar_Extraction_ML_Syntax.E_GHOST
        | (FStar_Extraction_ML_Syntax.E_PURE
           ,FStar_Extraction_ML_Syntax.E_PURE ) ->
            FStar_Extraction_ML_Syntax.E_PURE
        | uu____363 ->
            let uu____368 =
              let uu____369 = FStar_Range.string_of_range r in
              FStar_Util.format3
                "Impossible (%s): Inconsistent effects %s and %s" uu____369
                (eff_to_string f) (eff_to_string f') in
            failwith uu____368
let join_l:
  FStar_Range.range ->
    FStar_Extraction_ML_Syntax.e_tag Prims.list ->
      FStar_Extraction_ML_Syntax.e_tag
  =
  fun r  ->
    fun fs  ->
      FStar_List.fold_left (join r) FStar_Extraction_ML_Syntax.E_PURE fs
let mk_ty_fun:
  'Auu____383 .
    Prims.unit ->
      ('Auu____383,FStar_Extraction_ML_Syntax.mlty)
        FStar_Pervasives_Native.tuple2 Prims.list ->
        FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty
  =
  fun uu____394  ->
    FStar_List.fold_right
      (fun uu____403  ->
         fun t  ->
           match uu____403 with
           | (uu____409,t0) ->
               FStar_Extraction_ML_Syntax.MLTY_Fun
                 (t0, FStar_Extraction_ML_Syntax.E_PURE, t))
type unfold_t =
  FStar_Extraction_ML_Syntax.mlty ->
    FStar_Extraction_ML_Syntax.mlty FStar_Pervasives_Native.option[@@deriving
                                                                    show]
let rec type_leq_c:
  unfold_t ->
    FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option ->
      FStar_Extraction_ML_Syntax.mlty ->
        FStar_Extraction_ML_Syntax.mlty ->
          (Prims.bool,FStar_Extraction_ML_Syntax.mlexpr
                        FStar_Pervasives_Native.option)
            FStar_Pervasives_Native.tuple2
  =
  fun unfold_ty  ->
    fun e  ->
      fun t  ->
        fun t'  ->
          match (t, t') with
          | (FStar_Extraction_ML_Syntax.MLTY_Var
             x,FStar_Extraction_ML_Syntax.MLTY_Var y) ->
              if x = y
              then (true, e)
              else (false, FStar_Pervasives_Native.None)
          | (FStar_Extraction_ML_Syntax.MLTY_Fun
             (t1,f,t2),FStar_Extraction_ML_Syntax.MLTY_Fun (t1',f',t2')) ->
              let mk_fun xs body =
                match xs with
                | [] -> body
                | uu____496 ->
                    let e1 =
                      match body.FStar_Extraction_ML_Syntax.expr with
                      | FStar_Extraction_ML_Syntax.MLE_Fun (ys,body1) ->
                          FStar_Extraction_ML_Syntax.MLE_Fun
                            ((FStar_List.append xs ys), body1)
                      | uu____528 ->
                          FStar_Extraction_ML_Syntax.MLE_Fun (xs, body) in
                    let uu____535 =
                      (mk_ty_fun ()) xs body.FStar_Extraction_ML_Syntax.mlty in
                    FStar_Extraction_ML_Syntax.with_ty uu____535 e1 in
              (match e with
               | FStar_Pervasives_Native.Some
                   {
                     FStar_Extraction_ML_Syntax.expr =
                       FStar_Extraction_ML_Syntax.MLE_Fun (x::xs,body);
                     FStar_Extraction_ML_Syntax.mlty = uu____545;
                     FStar_Extraction_ML_Syntax.loc = uu____546;_}
                   ->
                   let uu____567 =
                     (type_leq unfold_ty t1' t1) && (eff_leq f f') in
                   if uu____567
                   then
                     (if
                        (f = FStar_Extraction_ML_Syntax.E_PURE) &&
                          (f' = FStar_Extraction_ML_Syntax.E_GHOST)
                      then
                        let uu____583 = type_leq unfold_ty t2 t2' in
                        (if uu____583
                         then
                           let body1 =
                             let uu____594 =
                               type_leq unfold_ty t2
                                 FStar_Extraction_ML_Syntax.ml_unit_ty in
                             if uu____594
                             then FStar_Extraction_ML_Syntax.ml_unit
                             else
                               FStar_All.pipe_left
                                 (FStar_Extraction_ML_Syntax.with_ty t2')
                                 (FStar_Extraction_ML_Syntax.MLE_Coerce
                                    (FStar_Extraction_ML_Syntax.ml_unit,
                                      FStar_Extraction_ML_Syntax.ml_unit_ty,
                                      t2')) in
                           let uu____599 =
                             let uu____602 =
                               let uu____603 =
                                 let uu____606 =
                                   (mk_ty_fun ()) [x]
                                     body1.FStar_Extraction_ML_Syntax.mlty in
                                 FStar_Extraction_ML_Syntax.with_ty uu____606 in
                               FStar_All.pipe_left uu____603
                                 (FStar_Extraction_ML_Syntax.MLE_Fun
                                    ([x], body1)) in
                             FStar_Pervasives_Native.Some uu____602 in
                           (true, uu____599)
                         else (false, FStar_Pervasives_Native.None))
                      else
                        (let uu____635 =
                           let uu____642 =
                             let uu____645 = mk_fun xs body in
                             FStar_All.pipe_left
                               (fun _0_43  ->
                                  FStar_Pervasives_Native.Some _0_43)
                               uu____645 in
                           type_leq_c unfold_ty uu____642 t2 t2' in
                         match uu____635 with
                         | (ok,body1) ->
                             let res =
                               match body1 with
                               | FStar_Pervasives_Native.Some body2 ->
                                   let uu____669 = mk_fun [x] body2 in
                                   FStar_Pervasives_Native.Some uu____669
                               | uu____678 -> FStar_Pervasives_Native.None in
                             (ok, res)))
                   else (false, FStar_Pervasives_Native.None)
               | uu____686 ->
                   let uu____689 =
                     ((type_leq unfold_ty t1' t1) && (eff_leq f f')) &&
                       (type_leq unfold_ty t2 t2') in
                   if uu____689
                   then (true, e)
                   else (false, FStar_Pervasives_Native.None))
          | (FStar_Extraction_ML_Syntax.MLTY_Named
             (args,path),FStar_Extraction_ML_Syntax.MLTY_Named (args',path'))
              ->
              if path = path'
              then
                let uu____725 =
                  FStar_List.forall2 (type_leq unfold_ty) args args' in
                (if uu____725
                 then (true, e)
                 else (false, FStar_Pervasives_Native.None))
              else
                (let uu____741 = unfold_ty t in
                 match uu____741 with
                 | FStar_Pervasives_Native.Some t1 ->
                     type_leq_c unfold_ty e t1 t'
                 | FStar_Pervasives_Native.None  ->
                     let uu____755 = unfold_ty t' in
                     (match uu____755 with
                      | FStar_Pervasives_Native.None  ->
                          (false, FStar_Pervasives_Native.None)
                      | FStar_Pervasives_Native.Some t'1 ->
                          type_leq_c unfold_ty e t t'1))
          | (FStar_Extraction_ML_Syntax.MLTY_Tuple
             ts,FStar_Extraction_ML_Syntax.MLTY_Tuple ts') ->
              let uu____777 = FStar_List.forall2 (type_leq unfold_ty) ts ts' in
              if uu____777
              then (true, e)
              else (false, FStar_Pervasives_Native.None)
          | (FStar_Extraction_ML_Syntax.MLTY_Top
             ,FStar_Extraction_ML_Syntax.MLTY_Top ) -> (true, e)
          | (FStar_Extraction_ML_Syntax.MLTY_Named uu____794,uu____795) ->
              let uu____802 = unfold_ty t in
              (match uu____802 with
               | FStar_Pervasives_Native.Some t1 ->
                   type_leq_c unfold_ty e t1 t'
               | uu____816 -> (false, FStar_Pervasives_Native.None))
          | (uu____821,FStar_Extraction_ML_Syntax.MLTY_Named uu____822) ->
              let uu____829 = unfold_ty t' in
              (match uu____829 with
               | FStar_Pervasives_Native.Some t'1 ->
                   type_leq_c unfold_ty e t t'1
               | uu____843 -> (false, FStar_Pervasives_Native.None))
          | uu____848 -> (false, FStar_Pervasives_Native.None)
and type_leq:
  unfold_t ->
    FStar_Extraction_ML_Syntax.mlty ->
      FStar_Extraction_ML_Syntax.mlty -> Prims.bool
  =
  fun g  ->
    fun t1  ->
      fun t2  ->
        let uu____859 = type_leq_c g FStar_Pervasives_Native.None t1 t2 in
        FStar_All.pipe_right uu____859 FStar_Pervasives_Native.fst
let is_type_abstraction:
  'Auu____881 'Auu____882 'Auu____883 .
    (('Auu____883,'Auu____882) FStar_Util.either,'Auu____881)
      FStar_Pervasives_Native.tuple2 Prims.list -> Prims.bool
  =
  fun uu___182_897  ->
    match uu___182_897 with
    | (FStar_Util.Inl uu____908,uu____909)::uu____910 -> true
    | uu____933 -> false
let is_xtuple:
  (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2 ->
    Prims.int FStar_Pervasives_Native.option
  =
  fun uu____954  ->
    match uu____954 with
    | (ns,n1) ->
        let uu____969 =
          let uu____970 = FStar_Util.concat_l "." (FStar_List.append ns [n1]) in
          FStar_Parser_Const.is_tuple_datacon_string uu____970 in
        if uu____969
        then
          let uu____973 =
            let uu____974 = FStar_Util.char_at n1 (Prims.parse_int "7") in
            FStar_Util.int_of_char uu____974 in
          FStar_Pervasives_Native.Some uu____973
        else FStar_Pervasives_Native.None
let resugar_exp:
  FStar_Extraction_ML_Syntax.mlexpr -> FStar_Extraction_ML_Syntax.mlexpr =
  fun e  ->
    match e.FStar_Extraction_ML_Syntax.expr with
    | FStar_Extraction_ML_Syntax.MLE_CTor (mlp,args) ->
        let uu____985 = is_xtuple mlp in
        (match uu____985 with
         | FStar_Pervasives_Native.Some n1 ->
             FStar_All.pipe_left
               (FStar_Extraction_ML_Syntax.with_ty
                  e.FStar_Extraction_ML_Syntax.mlty)
               (FStar_Extraction_ML_Syntax.MLE_Tuple args)
         | uu____989 -> e)
    | uu____992 -> e
let record_field_path:
  FStar_Ident.lident Prims.list -> Prims.string Prims.list =
  fun uu___183_999  ->
    match uu___183_999 with
    | f::uu____1005 ->
        let uu____1008 = FStar_Util.prefix f.FStar_Ident.ns in
        (match uu____1008 with
         | (ns,uu____1018) ->
             FStar_All.pipe_right ns
               (FStar_List.map (fun id1  -> id1.FStar_Ident.idText)))
    | uu____1029 -> failwith "impos"
let record_fields:
  'Auu____1037 .
    FStar_Ident.lident Prims.list ->
      'Auu____1037 Prims.list ->
        (Prims.string,'Auu____1037) FStar_Pervasives_Native.tuple2 Prims.list
  =
  fun fs  ->
    fun vs  ->
      FStar_List.map2
        (fun f  -> fun e  -> (((f.FStar_Ident.ident).FStar_Ident.idText), e))
        fs vs
let is_xtuple_ty:
  (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2 ->
    Prims.int FStar_Pervasives_Native.option
  =
  fun uu____1078  ->
    match uu____1078 with
    | (ns,n1) ->
        let uu____1093 =
          let uu____1094 =
            FStar_Util.concat_l "." (FStar_List.append ns [n1]) in
          FStar_Parser_Const.is_tuple_constructor_string uu____1094 in
        if uu____1093
        then
          let uu____1097 =
            let uu____1098 = FStar_Util.char_at n1 (Prims.parse_int "5") in
            FStar_Util.int_of_char uu____1098 in
          FStar_Pervasives_Native.Some uu____1097
        else FStar_Pervasives_Native.None
let resugar_mlty:
  FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty =
  fun t  ->
    match t with
    | FStar_Extraction_ML_Syntax.MLTY_Named (args,mlp) ->
        let uu____1109 = is_xtuple_ty mlp in
        (match uu____1109 with
         | FStar_Pervasives_Native.Some n1 ->
             FStar_Extraction_ML_Syntax.MLTY_Tuple args
         | uu____1113 -> t)
    | uu____1116 -> t
let flatten_ns: Prims.string Prims.list -> Prims.string =
  fun ns  ->
    let uu____1124 = FStar_Options.codegen_fsharp () in
    if uu____1124
    then FStar_String.concat "." ns
    else FStar_String.concat "_" ns
let flatten_mlpath:
  (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2 ->
    Prims.string
  =
  fun uu____1134  ->
    match uu____1134 with
    | (ns,n1) ->
        let uu____1147 = FStar_Options.codegen_fsharp () in
        if uu____1147
        then FStar_String.concat "." (FStar_List.append ns [n1])
        else FStar_String.concat "_" (FStar_List.append ns [n1])
let mlpath_of_lid:
  FStar_Ident.lident ->
    (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun l  ->
    let uu____1158 =
      FStar_All.pipe_right l.FStar_Ident.ns
        (FStar_List.map (fun i  -> i.FStar_Ident.idText)) in
    (uu____1158, ((l.FStar_Ident.ident).FStar_Ident.idText))
let rec erasableType:
  unfold_t -> FStar_Extraction_ML_Syntax.mlty -> Prims.bool =
  fun unfold_ty  ->
    fun t  ->
      let uu____1178 = FStar_Extraction_ML_UEnv.erasableTypeNoDelta t in
      if uu____1178
      then true
      else
        (let uu____1180 = unfold_ty t in
         match uu____1180 with
         | FStar_Pervasives_Native.Some t1 -> erasableType unfold_ty t1
         | FStar_Pervasives_Native.None  -> false)
let rec eraseTypeDeep:
  unfold_t ->
    FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty
  =
  fun unfold_ty  ->
    fun t  ->
      match t with
      | FStar_Extraction_ML_Syntax.MLTY_Fun (tyd,etag,tycd) ->
          if etag = FStar_Extraction_ML_Syntax.E_PURE
          then
            let uu____1200 =
              let uu____1207 = eraseTypeDeep unfold_ty tyd in
              let uu____1211 = eraseTypeDeep unfold_ty tycd in
              (uu____1207, etag, uu____1211) in
            FStar_Extraction_ML_Syntax.MLTY_Fun uu____1200
          else t
      | FStar_Extraction_ML_Syntax.MLTY_Named (lty,mlp) ->
          let uu____1222 = erasableType unfold_ty t in
          if uu____1222
          then FStar_Extraction_ML_UEnv.erasedContent
          else
            (let uu____1227 =
               let uu____1234 = FStar_List.map (eraseTypeDeep unfold_ty) lty in
               (uu____1234, mlp) in
             FStar_Extraction_ML_Syntax.MLTY_Named uu____1227)
      | FStar_Extraction_ML_Syntax.MLTY_Tuple lty ->
          let uu____1245 = FStar_List.map (eraseTypeDeep unfold_ty) lty in
          FStar_Extraction_ML_Syntax.MLTY_Tuple uu____1245
      | uu____1251 -> t
let prims_op_equality: FStar_Extraction_ML_Syntax.mlexpr =
  FStar_All.pipe_left
    (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top)
    (FStar_Extraction_ML_Syntax.MLE_Name (["Prims"], "op_Equality"))
let prims_op_amp_amp: FStar_Extraction_ML_Syntax.mlexpr =
  let uu____1254 =
    let uu____1257 =
      (mk_ty_fun ())
        [("x", FStar_Extraction_ML_Syntax.ml_bool_ty);
        ("y", FStar_Extraction_ML_Syntax.ml_bool_ty)]
        FStar_Extraction_ML_Syntax.ml_bool_ty in
    FStar_Extraction_ML_Syntax.with_ty uu____1257 in
  FStar_All.pipe_left uu____1254
    (FStar_Extraction_ML_Syntax.MLE_Name (["Prims"], "op_AmpAmp"))
let conjoin:
  FStar_Extraction_ML_Syntax.mlexpr ->
    FStar_Extraction_ML_Syntax.mlexpr -> FStar_Extraction_ML_Syntax.mlexpr
  =
  fun e1  ->
    fun e2  ->
      FStar_All.pipe_left
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.ml_bool_ty)
        (FStar_Extraction_ML_Syntax.MLE_App (prims_op_amp_amp, [e1; e2]))
let conjoin_opt:
  FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option ->
    FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option ->
      FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option
  =
  fun e1  ->
    fun e2  ->
      match (e1, e2) with
      | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.None ) ->
          FStar_Pervasives_Native.None
      | (FStar_Pervasives_Native.Some x,FStar_Pervasives_Native.None ) ->
          FStar_Pervasives_Native.Some x
      | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.Some x) ->
          FStar_Pervasives_Native.Some x
      | (FStar_Pervasives_Native.Some x,FStar_Pervasives_Native.Some y) ->
          let uu____1322 = conjoin x y in
          FStar_Pervasives_Native.Some uu____1322
let mlloc_of_range:
  FStar_Range.range ->
    (Prims.int,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun r  ->
    let pos = FStar_Range.start_of_range r in
    let line = FStar_Range.line_of_pos pos in
    let uu____1332 = FStar_Range.file_of_range r in (line, uu____1332)
let rec doms_and_cod:
  FStar_Extraction_ML_Syntax.mlty ->
    (FStar_Extraction_ML_Syntax.mlty Prims.list,FStar_Extraction_ML_Syntax.mlty)
      FStar_Pervasives_Native.tuple2
  =
  fun t  ->
    match t with
    | FStar_Extraction_ML_Syntax.MLTY_Fun (a,uu____1349,b) ->
        let uu____1351 = doms_and_cod b in
        (match uu____1351 with | (ds,c) -> ((a :: ds), c))
    | uu____1372 -> ([], t)
let argTypes:
  FStar_Extraction_ML_Syntax.mlty ->
    FStar_Extraction_ML_Syntax.mlty Prims.list
  =
  fun t  ->
    let uu____1382 = doms_and_cod t in FStar_Pervasives_Native.fst uu____1382
let rec uncurry_mlty_fun:
  FStar_Extraction_ML_Syntax.mlty ->
    (FStar_Extraction_ML_Syntax.mlty Prims.list,FStar_Extraction_ML_Syntax.mlty)
      FStar_Pervasives_Native.tuple2
  =
  fun t  ->
    match t with
    | FStar_Extraction_ML_Syntax.MLTY_Fun (a,uu____1407,b) ->
        let uu____1409 = uncurry_mlty_fun b in
        (match uu____1409 with | (args,res) -> ((a :: args), res))
    | uu____1430 -> ([], t)
exception CallNotImplemented of Prims.string
let uu___is_CallNotImplemented: Prims.exn -> Prims.bool =
  fun projectee  ->
    match projectee with
    | CallNotImplemented uu____1439 -> true
    | uu____1440 -> false
let __proj__CallNotImplemented__item__uu___: Prims.exn -> Prims.string =
  fun projectee  ->
    match projectee with | CallNotImplemented uu____1447 -> uu____1447
let not_implemented_warning:
  FStar_Range.range -> Prims.string -> Prims.string -> Prims.unit =
  fun r  ->
    fun t  ->
      fun msg  ->
        let uu____1457 =
          let uu____1462 =
            FStar_Util.format2
              ". Tactic %s will not run natively because %s.\n" t msg in
          (FStar_Errors.CallNotImplemented, uu____1462) in
        FStar_Errors.maybe_fatal_error r uu____1457
type emb_decl =
  | Embed
  | Unembed[@@deriving show]
let uu___is_Embed: emb_decl -> Prims.bool =
  fun projectee  ->
    match projectee with | Embed  -> true | uu____1466 -> false
let uu___is_Unembed: emb_decl -> Prims.bool =
  fun projectee  ->
    match projectee with | Unembed  -> true | uu____1470 -> false
let lid_to_name: FStar_Ident.lident -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun l  ->
    let uu____1474 = FStar_Extraction_ML_Syntax.mlpath_of_lident l in
    FStar_Extraction_ML_Syntax.MLE_Name uu____1474
let lid_to_top_name: FStar_Ident.lident -> FStar_Extraction_ML_Syntax.mlexpr
  =
  fun l  ->
    let uu____1478 =
      let uu____1479 = FStar_Extraction_ML_Syntax.mlpath_of_lident l in
      FStar_Extraction_ML_Syntax.MLE_Name uu____1479 in
    FStar_All.pipe_left
      (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top)
      uu____1478
let str_to_name: Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  ->
    let uu____1483 = FStar_Ident.lid_of_str s in lid_to_name uu____1483
let str_to_top_name: Prims.string -> FStar_Extraction_ML_Syntax.mlexpr =
  fun s  ->
    let uu____1487 = FStar_Ident.lid_of_str s in lid_to_top_name uu____1487
let fstar_syn_syn_prefix: Prims.string -> FStar_Extraction_ML_Syntax.mlexpr'
  = fun s  -> str_to_name (Prims.strcat "FStar_Syntax_Syntax." s)
let fstar_tc_common_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_TypeChecker_Common." s)
let fstar_refl_basic_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_Reflection_Basic." s)
let fstar_refl_data_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_Reflection_Data." s)
let fstar_emb_basic_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_Syntax_Embeddings." s)
let mk_basic_embedding:
  emb_decl -> Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun m  ->
    fun s  ->
      match m with
      | Embed  -> fstar_emb_basic_prefix (Prims.strcat "embed_" s)
      | Unembed  -> fstar_emb_basic_prefix (Prims.strcat "unembed_" s)
let mk_embedding:
  emb_decl -> Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun m  ->
    fun s  ->
      match m with
      | Embed  -> fstar_refl_basic_prefix (Prims.strcat "embed_" s)
      | Unembed  -> fstar_refl_basic_prefix (Prims.strcat "unembed_" s)
let mk_tactic_unembedding:
  FStar_Extraction_ML_Syntax.mlexpr' Prims.list ->
    FStar_Extraction_ML_Syntax.mlexpr'
  =
  fun args  ->
    let tac_arg = "t" in
    let reify_tactic =
      let uu____1524 =
        let uu____1525 =
          let uu____1532 =
            str_to_top_name "FStar_Tactics_Interpreter.reify_tactic" in
          let uu____1533 =
            let uu____1536 = str_to_top_name tac_arg in [uu____1536] in
          (uu____1532, uu____1533) in
        FStar_Extraction_ML_Syntax.MLE_App uu____1525 in
      FStar_All.pipe_left
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.MLTY_Top) uu____1524 in
    let from_tac =
      let uu____1540 =
        let uu____1541 =
          FStar_Util.string_of_int
            ((FStar_List.length args) - (Prims.parse_int "1")) in
        Prims.strcat "FStar_Tactics_Builtins.from_tac_" uu____1541 in
      str_to_top_name uu____1540 in
    let unembed_tactic =
      let uu____1543 =
        let uu____1544 =
          FStar_Util.string_of_int
            ((FStar_List.length args) - (Prims.parse_int "1")) in
        Prims.strcat "FStar_Tactics_Interpreter.unembed_tactic_" uu____1544 in
      str_to_top_name uu____1543 in
    let app =
      match FStar_List.length args with
      | _0_44 when _0_44 = (Prims.parse_int "1") ->
          let uu____1546 =
            let uu____1553 =
              let uu____1556 =
                let uu____1557 =
                  let uu____1558 =
                    let uu____1565 =
                      let uu____1568 =
                        FStar_List.map
                          (FStar_Extraction_ML_Syntax.with_ty
                             FStar_Extraction_ML_Syntax.MLTY_Top) args in
                      FStar_List.append uu____1568 [reify_tactic] in
                    (unembed_tactic, uu____1565) in
                  FStar_Extraction_ML_Syntax.MLE_App uu____1558 in
                FStar_Extraction_ML_Syntax.with_ty
                  FStar_Extraction_ML_Syntax.MLTY_Top uu____1557 in
              [uu____1556] in
            (from_tac, uu____1553) in
          FStar_Extraction_ML_Syntax.MLE_App uu____1546
      | n1 ->
          let uu____1576 =
            let uu____1577 =
              let uu____1578 = FStar_Util.string_of_int n1 in
              FStar_Util.format1
                "Unembedding not defined for tactics of %s arguments\n"
                uu____1578 in
            CallNotImplemented uu____1577 in
          FStar_Exn.raise uu____1576 in
    FStar_Extraction_ML_Syntax.MLE_Fun
      ([(tac_arg, FStar_Extraction_ML_Syntax.MLTY_Top);
       ("()", FStar_Extraction_ML_Syntax.MLTY_Top)],
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.MLTY_Top app))
let rec mk_tac_param_type:
  FStar_Syntax_Syntax.term -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun t  ->
    let uu____1606 =
      let uu____1607 = FStar_Syntax_Subst.compress t in
      uu____1607.FStar_Syntax_Syntax.n in
    match uu____1606 with
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.int_lid ->
        fstar_syn_syn_prefix "t_int"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.bool_lid ->
        fstar_syn_syn_prefix "t_bool"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.unit_lid ->
        fstar_syn_syn_prefix "t_unit"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.string_lid ->
        fstar_syn_syn_prefix "t_string"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1615 = FStar_Reflection_Data.fstar_refl_types_lid "binder" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1615 ->
        fstar_refl_data_prefix "t_binder"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1617 = FStar_Reflection_Data.fstar_refl_types_lid "term" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1617 ->
        fstar_refl_data_prefix "t_term"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1619 = FStar_Reflection_Data.fstar_refl_types_lid "fv" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1619 ->
        fstar_refl_data_prefix "t_fv"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1621 = FStar_Reflection_Data.fstar_refl_syntax_lid "binder" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1621 ->
        fstar_refl_data_prefix "t_binders"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1623 =
          FStar_Reflection_Data.fstar_refl_syntax_lid "norm_step" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1623 ->
        fstar_refl_data_prefix "t_norm_step"
    | FStar_Syntax_Syntax.Tm_app (h,args) ->
        let uu____1646 =
          let uu____1647 = FStar_Syntax_Subst.compress h in
          uu____1647.FStar_Syntax_Syntax.n in
        (match uu____1646 with
         | FStar_Syntax_Syntax.Tm_uinst (h',uu____1651) ->
             let uu____1656 =
               let uu____1657 = FStar_Syntax_Subst.compress h' in
               uu____1657.FStar_Syntax_Syntax.n in
             (match uu____1656 with
              | FStar_Syntax_Syntax.Tm_fvar fv when
                  FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.list_lid
                  ->
                  let arg_term =
                    let uu____1664 = FStar_List.hd args in
                    FStar_Pervasives_Native.fst uu____1664 in
                  let uu____1679 =
                    let uu____1686 =
                      let uu____1687 = fstar_tc_common_prefix "t_list_of" in
                      FStar_Extraction_ML_Syntax.with_ty
                        FStar_Extraction_ML_Syntax.MLTY_Top uu____1687 in
                    let uu____1688 =
                      let uu____1691 =
                        let uu____1694 = mk_tac_param_type arg_term in
                        [uu____1694] in
                      FStar_List.map
                        (FStar_Extraction_ML_Syntax.with_ty
                           FStar_Extraction_ML_Syntax.MLTY_Top) uu____1691 in
                    (uu____1686, uu____1688) in
                  FStar_Extraction_ML_Syntax.MLE_App uu____1679
              | FStar_Syntax_Syntax.Tm_fvar fv when
                  FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.option_lid
                  ->
                  let arg_term =
                    let uu____1701 = FStar_List.hd args in
                    FStar_Pervasives_Native.fst uu____1701 in
                  let uu____1716 =
                    let uu____1723 =
                      let uu____1724 = fstar_tc_common_prefix "t_option_of" in
                      FStar_Extraction_ML_Syntax.with_ty
                        FStar_Extraction_ML_Syntax.MLTY_Top uu____1724 in
                    let uu____1725 =
                      let uu____1728 =
                        let uu____1731 = mk_tac_param_type arg_term in
                        [uu____1731] in
                      FStar_List.map
                        (FStar_Extraction_ML_Syntax.with_ty
                           FStar_Extraction_ML_Syntax.MLTY_Top) uu____1728 in
                    (uu____1723, uu____1725) in
                  FStar_Extraction_ML_Syntax.MLE_App uu____1716
              | uu____1734 ->
                  let uu____1735 =
                    let uu____1736 =
                      let uu____1737 =
                        let uu____1738 = FStar_Syntax_Subst.compress h' in
                        FStar_Syntax_Print.term_to_string uu____1738 in
                      Prims.strcat
                        "Type term not defined for higher-order type"
                        uu____1737 in
                    CallNotImplemented uu____1736 in
                  FStar_Exn.raise uu____1735)
         | uu____1739 -> FStar_Exn.raise (CallNotImplemented "Impossible\n"))
    | uu____1740 ->
        let uu____1741 =
          let uu____1742 =
            let uu____1743 =
              let uu____1744 = FStar_Syntax_Subst.compress t in
              FStar_Syntax_Print.term_to_string uu____1744 in
            Prims.strcat "Type term not defined for " uu____1743 in
          CallNotImplemented uu____1742 in
        FStar_Exn.raise uu____1741
let rec mk_tac_embedding_path:
  emb_decl -> FStar_Syntax_Syntax.term -> FStar_Extraction_ML_Syntax.mlexpr'
  =
  fun m  ->
    fun t  ->
      let uu____1751 =
        let uu____1752 = FStar_Syntax_Subst.compress t in
        uu____1752.FStar_Syntax_Syntax.n in
      match uu____1751 with
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.int_lid ->
          mk_basic_embedding m "int"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.bool_lid ->
          mk_basic_embedding m "bool"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.unit_lid ->
          mk_basic_embedding m "unit"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.string_lid ->
          mk_basic_embedding m "string"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1760 =
            FStar_Reflection_Data.fstar_refl_types_lid "binder" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1760 ->
          mk_embedding m "binder"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1762 = FStar_Reflection_Data.fstar_refl_types_lid "term" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1762 ->
          mk_embedding m "term"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1764 = FStar_Reflection_Data.fstar_refl_types_lid "fv" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1764 ->
          mk_embedding m "fvar"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1766 =
            FStar_Reflection_Data.fstar_refl_syntax_lid "binders" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1766 ->
          mk_embedding m "binders"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1768 =
            FStar_Reflection_Data.fstar_refl_syntax_lid "norm_step" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1768 ->
          mk_embedding m "norm_step"
      | FStar_Syntax_Syntax.Tm_app (h,args) ->
          let uu____1791 =
            let uu____1792 = FStar_Syntax_Subst.compress h in
            uu____1792.FStar_Syntax_Syntax.n in
          (match uu____1791 with
           | FStar_Syntax_Syntax.Tm_uinst (h',uu____1796) ->
               let uu____1801 =
                 let uu____1812 =
                   let uu____1813 = FStar_Syntax_Subst.compress h' in
                   uu____1813.FStar_Syntax_Syntax.n in
                 match uu____1812 with
                 | FStar_Syntax_Syntax.Tm_fvar fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.list_lid
                     ->
                     let arg_term =
                       let uu____1830 = FStar_List.hd args in
                       FStar_Pervasives_Native.fst uu____1830 in
                     let uu____1845 =
                       let uu____1848 = mk_tac_embedding_path m arg_term in
                       [uu____1848] in
                     let uu____1849 = mk_tac_param_type arg_term in
                     ("list", uu____1845, uu____1849, false)
                 | FStar_Syntax_Syntax.Tm_fvar fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.option_lid
                     ->
                     let arg_term =
                       let uu____1856 = FStar_List.hd args in
                       FStar_Pervasives_Native.fst uu____1856 in
                     let uu____1871 =
                       let uu____1874 = mk_tac_embedding_path m arg_term in
                       [uu____1874] in
                     let uu____1875 = mk_tac_param_type arg_term in
                     ("option", uu____1871, uu____1875, false)
                 | FStar_Syntax_Syntax.Tm_fvar fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.tactic_lid
                     ->
                     let arg_term =
                       let uu____1882 = FStar_List.hd args in
                       FStar_Pervasives_Native.fst uu____1882 in
                     let uu____1897 =
                       let uu____1900 = mk_tac_embedding_path m arg_term in
                       [uu____1900] in
                     let uu____1901 = mk_tac_param_type arg_term in
                     ("list", uu____1897, uu____1901, true)
                 | uu____1904 ->
                     let uu____1905 =
                       let uu____1906 =
                         let uu____1907 =
                           let uu____1908 = FStar_Syntax_Subst.compress h' in
                           FStar_Syntax_Print.term_to_string uu____1908 in
                         Prims.strcat
                           "Embedding not defined for higher-order type "
                           uu____1907 in
                       CallNotImplemented uu____1906 in
                     FStar_Exn.raise uu____1905 in
               (match uu____1801 with
                | (ht,hargs,type_arg,is_tactic) ->
                    let hargs1 =
                      match m with
                      | Embed  -> FStar_List.append hargs [type_arg]
                      | Unembed  -> hargs in
                    if is_tactic
                    then
                      (match m with
                       | Embed  ->
                           FStar_Exn.raise
                             (CallNotImplemented
                                "Embedding not defined for tactic type\n")
                       | Unembed  -> mk_tactic_unembedding hargs1)
                    else
                      (let uu____1933 =
                         let uu____1940 =
                           let uu____1941 = mk_basic_embedding m ht in
                           FStar_Extraction_ML_Syntax.with_ty
                             FStar_Extraction_ML_Syntax.MLTY_Top uu____1941 in
                         let uu____1942 =
                           FStar_List.map
                             (FStar_Extraction_ML_Syntax.with_ty
                                FStar_Extraction_ML_Syntax.MLTY_Top) hargs1 in
                         (uu____1940, uu____1942) in
                       FStar_Extraction_ML_Syntax.MLE_App uu____1933))
           | uu____1947 ->
               FStar_Exn.raise (CallNotImplemented "Impossible\n"))
      | uu____1948 ->
          let uu____1949 =
            let uu____1950 =
              let uu____1951 =
                let uu____1952 = FStar_Syntax_Subst.compress t in
                FStar_Syntax_Print.term_to_string uu____1952 in
              Prims.strcat "Embedding not defined for type " uu____1951 in
            CallNotImplemented uu____1950 in
          FStar_Exn.raise uu____1949
let mk_interpretation_fun:
  'Auu____1958 .
    FStar_Ident.lident ->
      FStar_Extraction_ML_Syntax.mlexpr' ->
        FStar_Syntax_Syntax.term ->
          (FStar_Syntax_Syntax.bv,'Auu____1958)
            FStar_Pervasives_Native.tuple2 Prims.list ->
            FStar_Extraction_ML_Syntax.mlexpr' FStar_Pervasives_Native.option
  =
  fun tac_lid  ->
    fun assm_lid  ->
      fun t  ->
        fun bs  ->
          try
            let arg_types =
              FStar_List.map
                (fun x  ->
                   (FStar_Pervasives_Native.fst x).FStar_Syntax_Syntax.sort)
                bs in
            let arity = FStar_List.length bs in
            let h =
              let uu____2026 =
                let uu____2027 = FStar_Util.string_of_int arity in
                Prims.strcat
                  "FStar_Tactics_Interpreter.mk_tactic_interpretation_"
                  uu____2027 in
              str_to_top_name uu____2026 in
            let tac_fun =
              let uu____2035 =
                let uu____2042 =
                  let uu____2043 =
                    let uu____2044 = FStar_Util.string_of_int arity in
                    Prims.strcat "FStar_Tactics_Native.from_tactic_"
                      uu____2044 in
                  str_to_top_name uu____2043 in
                let uu____2051 =
                  let uu____2054 = lid_to_top_name tac_lid in [uu____2054] in
                (uu____2042, uu____2051) in
              FStar_Extraction_ML_Syntax.MLE_App uu____2035 in
            let tac_lid_app =
              let uu____2058 =
                let uu____2065 = str_to_top_name "FStar_Ident.lid_of_str" in
                (uu____2065,
                  [FStar_Extraction_ML_Syntax.with_ty
                     FStar_Extraction_ML_Syntax.MLTY_Top assm_lid]) in
              FStar_Extraction_ML_Syntax.MLE_App uu____2058 in
            let psc = str_to_name "psc" in
            let args =
              let uu____2072 =
                let uu____2075 =
                  FStar_List.map (mk_tac_embedding_path Unembed) arg_types in
                let uu____2078 =
                  let uu____2081 = mk_tac_embedding_path Embed t in
                  let uu____2082 =
                    let uu____2085 = mk_tac_param_type t in
                    let uu____2086 =
                      let uu____2089 =
                        let uu____2092 =
                          let uu____2095 = str_to_name "args" in [uu____2095] in
                        psc :: uu____2092 in
                      tac_lid_app :: uu____2089 in
                    uu____2085 :: uu____2086 in
                  uu____2081 :: uu____2082 in
                FStar_List.append uu____2075 uu____2078 in
              FStar_List.append [tac_fun] uu____2072 in
            let app =
              let uu____2097 =
                let uu____2098 =
                  let uu____2105 =
                    FStar_List.map
                      (FStar_Extraction_ML_Syntax.with_ty
                         FStar_Extraction_ML_Syntax.MLTY_Top) args in
                  (h, uu____2105) in
                FStar_Extraction_ML_Syntax.MLE_App uu____2098 in
              FStar_All.pipe_left
                (FStar_Extraction_ML_Syntax.with_ty
                   FStar_Extraction_ML_Syntax.MLTY_Top) uu____2097 in
            FStar_Pervasives_Native.Some
              (FStar_Extraction_ML_Syntax.MLE_Fun
                 ([("psc", FStar_Extraction_ML_Syntax.MLTY_Top);
                  ("args", FStar_Extraction_ML_Syntax.MLTY_Top)], app))
          with
          | CallNotImplemented msg ->
              ((let uu____2136 = FStar_Ident.string_of_lid tac_lid in
                not_implemented_warning t.FStar_Syntax_Syntax.pos uu____2136
                  msg);
               FStar_Pervasives_Native.None)