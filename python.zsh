# [ Python - 기본 명령어 ]
alias py='python3'
alias py2='python2'
alias pip='pip3'

# [ Python - 가상환경 (venv) ]
alias pv='python3 -m venv venv'           # 가상환경 생성
alias pa='source venv/bin/activate'        # 가상환경 활성화
alias pd='deactivate'                      # 가상환경 비활성화
alias prm='rm -rf venv'                    # 가상환경 삭제

# [ Python - 패키지 관리 (pip) ]
alias pi='pip install'                     # 패키지 설치
alias piu='pip install --upgrade'          # 패키지 업그레이드
alias pu='pip uninstall'                   # 패키지 삭제
alias pr='pip install -r requirements.txt' # requirements 설치
alias pf='pip freeze'                      # 설치된 패키지 목록
alias pfr='pip freeze > requirements.txt'  # requirements.txt 생성
alias pl='pip list'                        # 설치된 패키지 보기
alias plo='pip list --outdated'            # 업데이트 가능한 패키지

# [ Python - 실행 관련 ]
alias pyr='python3 -m'                     # 모듈 실행 (예: pyr pytest)
alias pyc='python3 -c'                     # 코드 직접 실행
alias pys='python3 -m http.server'         # 간단한 웹서버
alias pyj='python3 -m json.tool'           # JSON 예쁘게 출력

# [ Python - 개발 도구 ]
alias pytest='python3 -m pytest'           # 테스트 실행
alias pylint='python3 -m pylint'           # 코드 검사
alias black='python3 -m black'             # 코드 포맷팅
alias mypy='python3 -m mypy'               # 타입 체크

# [ Python - 유용한 함수 ]
# 새 프로젝트 시작 (가상환경 생성 + 활성화)
pynew() {
    python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip
    echo "✨ 가상환경이 준비됐어! (venv 활성화됨)"
}

# 가상환경 + requirements 한번에
pysetup() {
    python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        echo "✨ 가상환경 + 패키지 설치 완료!"
    else
        echo "✨ 가상환경 준비 완료! (requirements.txt 없음)"
    fi
}
