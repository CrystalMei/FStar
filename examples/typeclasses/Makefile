FSTAR_HOME=../..
# KREMLIN_HOME?=$(FSTAR_HOME)/../Kremlin
EXCLUDED_FSTAR_FILES=
FSTAR_FILES = $(filter-out $(EXCLUDED_FSTAR_FILES), $(wildcard *.fst))

all: verify-all

$(CACHE_DIR):
	mkdir -p $@

include ../Makefile.common

verify-all: $(CACHE_DIR) $(addsuffix .checked, $(addprefix $(CACHE_DIR)/, $(FSTAR_FILES)))

native_bench1:
	$(FSTAR) Big.fst --timing

native_bench2:
	rm -f FStar_Tactics_Typeclasses.*
	$(FSTAR) $(FSTAR_HOME)/ulib/FStar.Tactics.Typeclasses.fst --extract FStar.Tactics.Typeclasses --codegen Plugin
	$(FSTAR) Big.fst --timing --load FStar.Tactics.Typeclasses

mkdir:
	@mkdir -p ./Logs
	@mkdir -p $(CACHE_DIR)
all-time: clean mkdir verify-all