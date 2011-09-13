COMPONENT=SinkAppC
BUILD_EXTRA_DEPS += Sink.class
CLEAN_EXTRA = *.class SerialMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack

Sink.class: $(wildcard *.java) SerialMsg.java
	javac -target 1.4 -source 1.4 *.java

SerialMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=SerialMsg SerialMsg.h serial_msg -o $@


include $(MAKERULES)

