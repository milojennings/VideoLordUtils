#!/bin/sh

# INFO:
# ----
# split video into timed segments
# 
# USAGE:
# ----
# convert_video.sh --help

VIDEO_QUALITY="23"
AUDIO_BITRATE="80k"

function usage()
{
    echo "Usage:"
    echo ""
    echo "./split_video.sh"
    echo "\t-h  --help"
    echo "\t-t  --segment-time=0:02:00 (hours:minutes:seconds)"
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
      usage
      exit
      ;;
    -t | --sement-time)
      SEGMENT_TIME=$VALUE
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

DIGIT_FORMAT="%02d" # Two digit format (E.G. 2 = 02)

OUTPUT_FILENAME="${FILENAME}-${DIGIT_FORMAT}.mp4"

audio_bitrate=80k
audio_codec=aac

if [ ! -z "$SEGMENT_TIME" ]; then
  echo "splitting!"
  # ffmpeg -i "${SOURCE_FILE}" -c copy -c:a $audio_codec -b:a $audio_bitrate -map 0 -segment_time $SEGMENT_TIME -f segment -reset_timestamps 1 "${OUTPUT_FILENAME}"
  ## Set timestamp of segments to match original file
  # find ./ -name "${FILENAME}-*" -type f | xargs -I '{}' touch -r "${SOURCE_FILE}" {}

  ## Number the video
  formatted_count=$(printf -v segment_count "${DIGIT_FORMAT}" $segment_count; echo $segment_count)
  formatted_segment_count=$(printf -v segment_count "${DIGIT_FORMAT}" $segment_count; echo $segment_count)
  COUNTER=0
  while [  $COUNTER -lt $segment_count ]; do
      echo The counter is $COUNTER
      formatted_counter=$(printf -v COUNTER "${DIGIT_FORMAT}" $COUNTER; echo $COUNTER)
      ffmpeg -i "${FILENAME}-${formatted_counter}.mp4" -vf "drawtext=text='${formatted_counter}/${formatted_segment_count}':x=10:y=H-th-10:fontfile=/Library/Fonts/Arial Black.ttf:fontsize=14:fontcolor=white:shadowcolor=black:shadowx=2:shadowy=2" "${FILENAME}-${formatted_counter}-overlay.mp4"
      let COUNTER=COUNTER+1
  done
else
  echo "no segment time specified"
  usage
fi

##
## Fancy time stamp copying
## -------------------------------------------------------
## @TODO: Still doesn't account for timezone and ends up 8 hours off, set to GMT / Zulu time
## =======================================================
## Source Format
## 2019-02-02T22:26:46.000000Z
## Goal Format
## [-t [[CC]YY]MMDDhhmm[.SS]]
##       20 19 02022226.46
## CC      The first two digits of the year (the century).
## YY      The second two digits of the year.  If ``YY'' is specified, but ``CC'' is not, a value for ``YY''
##         between 69 and 99 results in a ``CC'' value of 19.  Otherwise, a ``CC'' value of 20 is used.
## MM      The month of the year, from 01 to 12.
## DD      the day of the month, from 01 to 31.
## hh      The hour of the day, from 00 to 23.
## mm      The minute of the hour, from 00 to 59.
## SS      The second of the minute, from 00 to 61.

# creation_time=$(ffprobe "${SOURCE_FILE}" 2>&1 | grep -m 1 'creation_time' | tr -d '-' | tr -d 'T' | tr -d ':' | awk '{print $2}' | awk -F'.' '{print $1}' | sed 's/.\{2\}$/.&/')
# echo "${creation_time}"

# touch -t "${creation_time}" 02022019_142646-00.mp4