#!/bin/sh

MUSICDIR=~/media/
HTMLPATH=/tmp/mpdinfo.htm

update_screen() {
	clear
	GENRE=`mpc current --format='%genre%'`
	FILE="$MUSICDIR"`mpc current --format='%file%'`

	case "$GENRE" in
		*Classical*)
			WORK=`metaflac --show-tag=WORK "$FILE" | cut -d= -f2-`
			ARTIST=`metaflac --show-tag=COMPOSER "$FILE" | cut -d= -f2-`
			ARGS=`metaflac --export-tags-to=- "$FILE" | grep -Ei '^(performer|conductor|ensemble|label|recordingdate|recordinglocation)='`
		;;
		*)
			WORK=`mpc current --format='%album%'`
			ARTIST=`mpc current --format='%artist%'`
			ARGS=`metaflac --export-tags-to=- "$FILE" | grep -Ei '^(performer|label|recordingdate|recordinglocation)='`
		;;
	esac

	tput bold
	printf "\033[36m"
	printf "\033#3$ARTIST\n\033#4$ARTIST\n"
	printf "\033#3$WORK\n\033#4$WORK\n"
	for i in `seq 1 ${COLUMNS:=$(tput cols)}`; do printf "─"; done
	tput sgr0
	echo "$ARGS" | column -c ${COLUMNS:=`tput cols`}  -W 0,1,2 -t -s=
	tput civis
}

copy_coverart() {
	FILE="$MUSICDIR"`mpc current --format='%file%'`
	COVERIMG=`dirname "$FILE"`/cover.jpg
	cp "$COVERIMG" /tmp/cover.jpg
}

update() {
	kill $MPC_PID
	copy_coverart
	update_screen
}

trap update WINCH

while true
do
	update
	mpc current --wait &
	MPC_PID=$!
	wait $MPC_PID
done