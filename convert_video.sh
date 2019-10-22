#!/bin/sh

# INFO:
# ----
# Convert a video to H264 with AAC audio. 
# You can specify the bitrate or constant rate factor/quality for the video,
# the bitrate of the audio, andthe height of the video to scale down (will not scale up).
# This information is added to the filename unless you specify a custom filename.
# 
# USAGE:
# ----
# convert_video.sh --help

VIDEO_QUALITY="23"
AUDIO_BITRATE="80k"

function usage()
{
    echo "Usage:"
    echo "Note: use either video_quality or video_bitrate, not both"
    echo "video_quality=23 is the default"
    echo ""
    echo "./convert_video.sh"
    echo "\t-h  --help"
    echo "\t-o  --output=custom_file_name.mp4"
    echo "\t-vq --video_quality=23             (0–51, 0=lossless, 51=worst)"
    echo "\t-vb --video_bitrate=1000k" 
    echo "\t-vh --video_height=720"
    echo "\t-a  --animation                    (tune for animation)"
    echo "\t-ab --audio_bitrate=$AUDIO_BITRATE"
    echo "\texample.mp4"
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
      usage
      exit
      ;;
    -vb | --video_bitrate)
      VIDEO_BITRATE=$VALUE
      ;;
    -vq | --video_quality)
      VIDEO_QUALITY=$VALUE
      ;;
    -vh | --video_height)
      VIDEO_HEIGHT=$VALUE
      ;;
    -ab | --audio_bitrate)
      AUDIO_BITRATE=$VALUE
      ;;
    -a | --animation)
      TUNE_FOR_ANIMATION=true
      ;;
    -o | --output)
      CUSTOM_OUTPUT_NAME=$VALUE
      ;;
    *)
      if [ -f "$PARAM" ]; then 
          # echo "Source file found!\n$PARAM";
          SOURCE_FILE="${PARAM}"
      else
          echo "Arguments not correct!\n$PARAM";
          usage
          exit 1
      fi
      ;;
  esac
  shift
done

if [ -z "$SOURCE_FILE" ]; then 
  echo "No source file found"
  usage
  exit 1
fi

FULL_FILENAME=$(basename "$SOURCE_FILE")
EXTENSION="${FULL_FILENAME##*.}"
FILENAME="${FULL_FILENAME%.*}"

function get_video_metadata()
{
  ACTUAL_VIDEO_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "${SOURCE_FILE}")
  VIDEO_CREATION_TIME=$(ffprobe -v error -select_streams v:0 -show_entries stream_tags=creation_time: -of csv=s=x:p=0 "${SOURCE_FILE}")
  # ACTUAL_VIDEO_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "${SOURCE_FILE}")
}
get_video_metadata

## If no OUTPUT_NAME specified, generate output name using bitrate & quality
if [ -z "$CUSTOM_OUTPUT_NAME" ]; then 
  if [ -z "$VIDEO_HEIGHT" ]; then
    VIDEO_HEIGHT=$ACTUAL_VIDEO_HEIGHT
  fi
  if [ "$VIDEO_HEIGHT" -gt "$ACTUAL_VIDEO_HEIGHT" ]; then
    VIDEO_HEIGHT=$ACTUAL_VIDEO_HEIGHT
  fi
  FILENAME_HEIGHT=" (${VIDEO_HEIGHT}p)"

  if [ ! -z "$VIDEO_BITRATE" ]; then
    OUTPUT_FILENAME="${FILENAME}-[VB_${VIDEO_BITRATE}-A_${AUDIO_BITRATE}]${FILENAME_HEIGHT}.mp4"
  else 
    OUTPUT_FILENAME="${FILENAME}-[VQ_${VIDEO_QUALITY}-A_${AUDIO_BITRATE}]${FILENAME_HEIGHT}.mp4"
  fi
else
  OUTPUT_FILENAME="${CUSTOM_OUTPUT_NAME}"
fi

consecutive_b_frames=2
encoding_speed=slow
threads=12

if [ ! -z "$VIDEO_HEIGHT" ]; then
  ffmpeg_scale="-vf scale=-2:min'(${VIDEO_HEIGHT},ih)'"
else 
  ffmpeg_scale=""
fi

if [ ! -z "$TUNE_FOR_ANIMATION" ]; then 
  $ffmpeg_tune="-tune animation"
else
  $ffmpeg_tune=""
fi

if [ ! -z "$VIDEO_BITRATE" ]; then
  ## use two pass encoding when bitrate is set
  ffmpeg -y -i "${SOURCE_FILE}" -c:v libx264 -b:v $VIDEO_BITRATE -pass 1 \
    -preset $encoding_speed -threads $threads \
    $ffmpeg_scale \
    $ffmpeg_tune \
    -movflags +faststart -bf $consecutive_b_frames -pix_fmt yuv420p \
    -an -f mp4 /dev/null && \
  ffmpeg -y -i "${SOURCE_FILE}" -c:v libx264 -b:v $VIDEO_BITRATE -pass 2 \
    -preset $encoding_speed -threads $threads \
    $ffmpeg_scale \
    $ffmpeg_tune \
    -metadata creation_time="${VIDEO_CREATION_TIME}" \
    -movflags +faststart -bf $consecutive_b_frames -pix_fmt yuv420p \
    -c:a aac -b:a $AUDIO_BITRATE "${OUTPUT_FILENAME}"
else
  ## Use single pass encoding when quality is set
  ffmpeg -y -i "${SOURCE_FILE}" -c:v libx264 \
    -crf $VIDEO_QUALITY \
    $ffmpeg_scale \
    $ffmpeg_tune \
    -metadata creation_time="${VIDEO_CREATION_TIME}" \
    -movflags +faststart -bf $consecutive_b_frames -pix_fmt yuv420p -threads $threads \
    -preset $encoding_speed -c:a aac -b:a $AUDIO_BITRATE \
    "${OUTPUT_FILENAME}"
fi
## Copy time stamps
touch -r "${SOURCE_FILE}" "${OUTPUT_FILENAME}"