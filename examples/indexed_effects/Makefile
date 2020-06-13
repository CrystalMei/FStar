FSTAR_HOME=../..
include ../Makefile.include

all: uall

uall: $(patsubst %.fst,%.uver,$(wildcard *.fst))

# Targets to get F* arguments in interactive mode
%.fst-in: 
	@echo --use_hints

all-time: mkdir uall-time
uall-time: $(patsubst %.fst,%.uver-time,$(wildcard *.fst))