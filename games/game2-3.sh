#!/bin/bash

# === 오목 게임 === #
board_size=15
gomoku_board=()
for ((i=0; i < board_size; i++)); do
  for ((j=0; j < board_size; j++)); do
    gomoku_board+=(".")
  done
done

gomoku_display_board() {
  clear
  echo "   $(seq -s " " 0 $((board_size - 1)))"
  for ((i=0; i < board_size; i++)); do
    printf "%2d " $i
    for ((j=0; j < board_size; j++)); do
      echo -n "${gomoku_board[$((i * board_size + j))]} "
    done
    echo
  done
}

check_win() {
  local symbol=$1
  for ((i=0; i < board_size; i++)); do
    for ((j=0; j < board_size; j++)); do
      if [[ $((j + 4)) -lt $board_size ]]; then
        local win=1
        for ((k=0; k < 5; k++)); do
          if [[ ${gomoku_board[$((i * board_size + j + k))]} != "$symbol" ]]; then
            win=0
            break
          fi
        done
        [[ $win -eq 1 ]] && return 0
      fi
      if [[ $((i + 4)) -lt $board_size ]]; then
        local win=1
        for ((k=0; k < 5; k++)); do
          if [[ ${gomoku_board[$(((i + k) * board_size + j))]} != "$symbol" ]]; then
            win=0
            break
          fi
        done
        [[ $win -eq 1 ]] && return 0
      fi
      if [[ $((i + 4)) -lt $board_size && $((j + 4)) -lt $board_size ]]; then
        local win=1
        for ((k=0; k < 5; k++)); do
          if [[ ${gomoku_board[$(((i + k) * board_size + j + k))]} != "$symbol" ]]; then
            win=0
            break
          fi
        done
        [[ $win -eq 1 ]] && return 0
      fi
      if [[ $((i + 4)) -lt $board_size && $((j - 4)) -ge 0 ]]; then
        local win=1
        for ((k=0; k < 5; k++)); do
          if [[ ${gomoku_board[$(((i + k) * board_size + j - k))]} != "$symbol" ]]; then
            win=0
            break
          fi
        done
        [[ $win -eq 1 ]] && return 0
      fi
    done
  done
  return 1
}

play_gomoku() {
  local turn="X"
  local max_turns=30    # 최대 턴 수
  local current_turn=0  # 현재 턴 수

  while true; do
    gomoku_display_board
    echo "현재 턴: $turn, 남은 턴: $((max_turns - current_turn))"
    echo -n "위치 입력 (행 열): "
    read row col

    # 입력 유효성 검사
    if [[ $row -lt 0 || $row -ge $board_size || $col -lt 0 || $col -ge $board_size ]]; then
      echo "잘못된 입력입니다. 바둑판 밖의 위치입니다."
      exit 1  # 바둑판 밖 입력으로 생명 감소
    fi

    if [[ ${gomoku_board[$((row * board_size + col))]} != "." ]]; then
      echo "이미 돌이 놓인 곳입니다. 다른 위치를 선택하세요."
      exit 1  # 중복 위치 입력으로 생명 감소
    fi

    gomoku_board[$((row * board_size + col))]=$turn
    current_turn=$((current_turn + 1))

    # 승리 조건 확인
    if check_win "$turn"; then
      gomoku_display_board
      echo "축하합니다! $turn 승리!"
      exit 0  # 성공 시 exit 0
    fi

    # 실패 조건 확인
    if [[ $current_turn -ge $max_turns ]]; then
      echo "제한된 턴 수를 초과했습니다. 게임 실패!"
      exit 1  # 턴 초과로 실패
    fi

    # 턴 교체
    turn=$([[ $turn == "X" ]] && echo "O" || echo "X")
  done
}

# 실행
play_gomoku
