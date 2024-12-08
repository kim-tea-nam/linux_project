LIVES=3

update_lives_ui() {
    echo "-----------------------"
    echo "생명: $LIVES"
    echo "-----------------------"
}

run_game() {
    local game_script=$1
    echo "$(basename $game_script) 실행"
    
    # 게임 스크립트 실행
    if [[ -f "./games/$game_script" ]]; then
        bash ./games/$game_script
        local exit_code=$?  # 종료 코드 저장
        if [[ $exit_code -ne 0 ]]; then
            LIVES=$((LIVES - 1))  # 생명 감소
            echo "하트 감소!"
        else
            echo "게임 성공!"
        fi
    else
        echo "Error: $game_script not found in ./games/"
        exit 1
    fi

    # UI 업데이트
    update_lives_ui

    # 생명이 0이면 게임 종료
    if [[ $LIVES -le 0 ]]; then
        echo "게임오버!!"
        exit 1
    fi
}

update_lives_ui

games=("game1.sh" "game2-1.sh" "game2-2.sh" "game2-3.sh" "game3.sh" "game4.sh" "game5.sh")
for game in "${games[@]}"; do
    run_game $game
    echo "엔터를 입력해주세요."
    read
done

echo "모든 스테이지 클리어!!!"
