#! /bin/sh

ETCD_KEY=${1:-$ETCD_KEY}
TARGET=${2:-`etcdctl --no-sync get $ETCD_KEY`}
PROTOCOL=${PROTOCOL:-TCP}

if [ $? -ne 0 ]
then
    echo ${TARGET}
    exit 1
fi

if [ -z "${TARGET}" ]
then
    echo "Proxy target not found. Waiting for change."
    SOCAT_PID=""
else
    echo "Proxy to ${TARGET} (at ${ETCD_KEY}), protocol ${PROTOCOL}"
    echo socat ${PROTOCOL}-LISTEN:1000,fork ${PROTOCOL}:${TARGET} &
    socat ${PROTOCOL}-LISTEN:1000,fork ${PROTOCOL}:${TARGET} &
    SOCAT_PID=$!
    echo "PID: ${SOCAT_PID}"
fi

TARGET=`etcdctl --no-sync watch ${ETCD_KEY}`

if [ -n "${SOCAT_PID}" ]
then
    echo "kill ${SOCAT_PID}"
    kill ${SOCAT_PID}
fi

if [ $? -ne 0 ]
then
    echo ${TARGET}
    exit 1
fi

if (echo ${TARGET} | grep PrevNode.Value)
then
    TARGET=""
fi

$0 ${ETCD_KEY} ${TARGET}

