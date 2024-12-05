#!/bin/bash

player_attack=5
player_position=0         # -1: 왼쪽, 0: 중앙, 1: 오른쪽
current_al_position=0     # 현재 알 위치
next_al_position=1        # 다음 알 위치
turns=1
has_preview_item=0        # 미리보기 아이템
current_al_attack=0         # 공격력, 타입 설정
next_al_attack=0
current_al_type=""
next_al_type=""
time_limit=15             # 제한시간 설정
time_left=$time_limit

# 게임 시작
start_game() {
    clear

    # 게임 시작 화면 출력
    while true; do
        clear
        echo "==============================="
        echo "1. 게임 시작"
        echo "2. 게임 방법"
        echo "==============================="
        echo "선택해주세요: "
        read choice

        case $choice in
            1)
                # 게임 시작
                clear
                echo "게임 시작! 잠시 후 알이 나타납니다..."
                sleep 2
                break
                ;;
            2)
                echo "게임 방법:"
                echo "1. 왼쪽(a) 또는 오른쪽(d)으로 말(▲)을 움직입니다."
                echo "2. 게임을 시작하면 랜덤 숫자가 써있는 알이 등장합니다."
                echo "3. 알을 선택(s)하면 알이 깨집니다. 알을 깨면 그 수가 +일지, -일지 알게 됩니다."
                echo "4. 알 안에는 어떤 것이 있을지 깨기 전까지는 알 수 없습니다. 깬 알에 따라서 플레이어의 공격력이 변화합니다."
                echo "5. 미리보기 아이템(♣) : 'p' 키를 누르면 공격력 200을 소모하는 대신, 다음 알의 숫자를 미리 확인할 수 있습니다."
                echo "6. 공격력이 증가할수록 선택 시간이 점점 줄어들어 난이도가 올라갑니다."
                echo "7. 당신의 공격력이 15,000 이상이 되면 방에서 탈출할 수 있습니다."
                echo "8. 반대로 당신보다 센 적을 마주쳐 공격력이 0보다 낮아지면 목숨을 1개 잃습니다."
                echo "게임을 시작하려면 엔터를 누르세요."
                read
                ;;
            *)
                echo "잘못된 입력입니다. 다시 선택해주세요."
                ;;
        esac
    done
}

# 말 이동
draw_player() {
    tput cup 10 0
    if [ $player_position -eq -1 ]; then
        echo "  ▲                      "
    elif [ $player_position -eq 0 ]; then
        echo "         ▲              "
    elif [ $player_position -eq 1 ]; then
        echo "                   ▲    "
    fi
}

draw_game() {
    clear
    echo "===================================="
    echo "플레이어 공격력: $player_attack  |  아이템 여부: $has_preview_item"
    echo "조작키: 왼쪽(a), 오른쪽(d), 알 깨기(s), 아이템 사용(p)"
    echo "===================================="

    if [ $turns -eq 1 ]; then
        sleep 1
        echo "당신은 빛이 있는 곳으로 걸어갑니다..."
        sleep 2
        echo "수상한 알이 등장했습니다!"
        sleep 1
    fi

    # 다음 알 출력
    if [ $next_al_position -eq -1 ]; then
        echo "  ____             "
        echo "/     \\            "
        echo "|   ?   |          "
        echo "\\__/            "
    elif [ $next_al_position -eq 0 ]; then
        echo "          ___     "
        echo "        /    \\    "
        echo "        |   ?   |  "
        echo "       \\___/    "
    else
        echo "                      ___"
        echo "                    /   \\"
        echo "                   |   ?   |    "
        echo "                   \\___/"
    fi

    # 현재 알 출력
    if [ $current_al_position -eq -1 ]; then
        echo "                    _____ "
        echo "                  /       \\"
        echo "                /          \\"
        echo "                |    $current_al_attack     |"
        echo "                \\        /"
        echo "                 \\_____/ "
    elif [ $current_al_position -eq 0 ]; then
        echo "          _____    "
        echo "        /       \\   "
        echo "      /           \\  "
        echo "      |    $current_al_attack     | "
        echo "       \\        /  "
        echo "        \\_____/   "
    else
        echo "                   _____ "
        echo "                 /       \\"
        echo "               /          \\"
        echo "               |    $current_al_attack     |"
        echo "               \\        /"
        echo "                \\_____/ "
    fi
    draw_player

    echo "==============================="

    # 남은 시간 표시
    echo "선택 제한 시간: $time_left 초 남음"
}

# 알 공격력 설정
set_current_al_attack() {
    # min_attack=$((player_attack - 5))
    # max_attack=$((player_attack + 9))
    # current_al_attack=$((RANDOM % (max_attack - min_attack + 1) + min_attack))
    # if [ $current_al_attack -lt 1 ]; then
    #    current_al_attack=1
    # fi
    
    if [ $turns -le 3 ]; then
        current_al_attack=$((RANDOM % 5 + 1))  # 1~5
    elif [ $turns -le 6 ]; then
        current_al_attack=$((RANDOM % 15 + 6))  # 6~20
    elif [ $turns -le 11 ]; then
        current_al_attack=$((RANDOM % 30 + 21))  # 21~50
    elif [ $turns -le 15 ]; then
        current_al_attack=$((RANDOM % 30 + 51))  # 51~80
    elif [ $turns -le 18 ]; then
        current_al_attack=$((RANDOM % 20 + 81))  # 81~100
    else
        current_al_attack=$((RANDOM % 1000 + player_attack - 30))  # ~1000, 30 오차
    fi
}

set_next_al_attack() {
    if [ $turns -le 3 ]; then
        next_al_attack=$((RANDOM % 5 + 1))  # 1~5
    elif [ $turns -le 6 ]; then
        next_al_attack=$((RANDOM % 15 + 6))  # 6~20
    elif [ $turns -le 11 ]; then
        next_al_attack=$((RANDOM % 30 + 21))  # 21~50
    elif [ $turns -le 15 ]; then
        next_al_attack=$((RANDOM % 30 + 51))  # 51~80
    elif [ $turns -le 18 ]; then
        next_al_attack=$((RANDOM % 20 + 81))  # 81~100
    else
        next_al_attack=$((RANDOM % 1000 + player_attack - 30))  # ~1000, 30 오차
    fi
}

# 알 종류 결정
set_current_al_type() {
    rand=$((RANDOM % 100))
    if [ $rand -lt 5 ]; then  # 0% ~ 5%: 미리보기 아이템 (5%)
        current_al_type="미리보기 아이템"
        has_preview_item=$((has_preview_item + 1))
    elif [ $rand -lt 50 ]; then  # 5% ~ 50%: 적 등장 (45%)
        current_al_type="적"
    elif [ $rand -lt 95 ]; then  # 50% ~ 95%: 무기 등장 (45%)
        current_al_type="무기"
    else  # 95% ~ 100%: 선물 등장 (5%)
        current_al_type="선물"
    fi
}

# 깨졌을 때
break_al() {
    clear
    echo "===================================="
    echo "알이 깨졌습니다!"
    case $current_al_type in
        "적")
            echo ""
            echo "  - $current_al_attack"
            echo "/\ /\ /\ /\"
            echo " \\   ※     /"
            echo "  \\_____/ "
            echo ""
            echo "알 안에서 $current_al_type 이 나타났습니다! $current_al_attack 만큼 공격력을 잃습니다."
            player_attack=$((player_attack - current_al_attack))
            sleep 2
            ;;

        "무기")
            echo ""
            echo "  + $current_al_attack"
            echo "/\ /\ /\ /\"
            echo " \\   †      /"
            echo "  \\_____/ "
            echo ""
            echo "알 안에서 $current_al_type 이 나타났습니다! $current_al_attack 만큼 공격력을 증가합니다."
            player_attack=$((player_attack + current_al_attack))
            sleep 2
            ;;

        "선물")
            echo ""
            echo "  ☆ *1.5 ☆"
            echo "/\ /\ /\ /\"
            echo " \\   ☆    /"
            echo "  \\_____/ "
            echo ""
            echo "알 안에 $current_al_type 이 있습니다! 공격력이 1.5배로 증가합니다."
            player_attack=$((player_attack * 3 / 2))
            sleep 2
            ;;

        "미리보기 아이템")
            echo ""
            echo "   ♣ ♣ ♣"
            echo "/\ /\ /\ /\"
            echo " \\   ♣    /"
            echo "  \\_____/ "
            echo ""
            echo "알 안에 $current_al_type 이 있습니다! 'p'를 눌러 사용할 수 있습니다."
            has_preview_item=$((has_preview_item + 1))
            sleep 2
            ;;
    esac

    check_game_status
}  

# 게임 턴 처리
play_turn() {
    set_current_al_attack
    set_current_al_type
    set_next_al_attack

    # 다음 알 설정
    if [ $rand -lt 5 ]; then
        next_al_type="미리보기 아이템"
    elif [ $rand -lt 50 ]; then
        next_al_type="적"
    elif [ $rand -lt 95 ]; then
        next_al_type="무기"
    else
        next_al_type="선물"
    fi

    # 게임 화면 출력
    draw_game

    echo "선택 시간: $time_limit 초"
    echo "(a: 왼쪽 이동, d: 오른쪽 이동, s: 알 깨기, q: 종료)"

    # 제한 시간 안에 입력 처리
    local start_time=$(date +%s)
    while true; do
        # 남은 시간 계산
        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))
        time_left=$((time_limit - elapsed_time))

        if [ $time_left -le 0 ]; then
            echo "시간 초과! 다음 턴으로 넘어갑니다."
            break
        fi

        # 입력 처리
        read -t $time_limit -n 1 move
        if [ $? -eq 0 ]; then
           case $move in
              "a")  # 왼쪽 이동
                  if [ $player_position -gt -1 ]; then
                      player_position=$((player_position - 1))
                  fi
                  ;;
              "d")  # 오른쪽 이동
                  if [ $player_position -lt 1 ]; then
                      player_position=$((player_position + 1))
                  fi
                  ;;
              "s")  # 알 깨기
                  if [ $player_position -eq $current_al_position ]; then
                      break_al
                      return
                  elif [ $player_position -eq $next_al_position ]; then
                      echo "현재 알을 스킵하고 다음 알로 넘어갑니다!"
                      sleep 1
                      current_al_position=$next_al_position
                      current_al_attack=$next_al_attack
                      current_al_type=$next_al_type
                      next_al_position=$((RANDOM % 3 - 1))
                      set_next_al_attack
                      draw_game
                      return
                  else
                      echo "플레이어 위치와 알이 맞지 않습니다!"
                      sleep 1
                      draw_game
                  fi
                  ;;
                "p")  # 미리보기 아이템 사용
                    if [ $has_preview_item -gt 0 ]; then
                        echo "미리보기 아이템을 사용합니다!"
                        echo "다음 알의 정보:"
                        echo "공격력: $next_al_attack | 종류: $next_al_type"
                        has_preview_item=$((has_preview_item - 1))
                        sleep 2
                        draw_game
                   elif [ $player_attack -ge 200 ]; then
                        echo "공격력 200을 소모하여, 미리보기 기능을 사용합니다!"
                        player_attack=$((player_attack - 200))
                        echo "다음 알의 정보:"
                        echo "공격력: $next_al_attack | 종류: $next_al_type"
                        sleep 2
                        draw_game
                    else
                        echo "미리보기 아이템이 없습니다! 알에서 발견한 후에 사용하세요."
                        echo "공격력이 부족합니다! 아이템을 사용하기 위해 필요한 공격력: 200"
                        sleep 1
                        draw_game
                    fi
                    ;;
              *)  # 잘못된 입력
                  echo "잘못된 입력입니다!"
                  ;;
            esac
          fi
          time_left=$((time_left - 1))
          turns=$((turns + 1))
      done

    # 다음 턴 준비
    current_al_position=$next_al_position
    next_al_position=$((RANDOM % 3 - 1))  # -1, 0, 1 위치 중 랜덤
    time_left=$time_limit  # 제한 시간 리셋

    # 난이도 조정
    if [ $player_attack -ge 2500 ]; then
        time_limit=11
    fi
    if [ $player_attack -ge 4500 ]; then
        time_limit=7
    fi
    if [ $player_attack -ge 5500 ]; then
        time_limit=5
    fi

    check_game_status    
}

# 게임 종료 조건 확인
check_game_status() {
    if [ $player_attack -ge 15000 ]; then
        echo "축하합니다. 모든 적을 물리쳤습니다! 다음 방으로 가는 문이 열렸습니다."
        exit 0
    elif [ $player_attack -le 0 ]; then
        echo "게임 종료! 당신의 공격력이 0으로 떨어졌습니다."
        exit 1
    fi
}

# 게임 시작 루프
start_game
while true; do
    play_turn
done