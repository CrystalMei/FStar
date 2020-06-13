FSTAR_HOME=../..
include ../Makefile.include

all: uall

%.uveri: %.fsti
	$(FSTAR) --use_extracted_interfaces true $^

uall: DoublyLinkedList.uver DoublyLinkedListIface.uver DoublyLinkedListIface.uveri Example.uver 

all-time: mkdir uall-time
%.uveri-time: %.fsti
	@d=$$(date +%s) \
	; $(FSTAR) --use_extracted_interfaces true --query_stats $^ > Logs/$^.trace \
	&& echo "$^,	$$(($$(date +%s)-d))"
uall-time: DoublyLinkedList.uver-time DoublyLinkedListIface.uver-time DoublyLinkedListIface.uveri-time Example.uver-time 