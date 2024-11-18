#!/bin/bash

# 게임 초기화 및 랜덤 숫자 생성
initialize_game() {
    secret_number=($(shuf -i 0-9 -n 3))
    attempts=0
    user_inputs=()
    results=()  # 각 입력에 대한 결과를 저장할 배열
    echo -e "\n⚾ 숫자 야구 게임을 시작합니다! ⚾"
    echo "컴퓨터가 0에서 9 사이의 서로 다른 세 숫자를 골랐습니다."
    echo "게임의 룰:"
    echo "1. 숫자 3자리를 맞추세요. (0부터 9까지 서로 다른 숫자)"
    echo "2. 스트라이크는 자리가 정확한 맞힌 숫자입니다."
    echo "3. 볼은 숫자는 맞았으나 자리가 틀린 숫자입니다."
    echo "4. 기회는 12번입니다!"
    echo "게임을 종료하려면 'exit'를 입력하세요."
}

# 사용자 입력 처리
get_user_input() {
    while true; do
        echo -n "세 자리 숫자를 입력하세요 (연속된 숫자: 123 또는 공백 구분: 1 2 3): "
        read input

        # 게임 종료 명령 처리
        if [[ "$input" == "exit" ]]; then
            echo "게임을 종료합니다. 감사합니다! ⚾"
            exit 0
        fi

        # 입력값 포맷 변환 (공백 구분 -> 연속된 숫자로 변환)
        formatted_input=$(echo "$input" | tr -d ' ')

        # 입력값 유효성 검사
        if [[ ! "$formatted_input" =~ ^[0-9]{3}$ ]]; then
            echo "❌ 유효하지 않은 입력입니다. 세 자리 숫자를 입력하세요."
        elif [[ $(echo "$formatted_input" | grep -o . | sort | uniq -d | wc -l) -gt 0 ]]; then
            echo "❌ 숫자가 중복됩니다. 각 숫자는 달라야 합니다."
        else
            # 입력이 올바르면 루프 종료
            user_guess=($(echo "$formatted_input" | grep -o .))
            user_inputs+=("$input")  # 입력값 기록 (원래 형식 유지)
            break
        fi
    done
}

# 결과 계산 (스트라이크와 볼 판정)
check_result() {
    strikes=0
    balls=0

    for i in {0..2}; do
        if [[ "${user_guess[$i]}" -eq "${secret_number[$i]}" ]]; then
            ((strikes++))
        elif [[ " ${secret_number[@]} " =~ " ${user_guess[$i]} " ]]; then
            ((balls++))
        fi
    done

    attempts=$((attempts + 1))

    if [[ $strikes -eq 0 && $balls -eq 0 ]]; then
        results+=("OUT")
        echo -e "결과: 🔴 OUT"
    elif [[ $strikes -eq 3 ]]; then
        results+=("Homerun")
        echo -e "🎉 결과: Homerun! 정답(${secret_number[@]})을 맞췄습니다! 🎉 시도 횟수: ${attempts}번"
        echo -n "게임을 종료하시겠습니까? (y/n): "
        read exit_choice
        if [[ "$exit_choice" == "y" || "$exit_choice" == "Y" ]]; then
            echo "게임을 종료합니다. 감사합니다! ⚾"
            exit 0
        fi
    else
        results+=("${strikes} Strike, ${balls} Ball")
        echo -e "결과: ${strikes} Strike, ${balls} Ball"
    fi
}

# 이전 입력값 및 결과 표시
display_previous_inputs() {
    echo -e "\n📜 이전 입력 기록:"
    for i in "${!user_inputs[@]}"; do
        echo -e "  $((i + 1))번째 입력: ${user_inputs[$i]} - 결과: ${results[$i]}"
    done
    echo -e "-----------------------------------"
}

# 게임 메인 루프
play_game() {
    initialize_game

    while true; do
        display_previous_inputs
        get_user_input
        check_result

        # 12번 기회 초과 시 패배 처리
        if [[ $attempts -ge 12 ]]; then
            echo "💥 패배하셨습니다! 12번의 기회를 초과했습니다. 정답은 ${secret_number[@]}였습니다. 💥"
            echo -n "게임을 종료하시겠습니까? (y/n): "
            read exit_choice
            if [[ "$exit_choice" == "y" || "$exit_choice" == "Y" ]]; then
                echo "게임을 종료합니다. 감사합니다! ⚾"
                exit 0
            fi
        fi
    done
}

# 프로그램 시작
play_game

