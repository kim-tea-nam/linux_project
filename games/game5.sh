#!/bin/bash

draw_cups() {
    local positions=("$@")
    echo "   ${positions[0]}        ${positions[1]}        ${positions[2]}        ${positions[3]}        ${positions[4]}"
    echo "  ____      ____      ____      ____      ____"
    echo " || || ||    | / / |    |( (  (|    |  #  |    |     |"
    echo " || || ||    |/ / /|    |( ( ( |    |  #  |    | ♥ |"
    echo " |____|    |/_/_|    |(__(_|    |_#__|    |____|"
}

shuffle_cups() {
    local -n cups_ref=$1
    local iterations=$2

    for ((i = 1; i <= iterations; i++)); do
        clear
        cups_ref=($(shuf -e "${cups_ref[@]}"))
        draw_cups "${cups_ref[@]}"
        sleep 0.5
    done
}

double_reward() {
    if $bonus_double; then
        bonus_double=false
        echo "다음 보상은 2배로 적용됩니다!"
        case $reward in
            "+1")
                lives=$((lives + 2))
                echo "컵 안에 치료제가 2개 들어있습니다. 목숨이 2개 회복되었습니다!"
                ;;
            "+3")
                lives=3
                echo "echo "컵 안에서 밝은 빛이 나옵니다. 목숨이 전부 회복되었습니다!"
                ;;
            "-1")
                lives=0
                echo "컵을 들자 방의 문이 잠겼습니다. 목숨을 잃었습니다."
                exit 1
                ;;
        esac
    fi
}

bonus_game() {
    echo "== = = = 보 너 스 스 테 이 지 = = = =="
    sleep 1

    # 컵과 리워드 설정
    cups=("A" "B" "C" "D" "E")
    rewards=("+1" "-1" "+0" "+3" "x2")  # x2는 다음 보너스 보상 2배

    # 랜덤 보너스 배치
    reward_index=$((RANDOM % 5))
    correct_cup=${cups[$reward_index]}

    echo "컵을 섞습니다..."
    echo ""
    sleep 2

    # 섞기 애니메이션 호출
    shuffle_cups cups 5  # 5번 섞음

    # 최종 배치 출력
    clear
    echo "최종 컵 배치:"
    draw_cups "${cups[@]}"
    echo
    echo "컵을 선택하세요 (A, B, C, D, E):"
    echo "(10초 내로 선택하지 않으면 아무것도 얻지 못합니다.)"
    echo "(목숨을 회복할 수도, 잃을 수도 있습니다.)"

    # 제한시간 설정
    read -t 10 -r choice
    if [[ -z $choice ]]; then
        echo "시간 초과! 아무것도 얻지 못했습니다."
        sleep 2
        return
    fi

    # 선택 확인
    if [[ $choice == "$correct_cup" ]]; then
        reward=${rewards[$reward_index]}
        echo "축하합니다! 선택한 컵에 ${reward} 보상이 있습니다."

        case $reward in
            "+1")
                lives=$((lives + 1))
                echo "컵 안에 치료제가 들어있습니다. 목숨이 1개 회복되었습니다!"
                ;;
            "-1")
                lives=0  # 즉시 종료
                echo "컵을 들자 방의 문이 잠겼습니다. 목숨을 잃었습니다."
                exit 1
                ;;
            "+0")
                echo "아무것도 들어있지 않습니다. 보너스 게임 종료! 다시 기존 방으로 돌아갑니다."
                exit 0
                ;;
            "+3")
                lives=3  # 목숨 전부 회복
                echo "컵 안에서 밝은 빛이 나옵니다. 목숨이 전부 회복되었습니다!"
                ;;
            "x2")
                echo "다음 보너스 게임 보상 2배 획득! 다시 보너스 게임을 시작합니다."
                bonus_double = true
                bonus_game  # 보너스 게임 다시 실행
                ;;
        esac
    fi

    sleep 2
    clear
}
