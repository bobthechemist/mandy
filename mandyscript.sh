#!/bin/bash
# -- Script to handle Mandy service --

cd "${0%/*}"

start() {
  python mandyloop.py
}

stop() {
  pids=`ps ax | grep "python mandyloop.py" | awk '{print $1}'`
  if [ -z "$pids" ] ; then
    echo ""
  else
    for pid in $pids; do
      kill -9 $pid
    done
  fi
}
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    sleep 1
    start
    ;;
  *) exit 1
esac
