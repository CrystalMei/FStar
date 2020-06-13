
OTHERFLAGS+=$(FLAGS) $(LIB) --include ../dm4free
FSTAR_HOME=../..
include ../Makefile.include

uall: all

.PHONY: benton2004

all:\
  benton2004\
  Bijection.uver\
  Equivalence.uver\
  IfcComposeReify.uver\
  IfcDeclassify.uver\
  IfcDelimitedRelease.uver\
  IfcDelimitedReleaseReify.uver\
  IfcExample.uver\
  IfcExampleReify0.uver\
  IfcExampleReify1.uver\
  IfcExampleReify2.uver\
  IfcExampleReify3.uver\
  IfcRecursiveReify.uver\
  IfcReificationRegressionTest.uver\
  IfcRules.uver\
  IfcRulesReify.uver\
  IfcTypechecker.uver\
  Loops.uver\
  Memo.uver\
  NetKat.uver\
  OneTimePad.uver\
  Point.uver\
  ProgramEquivalence.uver\
  ProgramOptimizations.uver\
  RandomTapes.uver\
  Recursive.uver\
  ReifyLong.uver\
  Rel.uver\
  StRel.uver\
  Swap.uver\
  UnionFind.Forest.uver\
  UnionFind.uver\
  UnionFind.Functions.uver\
  While.uver\
  WhileReify.uver \
  OTP.uver \
  ElGamal.uver
  # IfcRecursiveHeapReify.uver\ regressed; too slow (NS/07-10)

benton2004:\
  Benton2004.Aux.uver\
  Benton2004.uver\
  Benton2004.DDCC.uver\
  Benton2004.DDCC.Examples.uver\
  Benton2004.SmithVolpano.uver\
  Benton2004.RHL.uver\
  Benton2004.RHL.Examples.uver\
  Benton2004.RHL.Derived.uver\
  Benton2004.RHL.Examples2.uver\

%.fsti-in %.fst-in:
	@echo $(OTHERFLAGS)

pack:
	cd ../..; zip -r relational.zip examples/rel examples/dm4free

all-time: mkdir\
  benton2004-time\
  Bijection.uver-time\
  Equivalence.uver-time\
  IfcComposeReify.uver-time\
  IfcDeclassify.uver-time\
  IfcDelimitedRelease.uver-time\
  IfcDelimitedReleaseReify.uver-time\
  IfcExample.uver-time\
  IfcExampleReify0.uver-time\
  IfcExampleReify1.uver-time\
  IfcExampleReify2.uver-time\
  IfcExampleReify3.uver-time\
  IfcRecursiveReify.uver-time\
  IfcReificationRegressionTest.uver-time\
  IfcRules.uver-time\
  IfcRulesReify.uver-time\
  IfcTypechecker.uver-time\
  Loops.uver-time\
  Memo.uver-time\
  NetKat.uver-time\
  OneTimePad.uver-time\
  Point.uver-time\
  ProgramEquivalence.uver-time\
  ProgramOptimizations.uver-time\
  RandomTapes.uver-time\
  Recursive.uver-time\
  ReifyLong.uver-time\
  Rel.uver-time\
  StRel.uver-time\
  Swap.uver-time\
  UnionFind.Forest.uver-time\
  UnionFind.uver-time\
  UnionFind.Functions.uver-time\
  While.uver-time\
  WhileReify.uver-time \
  OTP.uver-time \
  ElGamal.uver-time

benton2004-time:\
  Benton2004.Aux.uver-time\
  Benton2004.uver-time\
  Benton2004.DDCC.uver-time\
  Benton2004.DDCC.Examples.uver-time\
  Benton2004.SmithVolpano.uver-time\
  Benton2004.RHL.uver-time\
  Benton2004.RHL.Examples.uver-time\
  Benton2004.RHL.Derived.uver-time\
  Benton2004.RHL.Examples2.uver-time\
