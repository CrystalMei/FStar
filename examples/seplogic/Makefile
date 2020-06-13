FSTAR_HOME=../..
include ../Makefile.include

OTHERFLAGS+=--include ../tactics

all: SepLogic.Heap.uver Shallow.uver SL.Heap.uver SL.Effect.uver	\
	SL.Shallow.uver Examples.uver \
	SL.ExamplesAuto.custom

#SL.Examples.uver disable for now
SL.ExamplesAuto.custom: OTHERFLAGS+=--cache_off

#Excludes extracted interfaces for these examples
%.custom: %.fst
	$(FSTAR) --use_extracted_interfaces true $^

%.fst-in:
	@echo $(OTHERFLAGS)

all-time: mkdir SepLogic.Heap.uver-time Shallow.uver-time SL.Heap.uver-time SL.Effect.uver-time	\
	SL.Shallow.uver-time Examples.uver-time \
	SL.ExamplesAuto.custom-time

%.custom-time: %.fst
	@d=$$(date +%s) \
	; $(FSTAR) --use_extracted_interfaces true --query_stats $^ > Logs/$^.trace \
	&& echo "$^,	$$(($$(date +%s)-d))"