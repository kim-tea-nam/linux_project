#!/bin/bash

# === 바둑판 초기화 === #
board_size=8
go_board=()
correct_row=6
correct_col=6

# 바둑판 데이터 초기화
for ((i = 0; i < board_size; i++)); do
  for ((j = 0; j < board_size; j++)); do
    if [[ ($i -eq 2 && $j -ge 5 && $j -le 7) || \
          ($i -eq 3 && $j -eq 5) || \
          ($i -eq 4 && $j -eq 5) || \
          ($i -eq 5 && $j -ge 2 && $j -le 5) || \
          ($i -eq 6 && $j -eq 2) || \
          ($i -eq 7 && ($j -eq 2 || $j -eq 7)) ]]; then
      go_board+=("●")  # 흑돌
    elif [[ ($i -eq 3 && $j -ge 6 && $j -le 7) || \
            ($i -eq 4 && $j -eq 6) || \
            ($i -eq 5 && ($j -ge 6 && $j -le 7)) || \
            ($i -eq 6 && ($j -ge 3 && $j -le 5)) || \
            ($i -eq 7 && ($j -eq 3 || $j -eq 5)) ]]; then
      go_board+=("○")  # 백돌
    else
      go_board+=(".")  # 빈칸
    fi
  done
done

# === 바둑판 출력 함수 === #
display_board() {
  clear
  echo "=== 바둑 묘수풀이 ==="
  echo "○: 백돌, ●: 흑돌, .: 빈칸"
  echo "   0 1 2 3 4 5 6 7"
  for ((i = 0; i < board_size; i++)); do
    printf "%d " $i
    for ((j = 0; j < board_size; j++)); do
      index=$((i * board_size + j))
      echo -n " ${go_board[$index]}"
    done
    echo
  done
}

# === 돌 놓기 함수 === #
place_stone() {
  local row=$1
  local col=$2
  local index=$((row * board_size + col))

  # 돌이 이미 놓인 자리인지 확인
  if [[ ${go_board[$index]} != "." ]]; then
    echo "이미 돌이 있는 자리입니다. 게임 종료."
    exit 1  # 실패 시 종료
  fi

  # 흑돌을 놓음
  go_board[$index]="●"

  # 정답 확인
  if [[ $row -eq $correct_row && $col -eq $correct_col ]]; then
    display_board
    echo "축하합니다! 정답입니다!"
    exit 0  # 성공 시 종료
  else
    echo "틀렸습니다! 게임 종료."
    exit 1  # 실패 시 종료
  fi
}

# === 메인 로직 === #
display_board
echo -n "돌을 놓을 위치 (행 열): "
read row col

# 입력값 유효성 검사
if [[ ! $row =~ ^[0-7]$ || ! $col =~ ^[0-7]$ ]]; then
  echo "잘못된 입력입니다. 행과 열은 0부터 7 사이의 숫자여야 합니다."
  exit 1  # 잘못된 입력으로 실패
fi

# 돌 놓기 시도
place_stone $row $col
