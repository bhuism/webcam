#!/bin/bash

if [ $(id -u) != "0" ]; then
  echo "You must be root to do this." 1>&2
  exit 100
fi
if [ ${HOSTTYPE} != "arm" ] && [ ${HOSTTYPE} != "aarch64" ] ; then
  echo No arm architecture 1>&2
  exit 101
fi

raspi-config nonint do_camera 0
raspi-config nonint do_memory_split 128

systemctl disable hciuart.service
systemctl disable bluealsa.service
systemctl disable bluetooth.service

if [ ! -c /dev/video0 ]; then
  echo "No camera device /dev/video0" 1>&2
  exit 102
fi

CURL=(-s -H "Cache-Control: no-cache")

echo stopping watchdog
systemctl stop watchdog

echo stopping stream_camera
systemctl stop stream_camera

echo updating apt

apt update -y
apt full-upgrade -y

echo add user pi

useradd -m pi
for i in video dialout cdrom audio plugdev games users render netdev spi i2c gpio ; do
usermod -a -G $i pi
done

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

apt install -y ffmpeg watchdog nginx unattended-upgrades ntp joe libcamera-apps

echo installing watchdog.conf

curl "${CURL[@]}" https://raw.githubusercontent.com/bhuism/webcam/master/watchdog.conf -o /etc/watchdog.conf

echo installing htmls

HTMLDIR=/var/www/html

curl "${CURL[@]}" https://raw.githubusercontent.com/bhuism/webcam/master/index.html -o ${HTMLDIR}/index.html \
  https://raw.githubusercontent.com/bhuism/webcam/master/style.css -o ${HTMLDIR}/style.css

ln -sf /dev/shm/streaming /var/www/html/

echo enable watchdog
systemctl enable watchdog

shutdown -r +1
