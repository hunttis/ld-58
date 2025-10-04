#!/usr/bin/env bash

INPUT=${1:-"20"}
T="-"$INPUT"dB"


FILES=($(ls | grep '.wav' | sed -e 's|.wav||'))

mkdir converted

for f in ${FILES[@]}; do
	echo "trimming $f.wav"
	if ffmpeg -i $f.wav -af "silenceremove=1:0:$T,silenceremove=stop_periods=-1:stop_duration=0.1:stop_threshold=$T" converted/$f-trimmed.wav  1>/dev/null 2>/dev/null; then
		echo "$f.wav trimmed"
	else 
		echo "$f.wav failed"
	fi
done

echo "All files trimmed with noice thershold of $T"
