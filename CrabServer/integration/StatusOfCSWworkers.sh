#!/bin/sh
for i in 0 1 2 3 4; do grep -h ":FW worker_$i" $PRODAGENT_WORKDIR/CrabServerWorker/ComponentLo* | sort -n | tail -1; done
