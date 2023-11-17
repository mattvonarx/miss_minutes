#!/bin/bash
prep_terminal() {
    echo -n -e "\e[?25l\e[48;2;88;77;75m\e[38;2;204;188;141m"
    clear
}
cleanup_terminal() {
    echo -n -e "\033[0m\e[?25h"
    clear
}
get_width(){
    local STR=${1:-=}
    echo "${STR}" | wc -L
}
get_cols_before(){
    local STR=${1:-=}
    local COLS=$(tput cols)
    echo $((($COLS-$(get_width "${STR}"))/2))
}
get_cols_after(){
    local STR=${1:-=}
    local COLS=$(tput cols)
    local COLS_BEFORE=$(get_cols_before "${STR}")
    local WIDTH=$(get_width "${STR}")
    echo $(($COLS-$WIDTH-$COLS_BEFORE))
}
get_height(){
    local STR=${1:-=}
    echo "$STR" | wc -l
}
get_lines_before(){
    local STR=${1:-=}
    local LINES=$(tput lines)
    local HEIGHT=$(get_height "${STR}")
    echo $((($LINES-$HEIGHT)/2))
}
get_lines_after(){
    local STR=${1:-=}
    local LINES=$(tput lines)
    local LINES_BEFORE=$(get_lines_before "${STR}")  
    local HEIGHT=$(get_height "${STR}")
    echo $(($LINES-$HEIGHT-$LINES_BEFORE))
}
print_with_transparency(){
    local STR=${1:-=}
    local X_POS=${2:-1}
    local Y_POS=${3:-1}
    local TRANSPARENT_CHAR=${4:-"X"}
    for (( i=0; i<${#STR}; i++ ))
    do
        local CHAR=${STR:$i:1}
        if [[ $CHAR != $TRANSPARENT_CHAR ]]
        then
            echo -n -e "\e[${Y_POS};${X_POS}H${CHAR}"
        fi
        X_POS=$(($X_POS+1))
    done
}
center(){
    local STR=${1:-=}
    local X_POS=${2:-$(($(get_cols_before "${STR}")+1))}
    local Y_POS=${3:-$(($(get_lines_before "${STR}")+1))}
    while IFS= read -r LINE
    do
        if [ -z ${4+x} ]
        then
            echo -n -e "\e[${Y_POS};${X_POS}H${LINE}"
        else
            local TRANSPARENT_CHAR=$4
            print_with_transparency "$LINE" $X_POS $Y_POS $TRANSPARENT_CHAR
        fi
        Y_POS=$(($Y_POS+1))
    done <<<$(echo -n "${STR}")
}
extract_contents(){
    local STR=${1:-=}
    local X_POS=${2:-1}
    local Y_POS=${3:-1}
    local WIDTH=${4:-1}
    local HEIGHT=${5:-1}
    while IFS= read -r LINE
    do
	echo $Y_POS
	if (( $Y_POS < $((0-$HEIGHT)) ))
	then
	    echo "BROKE HERE"
	    break
	fi
	if (( $Y_POS <= 0 ))
	then
	    echo "GOT HERE"
	    echo ${LINE:$X_POS:$WIDTH}
	fi
        Y_POS=$(($Y_POS-1))
    done <<<$(echo -n "${STR}")
}
