#!/bin/bash

# 랜덤 코딩 관련 단어 설정
words=("algorithm" "compiler" "debugging" "function" "variable" "iteration" "syntax" "parameter" "array" "class")

# 행맨 그림 (완전한 그림에서 시작해서 틀린 횟수에 따라 변함)
hangman=(  
  "-----"
  "|   |"
  "|   O"
  "|  /|\\"
  "|  / \\"
  "|"
  "-----"
)

# 행맨 그림을 점차적으로 사라지게 하기 위한 상태들
hangman_parts=("  |   O" "  |  /|\\" "  |  / \\" "  |  " "  |  " "-----")

# 단어별 힌트 설정 (각 단어마다 다르게 설정)
declare -A hints
hints["algorithm"]="힌트 1: 문제 해결을 위한 단계적인 절차. 힌트 2: 주로 코드나 프로그램을 작성할 때 사용되는 개념. 힌트 3: 컴퓨터 과학의 기본 개념 중 하나."
hints["compiler"]="힌트 1: 소스 코드를 기계어로 변환하는 프로그램. 힌트 2: 프로그래밍 언어를 실행 가능하게 만드는 도구. 힌트 3: 컴파일을 통해 코드가 실행될 수 있도록 만든다."
hints["debugging"]="힌트 1: 코드에서 오류를 찾고 수정하는 과정. 힌트 2: 프로그램의 버그를 해결하는 작업. 힌트 3: 에러를 추적하고 문제를 해결하는 중요한 과정."
hints["function"]="힌트 1: 특정 작업을 수행하는 코드의 블록. 힌트 2: 입력을 받아 출력을 반환하는 코드의 모듈. 힌트 3: 다른 프로그램에서 재사용이 가능한 독립적인 코드."
hints["variable"]="힌트 1: 값을 저장하는 공간. 힌트 2: 프로그램에서 값의 저장과 변경을 가능하게 하는 요소. 힌트 3: 프로그래밍에서 데이터를 임시로 저장하는 장소."
hints["iteration"]="힌트 1: 반복적으로 수행되는 과정. 힌트 2: 특정 작업을 여러 번 반복하는 개념. 힌트 3: 루프와 관련된 개념으로, 주로 반복문에서 사용."
hints["syntax"]="힌트 1: 프로그래밍 언어의 규칙. 힌트 2: 문법 오류가 발생하지 않도록 작성해야 하는 코드 규칙. 힌트 3: 코드가 제대로 실행되도록 하기 위한 형식."
hints["parameter"]="힌트 1: 함수나 메서드에서 전달되는 입력 값. 힌트 2: 함수나 메서드가 작업을 수행할 때 필요한 값. 힌트 3: 함수 정의에서 괄호 안에 있는 변수."
hints["array"]="힌트 1: 같은 유형의 여러 데이터를 저장하는 자료구조. 힌트 2: 인덱스를 통해 데이터에 접근할 수 있다. 힌트 3: 배열은 연속된 메모리 공간에 데이터를 저장한다."
hints["class"]="힌트 1: 객체 지향 프로그래밍에서 객체를 생성하는 설계도. 힌트 2: 데이터를 다루는 방법과 상태를 정의하는 코드 구조. 힌트 3: 클래스에서 객체를 만들 수 있다."

# 함수: 행맨 그림 출력
display_hangman() {
  echo "행맨 그림:"
  # 틀린 횟수에 맞춰 행맨 그림을 점차적으로 사라지게 출력
  for i in $(seq 0 $((max_incorrect - incorrect_guesses))); do
    echo "${hangman_parts[$i]}"
  done
  echo ""
}

# 함수: 현재 맞힌 단어 상태 출력
display_word() {
  # 단어를 _ _ _ 형태로 출력
  display_word=""
  for (( i=0; i<${#word}; i++ )); do
    if [ "${guessed_word:$i:1}" == "_" ]; then
      display_word+="_ "
    else
      display_word+="${guessed_word:$i:1} "
    fi
  done
  echo "현재 단어: $display_word"
}

# 힌트를 제공하는 함수
give_hint() {
  if [ "$hint_count" -lt 3 ]; then
    # 각 힌트마다 출력
    hint=$(echo "${hints[$word]}" | cut -d '.' -f$((hint_count+1)) | sed 's/^ *//g')
    echo "힌트: $hint"
    hint_count=$((hint_count + 1))
  else
    echo "더 이상 힌트가 없습니다."
  fi
}

# 함수: 게임 시작 전에 초기화
start_game() {
  # 단어와 힌트 준비
  word=${words[$((RANDOM % ${#words[@]}))]}
  guessed_word=$(echo "$word" | sed 's/./_/g')
  incorrect_guesses=0
  hint_count=0
  max_incorrect=6  # 최대 틀린 기회

  # 틀린 알파벳 초기화
  wrong_guesses=()
}

# 게임 진행
game_loop() {
  while [ "$incorrect_guesses" -lt "$max_incorrect" ]; do
    # 현재 상태 출력
    display_hangman
    display_word
    echo "틀린 알파벳들: ${wrong_guesses[@]}"
    echo "힌트를 원하면 'h'를 입력하세요."

    # 사용자 입력
    read -n 1 -p "알파벳을 입력하세요 (힌트를 원하면 'h'를 입력): " guess
    echo ""

    # 힌트 요청 처리
    if [ "$guess" == "h" ]; then
      give_hint
      continue
    fi

    # 알파벳이 맞는지 확인
    if [[ "$word" == *"$guess"* ]]; then
      echo "$guess는 맞았습니다!"
      for i in $(seq 0 ${#word}-1); do
        if [ "${word:$i:1}" == "$guess" ]; then
          guessed_word="${guessed_word:0:$i}$guess${guessed_word:$((i + 1))}"
        fi
      done
    else
      echo "$guess는 틀렸습니다!"
      wrong_guesses+=("$guess")
      incorrect_guesses=$((incorrect_guesses + 1))
    fi

    # 정답을 맞혔는지 확인
    if [ "$guessed_word" == "$word" ]; then
      display_hangman
      echo "축하합니다! 정답은 '$word'였습니다."
      break
    fi
  done

  if [ "$incorrect_guesses" -eq "$max_incorrect" ]; then
    display_hangman
    echo "게임 오버! 정답은 '$word'였습니다."
  fi
}

# 게임 시작 메시지 출력
echo "행맨 게임이 시작되었습니다! 코딩 관련 단어를 맞춰보세요."
echo "힌트는 3번 있습니다."

# 게임 루프 실행
start_game
game_loop




