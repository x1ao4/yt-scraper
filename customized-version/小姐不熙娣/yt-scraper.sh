#!/bin/bash

video_list_id="PLih1-oWJUt3nj0IHCIUsm8JmH0KC13KGH"
download_info=true
download_covers=true

output_file="infos.txt"

YTDL="yt-dlp"
JQ="jq"

if [[ "$video_list_id" == *"@"* ]]; then
    channel_id="$video_list_id"
    channel_url="https://www.youtube.com/$channel_id/videos"
    channel_info=$($YTDL -J --flat-playlist "$channel_url" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Failed to get channel info"
        exit 1
    fi
    list_name=$(echo "$channel_info" | $JQ -r '.title' | sed 's/ - Videos//')
    video_count=$(echo "$channel_info" | $JQ '.entries | length')
    echo "Total videos in channel: $video_count"
elif [[ "$video_list_id" == *"PL"* ]]; then
    playlist_id="$video_list_id"
    playlist_url="https://www.youtube.com/playlist?list=$playlist_id"
    playlist_info=$($YTDL -J --flat-playlist "$playlist_url" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Failed to get playlist info"
        exit 1
    fi
    list_name=$(echo "$playlist_info" | $JQ -r '.title')
    video_count=$(echo "$playlist_info" | $JQ '.entries | length')
    echo "Total videos in playlist: $video_count"
else
    echo "Please set a valid channel ID or playlist ID"
    exit 1
fi

output_dir="$list_name/covers"
mkdir -p "$output_dir"

archive_dir="$list_name/archive"
mkdir -p "$archive_dir"

output_file="$list_name/$output_file"

infos_archive_file="$list_name/archive/infos-archive.txt"
covers_archive_file="$list_name/archive/covers-archive.txt"

touch "$infos_archive_file"
touch "$covers_archive_file"

videos_to_process=0

if $download_info && $download_covers; then
    archive_info_count=$(wc -l < "$infos_archive_file")
    archive_covers_count=$(wc -l < "$covers_archive_file")
    min_count=$((archive_info_count < archive_covers_count ? archive_info_count : archive_covers_count))
    videos_to_process=$((video_count - min_count))
elif $download_info; then
    archive_info_count=$(wc -l < "$infos_archive_file")
    videos_to_process=$((video_count - archive_info_count))
elif $download_covers; then
    archive_covers_count=$(wc -l < "$covers_archive_file")
    videos_to_process=$((video_count - archive_covers_count))
fi

echo "Videos to process: $videos_to_process"
printf "\n"

if [[ $videos_to_process -eq 0 ]]; then
    echo "Total saved: 0"
    echo "Total failed: 0"
    echo "Total skipped: 0"
    exit 0
fi

print_progress() {
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    remaining_time=$((elapsed_time * (videos_to_process - processed_videos) / processed_videos))
        
    printf "Processing progress: %d%% %d/%d %02d:%02d:%02d/%02d:%02d:%02d\n" $progress $processed_videos $videos_to_process $((elapsed_time / 3600)) $(((elapsed_time / 60) % 60)) $((elapsed_time % 60)) $((remaining_time / 3600)) $(((remaining_time / 60) % 60)) $((remaining_time % 60))
}

success_count=0
fail_count=0
skip_count=0
failed_videos=()
failed_info=()
failed_cover=()


start_time=$(date +%s)

total_videos=$video_count
processed_videos=0

if ! $download_info && ! $download_covers; then
    printf "\n"
    echo "Total saved: 0"
    echo "Total failed: 0"
    echo "Total skipped: 0"
    exit 0
fi

if [[ -n "$channel_id" && -z "$playlist_id" ]]; then
    video_ids=$(echo "$channel_info" | $JQ -r '.entries[] | .id' | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }')
elif [[ -z "$channel_id" && -n "$playlist_id" ]]; then
    video_ids=$(echo "$playlist_info" | $JQ -r '.entries[] | .id' | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }')
fi

while read id; do
    download_info_temp=$download_info
    download_covers_temp=$download_covers

    if grep -q -- "$id" "$infos_archive_file" 2>/dev/null; then
        download_info_temp=false
    fi

    if grep -q -- "$id" "$covers_archive_file" 2>/dev/null; then
        download_covers_temp=false
    fi

    if ! $download_info_temp && ! $download_covers_temp; then
        continue
    fi

    progress=$((processed_videos * 100 / videos_to_process))

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [[ $processed_videos -gt 0 ]]; then
        remaining_time=$((elapsed_time * (videos_to_process - processed_videos) / processed_videos))
        printf "\033[1A\033[K\rProcessing progress: %d%% %d/%d %02d:%02d:%02d/%02d:%02d:%02d\n" $progress $processed_videos $videos_to_process $((elapsed_time / 3600)) $(((elapsed_time / 60) % 60)) $((elapsed_time % 60)) $((remaining_time / 3600)) $(((remaining_time / 60) % 60)) $((remaining_time % 60))
    else
        printf "Processing progress: %d%% %d/%d %02d:%02d:%02d\n\n" $progress $processed_videos $videos_to_process $((elapsed_time / 3600)) $(((elapsed_time / 60) % 60)) $((elapsed_time % 60))
    fi

    video_url="https://www.youtube.com/watch?v=$id"
    video_info=$($YTDL -J "$video_url" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        skip_count=$((skip_count + 1))
        skip_reason="This video is private"
        echo "$id" >> "$infos_archive_file"
        echo "$id" >> "$covers_archive_file"

        printf "\033[1A\033[K\033[1A\033[K\r"
        echo "Skipped video: $video_url - $skip_reason"
        printf "\033[K\n\n"

        processed_videos=$((processed_videos + 1))
        continue
    fi

    title=$(echo "$video_info" | $JQ -r '.title')
    if [[ -z "$title" ]]; then
        skip_count=$((skip_count + 1))
        skip_reason="This video has an empty title"

        printf "\033[1A\033[K\033[1A\033[K\r"
        echo "Skipped video: $video_url - $skip_reason"
        printf "\033[K\n\n"

        processed_videos=$((processed_videos + 1))
        continue
    fi
    
    description=$(echo "$video_info" | jq -r '.description')

    topic=$(echo "$description" | grep -oE '主題：.*' | sed 's/主題：//')
    description=$(echo "$description" | awk '{gsub(/敬請鎖定晚間10點《小姐不熙娣》！|請鎖定晚間10點《小姐不熙娣》！/, ""); print}')
    description=$(echo "$description" | awk -v RS='\n\n' 'NR==3' | sed '/^\s*$/d' | tr -d '\n')

    episode_number=$(echo "$title" | grep -oE 'EP[0-9]+')

    info_saved=true
    cover_saved=true

    upload_date=$(echo "$title" | grep -oE '[0-9]{8}')
    formatted_date=$(date -j -f "%Y%m%d" "$upload_date" "+%Y/%-m/%-d" 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        failed_videos+=("${episode_number#EP}")
        failed_info+=("${episode_number#EP}")
        info_saved=false
        fail_reason="Failed to convert date"
        
        printf "\033[1A\033[K\033[1A\033[K\r"
        echo "Failed to save video info: $video_url - $fail_reason"
        printf "\033[K\n\n"
        
        processed_videos=$((processed_videos + 1))
        print_progress
    else
        duration=$(echo "$video_info" | $JQ -r '.duration')
        duration=$((duration / 60))
        
        if $download_info_temp; then
            printf "%s;%s;%s;%s;%s\n" "${episode_number#EP}" "$formatted_date" "$duration" "$topic" "$description" >> "$output_file"
            if ! grep -q -- "$id" "$infos_archive_file" 2>/dev/null; then
                echo "$id" >> "$infos_archive_file"
            fi
        fi

    fi

    if $download_covers_temp; then
        if grep -q -- "$id" "$covers_archive_file" 2>/dev/null; then
            continue
        fi

        if [[ ! $episode_number ]] || ! [[ $episode_number =~ ^EP[0-9]+$ ]]; then
            failed_videos+=("${episode_number#EP}")
            failed_cover+=("${episode_number#EP}")
            cover_saved=false
            
            if ! $info_saved; then 
                fail_reason="Episode number is empty or invalid"
                echo "Failed to save video: $video_url - $fail_reason"
                fail_count=$((fail_count + 1))
                processed_videos=$((processed_videos + 1))
            fi
            
            continue
        fi

        cover_output_file="$output_dir/${episode_number#EP}"
        if [[ -e "$cover_output_file.jpg" ]]; then
            i=1
            while [[ -e "$cover_output_file-$i.jpg" ]]; do
                i=$((i + 1))
            done
            cover_output_file="$output_dir/${episode_number#EP}-$i"
        fi

        $YTDL --quiet --no-warnings --write-thumbnail --convert-thumbnails jpg --skip-download --output "$cover_output_file" "$video_url"
        
        if [[ $? -ne 0 ]]; then
            failed_videos+=("${episode_number#EP}")
            failed_cover+=("${episode_number#EP}")
            cover_saved=false
            
            fail_reason="Failed to download cover image"
            
            printf "\033[1A\033[K\033[1A\033[K\r"
            if $info_saved; then 
                echo "Failed to save video cover: $video_url - $fail_reason"
                printf "\033[K\n\n"
            else
                echo "Failed to save video: $video_url - $fail_reason"
                printf "\033[K\n\n"
            fi
            
            processed_videos=$((processed_videos + 1))
            print_progress
        else
            echo "$id" >> "$covers_archive_file"
        fi
        
    fi

    if $info_saved && $cover_saved; then
        printf "\033[1A\033[K\033[1A\033[K\r"
        echo "Successfully saved video: ${episode_number#EP}"
        printf "\033[K\n\n"
        success_count=$((success_count + 1))
    elif ! $info_saved && ! $cover_saved; then
        fail_count=$((fail_count + 1))
    fi
    processed_videos=$((processed_videos + 1))

done <<< "$video_ids"

printf "\033[1A\033[K\r"
progress=$((processed_videos * 100 / videos_to_process))
print_progress
printf "\n"

echo "Total saved: $success_count"
echo "Total failed: $fail_count"
echo "Total skipped: $skip_count"

if [[ ${#failed_info[@]} -gt 0 ]]; then
    printf "Failed info: "
    for id in "${failed_info[@]}"; do
        printf "%s " "$id"
    done
    printf "\n"
fi
if [[ ${#failed_cover[@]} -gt 0 ]]; then
    printf "Failed cover: "
    for id in "${failed_cover[@]}"; do
        printf "%s " "$id"
    done
    printf "\n"
fi
