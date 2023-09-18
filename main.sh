#!/usr/bin/env bash

main() {
    init

    tput civis # hide cursor

    echo -e "\e[2J"
    echo -e "\e[1;${FINISH}H \e[7mF I N I S H"
    echo -e "\e[2;$((FINISH+6))H\e[7m "

    echo -e "\e[32;$((FINISH+6))H\e[7m "
    echo -e "\e[33;${FINISH}H \e[7mF I N I S H\e[0m"
    while race; do
        echo -e "\e[2;0H"
        for ((i=0; i<${#distances[@]}; i++)) {
            render "$i" "${distances[i]}" "${frame1[@]}"
        }
        sleep "$PAUSE"
        update
        echo -e "\e[2;0H"
        for ((i=0; i<${#distances[@]}; i++)) {
            render "$i" "${distances[i]}" "${frame2[@]}"
        }
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
    
    FINISH=100
    MAX_SPEED=9
    PAUSE=0.1
    distances=("" "" "" "" "")
}

render() {
    nr="$1"
    local distance="$2"
    shift 2
    local arr=("$@")
    for ((line=0; line<"${#arr[@]}"; line++)); do
        if [ "$line" -ne 2 ]; then 
            echo "${distance}${arr[line]}"
        else
            echo "${distance}${arr[line]}" | tr 'N' "$((nr + 1))"
        fi
    done
}

update() {
    for ((i=0; i<${#distances[@]}; i++)); do
        move=$(( RANDOM % MAX_SPEED + 1 ))
        for ((j=0; j<"$move"; j++ )); do
            distances[i]+=" "
        done
    done
}

race() {
    for ((i=0; i<${#distances[@]}; i++)) {
        [ "${#distances[i]}" -ge $((FINISH - 19)) ] && return 1
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
