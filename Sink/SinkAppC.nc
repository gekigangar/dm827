#include "SerialMsg.h"
#define AM_BLINKTORADIO 6

configuration SinkAppC {}
implementation {
    components SinkC as App, LedsC, MainC;
    components new TimerMilliC();

    components SerialActiveMessageC as AMSerial;

    components ActiveMessageC;
//    components new AMSenderC(AM_BLINKTORADIO);
    components new AMReceiverC(AM_BLINKTORADIO);
    components CC2420ActiveMessageC;


    App.Boot -> MainC.Boot;
    App.Leds -> LedsC;
    App.MilliTimer -> TimerMilliC;

    App.SerialPacket -> AMSerial;
    App.SerialControl -> AMSerial;
    App.SerialReceive -> AMSerial.Receive[AM_SERIAL_MSG];
    App.SerialAMSend -> AMSerial.AMSend[AM_SERIAL_MSG];

    App.RadioControl -> ActiveMessageC;
    App.RadioReceive -> AMReceiverC;
    App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;
}


