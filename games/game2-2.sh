#!/bin/bash

# === 미로 탐험 === #
maze=(
  "###############"
  "#S..........#.#"
  "#.#####.#####.#"
  "#...........#.#"
  "#####.#####.#.#"
  "#...K.......#.#"
  "###.#########.#"
  "#.............#"
  "#.###########.#"
  "#.#.......#...#"
  "#.#.#####.#.###"
  "#.#.#.....#...#"
  "#.#.#####.#####"
  "#.............E"
  "###############"
)

player_row=1
player_col=1
exit_row=13
exit_col=13
key_row=5
key_col=4
has_key=0
last_move_invalid=0

# 미로 출력 함수
display_maze() {
  clear
  echo "==================== 미로 탐험 ===================="
  echo "기호 안내:"
  echo "S: 시작점, E: 출구, K: 열쇠, .: 빈 공간, #: 벽"
  echo "열쇠를 획득해야 출구로 나갈 수 있습니다!"
  echo "==================================================="
  echo
  for ((i = 0; i < ${#maze[@]}; i++)); do
    row="${maze[$i]}"
    for ((j = 0; j < ${#row}; j++)); do
      if [[ $i -eq $player_row && $j -eq $player_col ]]; then
        echo -n "P"
      else
        echo -n "${row:$j:1}"
      fi
    done
    echo
  done
}

# 플레이어 이동 함수
move_player() {
  new_row=$player_row
  new_col=$player_col

  case $1 in
    w) ((new_row--)) ;;
    s) ((new_row++)) ;;
    a) ((new_col--)) ;;
    d) ((new_col++)) ;;
    *) echo "잘못된 입력입니다!" && return ;;
  esac

  local target=${maze[$new_row]:$new_col:1}
  if [[ $target == "#" ]]; then
    echo "벽에 막혀 이동할 수 없습니다!"
    if [[ $last_move_invalid -eq 1 ]]; then
      echo "벽 방향으로 다시 이동하려 했습니다. 생명력 감소!"
      exit 1  # 생명 감소 (벽에 부딪힘으로 게임 계속 진행)
    fi
    last_move_invalid=1
    return
  fi

  last_move_invalid=0

  if [[ $target == "K" ]]; then
    has_key=1
    echo "열쇠를 획득했습니다!"
  fi

  if [[ $new_row -eq $exit_row && $new_col -eq $exit_col ]]; then
    if [[ $has_key -eq 1 ]]; then
      echo "축하합니다! 미로를 탈출했습니다!"
      exit 0  # 성공적으로 탈출 후 다음 게임으로 진행
    else
      echo "출구를 열려면 열쇠가 필요합니다!"
      return
    fi
  fi

  player_row=$new_row
  player_col=$new_col
}

# 미로 탐험 실행 함수
play_maze() {
  while true; do
    display_maze
    echo "움직이세요: w(위), a(왼쪽), s(아래), d(오른쪽)"
    read -n 1 move
    echo
    move_player $move
  done
}

# 게임 실행
play_maze
