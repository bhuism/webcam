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

echo installing cam.sh 

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/cam.sh -o /home/pi/cam.sh

chmod +x /home/pi/cam.sh

echo installing stream_camera.service

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/stream_camera.service -o /etc/systemd/system/stream_camera.service

echo reloading systemd

systemctl daemon-reload

echo enable time-wait-sync

systemctl enable systemd-time-wait-sync

echo enable stream_camera

systemctl enable stream_camera



