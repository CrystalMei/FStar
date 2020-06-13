FSTAR_HOME=../..
include ../Makefile.include

all: uall
uall:	FStar.DM4F.MonadLaws.uver \
	Effects.Def.uver \
	FStar.DM4F.IntST.uver \
	FStar.DM4F.Exceptions.uver \
	FStar.DM4F.ExnSt.uver \
	FStar.DM4F.StExn.uver \
	FStar.DM4F.ST.uver \
	FStar.DM4F.Heap.uver \
	FStar.DM4F.Heap.ST.uver \
	FStar.DM4F.Heap.IntStoreFixed.uver \
	FStar.DM4F.StExnC.uver \
	FStar.DM4F.IFC.uver \
	FStar.DM4F.Continuations.uver \
	delimcc.uver \
	FStar.DM4F.IntStore.uver \
	FStar.DM4F.IntStoreFixedReader.uver \
	FStar.DM4F.IntStoreFixed.uver \
	FStar.DM4F.IntStoreExcFixed.uver \
	FStar.DM4F.Heap.Random.uver \
	FStar.DM4F.Random.uver \
	FStar.DM4F.Id.uver

old:
	+$(MAKE) -C old

%.uver-explicit: %.fst
	$(FSTAR) $^ --explicit_deps

include $(FSTAR_HOME)/ulib/ml/Makefile.include

all-time: mkdir uall-time
uall-time:	FStar.DM4F.MonadLaws.uver-time \
	Effects.Def.uver-time \
	FStar.DM4F.IntST.uver-time \
	FStar.DM4F.Exceptions.uver-time \
	FStar.DM4F.ExnSt.uver-time \
	FStar.DM4F.StExn.uver-time \
	FStar.DM4F.ST.uver-time \
	FStar.DM4F.Heap.uver-time \
	FStar.DM4F.Heap.ST.uver-time \
	FStar.DM4F.Heap.IntStoreFixed.uver-time \
	FStar.DM4F.StExnC.uver-time \
	FStar.DM4F.IFC.uver-time \
	FStar.DM4F.Continuations.uver-time \
	delimcc.uver-time \
	FStar.DM4F.IntStore.uver-time \
	FStar.DM4F.IntStoreFixedReader.uver-time \
	FStar.DM4F.IntStoreFixed.uver-time \
	FStar.DM4F.IntStoreExcFixed.uver-time \
	FStar.DM4F.Heap.Random.uver-time \
	FStar.DM4F.Random.uver-time \
	FStar.DM4F.Id.uver-time