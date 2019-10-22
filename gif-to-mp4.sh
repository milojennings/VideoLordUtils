#!/bin/sh

# INFO:
# ----
# Convert an animated GIFs to MP4
# 
# USAGE:
# ----
# gif-to-mp4.sh --help

fullfile=$1
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"

ffmpeg -i "${fullfile}" -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "${filename}.mp4"
