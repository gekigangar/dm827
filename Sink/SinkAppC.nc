#include "SerialMsg.h"
#define AM_BLINKTORADIO 6

configuration SinkAppC {}
implementation {
    components CollectAndSendC as App, LedsC, MainC;
    components new TimerMilliC();

    components SerialActiveMessageC as AMSerial;

    components ActiveMessageC;
    components new AMReceiverC(AM_BLINKTORADIO);
    components CC2420ActiveMessageC;


    App.Boot -> MainC.Boot;
    App.Leds -> LedsC;
    App.MilliTimer -> TimerMilliC;

    App.Packet -> AMSerial;
    App.SendControl -> AMSerial;
    App.AMSend -> AMSerial.AMSend[AM_SERIAL_MSG];

    App.ReceiveControl -> ActiveMessageC;
    App.Receive -> AMReceiverC;
    App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;
}


