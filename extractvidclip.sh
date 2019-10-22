# INFO:
# ----
# Extract a clip from a video at a specific time index for a specific length in seconds
# and covert to H264 encoded MP4
# 
# USAGE:
# ----
# extractvidclip.sh time_index length_in_seconds input_file     output_file(optional)
# extractvidclip.sh 0:30       10                input_file.mkv output_file.mp4
# 
# The time index uses sexagesimal format (HOURS:MM:SS.MILLISECONDS, as in 01:23:45.678).
# If a fraction is used, such as 02:30.05, this is interpreted as "5 100ths of a second", 
# not as frame 5. For instance, 02:30.5 would be 2 minutes, 30 seconds, and a half a second, 
# which would be the same as using 150.5 in seconds.
# 
# If no output filename is provided, the time index and length will be appended to the original filename

time_index=$1
time_length=$2
source_file=$3

full_filename=$(basename "$source_file")
extension="${full_filename##*.}"
filename="${full_filename%.*}"

time_index_safe="${time_index/:/-}"

if [ -z "$source_file" ]; then echo "Source file not specified"; exit 1; fi
if [ ! -f "$source_file" ]; then echo "Source file not found!\n$source_file"; exit 1; fi

if [ -z "$4" ]; then 
  output_filename="${filename} [${time_index_safe}--${time_length}s].mp4"
else
  output_filename=$4
fi
echo "clipping ${time_length} seconds at time index ${time_index} from ${source_file} to ${output_filename}"

# ffmpeg -ss ${time_index} -t ${time_length} -i "${source_file}" -c:v libx264 -crf 23 -preset slow -c:a copy "${output_filename}"

# video_bitrate=800k
constant_rate_factor=22 #range between 0–51, where 0 is lossless, 23 is the default, and 51 is worst quality possible.
audio_bitrate=80k
consecutive_b_frames=2
audio_codec=aac
encoding_speed=slow
threads=12

ffmpeg -y -ss ${time_index} -t ${time_length} -i "${source_file}" -c:v libx264 \
  -crf $constant_rate_factor \
  -movflags +faststart -bf $consecutive_b_frames -pix_fmt yuv420p -threads $threads \
  -preset $encoding_speed -c:a $audio_codec -b:a $audio_bitrate \
  "${output_filename}"
  # -b:v $video_bitrate \

### two pass encoding
# ffmpeg -y -i "${source_file}" -c:v libx264 -b:v $video_bitrate -pass 1 \
#   -preset $encoding_speed -threads $threads \
#   -movflags +faststart -bf $consecutive_b_frames -pix_fmt yuv420p \
#   -ss ${time_index} -t ${time_length} -an -f mp4 /dev/null && \
# ffmpeg -y -i "${source_file}" -c:v libx264 -b:v $video_bitrate -pass 2 \
#   -preset $encoding_speed -threads $threads \
#   -movflags +faststart -bf $consecutive_b_frames -pix_fmt yuv420p \
#   -ss ${time_index} -t ${time_length} -c:a aac -b:a $audio_bitrate "${output_filename}"
