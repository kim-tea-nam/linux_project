#!/bin/bash

LIVES=3

update_lives_ui() {
    echo "-----------------------"
    echo "생명: $LIVES"
    echo "-----------------------"
}

reset_game() {
    LIVES=3  # 생명 초기화
    echo "게임을 다시 시작합니다!"
    update_lives_ui
}

run_game() {
    local game_script=$1
    echo "$(basename $game_script) 실행"
    
    if [[ -f "./games/$game_script" ]]; then
        bash ./games/$game_script
        local exit_code=$?
        if [[ $exit_code -ne 0 ]]; then
            LIVES=$((LIVES - 1))
            echo "하트 감소!"
        else
            echo "게임 성공!"
        fi
    else
        echo "Error: $game_script not found in ./games/"
        exit 1
    fi

    update_lives_ui

    if [[ $LIVES -le 0 ]]; then
        echo "-----------------------"
        echo "    죽었습니다. 😢"
        echo "-----------------------"
        while true; do
            echo "1. 다시 시작"
            echo "2. 종료"
            echo -n "선택: "
            read choice
            case $choice in
                1)
                    reset_game
                    return 0  # 처음부터 다시 실행
                    ;;
                2)
                    echo "게임을 종료합니다."
                    exit 1
                    ;;
                *)
                    echo "잘못된 입력입니다. 다시 선택해주세요."
                    ;;
            esac
        done
    fi
}

# 게임 시작 메시지
echo "======================="
echo "  게임을 시작합니다!   "
echo "======================="

update_lives_ui

games=("game1.sh" "game2-1.sh" "game2-2.sh" "game2-3.sh" "game3.sh" "game4.sh")

while true; do
    for game in "${games[@]}"; do
        run_game $game
        echo "엔터를 입력해주세요."
        read
    done

    echo "모든 스테이지 클리어!!!"
    echo "게임을 종료합니다."
    break
done
