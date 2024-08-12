#! /bin/bash

# Video streaming script by QWeb Ltd, using ffmpeg and a USB camera on a Raspberry Pi 4 B

# Just populate the STREAM_URL and STREAM_KEY variables with your Youtube stream credentials and run this script with a & suffix to make it a background process:

# wget https://raw.githubusercontent.com/qwebltd/Useful-scripts/main/Bash%20scripts%20for%20Linux/ffmpeg-to-youtube-feed-for-raspberry-pi.sh youtube-feed.sh
# chmod +x ./youtube-feed.sh
# nano ./youtube-feed.sh
#   (edit credentials)
# ./youtube-feed.sh &

# 5v 3a power in required, else fps suffers because USBs become under-supplied. Most phone chargers are only 1.8a - 2a
# USB 2 ports seem to work more reliably than USB 3 for some reason
# h264_v4l2m2m codec uses the Pi's hardware encoder, which only supports up to 1080p. Bitrate, maxrate, and bufsize are tuned for 1080p at 30fps
# h264_v4l2m2m codec can also hardware encode, but doesn't work with mjpeg and yuyv422 gives a lower input fps
# Audio is set up for silence. Youtube claims to require AAC but the aac encoder slows the fps and the pcm stream from lavfi seems to work anyway

AUDIO_IN="-f lavfi -i anullsrc=channel_layout=mono:sample_rate=44100"
VIDEO_IN="-f v4l2 -framerate 30 -video_size 1920x1080 -input_format mjpeg -thread_queue_size 16 -i /dev/video0"

AUDIO_OUT="copy"
VIDEO_OUT="h264_v4l2m2m -b:v 4541k -maxrate 4541k -bufsize 9082k -g 15 -bf 2 -pix_fmt yuv420p"

# Replace with your own Youtube live stream credentials
STREAM_URL="rtmp://a.rtmp.youtube.com/live2"
STREAM_KEY="xxxx-xxxx-xxxx-xxxx-xxxx"

VERBOSITY=""

# Comment this line if debugging. Otherwise ffmpeg won't output anything unless an error occurs
VERBOSITY="${VERBOSITY} -hide_banner -loglevel error -y"

ffmpeg -nostdin $VERBOSITY -use_wallclock_as_timestamps 1 -re $AUDIO_IN $VIDEO_IN -codec:a $AUDIO_OUT -codec:v $VIDEO_OUT -f flv $STREAM_URL/$STREAM_KEY
