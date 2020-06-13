FSTAR_HOME=../../..

all: verify-all

include .depend
include $(FSTAR_HOME)/examples/Makefile.include

verify-all: $(ALL_CHECKED_FILES)

.depend:
	$(FSTAR) --dep full $(wildcard *.fst *.fsti) > .depend

%.checked:
	@d=$$(date +%s) \
	; $(FSTAR) --cache_checked_modules $< --query_stats > Logs/$<.trace \
	&& echo "$<,	$$(($$(date +%s)-d))" \
	&& touch -c $@

clean:
	rm -f .depend *.checked

depend: .depend

all-time: clean mkdir verify-all