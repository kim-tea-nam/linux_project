#!/bin/bash

# === 바둑 묘수풀이 === #

# 바둑판 출력 함수
go_display_board() {
  clear
  echo "=== 바둑 묘수풀이 ==="
  echo "○: 백돌, ●: 흑돌, .: 빈칸"
  echo "8x8 바둑판입니다. 흑이 정확한 위치에 돌을 두어 백을 잡으세요."
  echo "   0 1 2 3 4 5 6 7"
  for ((i=0; i < board_size; i++)); do
    printf "%d " $i
    for ((j=0; j < board_size; j++)); do
      index=$((i * board_size + j))
      echo -n " ${go_board[$index]}"
    done
    echo
  done
}

# 돌 놓기 함수
place_stone() {
  local row=$1
  local col=$2
  local index=$((row * board_size + col))

  if [[ ${go_board[$index]} != "." ]]; then
    echo "이미 돌이 있는 자리입니다. 다른 위치를 선택하세요!"
    return 1
  fi

  go_board[$index]="●"  # 흑돌을 놓습니다.

  # 정답 확인
  if [[ $row -eq $correct_row && $col -eq $correct_col ]]; then
    go_display_board
    echo "축하합니다! 정답입니다! 백돌을 모두 잡았습니다."
    exit 0  # 성공적으로 게임 완료
  else
    echo "틀렸습니다! 다시 시도하세요!"
    return 1
  fi
}

# 바둑판 설정
board_size=8
go_board=()
for ((i=0; i < board_size; i++)); do
  for ((j=0; j < board_size; j++)); do
    if [[ ($i -eq 2 && $j -ge 5 && $j -le 7) || \
          ($i -eq 3 && $j -eq 5) || \
          ($i -eq 4 && $j -eq 5) || \
          ($i -eq 5 && $j -ge 2 && $j -le 5) || \
          ($i -eq 6 && $j -eq 2) || \
          ($i -eq 7 && ($j -eq 2 || $j -eq 7)) ]]; then
      go_board+=("●")
    elif [[ ($i -eq 3 && $j -ge 6 && $j -le 7) || \
            ($i -eq 4 && $j -eq 6) || \
            ($i -eq 5 && ($j -ge 6 && $j -le 7)) || \
            ($i -eq 6 && ($j -ge 3 && $j -le 5)) || \
            ($i -eq 7 && ($j -eq 3 || $j -eq 5)) ]]; then
      go_board+=("○")
    else
      go_board+=(".")
    fi
  done
done

# 실행 함수
play_go() {
  while true; do
    go_display_board
    echo -n "돌을 놓을 위치 (행 열): "
    read row col
    if [[ $row -ge 0 && $row -lt $board_size && $col -ge 0 && $col -lt $board_size ]]; then
      if ! place_stone $row $col; then
        echo "잘못된 돌 위치입니다."
      fi
    else
      echo "잘못된 입력입니다. 0부터 7 사이의 숫자를 입력하세요."
    fi
    echo "정답을 입력하지 못했습니다. 생명이 하나 깎입니다!"
    exit 1  # 생명 감소
  done
}

# 정답 위치
correct_row=6
correct_col=6

# 실행
play_go
