# INFO:
# ----
# Extract a GIF clip from a video at a specific time index for a specific length in seconds
# and covert to GIF at 320px wide
# 
# USAGE:
# ----
# extractvidclip.sh time_index length_in_seconds  input_file.mkv output_file(optional)
# extractvidclip.sh 0:30       10                 input_file.mkv output_file(optional)
# 
# Further info: 
# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html

if [ ! -z "$1" ]; then 
  echo "USAGE:"
  echo "----"
  echo "extractvidclip.sh time_index length_in_seconds input_file.mkv output_file(optional)"
  echo "extractvidclip.sh 0:30       10                input_file.mkv output_file(optional)"
fi

time_index=$1
time_length=$2
source_file=$3

full_filename=$(basename "$source_file")
extension="${full_filename##*.}"
filename="${full_filename%.*}"

time_index_safe="${time_index/:/-}"

palette="/tmp/palette.png"
filters="fps=15,scale=320:-1:flags=lanczos"

if [ ! -f "$source_file" ]; then
  echo "File not found!"
  return
fi
if [ -z "$4" ]; then 
  output_filename="${filename} [${time_index_safe}--${time_length}s].gif"
else
  output_filename=$4
fi
echo "clipping ${time_length} seconds at time index ${time_index} from ${source_file} to ${output_filename}"

## Generate Pallette
ffmpeg -ss ${time_index} -t ${time_length} -i "${source_file}" -vf "$filters,palettegen" -y $palette

## Generate GIF
ffmpeg -ss ${time_index} -t ${time_length} -i "${source_file}" -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y "${output_filename}"