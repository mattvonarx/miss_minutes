#!/bin/bash
source utils.sh
source minutes_frames.sh
clear
COLS_BEFORE=$(get_cols_before "${F01}")
LINES_BEFORE=$(get_lines_before "${F01}")
clear
for i in {01..06}
do
    FRAME_VAR="F${i}"
    center "${!FRAME_VAR}" $COLS_BEFORE $LINES_BEFORE
    sleep 0.5
done
for i in {07..17}
do
    FRAME_VAR="F${i}"
    center "${!FRAME_VAR}" $COLS_BEFORE $LINES_BEFORE
    sleep 0.1
done
clear
sleep 1
