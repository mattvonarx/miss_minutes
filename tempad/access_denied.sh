#!/bin/bash
source ../utils.sh
CELL_WIDTH=6
CELL_HEIGHT=3
get_grid_char() {
    local LINE=$(($1-1))
    local COL=$(($2-1))
    local HEIGHT=$3
    local WIDTH=$4
    if (( $LINE == 0 ))
    then
	if (( $COL == 0 ))
	then
	    echo -n "┌"
	    return
	fi
	if (( $COL == $WIDTH - 1 ))
	then
	    echo -n "┐"
	    return
	fi
	if (( $COL % $CELL_WIDTH == 0 ))
	then
	    echo -n "┬"
	    return
	fi
	echo -n "─"
	return
    fi
    if (( $LINE == $HEIGHT - 1 ))
    then
	if (( $COL == 0 ))
	then
	    echo -n "└"
	    return
	fi
	if (( $COL == $WIDTH - 1 ))
	then
	    echo -n "┘"
	    return
	fi
	if (( $COL % $CELL_WIDTH == 0 ))
	then
	    echo -n "┴"
	    return
	fi
	echo -n "─"
	return
    fi
    if (( $LINE % $CELL_HEIGHT == 0 ))
    then
	if (( $COL == 0 ))
	then
	    echo -n "├"
	    return
	fi
	if (( $COL == $WIDTH - 1 ))
	then
	    echo -n "┤"
	    return
	fi
	if (( $COL % $CELL_WIDTH == 0 ))
	then
	    echo -n "┼"
	    return
	fi
	echo -n "─"
	return
    fi
    if (( $COL == 0 ))
    then
	echo -n "│"
	return
    fi
    if (( $COL == $WIDTH - 1 ))
    then
	echo -n "│"
	return
    fi
    if (( $COL % $CELL_WIDTH == 0 ))
    then
	echo -n "│"
	return
    fi
    echo -n " "
    return
}
build_grid() {
    local HEIGHT=$1
    local WIDTH=$2
    for i in $(seq $HEIGHT)
    do
	for j in $(seq $WIDTH)
	do
	    get_grid_char $i $j $HEIGHT $WIDTH
	done
	if (( $i < $HEIGHT ))
	then
	    echo
	fi
    done
}

print_grid_with_buttons() {
    local COLS=$(tput cols)
    local LINES=$(tput lines)
    local GRID_COLS=$(($(($(($COLS))/$CELL_WIDTH))*$CELL_WIDTH+1))
    local GRID_LINES=$(($(($(($LINES))/$CELL_HEIGHT))*$CELL_HEIGHT+1))
    local GRID="$(build_grid $GRID_LINES $GRID_COLS)"
    local X_POS=$(($(get_cols_before "${GRID}")+1))
    local Y_POS=$(($(get_lines_before "${GRID}")+1))
    center "$GRID" $X_POS $Y_POS
    local BUTTONS=$(cat buttons.txt)
    local BUTTONS_HEIGHT=$(get_height "$BUTTONS")
    center "$BUTTONS" $X_POS $(($Y_POS+$GRID_LINES-$BUTTONS_HEIGHT-$CELL_HEIGHT)) "X"
    if [ -z ${1+x} ]
    then
	return
    else
	local ACCESS_DENIED=$(cat access_denied.txt)
	local ACCESS_X_POS=$(($(($(($(get_cols_before "${ACCESS_DENIED}")-$X_POS-1))/$CELL_WIDTH))*$CELL_WIDTH+$X_POS))
	local ACCESS_Y_POS=$(($(($(($(get_lines_before "${ACCESS_DENIED}")-$Y_POS-1))/$CELL_HEIGHT))*$CELL_HEIGHT+$Y_POS))
	center "$ACCESS_DENIED" $ACCESS_X_POS $ACCESS_Y_POS
    fi
}

print_miss() {
    local STR=${1:-=}
    local X_POS=$(($(get_cols_before "${STR}")+1))
    local Y_POS=$(($(get_lines_before "${STR}")+1))
    print_grid_with_buttons
    center "$STR" $X_POS $Y_POS "X"
}

bg_remove() {
    local STR=${1:-=}
    local X_OFF=${2:-1}
    local Y_OFF=${3:-1}
    local TRANSPARENT_CHAR=${4:-"X"}
    local Y_POS=0
    while IFS= read -r LINE
    do
        for (( i=0; i<${#LINE}; i++ ))
        do
 	   local CHAR=${LINE:$i:1}
 	   if [[ $CHAR != $TRANSPARENT_CHAR ]]
 	   then
 	       echo -n "$CHAR"
	   else
	      get_grid_char $(($Y_POS+$Y_OFF)) $(($i+$X_OFF)) 999 999
 	   fi
        done
	echo
        Y_POS=$(($Y_POS+1))
    done <<<$(echo -n "${STR}")
}

bg_clean() {
    local STR=${1:-=}
    local X_OFF=${2:-1}
    local Y_OFF=${3:-1}
    local Y_POS=0
    while IFS= read -r LINE
    do
        for (( i=0; i<${#LINE}; i++ ))
        do
	  get_grid_char $(($Y_POS+$Y_OFF)) $(($i+$X_OFF)) 999 999
        done
	echo
        Y_POS=$(($Y_POS+1))
    done <<<$(echo -n "${STR}")
}

COLS=$(tput cols)
LINES=$(tput lines)
GRID_COLS=$(($(($(($COLS))/$CELL_WIDTH))*$CELL_WIDTH+1))
GRID_LINES=$(($(($(($LINES))/$CELL_HEIGHT))*$CELL_HEIGHT+1))
if (( $GRID_LINES > $LINES ))
then
    GRID_LINES=$(($GRID_LINES-$CELL_HEIGHT))
fi
GRID="$(build_grid $GRID_LINES $GRID_COLS)"
GRID_X_OFFSET=$(($(get_cols_before "${GRID}")))
GRID_Y_OFFSET=$(($(get_lines_before "${GRID}")))
GRID_X_POS=$(($GRID_X_OFFSET+1))
GRID_Y_POS=$(($GRID_Y_OFFSET+1))
prep_terminal
center "$GRID" $GRID_X_POS $GRID_Y_POS
BUTTONS=$(cat buttons.txt)
BUTTONS_HEIGHT=$(get_height "$BUTTONS")
center "$BUTTONS" $GRID_X_POS $(($GRID_Y_POS+$GRID_LINES-$BUTTONS_HEIGHT-$CELL_HEIGHT)) "X"
sleep 1
direct_plot(){
    local STR=${1:-=}
    local GRID_X_OFFSET=${2:-0}
    local GRID_Y_OFFSET=${3:-0}
    local X_OFFSET=${4:-0}
    local Y_OFFSET=${5:-0}
    local CLEAN=$(bg_remove "$STR" $(($X_OFFSET-$GRID_X_OFFSET)) $(($Y_OFFSET-$GRID_Y_OFFSET)) "X")
    center "$CLEAN" $(($X_OFFSET)) $(($Y_OFFSET))
}
centering_clean_plot() {
    local STR=${1:-=}
    local GRID_X_OFFSET=${2:-0}
    local GRID_Y_OFFSET=${3:-0}
    if [ -z ${4+x} ]
    then
	local X_OFFSET=$(($(get_cols_before "${STR}")))
	local Y_OFFSET=$(($(get_lines_before "${STR}")))
    else
	local X_OFFSET=$(($(($(($(get_cols_before "${STR}")-$GRID_X_OFFSET))/$CELL_WIDTH))*$CELL_WIDTH+$GRID_X_OFFSET+1))
	local Y_OFFSET=$(($(($(($(get_lines_before "${STR}")-$GRID_Y_OFFSET))/$CELL_HEIGHT))*$CELL_HEIGHT+$GRID_Y_OFFSET+1))
    fi
    local BG=$(bg_clean "$STR" $(($X_OFFSET-$GRID_X_OFFSET)) $(($Y_OFFSET-$GRID_Y_OFFSET)))
    direct_plot "$STR" $GRID_X_OFFSET $GRID_Y_OFFSET $X_OFFSET $Y_OFFSET
    sleep 2
    center "$BG" $(($X_OFFSET)) $(($Y_OFFSET))
}
centering_clean_plot "$(cat tva.txt)" $GRID_X_OFFSET $GRID_Y_OFFSET
centering_clean_plot "$(cat access_denied.txt)" $GRID_X_OFFSET $GRID_Y_OFFSET "GRID_LOCK"
MINUTES=$(cat minutes.txt)
MIN_X_OFFSET=$(($(get_cols_before "${MINUTES}")))
MIN_Y_OFFSET=$(($(get_lines_before "${MINUTES}")))
direct_plot "$MINUTES" $GRID_X_OFFSET $GRID_Y_OFFSET $MIN_X_OFFSET $MIN_Y_OFFSET
HAND1=$(cat hand1.txt)
HAND2=$(cat hand2.txt)
HAND_OFFSET=7
for i in $(seq 5)
do
    direct_plot "$HAND1" $GRID_X_OFFSET $GRID_Y_OFFSET $(($MIN_X_OFFSET)) $(($MIN_Y_OFFSET+$HAND_OFFSET))
    sleep 0.5
    direct_plot "$HAND2" $GRID_X_OFFSET $GRID_Y_OFFSET $(($MIN_X_OFFSET)) $(($MIN_Y_OFFSET+$HAND_OFFSET))
    sleep 0.5
done
cleanup_terminal
