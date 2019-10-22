#!/bin/sh

# INFO:
# ----
# Extract audio from a video as an m4a file

if [ ! -z "$1" ]; then 
  echo "USAGE:"
  echo "----"
  echo "extractaudio.sh input_file.mp4 output_file(optional)"
fi

source_file=$1

full_filename=$(basename "$source_file")
extension="${full_filename##*.}"
filename="${full_filename%.*}"

if [ ! -f "$source_file" ]; then
  echo "File not found!"
  return
fi
if [ -z "$4" ]; then 
  output_filename="${filename}.m4a"
else
  output_filename=$4
fi

ffmpeg -i "${source_file}" -vn -c:a libfdk_aac -vbr 3 "${output_filename}"
