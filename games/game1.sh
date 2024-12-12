#!/bin/bash

# 게임 초기화 및 랜덤 숫자 생성
initialize_game() {
    secret_number=($(shuf -i 0-9 -n 3))
    attempts=0
    user_inputs=()
    results=()  # 각 입력에 대한 결과를 저장할 배열

    # 아스키아트 헤더
    echo -e "\n"
    echo "██████╗  █████╗ ███████╗███████╗██████╗  █████╗ ██╗     ██╗       "
    echo "██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔══██╗██║     ██║       "
    echo "██████╔╝███████║███████╗█████╗  ██████╔╝███████║██║     ██║       "
    echo "██╔══██╗██╔══██║╚════██║██╔══╝  ██╔══██╗██╔══██║██║     ██║       "
    echo "██████═╝██║  ██║███████║███████╗██████═╝██║  ██║███████╗███████╗  "
    
    echo -e "⚾ 숫자 야구 게임에 오신 것을 환영합니다! ⚾\n"

    echo "게임의 룰:"
    echo -e "1. 숫자3자리를맞추세요. (0부터 9까지 서로 다른 숫자)"
    echo -e "2. 스트라이크는 자리를 정확히 맞춘 숫자입니다."
    echo -e "3. 볼은 숫자는 맞았으나 자리가 틀린 숫자입니다."
    echo -e "4. 기회는 12번입니다!"
}

# 사용자 입력 처리
get_user_input() {
    while true; do
        echo -n "⚾ 세 자리 숫자를 입력하세요 (예: 123): "
        read input
        formatted_input=$(echo "$input" | tr -d ' ')  # 입력값에서 공백 제거

        # 게임 종료 명령 처리
        if [[ "$formatted_input" == "exit" ]]; then
            echo -e "🎮 게임을 종료합니다. 즐거운 시간 되세요! ⚾"
            exit 0
        fi

        # 입력값 유효성 검사
        if [[ ! "$formatted_input" =~ ^[0-9]{3}$ ]]; then
            echo -e "❌ 잘못된 입력입니다. 세 자리 숫자를 입력하세요."
        elif [[ $(echo "$formatted_input" | grep -o . | sort | uniq -d | wc -l) -gt 0 ]]; then
            echo -e "❌ 중복된 숫자가 있습니다. 각 숫자는 달라야 합니다."
        else
            # 입력이 올바르면 루프 종료
            user_guess=($(echo "$formatted_input" | grep -o .))
            user_inputs+=("$formatted_input")  # 입력값 기록
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
        echo -e "⚾ 결과: 🔴 아웃!"
    elif [[ $strikes -eq 3 ]]; then
        results+=("Homerun")
        echo -e "🎉 결과: 홈런! 정답(${secret_number[@]})을 맞추셨습니다! 🎉 시도 횟수: ${attempts}번"
        exit 0  # 성공 시 종료 코드 0 반환
    else
        results+=("${strikes} 스트라이크, ${balls} 볼")
        echo -e "⚾ 결과: ${strikes} 스트라이크, ${balls} 볼"
    fi
}

# 이전 입력값 및 결과 표시
display_previous_inputs() {
    echo -e "\n===================== 이전 입력 기록 ====================="
    for i in "${!user_inputs[@]}"; do
        echo -e "  $((i + 1))번째 입력: ${user_inputs[$i]} - 결과: ${results[$i]}"
    done
    echo -e "=========================================================="
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
            echo -e "💥 패배하셨습니다! 12번의 기회를 초과했습니다. 정답은 ${secret_number[@]}였습니다. 💥"
            exit 1  # 패배 시 종료 코드 1 반환
        fi
    done
}

# 프로그램 시작
play_game

