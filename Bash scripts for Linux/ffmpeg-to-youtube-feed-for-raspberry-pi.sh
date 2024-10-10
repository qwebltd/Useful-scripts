#! /bin/bash

# Video streaming script by QWeb Ltd, using ffmpeg and a USB camera on a Raspberry Pi 4 B

# Just populate the STREAM_URL and STREAM_KEY variables with your Youtube stream credentials and run this script as a background process to start streaming.

# wget https://raw.githubusercontent.com/qwebltd/Useful-scripts/main/Bash%20scripts%20for%20Linux/ffmpeg-to-youtube-feed-for-raspberry-pi.sh -O youtube-feed.sh
# chmod +x ./youtube-feed.sh
# nano ./youtube-feed.sh
#   (edit credentials)
# ./youtube-feed.sh &

# For a totally headless set-up, add this script to your crontab to launch on boot and relaunch every 10 minutes (thus self-resolving any stream issues that might occur):

# sudo crontab -e
#   (add the following lines)
# @reboot /path/to/youtube-feed.sh
# */10 * * * * /path/to/youtube-feed.sh

# This script also respawns ffmpeg automatically if it exits for any reason other than a purposeful kill signal.

# NOTE:
# 5v 3a power in required, else fps suffers because USBs become under-supplied. Most phone chargers are only 1.8a - 2a
# USB 2 ports seem to work more reliably than USB 3 for some reason
# h264_v4l2m2m codec uses the Pi's hardware encoder, which only supports up to 1080p. Bitrate, maxrate, and bufsize are tuned for 1080p at 30fps
# h264_v4l2m2m codec can also hardware encode, but doesn't work with mjpeg and yuyv422 gives a lower input fps
# Audio is set up for silence. Youtube claims to require AAC but the aac encoder slows the fps and the pcm stream from lavfi seems to work anyway
# Calling v4l2-ctl first shouldn't be needed, but without it the input is sometimes bordered suggesting a smaller input resolution than asked for

AUDIO_IN="-f lavfi -i anullsrc=channel_layout=mono:sample_rate=44100"
VIDEO_IN="-f v4l2 -framerate 30 -video_size 1920x1080 -input_format mjpeg -thread_queue_size 16 -i /dev/video0"
VIDEO_FOR_LINUX_CONTROLS="-d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat=MJPG"

AUDIO_OUT="copy"
VIDEO_OUT="h264_v4l2m2m -b:v 6000k -maxrate 6000k -bufsize 12000k -g 15 -bf 2 -pix_fmt yuv420p -strict experimental"

# Replace with your own Youtube live stream credentials
STREAM_URL="rtmp://a.rtmp.youtube.com/live2"
STREAM_KEY="xxxx-xxxx-xxxx-xxxx-xxxx"

VERBOSITY=""

# Comment this line if debugging. Otherwise ffmpeg won't output anything unless an error occurs
VERBOSITY="${VERBOSITY} -hide_banner -loglevel error -y"

# We need to initialise this with something other than 255 to kick-start the main loop
ffmpeg_exit_code=""

# The main loop
while [[ $ffmpeg_exit_code != "255" ]]; do
  # Kill any previous iterations of this script, to prevent cron from creating overlapping instances
  # It isn't ideal to do this before the connection check because we might hit latency there, but if we do the check first and get stuck there, we could end up spawning infinite processes
  kill -9 $(pgrep -f ${BASH_SOURCE[0]} | grep -v $$) &> /dev/null

  # Wait for a connection
  while ! ping -c 1 -W 1 a.rtmp.youtube.com &> /dev/null; do
    echo "Waiting for connection..."
    sleep 0.1
  done

  echo "Connection ready."

  # Now kill any old instances of ffmpeg. It should be safe to wait until after the connection check for this
  killall ffmpeg &> /dev/null

  # Wait until the v4l2 device is free again and then set it up
  while ! v4l2-ctl $VIDEO_FOR_LINUX_CONTROLS &> /dev/null; do
    echo "Waiting for device..."
    sleep 0.1
  done

  echo "Device ready."

  # Launch ffmpeg and grab its PID
  ffmpeg -nostdin $VERBOSITY -use_wallclock_as_timestamps 1 -re -fflags +genpts+nobuffer $AUDIO_IN $VIDEO_IN -codec:a $AUDIO_OUT -codec:v $VIDEO_OUT -f flv -flvflags no_duration_filesize $STREAM_URL/$STREAM_KEY &
  ffmpeg_process=$!

  echo "Stream started."

  # Wait for that PID to exit and grab its exit code
  wait $ffmpeg_process
  ffmpeg_exit_code=$?

  echo "Stream ended with exit code $ffmpeg_exit_code."

  # We'll loop back around if the exit code is not 255, i.e. ffmpeg was not putposefully killed with kill or killall commands
done
