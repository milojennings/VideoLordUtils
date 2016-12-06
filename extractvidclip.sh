# INFO:
# ----
# Extract a clip from a video at a specific time index for a specific length in seconds
# and covert to H264 encoded MP4
# 
# USAGE:
# ----
# extractvidclip.sh time_index length_in_seconds input_file.mkv output_file(optional)
# extractvidclip.sh 0:30       10                input_file.mkv output_file(optional)

time_index=$1
time_length=$2
source_file=$3

full_filename=$(basename "$source_file")
extension="${full_filename##*.}"
filename="${full_filename%.*}"

time_index_safe="${time_index/:/-}"

if [ ! -f "$source_file" ]; then
  echo "File not found!"
  return
fi
if [ -z "$4" ]; then 
  output_filename="${filename} [${time_index_safe}--${time_length}s].mp4"
else
  output_filename=$4
fi
echo "clipping ${time_length} seconds at time index ${time_index} from ${source_file} to ${output_filename}"

ffmpeg -ss ${time_index} -t ${time_length} -i "${source_file}" -c:v libx264 -crf 23 -preset slow -c:a copy "${output_filename}"