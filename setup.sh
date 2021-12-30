#!/bin/bash

if [ $(id -u) != "0" ]; then
  echo "You must be root to do this." 1>&2
  exit 100
fi

if [ ${HOSTTYPE} != "arm" ]; then
  echo No arm architecture 1>&2
  exit 101
fi

if [ ! -c /dev/video0 ]; then
  echo "No camera device /dev/video0" 1>&2
  exit 102
fi

CURL=(-s -H "Cache-Control: no-cache")

echo stopping watchdog

systemctl stop watchdog &>/dev/null

echo stopping stream_camera

systemctl stop stream_camera &>/dev/null

#echo updating apt
#apt update

echo installing cam.sh

curl "${CURL[@]}" https://raw.githubusercontent.com/bhuism/webcam/master/cam.sh -o /home/pi/cam.sh
chown pi:pi /home/pi/cam.sh

chmod +x /home/pi/cam.sh

echo installing stream_camera.service

curl "${CURL[@]}" https://raw.githubusercontent.com/bhuism/webcam/master/stream_camera.service -o /etc/systemd/system/stream_camera.service

echo reloading systemd

systemctl daemon-reload

echo enable time-wait-sync

systemctl enable systemd-time-wait-sync

echo enable stream_camera

systemctl enable stream_camera

echo install ffmpeg watchdog nginx

apt install -y ffmpeg watchdog nginx unattended-upgrades ntp

echo installing watchdog.conf

curl "${CURL[@]}" https://raw.githubusercontent.com/bhuism/webcam/master/watchdog.conf -o /etc/watchdog.conf

echo installing htmls

HTMLDIR=/var/www/html

curl "${CURL[@]}" https://raw.githubusercontent.com/bhuism/webcam/master/index.html -o ${HTMLDIR}/index.html \
  https://raw.githubusercontent.com/bhuism/webcam/master/style.css -o ${HTMLDIR}/style.css

ln -sf /dev/shm/streaming /var/www/html/

echo starting stream_camera

systemctl start stream_camera

echo restarting watchdog

systemctl restart watchdog
