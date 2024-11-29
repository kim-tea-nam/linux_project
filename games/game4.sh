#!/bin/bash

player_attack=5
lives=1
player_name=""
player_position=0   # 0: 중앙, -1: 왼쪽, 1: 오른쪽
turns=1  # 게임 턴 수

# 초기 설정
clear
echo "게임을 시작하려면 이름을 입력해주세요: "
read player_name

# 게임 시작 화면 출력
clear
echo "==============================="
echo "     게임 시작 - $player_name     "
echo "==============================="
echo "1. 게임 시작"
echo "2. 게임 방법"
echo "==============================="
echo "선택해주세요: "
read choice

if [ "$choice" -eq 1 ]; then
    # 게임 시작
    clear
    echo "게임 시작! 잠시 후 알이 나타납니다..."
    sleep 2
elif [ "$choice" -eq 2 ]; then
    echo "게임 방법:"
    echo "1. 왼쪽(a) 또는 오른쪽(d)으로 말(▲)을 움직입니다."
    echo "2. 게임을 시작하면 랜덤 숫자가 써있는 알이 등장합니다."
    echo "3. 알을 선택(s)하면 알이 깨집니다. 알을 깨면 그 수가 +일지, -일지 알게 됩니다."
    echo "4. 깬 알에 따라서 플레이어의 공격력이 변화합니다."
    echo "5. 공격력이 증가할수록 선택 시간이 점점 줄어들어 난이도가 올라갑니다. "
    echo "6. 공격력이 25,000 이상이 되면 방에서 탈출할 수 있습니다."
    echo "7. 반대로 공격력이 0보다 낮아지면 목숨을 1개 잃습니다."
    echo "게임을 시작하려면 엔터를 누르세요."
    read
fi

# 초기 플레이어 화면 출력
clear
while true; do
    clear
    echo "================================"
    echo "플레이어: $player_name  |  공격력: $player_attack  |  목숨: $lives"
    echo "================================"
    if [ $player_position -eq 0 ]; then
        echo "          ▲"
    elif [ $player_position -eq -1 ]; then
        echo "     ▲"
    elif [ $player_position -eq 1 ]; then
        echo "          ▲"
    fi
    echo "          $player_name"
    echo "==============================="
    
    # 알 등장
    sleep 2
    echo "알이 등장했습니다!"
    sleep 1
    
    # 턴 수에 따른 알 공격력 설정
    if [ $turns -le 3 ]; then
        al_attack=$((RANDOM % 6))  # 0~5
    elif [ $turns -le 6 ]; then
        al_attack=$((RANDOM % 15 + 6))  # 6~20
    elif [ $turns -le 10 ]; then
        al_attack=$((RANDOM % 30 + 21))  # 21~50
    elif [ $turns -le 13 ]; then
        al_attack=$((RANDOM % 30 + 51))  # 51~80
    elif [ $turns -le 18 ]; then
        al_attack=$((RANDOM % 20 + 81))  # 81~100
    else
        al_attack=$((RANDOM % 1000 + player_attack - 30))  # ~1000, 30 오차
    fi
    
    # 알의 종류 결정
    rand=$((RANDOM % 100))
    if [ $rand -lt 45 ]; then
        echo "알 안에서 적이 나타났습니다! 공격력을 잃습니다."
        sign="-"
        player_attack=$((player_attack - al_attack))
    elif [ $rand -lt 80 ]; then
        echo "알 안에 무기가 있습니다! 공격력이 증가합니다."
        sign="+"
        player_attack=$((player_attack + al_attack))
    else
        echo "알 안에 선물이 있습니다! 공격력이 1.5배로 증가합니다."
        sign="*"
        player_attack=$((player_attack * 3 / 2))
    fi
    

    al_shape=$((RANDOM % 2))  # 0 또는 1로 랜덤 선택
    
    if [ $al_shape -eq 0 ]; then
        # 첫 번째 모양 (큰 알)
        echo "   _____   "
        echo "  /     \\  "
        echo " /       \\ "
        echo "|  $sign$al_attack  |"
        echo " \\       / "
        echo "  \\_____/  "
    else
        # 두 번째 모양 (작은 알)
        echo "  ___  "
        echo " /   \\ "
        echo "| $sign$al_attack |"
        echo " \\___/ "
    fi
    
    # 플레이어 공격력
    echo "현재 공격력: $player_attack"
    sleep 3

    # 선택 제한시간 시작
    limit_time=10
    if [ $player_attack -ge 2500 ]; then
        limit_time=7
    fi
    if [ $player_attack -ge 4500 ]; then
        limit_time=5
    fi
    if [ $player_attack -ge 5500 ]; then
        limit_time=3
    fi

    echo "선택 시간: $limit_time 초"

    # a, d, s 입력 받기
    read -t $limit_time -n 1 move
    if [[ $move == "a" ]]; then
        player_position=-1
        echo "왼쪽으로 이동합니다!"
    elif [[ $move == "d" ]]; then
        player_position=1
        echo "오른쪽으로 이동합니다!"
    elif [[ $move == "s" ]]; then
        echo "알을 깨기로 선택했습니다!"

        # + 또는 -를 랜덤으로 결정 (확률 65%: +, 35%: -)
        rand2=$((RANDOM % 100))
        if [ $rand2 -lt 65 ]; then
            echo "알을 깨니 +${al_attack}이 나왔습니다!"
            echo "     /<         >\\"
            echo "    | < +$sign$al_attack >|"
            echo "     |<   >|"
            echo "      \\<___>/"
            player_attack=$((player_attack + al_attack))
        else
            echo "알을 깨니 -${al_attack}이 나왔습니다!"
            echo "     /<         >\\"
            echo "    | < -$sign$al_attack >|"
            echo "     |<   >|"
            echo "      \\<___>/"
            player_attack=$((player_attack - al_attack))
        fi
    fi

    # 게임 종료
    if [ $player_attack -ge 25000 ]; then
        echo "축하합니다! 모든 적을 물리쳤습니다. 당신은 방에서 탈출할 수 있습니다!"
	exit 0
        break
    fi

    if [ $player_attack -le 0 ]; then
        echo "게임 종료! 공격력이 0이 되었습니다."
	exit 1
        break
    fi

    # 턴 수 증가
    turns=$((turns + 1))
done
