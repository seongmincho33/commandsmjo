# [ Git - 작업의 시작과 끝! ]
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'     # 사용법: gc "메시지"
alias gp='git push'
alias gpl='git pull'

# [ Git - 흐름 파악하기 ]
alias gl='git log --oneline --graph --all' # 한눈에 예쁘게 그래프로 보여줘!
alias gb='git branch'
alias gco='git checkout'     # 사용법: gco 브랜치명
alias gd='git diff'

# [ Git - 추가 꿀팁 ]
alias gaa='git add --all'    # 모든 변경사항(삭제 포함) 다 담기!
alias gcm='git checkout main' # 메인 가지로 한 번에 슝~ 이동하기

# [ Git - 브랜치 관리 ]
alias gcb='git checkout -b'   # 사용법: gcb 새브랜치명 (브랜치 만들고 바로 이동!)
alias gbd='git branch -d'     # 사용법: gbd 브랜치명 (브랜치 삭제)
alias gbD='git branch -D'     # 강제 브랜치 삭제 (주의!)
alias gm='git merge'          # 사용법: gm 브랜치명 (병합하기)

# [ Git - 임시 저장 (Stash) ]
alias gst='git stash'         # 작업 중인 거 잠깐 치워두기
alias gstp='git stash pop'    # 치워둔 거 다시 꺼내기
alias gstl='git stash list'   # 치워둔 목록 보기

# [ Git - 되돌리기 ]
alias gundo='git reset HEAD~1' # 마지막 커밋 취소 (변경사항은 유지!)
alias grh='git reset --hard'   # 강제 되돌리기 (주의! 변경사항 사라짐)

# [ Git - 원격 저장소 ]
alias gf='git fetch'           # 원격 변경사항 가져오기 (병합 X)
alias gcl='git clone'          # 사용법: gcl URL (저장소 복제)
alias gra='git remote add origin' # 사용법: gra URL (원격 저장소 연결)

# [ Git - 고급 명령어 ]
alias gds='git diff --staged'  # 스테이징된 변경사항 보기
alias gcp='git cherry-pick'    # 사용법: gcp 커밋해시 (특정 커밋만 가져오기)
alias grb='git rebase'         # 리베이스
alias gt='git tag'             # 태그 관리
