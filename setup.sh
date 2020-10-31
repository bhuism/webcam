#!/bin/sh

if [ `id -u` != "0" ] ; then
   echo "You must be root to do this." 1>&2
   exit 100
fi

systemctl stop stream_camera &> /dev/null
systemctl stop watchdig &> /dev/null

#echo updating apt
#apt update

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

echo install ffmpeg watchdog nginx

apt install -y ffmpeg watchdog nginx

echo installing watchdog.conf

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/watchdog.conf -o /etc/watchdog.conf

systemctl restart watchdog

echo installing index.html

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/index.html -o /var/www/html/index.html

ln -sf /dev/shm/streaming /var/www/html/

echo starting stream_camera

systemctl start stream_camera
