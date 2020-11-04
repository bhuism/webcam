#!/bin/sh

DIR=/dev/shm/streaming
RESOLUTION=hd720
FRAMERATE=15
GOP=$(($FRAMERATE * 2))
FILENAME=stream-me-baby

#INPUTFORMAT=h264
INPUTFORMAT=yuv420p

#ENCODER=copy
ENCODER=h264_omx

BITRATE=3M

trap "rm -Rf $DIR" EXIT

rm -Rf $DIR
mkdir $DIR

ffmpeg -nostdin -hide_banner -loglevel warning -y \
  -f video4linux2 -input_format ${INPUTFORMAT} -video_size ${RESOLUTION} -framerate ${FRAMERATE} -i /dev/video0 \
  -vf "settb=AVTB \
		,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)' \
		,drawtext=text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d\:3}:fontsize=20:fontcolor=wheat:x=(w-tw)/2:y=16'" \
  -b:v ${BITRATE} -maxrate:v ${BITRATE} -bufsize ${BITRATE} -g ${GOP} -profile:v high \
  -c:v ${ENCODER} \
  -f hls \
  -hls_flags delete_segments+temp_file \
  -hls_allow_cache 0 \
  -hls_segment_type fmp4 \
  -hls_start_number_source datetime \
  $DIR/master.m3u8
