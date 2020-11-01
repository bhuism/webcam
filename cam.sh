#!/bin/sh

DIR=/dev/shm/streaming
RESOLUTION=hd720
FRAMERATE=25
GOP=$(($FRAMERATE * 1))
FILENAME=stream-me-baby

#INPUTFORMAT=h264
INPUTFORMAT=yuyv422

#ENCODER=copy
ENCODER=h264_omx

trap "rm -Rf $DIR" EXIT

rm -Rf $DIR
mkdir $DIR

curl -s https://raw.githubusercontent.com/bhuism/webcam/master/html/dash.html -o ${DIR}/dash.html \
	https://raw.githubusercontent.com/bhuism/webcam/master/html/hls.html -o ${DIR}/hls.html \
	https://raw.githubusercontent.com/bhuism/webcam/master/html/index.html -o ${DIR}/index.html \
	https://raw.githubusercontent.com/bhuism/webcam/master/html/style.css -o ${DIR}/style.css

ffmpeg	-nostdin -hide_banner -loglevel warning \
	-f video4linux2 -input_format ${INPUTFORMAT} -video_size ${RESOLUTION} -framerate ${FRAMERATE} -i /dev/video0 \
	-vf "settb=AVTB \
		,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)' \
		,drawtext=text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d\:3}:fontsize=20:fontcolor=wheat:x=(w-tw)/2:y=16'" \
 	-b:v 4M  -maxrate:v 6M -bufsize 4M \
	-c:v ${ENCODER} \
	-f dash \
	-seg_duration 1 \
	-media_seg_name 'slice-'"${FILENAME}"'-$RepresentationID$-$Number%08d$.m4s' \
	-window_size 15 \
	-hls_playlist 1 \
	-use_template 1 -use_timeline 1 -index_correction 1 \
	-utc_timing_url /iso.html \
	$DIR/manifest.mpd
