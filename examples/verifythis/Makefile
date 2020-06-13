FSTAR_HOME=../..
include ../Makefile.include

all: uall

uall:
	$(FSTAR) 2015/Problem01.fst

all-time: mkdir uall-time
uall-time:
	@d=$$(date +%s) \
	; $(FSTAR) --query_stats 2015/Problem01.fst > Logs/Problem01.fst.trace \
	&& echo "Problem01.fst,	$$(($$(date +%s)-d))"