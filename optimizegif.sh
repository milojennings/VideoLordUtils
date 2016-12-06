fullfile=$1
if [ -z "$2" ]; then width=300; else width=$2; fi
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
$(gifsicle --resize-width ${width} -O3 -o "${filename} - o-${width}.gif" "${fullfile}")
