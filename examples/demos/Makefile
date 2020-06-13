DIRS=low-star

all: $(addsuffix .all, $(DIRS))

%.all: %
	+$(MAKE) -C $^ all

all-time: $(addsuffix .all-time, $(DIRS))
%.all-time: %
	+$(MAKE) -C $^ all-time
