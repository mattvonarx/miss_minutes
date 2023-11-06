#!/bin/bash
source utils.sh
source minutes_frames.sh
clear
COLS_BEFORE=$(get_cols_before "${F01}")
LINES_BEFORE=$(get_lines_before "${F01}")
LINES_AFTER=$(get_lines_after "${F01}")
TOTAL_LINES=$(center "${F01}" $COLS_BEFORE $LINES_BEFORE $LINES_AFTER | wc -l)
clear
for i in {01..06}
do
    FRAME_VAR="F${i}"
    center "${!FRAME_VAR}" $COLS_BEFORE $LINES_BEFORE $LINES_AFTER
    sleep 0.5
    echo -e "\e[${TOTAL_LINES}A"
done
for i in {07..17}
do
    FRAME_VAR="F${i}"
    center "${!FRAME_VAR}" $COLS_BEFORE $LINES_BEFORE $LINES_AFTER
    sleep 0.1
    echo -e "\e[${TOTAL_LINES}A"
done
clear
sleep 1
