#!/bin/bash
repeat(){
    START=1
    END=${1:-80}
    STR="${2:-=}"
    RANGE=$(seq $START $END)
    for i in $RANGE ; do echo -n "${STR}"; done
}
get_width(){
    STR=${1:-=}
    WIDTH=0
    while IFS= read -r LINE
    do
       LINE_WIDTH=$(echo "${LINE}" | wc -m)
       WIDTH=$(( $LINE_WIDTH > $WIDTH ? $LINE_WIDTH : $WIDTH ))
    done <<<$(echo "${STR}")
    echo $WIDTH
}
get_cols_before(){
    STR=${1:-=}
    COLS=$(tput cols)
    echo $((($COLS-$(get_width "${STR}"))/2))
}
get_height(){
    STR=${1:-=}
    echo "$STR" | wc -l
}
get_lines_before(){
    STR=${1:-=}
    LINES=$(tput lines)
    HEIGHT=$(get_height "${STR}")
    echo $((($LINES-$HEIGHT)/2))
}
get_lines_after(){
    STR=${1:-=}
    LINES=$(tput lines)
    LINES_BEFORE=$(get_lines_before "${STR}")  
    HEIGHT=$(get_height "${STR}")
    echo $(($LINES-$HEIGHT-$LINES_BEFORE-1))
}
center(){
    STR=${1:-=}
    COLS_BEFORE=${2:-$(get_cols_before "${STR}")}
    LINES_BEFORE=${3:-$(get_lines_before "${STR}")}
    LINES_AFTER=${4:-$(get_lines_after "${STR}")}
    PREFACE=$(repeat $COLS_BEFORE ' ')
    for i in $(seq $LINES_BEFORE)
    do
       echo -e "\e[K"
    done
    while IFS= read -r LINE
    do
      echo -e "${PREFACE}${LINE}\e[K"
    done <<<$(echo "${STR}")
    for i in $(seq $LINES_AFTER)
    do
       echo -e "\e[K"
    done
}
