COMPONENT=SinkAppC
BUILD_EXTRA_DEPS += Sink.class
CLEAN_EXTRA = *.class AggregateMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack

Sink.class: $(wildcard *.java) AggregateMsg.java
	javac -target 1.4 -source 1.4 *.java

AggregateMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=AggregateMsg AggregateMsg.h aggregate_msg -o $@


include $(MAKERULES)

