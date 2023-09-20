#!/usr/bin/env bash

main() {
    init

    tput civis # hide cursor

    echo -e "\e[2J"
    echo -e "\e[1;$((FINISH_DISTANCE-6))H \e[7mF I N I S H"
    echo -e "\e[2;${FINISH_DISTANCE}H\e[7m "

    echo -e "\e[$((WINDOW_HEIGHT-3));${FINISH_DISTANCE}H\e[7m "
    echo -e "\e[$((WINDOW_HEIGHT-2));$((FINISH_DISTANCE-6))H \e[7mF I N I S H\e[0m"

    while race; do
        update
        render
        sleep "$PAUSE"
    done

    echo -n "WINNER: $(declareWinner)"
    
    while true; do
        read -t 3 -n 1
        [ $? = 0 ] && { tput cnorm; clear; exit 0; } # show cursor and exit
    done
}

init() {
    source './frames.sh'

    WINDOW_WIDTH=$(tput cols)    
    WINDOW_HEIGHT=$(tput lines)    
    FINISH_DISTANCE=$(( WINDOW_WIDTH * 2 / 3 ))
    MAX_SPEED=$((FINISH_DISTANCE / 10))
    DOGS=$(( WINDOW_HEIGHT / 7 ))
    NUMBER_OF_FRAMES=2
    DOG_WIDTH=
    DOG_HEIGHT=$(( ${#frames[@]} / NUMBER_OF_FRAMES ))
    PAUSE=0.1
    CURRENT_FRAME=0
    for ((i=0; i<DOGS; i++)); do distances+=(""); done
}

render() {
    echo -e "\e[2;0H"
    for ((i=0; i<DOGS; i++)); do
        for ((line=0; line<DOG_HEIGHT; line++)); do
            line_index=$((DOG_HEIGHT*CURRENT_FRAME + line))
            if [ "$line" -ne 2 ]; then 
                echo "${distances[i]}${frames[line_index]}"
            else
                echo "${distances[i]}${frames[line_index]}" | tr 'N' "$((i + 1))"
            fi
        done 
    done 
}

update() {
    CURRENT_FRAME=$(( (CURRENT_FRAME + 1) % 2 ))
    for ((i=0; i<${#distances[@]}; i++)); do
        move=$(( RANDOM % MAX_SPEED + 1 ))
        for ((j=0; j<"$move"; j++ )); do
            distances[i]+=" "
        done
    done
}

race() {
    for ((i=0; i<${#distances[@]}; i++)) {
        [ "${#distances[i]}" -ge $((FINISH_DISTANCE - 24)) ] && return 1
    }
    return 0;
}

declareWinner() {
    local longest_distance=${#distances[0]}
    local winner=1
    for ((i=1; i<${#distances[@]}; i++)) {
        if [ "${#distances[i]}" -gt "$longest_distance" ]; then
            winner=$((i + 1))
            longest_distance="${#distances[i]}"
        fi
    }
    echo $winner
}


main
