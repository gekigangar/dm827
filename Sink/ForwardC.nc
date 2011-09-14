#include "Timer.h"
#include "AggregateMsg.h"
#include "BeaconMsg.h"

module ForwardC {
    uses {
        interface Boot;
        interface SplitControl as SendControl;
        interface SplitControl as ReceiveControl;

        interface AMSend;
        interface Packet;

        interface Receive;
    }
}

implementation {
    message_t packet;
    bool locked = FALSE;

    event void Boot.booted() {
        call SendControl.start();
        call ReceiveControl.start();
    }
    event void AMSend.sendDone(message_t* bufPtr, error_t error) {
        if (&packet == bufPtr) {
            locked = FALSE;
        }
    }

    event void SendControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call SendControl.start();
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
        if (len == sizeof(aggregate_msg_t)) {
            aggregate_msg_t* pkt = (aggregate_msg_t*)payload;
            if (locked) {
                return msg;
            } else {
                aggregate_msg_t* rcm = (aggregate_msg_t*)call Packet.getPayload(&packet, sizeof(aggregate_msg_t));
                if (rcm == NULL) {return msg;}
                if (call Packet.maxPayloadLength() < sizeof(aggregate_msg_t)) {
                    return msg;
                }
                memcpy(rcm,pkt,sizeof(aggregate_msg_t));

                if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(aggregate_msg_t)) == SUCCESS) {
                    locked = TRUE;
                }
            }


        }
        return msg;
    }
}
