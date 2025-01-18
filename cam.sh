#!/bin/sh

DIR=/dev/shm/streaming
RESOLUTION=hd720
FRAMERATE=10
GOP=$(($FRAMERATE * 2))

#INPUTFORMAT=h264
#INPUTFORMAT=yuv420p

#ENCODER=copy
ENCODER=h264_omx

BITRATE=2M

trap "rm -Rf $DIR" EXIT

rm -Rf $DIR
mkdir $DIR

#  -vf "settb=AVTB,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)' \
#		,drawtext=text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d\:3}:fontsize=20:fontcolor=wheat:x=(w-tw)/2:y=16'" \


# ffmpeg -r 25 -i /dev/video0  -vcodec copy -acodec aac -hls_time 5 -hls_list_size 5 -hls_flags delete_segments /tmp/temp/stream.m3u8

# ffmpeg -r 25 -f video4linux2 -input_format h264 -i /dev/video0 -video_size hd720 -vcodec copy -acodec aac -hls_list_size 5 -hls_flags delete_segments /dev/shm/streaming/master.m3u8


#nice -n -10 ffmpeg -nostdin -y -loglevel warning \
#  -f video4linux2 -framerate ${FRAMERATE} -video_size ${RESOLUTION} -i /dev/video0 \
#  -vf "settb=AVTB,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)' \
#	,drawtext=text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d\:3}:fontsize=20:fontcolor=wheat:x=(w-tw)/2:y=16'" \
#  -b:v ${BITRATE} -maxrate:v ${BITRATE} -bufsize ${BITRATE} -g ${GOP} -profile:v high -c:v ${ENCODER} \
#  -f hls \
#  -hls_flags delete_segments+temp_file+independent_segments \
#  -hls_list_size 3 \
#  -hls_segment_type fmp4 \
#  -hls_start_number_source datetime \
#  $DIR/master.m3u8


#libcamera-vid -t 0 --codec yuv420 --width 1920 --height 1080 -o - | \
# ffmpeg -f rawvideo -pix_fmt yuv420p -s:v 1920x1080 -i - -y -vcodec h264_omx \
#  -f hls \
#  -hls_flags delete_segments+temp_file+independent_segments \
#  -hls_list_size 3 \
#  -hls_segment_type fmp4 \
#  -hls_start_number_source datetime \
#  $DIR/master.m3u8




rpicam-vid -n --framerate $FRAMERATE -t 0 --codec h264 --width 1920 --height 1080 -o - | \
 ffmpeg -i - -framerate $FRAMERATE -probesize 100M -y -loglevel warning -vcodec copy \
  -f hls \
  -hls_flags delete_segments+temp_file+independent_segments \
  -hls_list_size 3 \
  -hls_segment_type fmp4 \
  -hls_start_number_source datetime \
  $DIR/master.m3u8
