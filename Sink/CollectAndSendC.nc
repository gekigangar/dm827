#include "Timer.h"
#include "AggregateMsg.h"
#include "BeaconMsg.h"

module CollectAndSendC {
    uses {
        interface Leds;
        interface Boot;
        interface Timer<TMilli> as MilliTimer;

        interface SplitControl as SendControl;
        interface SplitControl as ReceiveControl;

        interface AMSend;
        interface Packet;

        interface Receive;
        interface CC2420Packet;
    }
}

implementation {
    struct seenMotes_t {
        int id;
        int msgNr;
        int8_t rssi;
    } seenMotes[2];

    message_t packet;
    bool locked = FALSE;

    uint16_t counter = 0;

    int8_t getRssi(message_t *msg){
        return (int8_t) call CC2420Packet.getRssi(msg);
    }

    event void Boot.booted() {
        call SendControl.start();
        call ReceiveControl.start();
    }

    event void MilliTimer.fired() {
        counter++;
        if (locked) {
            return;
        } else {
            aggregate_msg_t* rcm = (aggregate_msg_t*)call Packet.getPayload(&packet, sizeof(aggregate_msg_t));
            if (rcm == NULL) {return;}
            if (call Packet.maxPayloadLength() < sizeof(aggregate_msg_t)) {
                return;
            }

            rcm->counter = counter;
            rcm->motes[0].id = seenMotes[0].id;
            rcm->motes[0].count = seenMotes[0].msgNr;
            rcm->motes[0].rssi = seenMotes[0].rssi;
            if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(aggregate_msg_t)) == SUCCESS) {
                locked = TRUE;
            }
        }
    }

    event void AMSend.sendDone(message_t* bufPtr, error_t error) {
        if (&packet == bufPtr) {
            locked = FALSE;
        }
    }

    event void SendControl.startDone(error_t err) {
        if (err == SUCCESS) {
            call MilliTimer.startPeriodic(1000);
        }
    }
    event void SendControl.stopDone(error_t err) {}

    event void ReceiveControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call ReceiveControl.start();
        }
    }
    event void ReceiveControl.stopDone(error_t err) {}

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
        if (len == sizeof(RadioMsg)) {
            RadioMsg* pkt = (RadioMsg*)payload;
            seenMotes[0].id = pkt->nodeid;
            seenMotes[0].msgNr = pkt->counter;
            seenMotes[0].rssi = getRssi(msg);
            call Leds.set(pkt->counter);
        }
        return msg;
    }
}
