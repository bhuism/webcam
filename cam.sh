#!/bin/sh

DIR=/dev/shm/streaming
RESOLUTION=hd720
FRAMERATE=25
GOP=$(($FRAMERATE * 1))
FILENAME=stream-me-baby

INPUTFORMAT=h264
#INPUTFORMAT=yuyv422

ENCODER=copy
#ECODER=h264_omx

trap "rm -Rf $DIR" EXIT

rm -Rf $DIR
mkdir $DIR

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/html/dash.html -o ${DIR}/dash.html \
	https://raw.githubusercontent.com/bhuism/webcam/master/html/hls.html -o ${DIR}/hls.html \
	https://raw.githubusercontent.com/bhuism/webcam/master/html/index.html -o ${DIR}/index.html \
	https://raw.githubusercontent.com/bhuism/webcam/master/html/style.css -o ${DIR}/style.css

ffmpeg	-nostdin -loglevel warning \
	-f video4linux2 -input_format ${INPUTFORMAT} -video_size ${RESOLUTION} -framerate ${FRAMERATE} -i /dev/video0 \
 	-b:v 4M  -maxrate:v 6M -bufsize 4M \
	-c:v ${ENCODER} \
	-f dash \
	-seg_duration 2 \
	-media_seg_name 'slice-'"${FILENAME}"'-$RepresentationID$-$Number%08d$.m4s' \
	-window_size 10 \
	-hls_playlist 1 \
	$DIR/manifest.mpd
