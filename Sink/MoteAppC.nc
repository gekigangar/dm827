#include "AggregateMsg.h"
#define AM_BLINKTORADIO 6
#define AM_AGGREGATE 9

configuration MoteAppC {}
implementation {
    components CollectAndSendC as App, LedsC, MainC;
    components new TimerMilliC();

//    components SerialActiveMessageC as AMSerial;
    components new AMSenderC(AM_AGGREGATE);
    components ActiveMessageC;

    components new AMReceiverC(AM_BLINKTORADIO) as BeaconReciver;
    components new AMReceiverC(AM_AGGREGATE) as AggregateReciver;
    components CC2420ActiveMessageC;

    //components ForwardC;


    App.Boot -> MainC.Boot;
    App.Leds -> LedsC;
    App.MilliTimer -> TimerMilliC;

    App.Packet -> AMSenderC;
    App.SendControl -> ActiveMessageC;
    App.AMSend -> AMSenderC;

    App.ReceiveControl -> ActiveMessageC;
    App.Receive -> BeaconReciver;
    App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;

}
