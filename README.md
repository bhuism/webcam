# RPi Webcam with hardware encoding

# Install

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/setup.sh | sudo bash

sudo /usr/bin/vcdbg set awb_mode 0
ffmpeg  -video_size 1280x720 -i /dev/video0 \
        -f alsa -channels 1 -sample_rate 44100 -i hw:1 \
        -vf "drawtext=text='%{localtime}': x=(w-tw)/2: y=lh: fontcolor=white: fontsize=24" \
        -af "volume=15.0" \
        -c:v h264_omx -b:v 2500k \
        -c:a libmp3lame -b:a 128k \
        -map 0:v -map 1:a -f flv "${URL}/${KEY}"
