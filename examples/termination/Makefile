ALLFILES=CPS.Simple CPS.Double CPS.DoubleLambdaLifting2 CPS.DoubleDefun CPS.Expr \
	 CPS.SimpleDefun CPS.SimpleLambdaLifting Eval.DB mcCarthy91 termination

FSTAR_HOME=../..
include ../Makefile.include

all: $(addsuffix .uver, $(ALLFILES))
all-time: mkdir $(addsuffix .uver-time, $(ALLFILES))