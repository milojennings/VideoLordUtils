fullfile=$1
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
ffmpeg -i "${fullfile}" -vcodec copy -acodec copy "${filename}.mp4"