
#ifndef SERIAL_MSG_H
#define SERIAL_MSG_H

typedef nx_struct serial_msg {
    nx_uint16_t counter;
    nx_struct motes{
        nx_uint16_t id;
        nx_uint16_t count;
        nx_int8_t rssi;
    } motes[2];
} serial_msg_t;

enum {
    AM_SERIAL_MSG = 0x89,
};

#endif
