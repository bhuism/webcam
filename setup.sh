#!/bin/sh

if [ `id -u` != "0" ] ; then
   echo "You must be root to do this." 1>&2
   exit 100
fi

#LOG_FILE=/tmp/$0.log

#rm -Rf ${LOG_FILE}
#touch LOGFILE;

#exec 1<&- 2<&- 1<>${LOG_FILE} 2>&1
#exec 1<>${LOG_FILE} 2>&1

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/stream_camera.service -o /etc/systemd/system/stream_camera.service

systemctl daemon-reload

systemctl enable systemd-time-wait-sync

systemctl status stream_camera
