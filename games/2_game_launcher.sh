# 게임 런쳐 코드
#!/bin/bash

while true; do
  clear
  echo "==== 게임 카테고리 ===="
  echo "1. Five in a Row (오목)"
  echo "2. 미로 탐험"
  echo "3. 바둑 묘수풀이"
  echo "4. 종료"
  echo -n "게임을 선택하세요 (1-4): "
  read choice

  case $choice in
    1) bash 2_gomoku.sh ;;   # 오목 게임 실행
    2) bash 2_maze.sh ;;      # 미로 탐험 실행
    3) bash 2_go_puzzle.sh ;; # 바둑 묘수풀이 실행
    4) echo "게임을 종료합니다." ; exit ;;
    *) echo "잘못된 입력입니다. 다시 시도하세요." ;;
  esac
done
