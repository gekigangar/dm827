#include "Timer.h"
#include "SerialMsg.h"
#include "RadioMsg.h"

module SinkC {
    uses {
        interface Leds;
        interface Boot;
        interface Timer<TMilli> as MilliTimer;

        interface SplitControl as SerialControl;
        interface Receive as SerialReceive;
        interface AMSend as SerialAMSend;
        interface Packet as SerialPacket;

        interface Receive as RadioReceive;
        interface SplitControl as RadioControl;
        interface CC2420Packet;
    }
}

implementation {
    struct seenMotes_t {
        int id;
        int msgNr;
        int8_t rssi;
    } seenMotes[2];

    message_t serialPacket;
    bool serialLocked = FALSE;

    uint16_t counter = 0;

    int8_t getRssi(message_t *msg){
        return (int8_t) call CC2420Packet.getRssi(msg);
    }

    event void Boot.booted() {
        call SerialControl.start();
        call RadioControl.start();
    }

    event void MilliTimer.fired() {
        counter++;
        if (serialLocked) {
            return;
        } else {
            serial_msg_t* rcm = (serial_msg_t*)call SerialPacket.getPayload(&serialPacket, sizeof(serial_msg_t));
            if (rcm == NULL) {return;}
            if (call SerialPacket.maxPayloadLength() < sizeof(serial_msg_t)) {
                return;
            }

            rcm->counter = counter;
            rcm->motes[0].id = seenMotes[0].id;
            rcm->motes[0].count = seenMotes[0].msgNr;
            rcm->motes[0].rssi = seenMotes[0].rssi;
            if (call SerialAMSend.send(AM_BROADCAST_ADDR, &serialPacket, sizeof(serial_msg_t)) == SUCCESS) {
                serialLocked = TRUE;
            }
        }
    }

    event message_t* SerialReceive.receive(message_t* bufPtr, 
            void* payload, uint8_t len) {
         return bufPtr;
    }

    event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {
        if (&serialPacket == bufPtr) {
            serialLocked = FALSE;
        }
    }

    event void SerialControl.startDone(error_t err) {
        if (err == SUCCESS) {
            call MilliTimer.startPeriodic(1000);
        }
    }
    event void SerialControl.stopDone(error_t err) {}

    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call RadioControl.start();
        }
    }
    event void RadioControl.stopDone(error_t err) {}

    event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
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
