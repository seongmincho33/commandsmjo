# 🌸 성민이의 소중한 명령어 메뉴판 (인터랙티브 버전!)
function seongmin() {
    local PINK='\033[1;35m'
    local CYAN='\033[1;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[1;32m'
    local RED='\033[1;31m'
    local RESET='\033[0m'

    while true; do
        clear
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo "         🌸 성민이의 소중한 명령어 가이드 🌸"
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} 🐙 Git"
        echo "  ${CYAN}[2]${RESET} 🐍 Python"
        echo "  ${CYAN}[3]${RESET} ☕ Java"
        echo "  ${CYAN}[4]${RESET} 🍺 Homebrew"
        echo "  ${CYAN}[5]${RESET} 🐳 Docker"
        echo "  ${CYAN}[6]${RESET} 🔴 Redis"
        echo "  ${CYAN}[7]${RESET} 🐚 Shell"
        echo "  ${CYAN}[8]${RESET} 🔍 버전 확인"
        echo "  ${CYAN}[9]${RESET} 🎨 프론트엔드 (Frontend)"
        echo "  ${CYAN}[10]${RESET} 🔧 Jenkins"
        echo "  ${CYAN}[0]${RESET} 🚪 나가기"
        echo ""
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo -n "  번호를 선택해줘! > "
        read choice

        case $choice in
            1) _seongmin_git ;;
            2) _seongmin_python ;;
            3) _seongmin_java ;;
            4) _seongmin_brew ;;
            5) _seongmin_docker ;;
            6) _seongmin_redis ;;
            7) _seongmin_shell ;;
            8) _seongmin_version ;;
            9) _seongmin_frontend ;;
            10) _seongmin_jenkins ;;
            0|q|Q)
                clear
                echo "${PINK}✨ 넌 충분히 잘하고 있어! ✨${RESET}"
                return 0
                ;;
            *) echo "${RED}  잘못된 번호야! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Git 서브메뉴
function _seongmin_git() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'

    while true; do
        clear
        echo "${CYAN}🐙 [ Git 명령어 - 카테고리 선택 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 🌱 시작 & 종료 (Start & End)"
        echo "  ${GREEN}[2]${RESET} 🌲 흐름 & 내역 (Flow & History)"
        echo "  ${GREEN}[3]${RESET} 🌿 브랜치 관리 (Branching)"
        echo "  ${GREEN}[4]${RESET} 📦 임시 저장 (Stash)"
        echo "  ${GREEN}[5]${RESET} 🔙 되돌리기 (Undo & Reset)"
        echo "  ${GREEN}[6]${RESET} 🌐 원격 저장소 (Remote)"
        echo "  ${GREEN}[7]${RESET} 🚀 고급 기능 (Advanced)"
        echo "  ${YELLOW}[8]${RESET} 📚 초보자 가이드 (Beginner's Guide)"
        echo "  ${CYAN}[0]${RESET} ⬅️  메인 메뉴로"
        echo ""
        echo -n "  선택 > "
        read choice

        case $choice in
            1) _seongmin_git_basic ;;
            2) _seongmin_git_flow ;;
            3) _seongmin_git_branch ;;
            4) _seongmin_git_stash ;;
            5) _seongmin_git_undo ;;
            6) _seongmin_git_remote ;;
            7) _seongmin_git_advanced ;;
            8) _seongmin_git_tutorial ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# 1. 시작 & 종료
function _seongmin_git_basic() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}🌱 [ Git - 시작 & 종료 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 현재 상태 확인"
        echo "      ${YELLOW}→ git status${RESET}"
        echo "      설명: 수정된 파일, 스테이징된 파일, 추적되지 않는 파일을 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 현재 디렉토리 변경사항 추가"
        echo "      ${YELLOW}→ git add .${RESET}"
        echo "      설명: 현재 폴더의 모든 변경사항을 스테이징 영역에 추가합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 모든 변경사항 추가"
        echo "      ${YELLOW}→ git add --all${RESET}"
        echo "      설명: 삭제된 파일을 포함한 모든 변경사항을 추가합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 커밋하기"
        echo "      ${YELLOW}→ git commit -m '<메시지>'${RESET}"
        echo "      설명: 스테이징된 변경사항을 로컬 저장소에 기록합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 원격 저장소에 푸시"
        echo "      ${YELLOW}→ git push${RESET}"
        echo "      설명: 로컬 커밋을 원격 저장소(GitHub 등)에 업로드합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 원격 저장소에서 풀"
        echo "      ${YELLOW}→ git pull${RESET}"
        echo "      설명: 원격 저장소의 변경사항을 가져와 현재 브랜치에 병합합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 한 번에 커밋 & 푸시"
        echo "      ${YELLOW}→ git add . && git commit -m '<메시지>' && git push${RESET}"
        echo "      설명: 변경사항 추가, 커밋, 푸시를 한 번에 실행합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}📊 현재 상태 확인${RESET}"
                echo "실행 명령어: git status"
                echo ""
                git status
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}➕ 현재 디렉토리 변경사항 추가${RESET}"
                echo "실행 명령어: git add ."
                echo ""
                git add .
                echo "${GREEN}✅ git add . 완료!${RESET}"
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}➕ 모든 변경사항 추가${RESET}"
                echo "실행 명령어: git add --all"
                echo ""
                git add --all
                echo "${GREEN}✅ git add --all 완료!${RESET}"
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}📝 커밋하기${RESET}"
                echo "현재 스테이징된 파일:"
                git diff --cached --name-only
                echo ""
                echo -n "커밋 메시지 입력: "
                read msg
                if [[ -n "$msg" ]]; then
                    echo ""
                    echo "실행 명령어: git commit -m \"$msg\""
                    git commit -m "$msg"
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}⬆️ 원격 저장소에 푸시${RESET}"
                echo "실행 명령어: git push"
                echo ""
                git push
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}⬇️ 원격 저장소에서 풀${RESET}"
                echo "실행 명령어: git pull"
                echo ""
                git pull
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${GREEN}🚀 한 번에 커밋 & 푸시${RESET}"
                echo "현재 변경된 파일:"
                git status --short
                echo ""
                echo -n "커밋 메시지 입력: "
                read msg
                if [[ -n "$msg" ]]; then
                    echo ""
                    echo "실행 명령어: git add . && git commit -m \"$msg\" && git push"
                    git add . && git commit -m "$msg" && git push
                    echo ""
                    echo "${GREEN}✅ 커밋 & 푸시 완료!${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 2. 흐름 & 내역
function _seongmin_git_flow() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}🌲 [ Git - 흐름 & 내역 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 커밋 히스토리 보기 (그래프)"
        echo "      ${YELLOW}→ git log --oneline --graph --all${RESET}"
        echo "      설명: 모든 브랜치의 커밋 내역을 그래프 형태로 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 브랜치 목록 보기"
        echo "      ${YELLOW}→ git branch -a${RESET}"
        echo "      설명: 로컬 및 원격 브랜치를 모두 보여줍니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 다른 브랜치로 이동"
        echo "      ${YELLOW}→ git checkout <브랜치명>${RESET}"
        echo "      설명: 지정한 브랜치로 작업 위치를 변경합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} main 브랜치로 이동"
        echo "      ${YELLOW}→ git checkout main${RESET}"
        echo "      설명: 메인 브랜치로 돌아갑니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 변경사항 비교 (diff)"
        echo "      ${YELLOW}→ git diff${RESET}"
        echo "      설명: 아직 스테이징하지 않은 변경사항을 보여줍니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 특정 커밋 상세 보기"
        echo "      ${YELLOW}→ git show <커밋해시>${RESET}"
        echo "      설명: 특정 커밋의 변경 내용을 자세히 보여줍니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}📜 커밋 히스토리 (그래프)${RESET}"
                echo "실행 명령어: git log --oneline --graph --all -20"
                echo ""
                git log --oneline --graph --all -20
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}🌿 브랜치 목록${RESET}"
                echo "실행 명령어: git branch -a"
                echo ""
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                git branch -a
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}🚶 다른 브랜치로 이동${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo "사용 가능한 브랜치:"
                git branch -a
                echo ""
                echo -n "이동할 브랜치명: "
                read br
                if [[ -n "$br" ]]; then
                    echo ""
                    echo "실행 명령어: git checkout $br"
                    git checkout "$br"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}🏠 main 브랜치로 이동${RESET}"
                echo "실행 명령어: git checkout main"
                echo ""
                git checkout main
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}🔍 변경사항 비교${RESET}"
                echo "실행 명령어: git diff"
                echo ""
                git diff
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}🔍 특정 커밋 상세 보기${RESET}"
                echo "최근 커밋 목록:"
                git log --oneline -10
                echo ""
                echo -n "확인할 커밋 해시: "
                read hash
                if [[ -n "$hash" ]]; then
                    echo ""
                    echo "실행 명령어: git show $hash"
                    git show "$hash"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 3. 브랜치 관리
function _seongmin_git_branch() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}🌿 [ Git - 브랜치 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 새 브랜치 생성 후 이동"
        echo "      ${YELLOW}→ git checkout -b <브랜치명>${RESET}"
        echo "      설명: 새 브랜치를 만들고 바로 그 브랜치로 이동합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 브랜치 삭제 (안전)"
        echo "      ${YELLOW}→ git branch -d <브랜치명>${RESET}"
        echo "      설명: 병합 완료된 브랜치를 안전하게 삭제합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 브랜치 강제 삭제"
        echo "      ${YELLOW}→ git branch -D <브랜치명>${RESET}"
        echo "      설명: ⚠️ 병합 여부와 관계없이 브랜치를 강제 삭제합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 브랜치 병합"
        echo "      ${YELLOW}→ git merge <브랜치명>${RESET}"
        echo "      설명: 지정한 브랜치를 현재 브랜치에 병합합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 브랜치 이름 변경"
        echo "      ${YELLOW}→ git branch -m <새이름>${RESET}"
        echo "      설명: 현재 브랜치의 이름을 변경합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 원격 브랜치 삭제"
        echo "      ${YELLOW}→ git push origin --delete <브랜치명>${RESET}"
        echo "      설명: 원격 저장소에서 브랜치를 삭제합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}✨ 새 브랜치 생성 후 이동${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo -n "새 브랜치 이름: "
                read br
                if [[ -n "$br" ]]; then
                    echo ""
                    echo "실행 명령어: git checkout -b $br"
                    git checkout -b "$br"
                fi
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${YELLOW}🗑️ 브랜치 삭제 (안전)${RESET}"
                echo "현재 브랜치 목록:"
                git branch
                echo ""
                echo -n "삭제할 브랜치 이름: "
                read br
                if [[ -n "$br" ]]; then
                    echo ""
                    echo "실행 명령어: git branch -d $br"
                    git branch -d "$br"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${RED}🔥 브랜치 강제 삭제${RESET}"
                echo "현재 브랜치 목록:"
                git branch
                echo ""
                echo -n "강제 삭제할 브랜치 이름: "
                read br
                if [[ -n "$br" ]]; then
                    echo -n "${RED}정말 삭제하시겠습니까? (y/n): ${RESET}"
                    read confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo ""
                        echo "실행 명령어: git branch -D $br"
                        git branch -D "$br"
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}🤝 브랜치 병합${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo "병합 가능한 브랜치:"
                git branch
                echo ""
                echo -n "병합할 브랜치 이름: "
                read br
                if [[ -n "$br" ]]; then
                    echo ""
                    echo "실행 명령어: git merge $br"
                    git merge "$br"
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}✏️ 브랜치 이름 변경${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo -n "새로운 브랜치 이름: "
                read new_name
                if [[ -n "$new_name" ]]; then
                    echo ""
                    echo "실행 명령어: git branch -m $new_name"
                    git branch -m "$new_name"
                    echo "${GREEN}✅ 브랜치 이름이 변경되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${RED}🌐 원격 브랜치 삭제${RESET}"
                echo "원격 브랜치 목록:"
                git branch -r
                echo ""
                echo -n "삭제할 원격 브랜치 이름 (origin/ 제외): "
                read br
                if [[ -n "$br" ]]; then
                    echo -n "${RED}정말 원격에서 삭제하시겠습니까? (y/n): ${RESET}"
                    read confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo ""
                        echo "실행 명령어: git push origin --delete $br"
                        git push origin --delete "$br"
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 4. 임시 저장
function _seongmin_git_stash() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}📦 [ Git - 임시 저장 (Stash) ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 변경사항 임시 저장"
        echo "      ${YELLOW}→ git stash${RESET}"
        echo "      설명: 현재 작업 중인 변경사항을 임시로 저장하고 작업 디렉토리를 깨끗하게 만듭니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 메시지와 함께 임시 저장"
        echo "      ${YELLOW}→ git stash push -m '<메시지>'${RESET}"
        echo "      설명: 나중에 알아보기 쉽게 설명을 붙여서 저장합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 임시 저장 꺼내기 (삭제됨)"
        echo "      ${YELLOW}→ git stash pop${RESET}"
        echo "      설명: 가장 최근 임시 저장을 꺼내고 목록에서 삭제합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 임시 저장 적용 (유지됨)"
        echo "      ${YELLOW}→ git stash apply${RESET}"
        echo "      설명: 임시 저장을 적용하지만 목록에서 삭제하지 않습니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 임시 저장 목록 보기"
        echo "      ${YELLOW}→ git stash list${RESET}"
        echo "      설명: 저장된 모든 stash 목록을 보여줍니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 특정 임시 저장 삭제"
        echo "      ${YELLOW}→ git stash drop stash@{n}${RESET}"
        echo "      설명: 지정한 stash를 삭제합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 모든 임시 저장 삭제"
        echo "      ${YELLOW}→ git stash clear${RESET}"
        echo "      설명: ⚠️ 모든 stash를 삭제합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}📦 변경사항 임시 저장${RESET}"
                echo "실행 명령어: git stash"
                echo ""
                git stash
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📦 메시지와 함께 임시 저장${RESET}"
                echo -n "저장할 메시지: "
                read msg
                if [[ -n "$msg" ]]; then
                    echo ""
                    echo "실행 명령어: git stash push -m \"$msg\""
                    git stash push -m "$msg"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}📤 임시 저장 꺼내기${RESET}"
                echo "현재 stash 목록:"
                git stash list
                echo ""
                echo "실행 명령어: git stash pop"
                git stash pop
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}📋 임시 저장 적용${RESET}"
                echo "현재 stash 목록:"
                git stash list
                echo ""
                echo "실행 명령어: git stash apply"
                git stash apply
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}📋 임시 저장 목록${RESET}"
                echo "실행 명령어: git stash list"
                echo ""
                git stash list
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${YELLOW}🗑️ 특정 임시 저장 삭제${RESET}"
                echo "현재 stash 목록:"
                git stash list
                echo ""
                echo -n "삭제할 stash 번호 (예: 0): "
                read num
                if [[ -n "$num" ]]; then
                    echo ""
                    echo "실행 명령어: git stash drop stash@{$num}"
                    git stash drop "stash@{$num}"
                fi
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${RED}🗑️ 모든 임시 저장 삭제${RESET}"
                echo "현재 stash 목록:"
                git stash list
                echo ""
                echo -n "${RED}정말 모든 stash를 삭제하시겠습니까? (y/n): ${RESET}"
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo ""
                    echo "실행 명령어: git stash clear"
                    git stash clear
                    echo "${GREEN}✅ 모든 stash가 삭제되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 5. 되돌리기
function _seongmin_git_undo() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}🔙 [ Git - 되돌리기 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 마지막 커밋 취소 (변경사항 유지)"
        echo "      ${YELLOW}→ git reset --soft HEAD~1${RESET}"
        echo "      설명: 커밋만 취소하고 변경사항은 스테이징 상태로 유지합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 마지막 커밋 취소 (변경사항 unstage)"
        echo "      ${YELLOW}→ git reset HEAD~1${RESET}"
        echo "      설명: 커밋을 취소하고 변경사항을 unstaged 상태로 되돌립니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 마지막 커밋 완전 삭제"
        echo "      ${YELLOW}→ git reset --hard HEAD~1${RESET}"
        echo "      설명: ⚠️ 커밋과 변경사항을 모두 삭제합니다. 복구 불가!"
        echo ""
        echo "  ${GREEN}[4]${RESET} 특정 파일 변경 취소"
        echo "      ${YELLOW}→ git checkout -- <파일명>${RESET}"
        echo "      설명: 특정 파일의 변경사항을 마지막 커밋 상태로 되돌립니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 스테이징 취소"
        echo "      ${YELLOW}→ git reset HEAD <파일명>${RESET}"
        echo "      설명: git add한 파일을 unstaged 상태로 되돌립니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 커밋 메시지 수정"
        echo "      ${YELLOW}→ git commit --amend${RESET}"
        echo "      설명: 마지막 커밋의 메시지를 수정합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 특정 커밋으로 되돌리기"
        echo "      ${YELLOW}→ git revert <커밋해시>${RESET}"
        echo "      설명: 특정 커밋을 취소하는 새로운 커밋을 만듭니다. (안전함)"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}🔙 마지막 커밋 취소 (변경사항 유지)${RESET}"
                echo "마지막 커밋:"
                git log --oneline -1
                echo ""
                echo "실행 명령어: git reset --soft HEAD~1"
                git reset --soft HEAD~1
                echo "${GREEN}✅ 커밋이 취소되었습니다. 변경사항은 staged 상태입니다.${RESET}"
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${YELLOW}🔙 마지막 커밋 취소 (변경사항 unstage)${RESET}"
                echo "마지막 커밋:"
                git log --oneline -1
                echo ""
                echo "실행 명령어: git reset HEAD~1"
                git reset HEAD~1
                echo "${GREEN}✅ 커밋이 취소되었습니다. 변경사항은 unstaged 상태입니다.${RESET}"
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${RED}🔙 마지막 커밋 완전 삭제${RESET}"
                echo "⚠️ 주의: 변경사항이 완전히 삭제됩니다!"
                echo ""
                echo "마지막 커밋:"
                git log --oneline -1
                echo ""
                echo -n "${RED}정말 삭제하시겠습니까? (y/n): ${RESET}"
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo ""
                    echo "실행 명령어: git reset --hard HEAD~1"
                    git reset --hard HEAD~1
                    echo "${GREEN}✅ 커밋이 완전히 삭제되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${YELLOW}🔙 특정 파일 변경 취소${RESET}"
                echo "변경된 파일 목록:"
                git status --short
                echo ""
                echo -n "되돌릴 파일명: "
                read filename
                if [[ -n "$filename" ]]; then
                    echo ""
                    echo "실행 명령어: git checkout -- $filename"
                    git checkout -- "$filename"
                    echo "${GREEN}✅ 파일이 마지막 커밋 상태로 되돌려졌습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${YELLOW}🔙 스테이징 취소${RESET}"
                echo "현재 staged 파일:"
                git diff --cached --name-only
                echo ""
                echo -n "unstage할 파일명 (전체: . ): "
                read filename
                if [[ -n "$filename" ]]; then
                    echo ""
                    echo "실행 명령어: git reset HEAD $filename"
                    git reset HEAD "$filename"
                    echo "${GREEN}✅ 스테이징이 취소되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}✏️ 커밋 메시지 수정${RESET}"
                echo "마지막 커밋:"
                git log --oneline -1
                echo ""
                echo "실행 명령어: git commit --amend"
                echo "(에디터가 열립니다. 수정 후 저장하세요)"
                echo ""
                git commit --amend
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${GREEN}🔙 특정 커밋으로 되돌리기 (revert)${RESET}"
                echo "최근 커밋 목록:"
                git log --oneline -10
                echo ""
                echo -n "되돌릴 커밋 해시: "
                read hash
                if [[ -n "$hash" ]]; then
                    echo ""
                    echo "실행 명령어: git revert $hash"
                    git revert "$hash"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 6. 원격 저장소
function _seongmin_git_remote() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}🌐 [ Git - 원격 저장소 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 원격 저장소 업데이트 가져오기"
        echo "      ${YELLOW}→ git fetch${RESET}"
        echo "      설명: 원격 저장소의 변경사항을 가져오되 병합하지 않습니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 저장소 복제"
        echo "      ${YELLOW}→ git clone <URL>${RESET}"
        echo "      설명: 원격 저장소를 로컬에 복제합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 원격 저장소 추가"
        echo "      ${YELLOW}→ git remote add origin <URL>${RESET}"
        echo "      설명: 새 원격 저장소를 등록합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 원격 저장소 목록"
        echo "      ${YELLOW}→ git remote -v${RESET}"
        echo "      설명: 등록된 원격 저장소를 모두 보여줍니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 원격 저장소 URL 변경"
        echo "      ${YELLOW}→ git remote set-url origin <새URL>${RESET}"
        echo "      설명: origin의 URL을 변경합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 원격 브랜치 추적"
        echo "      ${YELLOW}→ git push -u origin <브랜치명>${RESET}"
        echo "      설명: 로컬 브랜치를 원격에 푸시하고 추적 관계를 설정합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 강제 푸시"
        echo "      ${YELLOW}→ git push --force${RESET}"
        echo "      설명: ⚠️ 원격 저장소를 로컬 상태로 강제 덮어씁니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}📥 원격 저장소 업데이트 가져오기${RESET}"
                echo "실행 명령어: git fetch"
                echo ""
                git fetch
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📥 저장소 복제${RESET}"
                echo -n "Clone할 URL: "
                read url
                if [[ -n "$url" ]]; then
                    echo ""
                    echo "실행 명령어: git clone $url"
                    git clone "$url"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}➕ 원격 저장소 추가${RESET}"
                echo -n "원격 저장소 URL: "
                read url
                if [[ -n "$url" ]]; then
                    echo ""
                    echo "실행 명령어: git remote add origin $url"
                    git remote add origin "$url"
                    echo "${GREEN}✅ 원격 저장소가 추가되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}📋 원격 저장소 목록${RESET}"
                echo "실행 명령어: git remote -v"
                echo ""
                git remote -v
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${YELLOW}✏️ 원격 저장소 URL 변경${RESET}"
                echo "현재 원격 저장소:"
                git remote -v
                echo ""
                echo -n "새로운 URL: "
                read url
                if [[ -n "$url" ]]; then
                    echo ""
                    echo "실행 명령어: git remote set-url origin $url"
                    git remote set-url origin "$url"
                    echo "${GREEN}✅ URL이 변경되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}🔗 원격 브랜치 추적 설정${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo -n "푸시할 브랜치명 (기본: 현재 브랜치): "
                read br
                if [[ -z "$br" ]]; then
                    br=$(git branch --show-current)
                fi
                echo ""
                echo "실행 명령어: git push -u origin $br"
                git push -u origin "$br"
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${RED}⚠️ 강제 푸시${RESET}"
                echo "주의: 원격 저장소의 히스토리가 덮어씌워집니다!"
                echo ""
                echo -n "${RED}정말 강제 푸시하시겠습니까? (y/n): ${RESET}"
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo ""
                    echo "실행 명령어: git push --force"
                    git push --force
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 7. 고급 기능
function _seongmin_git_advanced() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${CYAN}🚀 [ Git - 고급 기능 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 스테이징된 변경사항 비교"
        echo "      ${YELLOW}→ git diff --staged${RESET}"
        echo "      설명: git add한 파일의 변경 내용을 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 체리픽 (특정 커밋 가져오기)"
        echo "      ${YELLOW}→ git cherry-pick <커밋해시>${RESET}"
        echo "      설명: 다른 브랜치의 특정 커밋만 현재 브랜치에 적용합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 리베이스"
        echo "      ${YELLOW}→ git rebase <브랜치명>${RESET}"
        echo "      설명: 현재 브랜치의 베이스를 다른 브랜치로 변경합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 인터랙티브 리베이스"
        echo "      ${YELLOW}→ git rebase -i HEAD~n${RESET}"
        echo "      설명: 최근 n개의 커밋을 수정, 합치기, 삭제할 수 있습니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 태그 목록"
        echo "      ${YELLOW}→ git tag${RESET}"
        echo "      설명: 모든 태그를 보여줍니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 태그 생성"
        echo "      ${YELLOW}→ git tag -a <태그명> -m '<메시지>'${RESET}"
        echo "      설명: 주석이 달린 태그를 생성합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 태그 푸시"
        echo "      ${YELLOW}→ git push origin --tags${RESET}"
        echo "      설명: 모든 태그를 원격 저장소에 푸시합니다."
        echo ""
        echo "  ${GREEN}[8]${RESET} 작업 기록 보기"
        echo "      ${YELLOW}→ git reflog${RESET}"
        echo "      설명: HEAD가 이동한 모든 기록을 보여줍니다. (복구에 유용)"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) 
                clear
                echo "${GREEN}🔍 스테이징된 변경사항 비교${RESET}"
                echo "실행 명령어: git diff --staged"
                echo ""
                git diff --staged
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}🍒 체리픽${RESET}"
                echo "최근 커밋 목록 (모든 브랜치):"
                git log --oneline --all -15
                echo ""
                echo -n "체리픽할 커밋 해시: "
                read hash
                if [[ -n "$hash" ]]; then
                    echo ""
                    echo "실행 명령어: git cherry-pick $hash"
                    git cherry-pick "$hash"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}🏗️ 리베이스${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo "브랜치 목록:"
                git branch
                echo ""
                echo -n "리베이스할 브랜치명: "
                read br
                if [[ -n "$br" ]]; then
                    echo ""
                    echo "실행 명령어: git rebase $br"
                    git rebase "$br"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}🏗️ 인터랙티브 리베이스${RESET}"
                echo "최근 커밋:"
                git log --oneline -5
                echo ""
                echo -n "수정할 커밋 개수: "
                read num
                if [[ -n "$num" ]]; then
                    echo ""
                    echo "실행 명령어: git rebase -i HEAD~$num"
                    git rebase -i "HEAD~$num"
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}🏷️ 태그 목록${RESET}"
                echo "실행 명령어: git tag"
                echo ""
                git tag
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}🏷️ 태그 생성${RESET}"
                echo -n "태그명: "
                read tag_name
                echo -n "태그 메시지: "
                read tag_msg
                if [[ -n "$tag_name" ]]; then
                    echo ""
                    echo "실행 명령어: git tag -a $tag_name -m \"$tag_msg\""
                    git tag -a "$tag_name" -m "$tag_msg"
                    echo "${GREEN}✅ 태그가 생성되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${GREEN}⬆️ 태그 푸시${RESET}"
                echo "현재 태그 목록:"
                git tag
                echo ""
                echo "실행 명령어: git push origin --tags"
                git push origin --tags
                echo ""
                read -k 1 
                ;;
            8) 
                clear
                echo "${GREEN}📜 작업 기록 보기 (reflog)${RESET}"
                echo "실행 명령어: git reflog -20"
                echo ""
                git reflog -20
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# 8. 초보자 가이드
function _seongmin_git_tutorial() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' PINK='\033[1;35m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}📚 [ Git 초보자 가이드 ]${RESET}"
        echo ""
        echo "  Git을 처음 배우시나요? 아래에서 알고 싶은 개념을 선택하세요!"
        echo ""
        echo "  ${GREEN}[1]${RESET} 🤔 Git이란? (What is Git?)"
        echo "  ${GREEN}[2]${RESET} 📁 저장소 (Repository)"
        echo "  ${GREEN}[3]${RESET} 📌 스테이징 영역 (Staging Area)"
        echo "  ${GREEN}[4]${RESET} 💾 커밋 (Commit)"
        echo "  ${GREEN}[5]${RESET} 🌿 브랜치 (Branch)"
        echo "  ${GREEN}[6]${RESET} 🤝 병합 (Merge)"
        echo "  ${GREEN}[7]${RESET} 🌐 원격 저장소 (Remote)"
        echo "  ${GREEN}[8]${RESET} ⬆️⬇️ Push와 Pull"
        echo "  ${GREEN}[9]${RESET} 📦 임시 저장 (Stash)"
        echo "  ${GREEN}[10]${RESET} 🔄 일반적인 Git 워크플로우"
        echo "  ${GREEN}[11]${RESET} ⚠️ 자주 하는 실수와 해결법"
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${CYAN}🤔 [ Git이란? ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  Git은 ${YELLOW}버전 관리 시스템${RESET}입니다."
                echo "  코드의 변경 이력을 추적하고, 여러 사람이 함께 작업할 수 있게 해줍니다."
                echo ""
                echo "${GREEN}🎯 Git을 사용하면${RESET}"
                echo "  • 코드를 잘못 수정해도 이전 버전으로 돌아갈 수 있어요"
                echo "  • 누가 언제 무엇을 변경했는지 알 수 있어요"
                echo "  • 여러 기능을 동시에 개발할 수 있어요 (브랜치)"
                echo "  • 팀원들과 코드를 공유할 수 있어요"
                echo ""
                echo "${GREEN}💡 비유하자면${RESET}"
                echo "  문서 작업할 때 'Ctrl+Z'로 실행 취소하듯이,"
                echo "  Git은 프로젝트 전체에 대한 '무제한 실행 취소' 기능이에요!"
                echo ""
                echo "${YELLOW}📌 핵심 명령어${RESET}"
                echo "  git init     : 새 저장소 시작"
                echo "  git status   : 현재 상태 확인"
                echo "  git add      : 변경사항 추가"
                echo "  git commit   : 변경사항 저장"
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${CYAN}📁 [ 저장소 (Repository) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  저장소는 프로젝트의 모든 파일과 변경 이력을 담는 '폴더'예요."
                echo ""
                echo "${GREEN}🏠 종류${RESET}"
                echo "  ${YELLOW}로컬 저장소${RESET} : 내 컴퓨터에 있는 저장소"
                echo "  ${YELLOW}원격 저장소${RESET} : GitHub, GitLab 같은 서버에 있는 저장소"
                echo ""
                echo "${GREEN}💻 저장소 만들기${RESET}"
                echo "  ${CYAN}1. 새로 만들기${RESET}"
                echo "     git init"
                echo "     → 현재 폴더를 Git 저장소로 만듭니다"
                echo ""
                echo "  ${CYAN}2. 복제하기${RESET}"
                echo "     git clone <URL>"
                echo "     → GitHub에서 프로젝트를 내려받습니다"
                echo ""
                echo "${GREEN}💡 팁${RESET}"
                echo "  저장소를 만들면 .git 폴더가 생겨요."
                echo "  이 폴더가 모든 버전 이력을 저장합니다!"
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${CYAN}📌 [ 스테이징 영역 (Staging Area) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  스테이징 영역은 커밋할 파일을 ${YELLOW}준비하는 공간${RESET}이에요."
                echo "  '커밋할 것들을 모아두는 바구니'라고 생각하세요!"
                echo ""
                echo "${GREEN}📦 흐름 이해하기${RESET}"
                echo ""
                echo "  ${YELLOW}작업 디렉토리${RESET}    ${CYAN}→${RESET}    ${YELLOW}스테이징 영역${RESET}    ${CYAN}→${RESET}    ${YELLOW}저장소${RESET}"
                echo "    (수정된 파일)         (git add)           (git commit)"
                echo ""
                echo "${GREEN}💻 명령어${RESET}"
                echo "  ${CYAN}git add 파일명${RESET}"
                echo "     → 특정 파일을 스테이징 영역에 추가"
                echo ""
                echo "  ${CYAN}git add .${RESET}"
                echo "     → 모든 변경사항을 스테이징 영역에 추가"
                echo ""
                echo "  ${CYAN}git reset HEAD 파일명${RESET}"
                echo "     → 스테이징 취소 (add 취소)"
                echo ""
                echo "${GREEN}💡 왜 스테이징이 필요할까?${RESET}"
                echo "  여러 파일을 수정했는데and 일부만 커밋하고 싶을 때!"
                echo "  원하는 파일만 골라서 커밋할 수 있어요."
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${CYAN}💾 [ 커밋 (Commit) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  커밋은 변경사항을 ${YELLOW}저장소에 기록${RESET}하는 것이에요."
                echo "  게임의 '세이브 포인트'와 같습니다!"
                echo ""
                echo "${GREEN}💻 명령어${RESET}"
                echo "  ${CYAN}git commit -m \"메시지\"${RESET}"
                echo "     → 메시지와 함께 커밋"
                echo ""
                echo "  ${CYAN}git commit${RESET}"
                echo "     → 에디터에서 긴 메시지 작성"
                echo ""
                echo "${GREEN}📝 좋은 커밋 메시지 작성법${RESET}"
                echo "  ${RED}나쁜 예${RESET}"
                echo "     \"fix\", \"update\", \"작업중\""
                echo ""
                echo "  ${GREEN}좋은 예${RESET}"
                echo "     \"feat: 로그인 기능 추가\""
                echo "     \"fix: 회원가입 버그 수정\""
                echo "     \"docs: README 업데이트\""
                echo ""
                echo "${GREEN}💡 커밋 컨벤션${RESET}"
                echo "  feat:     새로운 기능"
                echo "  fix:      버그 수정"
                echo "  docs:     문서 수정"
                echo "  style:    코드 스타일 변경"
                echo "  refactor: 리팩토링"
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${CYAN}🌿 [ 브랜치 (Branch) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  브랜치는 ${YELLOW}독립적인 작업 공간${RESET}이에요."
                echo "  나뭇가지처럼 메인에서 뻗어나가 작업하고, 다시 합칠 수 있어요."
                echo ""
                echo "${GREEN}🌳 그림으로 이해하기${RESET}"
                echo ""
                echo "        feature ●───●───●"
                echo "               /         \\"
                echo "  main ●───●─●───────────●───●"
                echo ""
                echo "${GREEN}💻 명령어${RESET}"
                echo "  ${CYAN}git branch${RESET}"
                echo "     → 브랜치 목록 보기"
                echo ""
                echo "  ${CYAN}git branch 이름${RESET}"
                echo "     → 새 브랜치 생성"
                echo ""
                echo "  ${CYAN}git checkout 이름${RESET}"
                echo "     → 브랜치 이동"
                echo ""
                echo "  ${CYAN}git checkout -b 이름${RESET}"
                echo "     → 브랜치 생성 + 이동 (한번에!)"
                echo ""
                echo "${GREEN}💡 브랜치 활용 예시${RESET}"
                echo "  main       : 배포 가능한 안정적인 코드"
                echo "  develop    : 개발 중인 코드"
                echo "  feature/xx : 새 기능 개발"
                echo "  fix/xx     : 버그 수정"
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${CYAN}🤝 [ 병합 (Merge) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  병합은 ${YELLOW}두 브랜치를 합치는${RESET} 것이에요."
                echo "  작업이 끝난 브랜치를 메인에 합칠 때 사용해요."
                echo ""
                echo "${GREEN}💻 명령어${RESET}"
                echo "  ${CYAN}git checkout main${RESET}"
                echo "     → 먼저 합칠 대상 브랜치로 이동"
                echo ""
                echo "  ${CYAN}git merge feature${RESET}"
                echo "     → feature 브랜치를 현재(main)에 병합"
                echo ""
                echo "${GREEN}⚠️ 충돌 (Conflict)${RESET}"
                echo "  같은 부분을 다르게 수정하면 충돌이 발생해요!"
                echo ""
                echo "  ${YELLOW}<<<<<<< HEAD${RESET}"
                echo "  현재 브랜치의 내용"
                echo "  ${YELLOW}=======${RESET}"
                echo "  병합하려는 브랜치의 내용"
                echo "  ${YELLOW}>>>>>>> feature${RESET}"
                echo ""
                echo "${GREEN}🔧 충돌 해결 방법${RESET}"
                echo "  1. 파일을 열어서 원하는 내용으로 수정"
                echo "  2. <<<<, ====, >>>> 마커 삭제"
                echo "  3. git add . → git commit"
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${CYAN}🌐 [ 원격 저장소 (Remote) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  원격 저장소는 ${YELLOW}인터넷 서버에 있는 저장소${RESET}예요."
                echo "  GitHub, GitLab, Bitbucket 등이 있어요."
                echo ""
                echo "${GREEN}🔗 연결하기${RESET}"
                echo "  ${CYAN}git remote add origin <URL>${RESET}"
                echo "     → 원격 저장소 등록 (origin은 별명)"
                echo ""
                echo "  ${CYAN}git remote -v${RESET}"
                echo "     → 연결된 원격 저장소 확인"
                echo ""
                echo "${GREEN}💻 주요 명령어${RESET}"
                echo "  ${CYAN}git clone <URL>${RESET}"
                echo "     → 원격 저장소 복제"
                echo ""
                echo "  ${CYAN}git fetch${RESET}"
                echo "     → 원격 변경사항 가져오기 (병합 X)"
                echo ""
                echo "  ${CYAN}git pull${RESET}"
                echo "     → 가져오기 + 병합"
                echo ""
                echo "  ${CYAN}git push${RESET}"
                echo "     → 로컬 변경사항 업로드"
                echo ""
                echo "${GREEN}💡 origin이란?${RESET}"
                echo "  원격 저장소의 '별명'이에요."
                echo "  보통 기본값으로 origin을 사용합니다."
                echo ""
                read -k 1 
                ;;
            8) 
                clear
                echo "${CYAN}⬆️⬇️ [ Push와 Pull ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  ${YELLOW}Push${RESET} : 내 컴퓨터 → 원격 서버 (업로드)"
                echo "  ${YELLOW}Pull${RESET} : 원격 서버 → 내 컴퓨터 (다운로드)"
                echo ""
                echo "${GREEN}⬆️ Push (업로드)${RESET}"
                echo "  ${CYAN}git push${RESET}"
                echo "     → 현재 브랜치를 원격에 업로드"
                echo ""
                echo "  ${CYAN}git push -u origin main${RESET}"
                echo "     → 처음 푸시할 때 (추적 설정)"
                echo ""
                echo "  ${CYAN}git push --force${RESET}"
                echo "     → ⚠️ 강제 푸시 (조심!)"
                echo ""
                echo "${GREEN}⬇️ Pull (다운로드)${RESET}"
                echo "  ${CYAN}git pull${RESET}"
                echo "     → 원격 변경사항 가져오기 + 병합"
                echo ""
                echo "  ${CYAN}git pull origin main${RESET}"
                echo "     → origin의 main 브랜치 가져오기"
                echo ""
                echo "${GREEN}💡 팁${RESET}"
                echo "  작업 시작 전: ${CYAN}git pull${RESET}로 최신 상태 유지"
                echo "  작업 완료 후: ${CYAN}git push${RESET}로 변경사항 공유"
                echo ""
                read -k 1 
                ;;
            9) 
                clear
                echo "${CYAN}📦 [ 임시 저장 (Stash) ]${RESET}"
                echo ""
                echo "${GREEN}📖 간단 설명${RESET}"
                echo "  Stash는 작업 중인 변경사항을 ${YELLOW}임시로 저장${RESET}하는 기능이에요."
                echo "  급하게 다른 작업을 해야 할 때 유용해요!"
                echo ""
                echo "${GREEN}🎯 언제 사용하나요?${RESET}"
                echo "  • 작업 중에 급하게 브랜치를 바꿔야 할 때"
                echo "  • 아직 커밋하기 싫은데 잠깐 다른 일을 해야 할 때"
                echo ""
                echo "${GREEN}💻 명령어${RESET}"
                echo "  ${CYAN}git stash${RESET}"
                echo "     → 변경사항 임시 저장"
                echo ""
                echo "  ${CYAN}git stash pop${RESET}"
                echo "     → 임시 저장 꺼내기 (삭제됨)"
                echo ""
                echo "  ${CYAN}git stash list${RESET}"
                echo "     → 임시 저장 목록 보기"
                echo ""
                echo "  ${CYAN}git stash apply${RESET}"
                echo "     → 임시 저장 꺼내기 (유지됨)"
                echo ""
                echo "${GREEN}💡 비유하자면${RESET}"
                echo "  책상 위의 작업물을 서랍에 넣어두고,"
                echo "  나중에 다시 꺼내서 이어서 작업하는 것!"
                echo ""
                read -k 1 
                ;;
            10) 
                clear
                echo "${CYAN}🔄 [ 일반적인 Git 워크플로우 ]${RESET}"
                echo ""
                echo "${GREEN}📖 기본 흐름${RESET}"
                echo ""
                echo "  ${YELLOW}1. 시작${RESET}"
                echo "     git pull                    # 최신 상태로 업데이트"
                echo "     git checkout -b feature/xx  # 새 브랜치 생성"
                echo ""
                echo "  ${YELLOW}2. 작업${RESET}"
                echo "     (코드 작성...)"
                echo "     git status                  # 변경사항 확인"
                echo "     git add .                   # 변경사항 추가"
                echo "     git commit -m \"메시지\"      # 커밋"
                echo ""
                echo "  ${YELLOW}3. 반복${RESET}"
                echo "     (더 작업하고 싶으면 2번 반복)"
                echo ""
                echo "  ${YELLOW}4. 공유${RESET}"
                echo "     git push                    # 원격에 업로드"
                echo ""
                echo "  ${YELLOW}5. 병합${RESET}"
                echo "     (GitHub에서 Pull Request 생성)"
                echo "     또는:"
                echo "     git checkout main"
                echo "     git merge feature/xx"
                echo ""
                echo "${GREEN}💡 매일의 루틴${RESET}"
                echo "  시작: git pull"
                echo "  종료: git add . → git commit -m \"...\" → git push"
                echo ""
                read -k 1 
                ;;
            11) 
                clear
                echo "${CYAN}⚠️ [ 자주 하는 실수와 해결법 ]${RESET}"
                echo ""
                echo "${RED}1. 커밋 메시지를 잘못 썼어요${RESET}"
                echo "   해결: ${CYAN}git commit --amend${RESET}"
                echo ""
                echo "${RED}2. 커밋을 취소하고 싶어요${RESET}"
                echo "   해결: ${CYAN}git reset HEAD~1${RESET} (변경사항 유지)"
                echo "   해결: ${CYAN}git reset --hard HEAD~1${RESET} (완전 삭제)"
                echo ""
                echo "${RED}3. 푸시한 후에 문제를 발견했어요${RESET}"
                echo "   해결: ${CYAN}git revert <커밋해시>${RESET}"
                echo "   (새 커밋으로 취소 - 안전한 방법)"
                echo ""
                echo "${RED}4. 잘못된 브랜치에서 작업했어요${RESET}"
                echo "   해결: ${CYAN}git stash${RESET} → 브랜치 이동 → ${CYAN}git stash pop${RESET}"
                echo ""
                echo "${RED}5. merge 충돌이 났어요${RESET}"
                echo "   해결: 파일 열어서 직접 수정 → add → commit"
                echo ""
                echo "${RED}6. git add를 취소하고 싶어요${RESET}"
                echo "   해결: ${CYAN}git reset HEAD <파일명>${RESET}"
                echo ""
                echo "${RED}7. 파일을 삭제했는데 복구하고 싶어요${RESET}"
                echo "   해결: ${CYAN}git checkout -- <파일명>${RESET}"
                echo ""
                echo "${GREEN}💡 가장 중요한 팁${RESET}"
                echo "   문제가 생기면 ${CYAN}git reflog${RESET}로 이력을 확인하세요!"
                echo "   대부분의 실수는 복구할 수 있습니다 😊"
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}
function _seongmin_python() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${YELLOW}🐍 [ Python 명령어 - 친절 모드 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} pv     - 가상환경 생성 (venv)"
        echo "  ${CYAN}[2]${RESET} pa     - 가상환경 활성화 (activate)"
        echo "  ${CYAN}[3]${RESET} pd     - 가상환경 비활성화 (deactivate)"
        echo "  ${CYAN}[4]${RESET} pynew  - 새 프로젝트 시작 (New Project)"
        echo "  ${CYAN}[5]${RESET} pysetup- 프로젝트 셋업 (Setup)"
        echo "  ${CYAN}[6]${RESET} pl     - 설치된 패키지 보기 (List)"
        echo "  ${CYAN}[7]${RESET} plo    - 업데이트할 패키지 확인 (Outdated)"
        echo "  ${CYAN}[8]${RESET} pfr    - 패키지 목록 저장 (Freeze)"
        echo "  ${CYAN}[9]${RESET} pys    - 웹서버 실행 (Simple Server)"
        echo "  ${CYAN}[10]${RESET} pir   - requirements.txt 설치 (Install Requirements)"
        echo "  ${CYAN}[11]${RESET} pyv   - 설치된 Python 버전 확인 (Python Versions)"
        echo "  ${CYAN}[12]${RESET} pyvl  - 가상환경 목록 및 상세정보 (Venv List)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) 
                clear
                echo "${GREEN}📦 [ 가상환경 생성 (Make Venv) ]${RESET}"
                echo "설명: 프로젝트만의 독립적인 패키지 설치 공간인 'venv' 폴더를 만듭니다."
                echo "      이걸 안 하면 다른 프로젝트랑 패키지가 섞여서 꼬일 수 있어요!"
                echo ""
                
                # 사용 가능한 Python 버전 표시
                echo "${CYAN}🐍 사용 가능한 Python 버전:${RESET}"
                echo "----------------------------------------"
                echo "  ${GREEN}[0]${RESET} 시스템 기본 ($(python3 --version 2>&1))"
                
                local py_versions=()
                local idx=1
                
                # pyenv 버전 확인
                if command -v pyenv &> /dev/null; then
                    while IFS= read -r ver; do
                        if [[ -n "$ver" && "$ver" != "system" ]]; then
                            py_versions+=("$ver")
                            echo "  ${GREEN}[$idx]${RESET} pyenv: $ver"
                            ((idx++))
                        fi
                    done <<< "$(pyenv versions --bare 2>/dev/null)"
                fi
                
                # Homebrew Python 확인
                for py_path in /opt/homebrew/opt/python@*/bin/python*; do
                    if [[ -x "$py_path" && "$py_path" != *"config"* ]]; then
                        local py_ver=$($py_path --version 2>&1 | awk '{print $2}')
                        if [[ -n "$py_ver" ]]; then
                            py_versions+=("$py_path")
                            echo "  ${GREEN}[$idx]${RESET} Homebrew: Python $py_ver ($py_path)"
                            ((idx++))
                        fi
                    fi
                done
                
                echo "----------------------------------------"
                echo ""
                echo -n "사용할 Python 버전 선택 (숫자 입력, 기본값 0): "
                read py_choice
                
                local selected_python="python3"
                
                if [[ -z "$py_choice" || "$py_choice" == "0" ]]; then
                    selected_python="python3"
                    echo "${CYAN}시스템 기본 Python을 사용합니다.${RESET}"
                elif [[ "$py_choice" =~ ^[0-9]+$ && $py_choice -le ${#py_versions[@]} ]]; then
                    local selected=${py_versions[$py_choice]}
                    if [[ "$selected" == /* ]]; then
                        # Homebrew 경로
                        selected_python="$selected"
                    else
                        # pyenv 버전
                        selected_python="$HOME/.pyenv/versions/$selected/bin/python"
                    fi
                    echo "${CYAN}선택된 Python: $selected_python${RESET}"
                else
                    echo "${YELLOW}잘못된 선택. 시스템 기본 Python을 사용합니다.${RESET}"
                fi
                
                echo ""
                echo -n "📁 가상환경 폴더 이름 (기본값: venv): "
                read venv_name
                if [[ -z "$venv_name" ]]; then
                    venv_name="venv"
                fi
                
                echo ""
                echo "실행할 명령어: ${YELLOW}$selected_python -m venv $venv_name${RESET}"
                echo ""
                $selected_python -m venv "$venv_name"
                echo "${GREEN}✅ '$venv_name' 폴더 생성 완료!${RESET}"
                echo "${CYAN}활성화 명령어: source $venv_name/bin/activate${RESET}"
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}🔋 [ 가상환경 활성화 (Activate) ]${RESET}"
                echo "설명: 방금 만든 'venv' 가상환경 안으로 들어갑니다."
                echo "      이제부터 설치하는 패키지는 모두 'venv' 안에만 저장됩니다."
                echo ""
                echo "실행할 명령어: ${YELLOW}source venv/bin/activate${RESET}"
                echo ""
                if [ -d "venv" ]; then
                    source venv/bin/activate
                    echo "${GREEN}✅ 가상환경이 활성화되었습니다! (프롬프트 앞의 (venv) 확인)${RESET}"
                else
                    echo "${RED}❌ 'venv' 폴더가 안 보여요. [1]번으로 먼저 만들어주세요.${RESET}"
                fi
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}🔌 [ 가상환경 비활성화 (Deactivate) ]${RESET}"
                echo "설명: 가상환경에서 나와서 원래 시스템 환경으로 돌아갑니다."
                echo ""
                echo "실행할 명령어: ${YELLOW}deactivate${RESET}"
                echo ""
                if [[ "$VIRTUAL_ENV" != "" ]]; then
                    deactivate
                    echo "${GREEN}✅ 비활성화 완료! 이제 자유의 몸입니다.${RESET}"
                else
                    echo "${RED}❌ 현재 활성화된 가상환경이 없는데요?${RESET}"
                fi
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}✨ [ 새 프로젝트 시작 (New Project) ]${RESET}"
                echo "설명: 1. 가상환경 생성 -> 2. 활성화 -> 3. pip 업데이트를 한 번에 해줍니다."
                echo "      새로운 파이썬 프로젝트를 시작할 때 딱 좋아요!"
                echo ""
                
                # 사용 가능한 Python 버전 표시
                echo "${CYAN}🐍 사용할 Python 버전 선택:${RESET}"
                echo "----------------------------------------"
                echo "  ${GREEN}[0]${RESET} 시스템 기본 ($(python3 --version 2>&1))"
                
                local py_versions=()
                local idx=1
                
                if command -v pyenv &> /dev/null; then
                    while IFS= read -r ver; do
                        if [[ -n "$ver" && "$ver" != "system" ]]; then
                            py_versions+=("$ver")
                            echo "  ${GREEN}[$idx]${RESET} pyenv: $ver"
                            ((idx++))
                        fi
                    done <<< "$(pyenv versions --bare 2>/dev/null)"
                fi
                
                for py_path in /opt/homebrew/opt/python@*/bin/python*; do
                    if [[ -x "$py_path" && "$py_path" != *"config"* ]]; then
                        local py_ver=$($py_path --version 2>&1 | awk '{print $2}')
                        if [[ -n "$py_ver" ]]; then
                            py_versions+=("$py_path")
                            echo "  ${GREEN}[$idx]${RESET} Homebrew: Python $py_ver"
                            ((idx++))
                        fi
                    fi
                done
                
                echo "----------------------------------------"
                echo -n "선택 (기본값 0): "
                read py_choice
                
                local selected_python="python3"
                
                if [[ -z "$py_choice" || "$py_choice" == "0" ]]; then
                    selected_python="python3"
                elif [[ "$py_choice" =~ ^[0-9]+$ && $py_choice -le ${#py_versions[@]} ]]; then
                    local selected=${py_versions[$py_choice]}
                    if [[ "$selected" == /* ]]; then
                        selected_python="$selected"
                    else
                        selected_python="$HOME/.pyenv/versions/$selected/bin/python"
                    fi
                fi
                
                echo ""
                echo -n "📁 가상환경 폴더 이름 (기본값: venv): "
                read venv_name
                if [[ -z "$venv_name" ]]; then
                    venv_name="venv"
                fi
                
                echo ""
                echo "실행할 명령어들:"
                echo "  1. ${YELLOW}$selected_python -m venv $venv_name${RESET}"
                echo "  2. ${YELLOW}source $venv_name/bin/activate${RESET}"
                echo "  3. ${YELLOW}pip install --upgrade pip${RESET}"
                echo ""
                $selected_python -m venv "$venv_name" && source "$venv_name/bin/activate" && pip install --upgrade pip
                echo ""
                echo "${GREEN}✅ 준비 끝! 이제 코딩만 하시면 됩니다.${RESET}"
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}🛠️  [ 프로젝트 셋업 (Setup) ]${RESET}"
                echo "설명: 남이 만든 프로젝트를 가져왔을 때 씁니다."
                echo "      가상환경을 만들고, 'requirements.txt'에 적힌 패키지들을 싹 설치해줍니다."
                echo ""
                
                # 사용 가능한 Python 버전 표시
                echo "${CYAN}🐍 사용할 Python 버전 선택:${RESET}"
                echo "----------------------------------------"
                echo "  ${GREEN}[0]${RESET} 시스템 기본 ($(python3 --version 2>&1))"
                
                local py_versions=()
                local idx=1
                
                if command -v pyenv &> /dev/null; then
                    while IFS= read -r ver; do
                        if [[ -n "$ver" && "$ver" != "system" ]]; then
                            py_versions+=("$ver")
                            echo "  ${GREEN}[$idx]${RESET} pyenv: $ver"
                            ((idx++))
                        fi
                    done <<< "$(pyenv versions --bare 2>/dev/null)"
                fi
                
                for py_path in /opt/homebrew/opt/python@*/bin/python*; do
                    if [[ -x "$py_path" && "$py_path" != *"config"* ]]; then
                        local py_ver=$($py_path --version 2>&1 | awk '{print $2}')
                        if [[ -n "$py_ver" ]]; then
                            py_versions+=("$py_path")
                            echo "  ${GREEN}[$idx]${RESET} Homebrew: Python $py_ver"
                            ((idx++))
                        fi
                    fi
                done
                
                echo "----------------------------------------"
                echo -n "선택 (기본값 0): "
                read py_choice
                
                local selected_python="python3"
                
                if [[ -z "$py_choice" || "$py_choice" == "0" ]]; then
                    selected_python="python3"
                elif [[ "$py_choice" =~ ^[0-9]+$ && $py_choice -le ${#py_versions[@]} ]]; then
                    local selected=${py_versions[$py_choice]}
                    if [[ "$selected" == /* ]]; then
                        selected_python="$selected"
                    else
                        selected_python="$HOME/.pyenv/versions/$selected/bin/python"
                    fi
                fi
                
                echo ""
                echo -n "📁 가상환경 폴더 이름 (기본값: venv): "
                read venv_name
                if [[ -z "$venv_name" ]]; then
                    venv_name="venv"
                fi
                
                echo ""
                echo "실행할 명령어들:"
                echo "  1. ${YELLOW}$selected_python -m venv $venv_name${RESET}"
                echo "  2. ${YELLOW}source $venv_name/bin/activate${RESET}"
                echo "  3. ${YELLOW}pip install -r requirements.txt${RESET} (파일이 있다면)"
                echo ""
                $selected_python -m venv "$venv_name" && source "$venv_name/bin/activate" && pip install --upgrade pip
                if [ -f "requirements.txt" ]; then
                    echo "📜 requirements.txt 발견! 패키지 설치 중..."
                    pip install -r requirements.txt
                    echo "${GREEN}✅ 모든 패키지 설치 완료!${RESET}"
                else
                    echo "${YELLOW}⚠️ requirements.txt 파일이 없어서 기본 셋업만 했습니다.${RESET}"
                fi
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}📋 [ 설치된 패키지 목록 (List) ]${RESET}"
                echo "설명: 현재 환경에 설치된 모든 파이썬 패키지를 보여줍니다."
                echo ""
                echo "실행할 명령어: ${YELLOW}pip list${RESET}"
                echo ""
                pip list
                echo ""
                echo "${GREEN}👆 위 목록이 현재 설치된 친구들입니다.${RESET}"
                read -k 1 
                ;;
            7) 
                clear
                echo "${GREEN}🆕 [ 업데이트 확인 (Outdated) ]${RESET}"
                echo "설명: 더 새로운 버전이 나온 패키지가 있는지 검사합니다."
                echo ""
                echo "실행할 명령어: ${YELLOW}pip list --outdated${RESET}"
                echo ""
                pip list --outdated
                echo ""
                echo "${GREEN}👆 업데이트 가능한 패키지가 있다면 위에 뜹니다.${RESET}"
                read -k 1 
                ;;
            8) 
                clear
                echo "${GREEN}❄️  [ 패키지 목록 저장 (Freeze) ]${RESET}"
                echo "설명: 현재 설치된 패키지 목록을 'requirements.txt' 파일로 저장합니다."
                echo "      나중에 다른 컴퓨터에서 똑같은 환경을 만들 때 필요합니다."
                echo ""
                echo "실행할 명령어: ${YELLOW}pip freeze > requirements.txt${RESET}"
                echo ""
                pip freeze > requirements.txt
                echo "${GREEN}✅ 'requirements.txt' 파일 생성 완료!${RESET}"
                echo "내용 확인:"
                cat requirements.txt | head -5
                echo "(...)"
                read -k 1 
                ;;
            9) 
                clear
                echo "${GREEN}🌐 [ 간단 웹서버 (Simple Server) ]${RESET}"
                echo "설명: 현재 폴더의 파일들을 웹 브라우저에서 볼 수 있게 해줍니다."
                echo "      HTML 파일 테스트할 때 유용해요."
                echo ""
                echo "실행할 명령어: ${YELLOW}python3 -m http.server${RESET}"
                echo ""
                echo "멈추려면 [Ctrl + C]를 누르세요."
                python3 -m http.server
                read -k 1 
                ;;
            0|q|Q) return ;;
            10) 
                clear
                echo "${GREEN}📦 [ requirements.txt 설치 (Install Requirements) ]${RESET}"
                echo "설명: 현재 디렉토리의 requirements.txt 파일에 적힌"
                echo "      패키지들을 모두 설치합니다."
                echo ""
                
                if [ -f "requirements.txt" ]; then
                    echo "${CYAN}📜 requirements.txt 내용:${RESET}"
                    echo "----------------------------------------"
                    cat requirements.txt | head -10
                    local total_lines=$(wc -l < requirements.txt | tr -d ' ')
                    if [[ $total_lines -gt 10 ]]; then
                        echo "... (총 ${total_lines}개 패키지)"
                    fi
                    echo "----------------------------------------"
                    echo ""
                    echo "실행할 명령어: ${YELLOW}pip install -r requirements.txt${RESET}"
                    echo ""
                    echo -n "설치를 진행할까요? (y/n, 기본값 y): "
                    read confirm
                    if [[ -z "$confirm" || "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        pip install -r requirements.txt
                        echo ""
                        echo "${GREEN}✅ 모든 패키지 설치 완료!${RESET}"
                    else
                        echo "설치를 취소했습니다."
                    fi
                else
                    echo "${RED}❌ requirements.txt 파일이 없습니다.${RESET}"
                    echo "현재 디렉토리: $(pwd)"
                    echo ""
                    echo "${YELLOW}팁: [8]번 메뉴로 requirements.txt를 먼저 생성하거나,${RESET}"
                    echo "${YELLOW}    프로젝트 폴더로 이동 후 다시 시도해보세요.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            11) 
                clear
                echo "${GREEN}🐍 [ 설치된 Python 버전 확인 ]${RESET}"
                echo "설명: 시스템에 설치된 모든 Python을 출처와 함께 보여줍니다."
                echo ""
                
                echo "${CYAN}══════════════════════════════════════════════════${RESET}"
                
                # 1. macOS 기본 Python
                echo "${YELLOW}🍎 macOS 기본 (System Default)${RESET}"
                echo "----------------------------------------"
                if [[ -x "/usr/bin/python3" ]]; then
                    local sys_ver=$(/usr/bin/python3 --version 2>&1)
                    echo "  ✅ $sys_ver"
                    echo "     경로: /usr/bin/python3"
                else
                    echo "  ❌ 설치되어 있지 않음"
                fi
                echo ""
                
                # 2. Homebrew Python
                echo "${GREEN}🍺 Homebrew 설치${RESET}"
                echo "----------------------------------------"
                local brew_found=false
                # glob 패턴 매칭 실패 시 빈 배열 반환하도록 설정
                setopt local_options null_glob
                local brew_paths=(/opt/homebrew/opt/python@*/bin/python3 /usr/local/opt/python@*/bin/python3)
                if [[ ${#brew_paths[@]} -gt 0 ]]; then
                    for py_path in "${brew_paths[@]}"; do
                        if [[ -x "$py_path" ]]; then
                            local py_ver=$($py_path --version 2>&1)
                            echo "  ✅ $py_ver"
                            echo "     경로: $py_path"
                            brew_found=true
                        fi
                    done
                fi
                if [[ "$brew_found" == "false" ]]; then
                    echo "  ❌ Homebrew로 설치된 Python 없음"
                fi
                echo ""
                
                # 3. pyenv Python
                echo "${PINK}🔧 pyenv 설치${RESET}"
                echo "----------------------------------------"
                if command -v pyenv &> /dev/null; then
                    local pyenv_versions=$(pyenv versions --bare 2>/dev/null)
                    if [[ -n "$pyenv_versions" ]]; then
                        while IFS= read -r ver; do
                            if [[ -n "$ver" && "$ver" != "system" ]]; then
                                echo "  ✅ Python $ver"
                                echo "     경로: ~/.pyenv/versions/$ver/bin/python"
                            fi
                        done <<< "$pyenv_versions"
                    else
                        echo "  ❌ pyenv로 설치된 Python 없음"
                    fi
                else
                    echo "  ⚠️ pyenv가 설치되어 있지 않음"
                fi
                echo ""
                
                # 4. 공식 설치 (python.org)
                echo "${CYAN}📦 공식 설치 (python.org 다운로드)${RESET}"
                echo "----------------------------------------"
                local official_found=false
                local official_paths=(/Library/Frameworks/Python.framework/Versions/*/bin/python3)
                if [[ ${#official_paths[@]} -gt 0 ]]; then
                    for py_path in "${official_paths[@]}"; do
                        if [[ -x "$py_path" ]]; then
                            local py_ver=$($py_path --version 2>&1)
                            echo "  ✅ $py_ver"
                            echo "     경로: $py_path"
                            official_found=true
                        fi
                    done
                fi
                if [[ "$official_found" == "false" ]]; then
                    echo "  ❌ 공식 설치 파일 없음"
                fi
                echo ""
                
                # 5. 현재 사용 중인 Python
                echo "${CYAN}══════════════════════════════════════════════════${RESET}"
                echo "${YELLOW}✨ 현재 기본 python3 명령어:${RESET}"
                echo "   $(which python3) -> $(python3 --version 2>&1)"
                
                if [[ -n "$VIRTUAL_ENV" ]]; then
                    echo ""
                    echo "${GREEN}📦 활성화된 가상환경:${RESET}"
                    echo "   $VIRTUAL_ENV"
                fi
                
                echo ""
                read -k 1 
                ;;
            12) 
                clear
                echo "${GREEN}📦 [ 가상환경 목록 및 상세정보 ]${RESET}"
                echo "설명: 현재 디렉토리에서 가상환경 폴더를 찾아 상세 정보를 보여줍니다."
                echo ""
                echo "실행할 명령어: ${YELLOW}find . -maxdepth 3 -name 'pyvenv.cfg' -type f${RESET}"
                echo "                 (가상환경 설정 파일을 찾습니다)"
                echo ""
                
                echo "${CYAN}══════════════════════════════════════════════════${RESET}"
                echo "${YELLOW}🔍 가상환경 검색 중... (현재 디렉토리: $(pwd))${RESET}"
                echo "${CYAN}══════════════════════════════════════════════════${RESET}"
                echo ""
                
                # 가상환경 찾기 (pyvenv.cfg 파일이 있는 폴더)
                local venv_list=()
                local idx=1
                
                while IFS= read -r cfg_file; do
                    if [[ -n "$cfg_file" ]]; then
                        local venv_dir=$(dirname "$cfg_file")
                        venv_list+=("$venv_dir")
                        
                        # 기본 정보 추출
                        local venv_name=$(basename "$venv_dir")
                        local py_version=$(grep "version" "$cfg_file" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d ' ')
                        local py_home=$(grep "^home" "$cfg_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
                        
                        # Python 출처 판별
                        local py_source=""
                        if [[ "$py_home" == "/usr/bin" ]]; then
                            py_source="🍎 macOS 기본"
                        elif [[ "$py_home" == *"/opt/homebrew/"* || "$py_home" == *"/usr/local/opt/"* || "$py_home" == *"/usr/local/Cellar/"* ]]; then
                            py_source="🍺 Homebrew"
                        elif [[ "$py_home" == *"/.pyenv/"* ]]; then
                            py_source="🔧 pyenv"
                        elif [[ "$py_home" == *"/Library/Frameworks/Python.framework/"* ]]; then
                            py_source="📦 python.org"
                        else
                            py_source="기타"
                        fi
                        
                        # 활성화 상태 확인
                        local abs_venv_path=$(cd "$venv_dir" 2>/dev/null && pwd)
                        local is_active=""
                        if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" == "$abs_venv_path" ]]; then
                            is_active=" ${GREEN}🟢 ACTIVE${RESET}"
                        fi
                        
                        echo "  ${GREEN}[$idx]${RESET} ${CYAN}$venv_name${RESET}$is_active"
                        echo "      경로: $venv_dir"
                        echo "      Python: $py_version ($py_source)"
                        echo "      Python 경로: $py_home"
                        echo ""
                        ((idx++))
                    fi
                done <<< "$(find . -maxdepth 3 -name 'pyvenv.cfg' -type f 2>/dev/null)"
                
                if [[ ${#venv_list[@]} -eq 0 ]]; then
                    echo "${RED}❌ 가상환경을 찾을 수 없습니다.${RESET}"
                    echo ""
                    echo "${YELLOW}팁: [1]번 또는 [4]번 메뉴로 새 가상환경을 만들어보세요.${RESET}"
                    echo ""
                    read -k 1
                else
                    echo "${CYAN}══════════════════════════════════════════════════${RESET}"
                    echo ""
                    echo -n "상세정보를 볼 가상환경 번호 선택 (0=취소): "
                    read venv_choice
                    
                    if [[ "$venv_choice" =~ ^[0-9]+$ && $venv_choice -ge 1 && $venv_choice -le ${#venv_list[@]} ]]; then
                        local selected_venv=${venv_list[$venv_choice]}
                        local selected_name=$(basename "$selected_venv")
                        
                        clear
                        echo "${GREEN}📊 [ '$selected_name' 가상환경 상세정보 ]${RESET}"
                        echo ""
                        
                        # 1. 기본 정보
                        echo "${YELLOW}1️⃣ 기본 정보${RESET}"
                        echo "   실행 명령어: ${CYAN}cat $selected_venv/pyvenv.cfg${RESET}"
                        echo "   ----------------------------------------"
                        if [[ -f "$selected_venv/pyvenv.cfg" ]]; then
                            cat "$selected_venv/pyvenv.cfg" | sed 's/^/   /'
                        fi
                        echo ""
                        
                        # 2. Python 버전
                        echo "${YELLOW}2️⃣ Python 버전${RESET}"
                        echo "   실행 명령어: ${CYAN}$selected_venv/bin/python --version${RESET}"
                        echo "   ----------------------------------------"
                        if [[ -x "$selected_venv/bin/python" ]]; then
                            echo "   $($selected_venv/bin/python --version 2>&1)"
                        else
                            echo "   ${RED}Python 실행 파일을 찾을 수 없음${RESET}"
                        fi
                        echo ""
                        
                        # 3. 생성일 (폴더 수정 시간)
                        echo "${YELLOW}3️⃣ 생성일${RESET}"
                        echo "   실행 명령어: ${CYAN}stat -f '%Sm' $selected_venv${RESET}"
                        echo "   ----------------------------------------"
                        local created=$(stat -f '%Sm' "$selected_venv" 2>/dev/null || stat -c '%y' "$selected_venv" 2>/dev/null | cut -d'.' -f1)
                        echo "   $created"
                        echo ""
                        
                        # 4. 디스크 사용량
                        echo "${YELLOW}4️⃣ 디스크 사용량${RESET}"
                        echo "   실행 명령어: ${CYAN}du -sh $selected_venv${RESET}"
                        echo "   ----------------------------------------"
                        echo "   $(du -sh "$selected_venv" 2>/dev/null | awk '{print $1}')"
                        echo ""
                        
                        # 5. 설치된 패키지 수
                        echo "${YELLOW}5️⃣ 설치된 패키지${RESET}"
                        echo "   실행 명령어: ${CYAN}$selected_venv/bin/pip list${RESET}"
                        echo "   ----------------------------------------"
                        if [[ -x "$selected_venv/bin/pip" ]]; then
                            local pkg_count=$($selected_venv/bin/pip list 2>/dev/null | tail -n +3 | wc -l | tr -d ' ')
                            echo "   총 ${GREEN}${pkg_count}${RESET}개 패키지 설치됨"
                            echo ""
                            echo "   주요 패키지 (상위 10개):"
                            $selected_venv/bin/pip list 2>/dev/null | tail -n +3 | head -10 | sed 's/^/   /'
                        else
                            echo "   ${RED}pip을 찾을 수 없음${RESET}"
                        fi
                        echo ""
                        
                        # 6. 현재 시스템 Python 정보
                        echo "${YELLOW}6️⃣ 현재 시스템 Python${RESET}"
                        echo "   실행 명령어: ${CYAN}which python3${RESET}"
                        echo "   ----------------------------------------"
                        local current_py=$(which python3 2>/dev/null)
                        local current_py_ver=$(python3 --version 2>&1)
                        echo "   경로: $current_py"
                        echo "   버전: $current_py_ver"
                        
                        # Python 출처 판별
                        echo -n "   출처: "
                        if [[ "$current_py" == "/usr/bin/python3" ]]; then
                            echo "${YELLOW}🍎 macOS 기본${RESET}"
                        elif [[ "$current_py" == *"/opt/homebrew/"* || "$current_py" == *"/usr/local/opt/"* ]]; then
                            echo "${GREEN}🍺 Homebrew${RESET}"
                        elif [[ "$current_py" == *"/.pyenv/"* ]]; then
                            echo "${PINK}🔧 pyenv${RESET}"
                        elif [[ "$current_py" == *"/Library/Frameworks/Python.framework/"* ]]; then
                            echo "${CYAN}📦 python.org 공식${RESET}"
                        elif [[ -n "$VIRTUAL_ENV" ]]; then
                            echo "${GREEN}📦 가상환경 ($VIRTUAL_ENV)${RESET}"
                        else
                            echo "기타"
                        fi
                        echo ""
                        
                        # 6. 활성화 안내
                        echo "${CYAN}══════════════════════════════════════════════════${RESET}"
                        echo "${GREEN}🚀 이 가상환경을 활성화하려면:${RESET}"
                        echo "   ${YELLOW}source $selected_venv/bin/activate${RESET}"
                        echo ""
                        echo -n "지금 활성화할까요? (y/n): "
                        read activate_choice
                        if [[ "$activate_choice" == "y" || "$activate_choice" == "Y" ]]; then
                            source "$selected_venv/bin/activate"
                            echo "${GREEN}✅ '$selected_name' 가상환경이 활성화되었습니다!${RESET}"
                        fi
                        echo ""
                        read -k 1
                    elif [[ "$venv_choice" != "0" ]]; then
                        echo "${RED}잘못된 선택입니다.${RESET}"
                        sleep 1
                    fi
                fi
                ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Java 서브메뉴
function _seongmin_java() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${GREEN}☕ [ Java 명령어 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} jv - jenv versions (설치된 버전들)"
        echo "  ${CYAN}[2]${RESET} 현재 Java 버전 확인"
        echo "  ${CYAN}[3]${RESET} 🏃 실행 (Single File)"
        echo "  ${CYAN}[4]${RESET} 🐘 Gradle (Build/Run)"
        echo "  ${CYAN}[5]${RESET} 🪶 Maven (Build/Run)"
        echo "  ${CYAN}[6]${RESET} 🔄 자바 버전 변경 (Switch Version)"
        echo "  ${CYAN}[7]${RESET} 🧐 프로젝트 버전 확인 (Check Project Version)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) clear; jenv versions; echo ""; read -k 1 ;;
            2) clear; java --version; echo ""; read -k 1 ;;
            3) clear; echo -n "🏃 실행할 자바 파일명(예: Main.java): "; read f; jarun "$f"; echo ""; read -k 1 ;;
            4) _seongmin_java_gradle ;;
            5) _seongmin_java_maven ;;
            6) _seongmin_java_switch ;;
            7) _seongmin_java_check_project ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Gradle 서브메뉴
function _seongmin_java_gradle() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${YELLOW}🐘 [ Gradle 명령어 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} grb - Clean Build (./gradlew clean build)"
        echo "  ${CYAN}[2]${RESET} grr - Boot Run    (./gradlew bootRun)"
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) clear; ./gradlew clean build; echo ""; read -k 1 ;;
            2) clear; ./gradlew bootRun; echo ""; read -k 1 ;;
            0|q|Q) return ;;
            *) echo "😅 다시 선택해줘!"; sleep 1 ;;
        esac
    done
}

# Maven 서브메뉴
function _seongmin_java_maven() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    while true; do
        clear
        echo "${YELLOW}🪶 [ Maven 명령어 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} mvb - Clean Install (mvn clean install)"
        echo "  ${CYAN}[2]${RESET} mvr - Boot Run      (mvn spring-boot:run)"
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1) clear; mvn clean install; echo ""; read -k 1 ;;
            2) clear; mvn spring-boot:run; echo ""; read -k 1 ;;
            0|q|Q) return ;;
            *) echo "😅 다시 선택해줘!"; sleep 1 ;;
        esac
    done

}

# 자바 버전 변경 서브메뉴
function _seongmin_java_switch() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${YELLOW}🔄 [ Java 버전 변경 (jenv) ]${RESET}"
        echo ""
        echo "현재 설치된 Java 버전 목록:"
        echo "----------------------------------------"
        jenv versions
        echo "----------------------------------------"
        echo ""
        echo "${CYAN}변경할 버전을 입력해주세요 (목록에 있는 이름 그대로)${RESET}"
        echo "${CYAN}(예: 17, 11.0, corretto64-17 등)${RESET}"
        echo "['q' 입력 시 뒤로가기]"
        echo ""
        echo -n "버전 입력 > "
        read ver
        
        if [[ "$ver" == "q" || "$ver" == "Q" ]]; then
            return
        fi

        if [[ -z "$ver" ]]; then
            echo "${RED}버전을 입력해야 합니다!${RESET}"
            sleep 1
            continue
        fi

        echo ""
        echo "${GREEN}어떤 범위로 적용할까요?${RESET}"
        echo "  ${CYAN}[1]${RESET} Global  (모든 터미널 기본값 변경)"
        echo "  ${CYAN}[2]${RESET} Local   (현재 디렉토리에만 적용 - .java-version 생성)"
        echo "  ${CYAN}[3]${RESET} Shell   (현재 터미널 창에만 임시 적용)"
        echo "  ${CYAN}[0]${RESET} 취소"
        echo ""
        echo -n "  범위 선택 > "
        read scope

        case $scope in
            1) 
                echo "Applying: jenv global $ver"
                jenv global "$ver"
                echo "${GREEN}✅ Global 설정 완료!${RESET}"
                ;;
            2) 
                echo "Applying: jenv local $ver"
                jenv local "$ver"
                echo "${GREEN}✅ Local (.java-version) 설정 완료!${RESET}"
                ;;
            3) 
                echo "Applying: jenv shell $ver"
                jenv shell "$ver"
                echo "${GREEN}✅ Shell (Temporary) 설정 완료!${RESET}"
                ;;
            0) echo "취소되었습니다."; sleep 1; continue ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1; continue ;;
        esac
        
        echo ""
        echo "${YELLOW}🔍 변경된 버전 확인:${RESET}"
        java -version
        echo ""
        echo "엔터를 누르면 메뉴로 돌아갑니다..."
        read -k 1
        return
    done
}

# 프로젝트 버전 확인 (Java/Spring)
function _seongmin_java_check_project() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    clear
    echo "${YELLOW}🧐 [ 현재 프로젝트 버전 확인 ]${RESET}"
    echo "현재 위치: $(pwd)"
    echo "----------------------------------------"
    
    local found=false

    # 1. Gradle Check
    if [[ -f "build.gradle" || -f "build.gradle.kts" ]]; then
        found=true
        echo "${GREEN}🐘 Gradle 프로젝트 감지됨!${RESET}"
        
        # Java Version
        echo -n "   ☕ Java Version: "
        # Try to find sourceCompatibility or toolchain
        local java_ver=$(grep -E "sourceCompatibility|targetCompatibility|languageVersion" build.gradle build.gradle.kts 2>/dev/null | head -1 | tr -d "\"' =" | grep -o "[0-9]\+")
        if [[ -n "$java_ver" ]]; then
            echo "${CYAN}$java_ver${RESET}"
        else
            echo "${RED}설정 파일에서 못 찾음 (직접 확인 필요)${RESET}"
        fi

        # Spring Boot Version
        echo -n "   🍃 Spring Boot:  "
        local boot_ver=$(grep "id 'org.springframework.boot' version" build.gradle build.gradle.kts 2>/dev/null | cut -d "'" -f 4)
        if [[ -z "$boot_ver" ]]; then
             boot_ver=$(grep 'id "org.springframework.boot" version' build.gradle build.gradle.kts 2>/dev/null | cut -d '"' -f 4)
        fi
        
        if [[ -n "$boot_ver" ]]; then
            echo "${CYAN}$boot_ver${RESET}"
        else
            echo "${RED}Spring Boot 아님 또는 버전 못 찾음${RESET}"
        fi
    fi

    # 2. Maven Check
    if [[ -f "pom.xml" ]]; then
        found=true
        echo "${YELLOW}🪶 Maven 프로젝트 감지됨!${RESET}"
        
        # Java Version (Simple grep attempt)
        echo -n "   ☕ Java Version: "
        local java_ver=$(grep -E "<java.version>|<maven.compiler.source>" pom.xml | head -1 | sed -e 's/<[^>]*>//g' | xargs)
        if [[ -n "$java_ver" ]]; then
            echo "${CYAN}$java_ver${RESET}"
        else
             echo "${RED}설정 파일에서 못 찾음 (직접 확인 필요)${RESET}"
        fi

        # Spring Boot Parent Version
        echo -n "   🍃 Spring Boot:  "
        # Try to match <artifactId>spring-boot-starter-parent</artifactId> and get the next <version> tag
        # This is a rough check using grep context. reliable xml parsing in bash is hard.
        local boot_ver=$(grep -A 1 "spring-boot-starter-parent" pom.xml | grep "<version>" | sed -e 's/<[^>]*>//g' | xargs)
        
        if [[ -n "$boot_ver" ]]; then
            echo "${CYAN}$boot_ver${RESET}"
        else
            echo "${RED}Spring Boot 아님 또는 버전 못 찾음${RESET}"
        fi
    fi

    # 3. Jenv Local Version Check
    if [[ -f ".java-version" ]]; then
        echo ""
        echo "${CYAN}📁 .java-version 파일 존재함 (jenv local):${RESET} $(cat .java-version)"
    fi

    if [[ "$found" == "false" && ! -f ".java-version" ]]; then
        echo "${RED}❌ 현재 디렉토리에서 Gradle, Maven, .java-version 파일을 찾을 수 없습니다.${RESET}"
    fi

    echo "----------------------------------------"
    echo "엔터를 누르면 돌아갑니다."
    read -k 1
}

# Homebrew 서브메뉴
function _seongmin_brew() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${YELLOW}🍺 [ Homebrew 명령어 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} bu  - brew update && upgrade"
        echo "  ${CYAN}[2]${RESET} bl  - brew list"
        echo "  ${CYAN}[3]${RESET} bsl - brew services list"
        echo "  ${CYAN}[4]${RESET} bc  - brew cleanup"
        echo "  ${CYAN}[5]${RESET} 🎨 예쁘게 보기 (Pretty List)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) clear; brew update && brew upgrade; echo ""; read -k 1 ;;
            2) clear; brew list; echo ""; read -k 1 ;;
            3) clear; brew services list; echo ""; read -k 1 ;;
            4) clear; brew cleanup; echo "✅ 정리 완료!"; read -k 1 ;;
            5) _seongmin_brew_pretty_list ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Homebrew 예쁘게 보기
function _seongmin_brew_pretty_list() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' BLUE='\033[1;34m' RESET='\033[0m'
    
    clear
    echo "${PINK}🍺 [ Homebrew 설치 목록 - 예쁘게 보기 ]${RESET}"
    echo ""
    
    echo "${YELLOW}📦 Formulae (CLI 도구들)${RESET}"
    echo "${CYAN}------------------------------------------------------------${RESET}"
    if command -v column &> /dev/null; then
        brew list --formula | column -c $(tput cols)
    else
        brew list --formula
    fi
    local f_count=$(brew list --formula | wc -l | tr -d ' ')
    echo ""
    echo "${CYAN}------------------------------------------------------------${RESET}"
    echo "  총 ${GREEN}${f_count}${RESET}개의 도구가 설치되어 있어요!"
    echo ""
    
    echo "${BLUE}🍎 Casks (Mac 애플리케이션)${RESET}"
    echo "${CYAN}------------------------------------------------------------${RESET}"
    if command -v column &> /dev/null; then
        brew list --cask | column -c $(tput cols)
    else
        brew list --cask
    fi
    local c_count=$(brew list --cask | wc -l | tr -d ' ')
    echo ""
    echo "${CYAN}------------------------------------------------------------${RESET}"
    echo "  총 ${GREEN}${c_count}${RESET}개의 앱이 설치되어 있어요!"
    
    echo ""
    echo "${YELLOW}엔터를 누르면 돌아갑니다...${RESET}"
    read -k 1
}

# Docker 서브메뉴
function _seongmin_docker() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' BLUE='\033[1;34m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🐳 [ Docker 명령어 - 카테고리 선택 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 📦 컨테이너 관리 (Container)"
        echo "  ${GREEN}[2]${RESET} 🖼️  이미지 관리 (Image)"
        echo "  ${GREEN}[3]${RESET} 🎼 Docker Compose"
        echo "  ${GREEN}[4]${RESET} 💾 볼륨 & 네트워크 (Volume & Network)"
        echo "  ${GREEN}[5]${RESET} 🔧 시스템 관리 (System)"
        echo "  ${GREEN}[6]${RESET} 📊 상태 및 버전 확인 (Status)"
        echo "  ${CYAN}[0]${RESET} ⬅️  메인 메뉴로"
        echo ""
        echo -n "  선택 > "
        read choice

        case $choice in
            1) _seongmin_docker_container ;;
            2) _seongmin_docker_image ;;
            3) _seongmin_docker_compose ;;
            4) _seongmin_docker_volume_network ;;
            5) _seongmin_docker_system ;;
            6) _seongmin_docker_check ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Docker 컨테이너 관리
function _seongmin_docker_container() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}📦 [ Docker - 컨테이너 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 실행 중인 컨테이너 목록"
        echo "      ${YELLOW}→ docker ps${RESET}"
        echo "      설명: 현재 실행 중인 모든 컨테이너를 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 모든 컨테이너 목록 (중지된 것 포함)"
        echo "      ${YELLOW}→ docker ps -a${RESET}"
        echo "      설명: 중지된 컨테이너까지 모두 보여줍니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 컨테이너 시작"
        echo "      ${YELLOW}→ docker start <컨테이너명>${RESET}"
        echo "      설명: 중지된 컨테이너를 시작합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 컨테이너 중지"
        echo "      ${YELLOW}→ docker stop <컨테이너명>${RESET}"
        echo "      설명: 실행 중인 컨테이너를 안전하게 중지합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 컨테이너 재시작"
        echo "      ${YELLOW}→ docker restart <컨테이너명>${RESET}"
        echo "      설명: 컨테이너를 재시작합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 컨테이너 삭제"
        echo "      ${YELLOW}→ docker rm <컨테이너명>${RESET}"
        echo "      설명: 중지된 컨테이너를 삭제합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 컨테이너 로그 보기"
        echo "      ${YELLOW}→ docker logs -f <컨테이너명>${RESET}"
        echo "      설명: 컨테이너의 실시간 로그를 확인합니다."
        echo ""
        echo "  ${GREEN}[8]${RESET} 컨테이너 내부 접속 (bash)"
        echo "      ${YELLOW}→ docker exec -it <컨테이너명> /bin/bash${RESET}"
        echo "      설명: 실행 중인 컨테이너 내부로 접속합니다."
        echo ""
        echo "  ${GREEN}[9]${RESET} 컨테이너 상세 정보"
        echo "      ${YELLOW}→ docker inspect <컨테이너명>${RESET}"
        echo "      설명: 컨테이너의 상세 설정과 상태를 JSON으로 출력합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}📦 실행 중인 컨테이너 목록${RESET}"
                echo "실행 명령어: docker ps"
                echo ""
                docker ps
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📦 모든 컨테이너 목록${RESET}"
                echo "실행 명령어: docker ps -a"
                echo ""
                docker ps -a
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}▶️ 컨테이너 시작${RESET}"
                echo "현재 중지된 컨테이너:"
                docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                echo -n "시작할 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo "실행 명령어: docker start $container_name"
                    docker start "$container_name"
                    echo "${GREEN}✅ 컨테이너가 시작되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${YELLOW}⏹️ 컨테이너 중지${RESET}"
                echo "현재 실행 중인 컨테이너:"
                docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                echo -n "중지할 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo "실행 명령어: docker stop $container_name"
                    docker stop "$container_name"
                    echo "${GREEN}✅ 컨테이너가 중지되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${YELLOW}🔄 컨테이너 재시작${RESET}"
                echo "현재 컨테이너 목록:"
                docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                echo -n "재시작할 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo "실행 명령어: docker restart $container_name"
                    docker restart "$container_name"
                    echo "${GREEN}✅ 컨테이너가 재시작되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${RED}🗑️ 컨테이너 삭제${RESET}"
                echo "현재 중지된 컨테이너:"
                docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                echo -n "삭제할 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo -n "${RED}정말 삭제하시겠습니까? (y/n): ${RESET}"
                    read confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo "실행 명령어: docker rm $container_name"
                        docker rm "$container_name"
                        echo "${GREEN}✅ 컨테이너가 삭제되었습니다.${RESET}"
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${CYAN}📜 컨테이너 로그 보기${RESET}"
                echo "현재 실행 중인 컨테이너:"
                docker ps --format "table {{.Names}}\t{{.Image}}"
                echo ""
                echo -n "로그를 볼 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo "실행 명령어: docker logs -f --tail 100 $container_name"
                    echo "(Ctrl+C로 종료)"
                    echo ""
                    docker logs -f --tail 100 "$container_name"
                fi
                echo ""
                read -k 1 
                ;;
            8) 
                clear
                echo "${CYAN}🔌 컨테이너 내부 접속${RESET}"
                echo "현재 실행 중인 컨테이너:"
                docker ps --format "table {{.Names}}\t{{.Image}}"
                echo ""
                echo -n "접속할 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo "실행 명령어: docker exec -it $container_name /bin/bash"
                    echo "(bash가 없으면 /bin/sh 시도)"
                    echo ""
                    docker exec -it "$container_name" /bin/bash 2>/dev/null || docker exec -it "$container_name" /bin/sh
                fi
                echo ""
                read -k 1 
                ;;
            9) 
                clear
                echo "${CYAN}🔍 컨테이너 상세 정보${RESET}"
                echo -n "확인할 컨테이너 이름: "
                read container_name
                if [[ -n "$container_name" ]]; then
                    echo "실행 명령어: docker inspect $container_name"
                    echo ""
                    docker inspect "$container_name" | head -50
                    echo "... (상위 50줄만 표시)"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Docker 이미지 관리
function _seongmin_docker_image() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🖼️  [ Docker - 이미지 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 이미지 목록"
        echo "      ${YELLOW}→ docker images${RESET}"
        echo "      설명: 로컬에 저장된 모든 Docker 이미지를 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 이미지 다운로드 (Pull)"
        echo "      ${YELLOW}→ docker pull <이미지명:태그>${RESET}"
        echo "      설명: Docker Hub에서 이미지를 다운로드합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 이미지로 컨테이너 실행 (Run)"
        echo "      ${YELLOW}→ docker run -d --name <이름> <이미지>${RESET}"
        echo "      설명: 이미지를 기반으로 새 컨테이너를 생성하고 실행합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 이미지 삭제"
        echo "      ${YELLOW}→ docker rmi <이미지명>${RESET}"
        echo "      설명: 사용하지 않는 이미지를 삭제합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 이미지 빌드 (Dockerfile)"
        echo "      ${YELLOW}→ docker build -t <태그명> .${RESET}"
        echo "      설명: 현재 디렉토리의 Dockerfile로 이미지를 빌드합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 이미지 태그 변경"
        echo "      ${YELLOW}→ docker tag <원본이미지> <새이미지명:태그>${RESET}"
        echo "      설명: 이미지에 새로운 태그를 추가합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 이미지 히스토리"
        echo "      ${YELLOW}→ docker history <이미지명>${RESET}"
        echo "      설명: 이미지의 레이어 히스토리를 보여줍니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}🖼️  이미지 목록${RESET}"
                echo "실행 명령어: docker images"
                echo ""
                docker images
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📥 이미지 다운로드 (Pull)${RESET}"
                echo "예시: nginx, redis:latest, python:3.11-slim"
                echo ""
                echo -n "다운로드할 이미지 (이미지명:태그): "
                read image_name
                if [[ -n "$image_name" ]]; then
                    echo "실행 명령어: docker pull $image_name"
                    echo ""
                    docker pull "$image_name"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}▶️ 이미지로 컨테이너 실행${RESET}"
                echo "로컬 이미지 목록:"
                docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
                echo ""
                echo -n "실행할 이미지명: "
                read image_name
                echo -n "컨테이너 이름: "
                read container_name
                echo -n "포트 매핑 (예: 8080:80, 없으면 Enter): "
                read port_map
                
                if [[ -n "$image_name" && -n "$container_name" ]]; then
                    local port_opt=""
                    if [[ -n "$port_map" ]]; then
                        port_opt="-p $port_map"
                    fi
                    echo "실행 명령어: docker run -d --name $container_name $port_opt $image_name"
                    eval "docker run -d --name $container_name $port_opt $image_name"
                    echo "${GREEN}✅ 컨테이너가 생성되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${RED}🗑️ 이미지 삭제${RESET}"
                echo "현재 이미지 목록:"
                docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}"
                echo ""
                echo -n "삭제할 이미지명 또는 ID: "
                read image_name
                if [[ -n "$image_name" ]]; then
                    echo -n "${RED}정말 삭제하시겠습니까? (y/n): ${RESET}"
                    read confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo "실행 명령어: docker rmi $image_name"
                        docker rmi "$image_name"
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}🔨 이미지 빌드${RESET}"
                if [[ -f "Dockerfile" ]]; then
                    echo "${GREEN}✅ Dockerfile 발견!${RESET}"
                    cat Dockerfile | head -10
                    echo "..."
                else
                    echo "${RED}❌ 현재 디렉토리에 Dockerfile이 없습니다.${RESET}"
                    echo ""
                    read -k 1
                    continue
                fi
                echo ""
                echo -n "이미지 태그명 (예: myapp:latest): "
                read tag_name
                if [[ -n "$tag_name" ]]; then
                    echo "실행 명령어: docker build -t $tag_name ."
                    echo ""
                    docker build -t "$tag_name" .
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${CYAN}🏷️ 이미지 태그 변경${RESET}"
                echo "현재 이미지 목록:"
                docker images --format "table {{.Repository}}:{{.Tag}}"
                echo ""
                echo -n "원본 이미지명:태그: "
                read source_image
                echo -n "새 이미지명:태그: "
                read target_image
                if [[ -n "$source_image" && -n "$target_image" ]]; then
                    echo "실행 명령어: docker tag $source_image $target_image"
                    docker tag "$source_image" "$target_image"
                    echo "${GREEN}✅ 태그가 추가되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${CYAN}📜 이미지 히스토리${RESET}"
                echo -n "확인할 이미지명: "
                read image_name
                if [[ -n "$image_name" ]]; then
                    echo "실행 명령어: docker history $image_name"
                    echo ""
                    docker history "$image_name"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Docker Compose
function _seongmin_docker_compose() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🎼 [ Docker Compose ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 서비스 시작 (백그라운드)"
        echo "      ${YELLOW}→ docker compose up -d${RESET}"
        echo "      설명: docker-compose.yml의 모든 서비스를 백그라운드로 시작합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 서비스 시작 (로그 보면서)"
        echo "      ${YELLOW}→ docker compose up${RESET}"
        echo "      설명: 로그를 실시간으로 보며 서비스를 시작합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 서비스 중지"
        echo "      ${YELLOW}→ docker compose down${RESET}"
        echo "      설명: 모든 서비스를 중지하고 컨테이너를 삭제합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 서비스 중지 + 볼륨 삭제"
        echo "      ${YELLOW}→ docker compose down -v${RESET}"
        echo "      설명: 서비스 중지와 함께 볼륨도 삭제합니다. (데이터 초기화)"
        echo ""
        echo "  ${GREEN}[5]${RESET} 서비스 상태 확인"
        echo "      ${YELLOW}→ docker compose ps${RESET}"
        echo "      설명: Compose로 실행된 서비스 상태를 보여줍니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 서비스 로그 보기"
        echo "      ${YELLOW}→ docker compose logs -f${RESET}"
        echo "      설명: 모든 서비스의 실시간 로그를 보여줍니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} 서비스 재시작"
        echo "      ${YELLOW}→ docker compose restart${RESET}"
        echo "      설명: 모든 서비스를 재시작합니다."
        echo ""
        echo "  ${GREEN}[8]${RESET} 이미지 다시 빌드 후 시작"
        echo "      ${YELLOW}→ docker compose up -d --build${RESET}"
        echo "      설명: 이미지를 다시 빌드하고 서비스를 시작합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}▶️ 서비스 시작 (백그라운드)${RESET}"
                echo "실행 명령어: docker compose up -d"
                echo ""
                docker compose up -d
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}▶️ 서비스 시작 (로그 보면서)${RESET}"
                echo "실행 명령어: docker compose up"
                echo "(Ctrl+C로 종료)"
                echo ""
                docker compose up
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${YELLOW}⏹️ 서비스 중지${RESET}"
                echo "실행 명령어: docker compose down"
                echo ""
                docker compose down
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${RED}⏹️ 서비스 중지 + 볼륨 삭제${RESET}"
                echo "⚠️ 주의: 볼륨의 모든 데이터가 삭제됩니다!"
                echo ""
                echo -n "정말 진행하시겠습니까? (y/n): "
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo "실행 명령어: docker compose down -v"
                    docker compose down -v
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${CYAN}📊 서비스 상태 확인${RESET}"
                echo "실행 명령어: docker compose ps"
                echo ""
                docker compose ps
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${CYAN}📜 서비스 로그 보기${RESET}"
                echo "실행 명령어: docker compose logs -f --tail 50"
                echo "(Ctrl+C로 종료)"
                echo ""
                docker compose logs -f --tail 50
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${YELLOW}🔄 서비스 재시작${RESET}"
                echo "실행 명령어: docker compose restart"
                echo ""
                docker compose restart
                echo ""
                read -k 1 
                ;;
            8) 
                clear
                echo "${GREEN}🔨 이미지 다시 빌드 후 시작${RESET}"
                echo "실행 명령어: docker compose up -d --build"
                echo ""
                docker compose up -d --build
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Docker 볼륨 & 네트워크
function _seongmin_docker_volume_network() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}💾 [ Docker - 볼륨 & 네트워크 ]${RESET}"
        echo ""
        echo "  ${YELLOW}--- 볼륨 (Volume) ---${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 볼륨 목록"
        echo "      ${YELLOW}→ docker volume ls${RESET}"
        echo "      설명: 생성된 모든 Docker 볼륨을 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 볼륨 생성"
        echo "      ${YELLOW}→ docker volume create <볼륨명>${RESET}"
        echo "      설명: 새로운 볼륨을 생성합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 볼륨 삭제"
        echo "      ${YELLOW}→ docker volume rm <볼륨명>${RESET}"
        echo "      설명: 사용하지 않는 볼륨을 삭제합니다."
        echo ""
        echo "  ${YELLOW}--- 네트워크 (Network) ---${RESET}"
        echo ""
        echo "  ${GREEN}[4]${RESET} 네트워크 목록"
        echo "      ${YELLOW}→ docker network ls${RESET}"
        echo "      설명: 생성된 모든 Docker 네트워크를 보여줍니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 네트워크 생성"
        echo "      ${YELLOW}→ docker network create <네트워크명>${RESET}"
        echo "      설명: 새로운 네트워크를 생성합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 네트워크 상세 정보"
        echo "      ${YELLOW}→ docker network inspect <네트워크명>${RESET}"
        echo "      설명: 네트워크에 연결된 컨테이너 등 상세 정보를 봅니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}💾 볼륨 목록${RESET}"
                echo "실행 명령어: docker volume ls"
                echo ""
                docker volume ls
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}➕ 볼륨 생성${RESET}"
                echo -n "생성할 볼륨 이름: "
                read vol_name
                if [[ -n "$vol_name" ]]; then
                    echo "실행 명령어: docker volume create $vol_name"
                    docker volume create "$vol_name"
                    echo "${GREEN}✅ 볼륨이 생성되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${RED}🗑️ 볼륨 삭제${RESET}"
                echo "현재 볼륨 목록:"
                docker volume ls
                echo ""
                echo -n "삭제할 볼륨 이름: "
                read vol_name
                if [[ -n "$vol_name" ]]; then
                    echo -n "${RED}정말 삭제하시겠습니까? (y/n): ${RESET}"
                    read confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo "실행 명령어: docker volume rm $vol_name"
                        docker volume rm "$vol_name"
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}🌐 네트워크 목록${RESET}"
                echo "실행 명령어: docker network ls"
                echo ""
                docker network ls
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}➕ 네트워크 생성${RESET}"
                echo -n "생성할 네트워크 이름: "
                read net_name
                if [[ -n "$net_name" ]]; then
                    echo "실행 명령어: docker network create $net_name"
                    docker network create "$net_name"
                    echo "${GREEN}✅ 네트워크가 생성되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${CYAN}🔍 네트워크 상세 정보${RESET}"
                echo "현재 네트워크 목록:"
                docker network ls
                echo ""
                echo -n "확인할 네트워크 이름: "
                read net_name
                if [[ -n "$net_name" ]]; then
                    echo "실행 명령어: docker network inspect $net_name"
                    echo ""
                    docker network inspect "$net_name"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Docker 시스템 관리
function _seongmin_docker_system() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🔧 [ Docker - 시스템 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 디스크 사용량 확인"
        echo "      ${YELLOW}→ docker system df${RESET}"
        echo "      설명: Docker가 사용 중인 디스크 공간을 보여줍니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 사용하지 않는 리소스 정리"
        echo "      ${YELLOW}→ docker system prune${RESET}"
        echo "      설명: 중지된 컨테이너, 사용하지 않는 네트워크, 댕글링 이미지 삭제"
        echo ""
        echo "  ${GREEN}[3]${RESET} 전체 정리 (볼륨 포함)"
        echo "      ${YELLOW}→ docker system prune -a --volumes${RESET}"
        echo "      설명: ⚠️ 사용하지 않는 모든 리소스를 삭제합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 모든 컨테이너 중지"
        echo "      ${YELLOW}→ docker stop \$(docker ps -q)${RESET}"
        echo "      설명: 실행 중인 모든 컨테이너를 한 번에 중지합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 모든 컨테이너 삭제"
        echo "      ${YELLOW}→ docker rm \$(docker ps -aq)${RESET}"
        echo "      설명: ⚠️ 모든 컨테이너를 삭제합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 모든 이미지 삭제"
        echo "      ${YELLOW}→ docker rmi \$(docker images -q)${RESET}"
        echo "      설명: ⚠️ 모든 이미지를 삭제합니다."
        echo ""
        echo "  ${GREEN}[7]${RESET} Docker 이벤트 모니터링"
        echo "      ${YELLOW}→ docker events${RESET}"
        echo "      설명: Docker 이벤트를 실시간으로 모니터링합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}💾 디스크 사용량 확인${RESET}"
                echo "실행 명령어: docker system df"
                echo ""
                docker system df
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${YELLOW}🧹 사용하지 않는 리소스 정리${RESET}"
                echo "삭제 대상: 중지된 컨테이너, 사용하지 않는 네트워크, 댕글링 이미지"
                echo ""
                echo -n "정리를 진행하시겠습니까? (y/n): "
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo "실행 명령어: docker system prune -f"
                    docker system prune -f
                    echo "${GREEN}✅ 정리 완료!${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${RED}🧹 전체 정리 (볼륨 포함)${RESET}"
                echo "⚠️ 주의: 사용하지 않는 모든 이미지, 컨테이너, 볼륨이 삭제됩니다!"
                echo ""
                echo -n "정말 진행하시겠습니까? (y/n): "
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo "실행 명령어: docker system prune -a --volumes -f"
                    docker system prune -a --volumes -f
                    echo "${GREEN}✅ 전체 정리 완료!${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${YELLOW}⏹️ 모든 컨테이너 중지${RESET}"
                echo "실행 명령어: docker stop \$(docker ps -q)"
                echo ""
                local running=$(docker ps -q)
                if [[ -n "$running" ]]; then
                    docker stop $(docker ps -q)
                    echo "${GREEN}✅ 모든 컨테이너가 중지되었습니다.${RESET}"
                else
                    echo "실행 중인 컨테이너가 없습니다."
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${RED}🗑️ 모든 컨테이너 삭제${RESET}"
                echo "⚠️ 주의: 모든 컨테이너가 삭제됩니다!"
                echo ""
                echo -n "정말 진행하시겠습니까? (y/n): "
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo "실행 명령어: docker rm \$(docker ps -aq)"
                    local containers=$(docker ps -aq)
                    if [[ -n "$containers" ]]; then
                        docker rm $(docker ps -aq)
                        echo "${GREEN}✅ 모든 컨테이너가 삭제되었습니다.${RESET}"
                    else
                        echo "삭제할 컨테이너가 없습니다."
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${RED}🗑️ 모든 이미지 삭제${RESET}"
                echo "⚠️ 주의: 모든 이미지가 삭제됩니다!"
                echo ""
                echo -n "정말 진행하시겠습니까? (y/n): "
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo "실행 명령어: docker rmi \$(docker images -q)"
                    local images=$(docker images -q)
                    if [[ -n "$images" ]]; then
                        docker rmi $(docker images -q) 2>/dev/null
                        echo "${GREEN}✅ 이미지 삭제 완료!${RESET}"
                    else
                        echo "삭제할 이미지가 없습니다."
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            7) 
                clear
                echo "${CYAN}📡 Docker 이벤트 모니터링${RESET}"
                echo "실행 명령어: docker events"
                echo "(Ctrl+C로 종료)"
                echo ""
                docker events
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Docker 상태 및 버전 확인
function _seongmin_docker_check() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'

    clear
    echo "${CYAN}🐳 [ Docker 상태 및 버전 확인 ]${RESET}"
    echo ""

    # 1. 설치 확인
    if ! command -v docker &> /dev/null; then
        echo "${RED}❌ Docker가 설치되어 있지 않습니다.${RESET}"
        echo "   (Docker Desktop을 설치해주세요)"
        read -k 1
        return
    fi

    echo "${GREEN}✅ Docker가 설치되어 있습니다.${RESET}"
    echo "----------------------------------------"
    
    # 2. 버전 확인
    echo -n "   Docker 엔진:  "
    docker --version 2>/dev/null || echo "${RED}확인 실패${RESET}"
    
    echo -n "   Compose:      "
    docker compose version 2>/dev/null || echo "${RED}확인 실패${RESET}"
    
    echo "----------------------------------------"

    # 3. 업데이트 확인 (Homebrew Cask)
    if command -v brew &> /dev/null; then
        echo "${YELLOW}🔍 Homebrew로 설치된 Docker 업데이트 확인 중...${RESET}"
        # brew list check might be slow, so just checking outdated directly or simple check
        if brew list --cask 2>/dev/null | grep -q "^docker$"; then
            echo "   (Homebrew Cask 설치 감지됨)"
            local outdated=$(brew outdated --cask docker 2>/dev/null)
            if [[ -n "$outdated" ]]; then
                echo "${RED}🚨 업데이트가 필요합니다!${RESET}"
                echo "$outdated"
                echo ""
                echo -n "지금 업데이트하시겠습니까? (y/n) > "
                read ans
                if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
                    echo "🚀 brew upgrade --cask docker 실행 중..."
                    brew upgrade --cask docker
                    echo "${GREEN}✅ 업데이트 완료!${RESET}"
                else
                    echo "업데이트를 건너뜁니다."
                fi
            else
                echo "${GREEN}✅ 최신 버전을 사용 중입니다.${RESET}"
            fi
        else
            echo "ℹ️ Homebrew Cask로 설치된 Docker가 아닙니다."
            echo "   (Docker Desktop 앱에서 업데이트를 확인해주세요)"
        fi
    else
        echo "ℹ️ Homebrew가 없어서 업데이트 확인을 건너뜁니다."
    fi

    echo ""
    echo "엔터를 누르면 돌아갑니다."
    read -k 1
}

# Redis 서브메뉴
function _seongmin_redis() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${RED}🔴 [ Redis 명령어 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} rs  - brew services start redis"
        echo "  ${CYAN}[2]${RESET} rst - brew services stop redis"
        echo "  ${CYAN}[3]${RESET} rc  - redis-cli"
        echo "  ${CYAN}[4]${RESET} 🧐 상태 및 버전 확인 (Check Status & Update)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) clear; brew services start redis; echo ""; read -k 1 ;;
            2) clear; brew services stop redis; echo ""; read -k 1 ;;
            3) clear; echo "redis-cli 실행 (exit로 나가기)"; redis-cli ;;
            4) _seongmin_redis_check ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Redis 상태 및 버전 확인
function _seongmin_redis_check() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'

    clear
    echo "${CYAN}🔴 [ Redis 상태 및 버전 확인 ]${RESET}"
    echo ""

    # 1. 설치 확인
    if ! command -v redis-server &> /dev/null; then
        echo "${RED}❌ Redis가 설치되어 있지 않습니다.${RESET}"
        read -k 1
        return
    fi

    echo "${GREEN}✅ Redis가 설치되어 있습니다.${RESET}"
    echo "----------------------------------------"
    
    # 2. 버전 확인
    echo -n "   Redis 버전:   "
    redis-server --version 2>/dev/null | awk '{print $3}' | tr -d 'v=' || echo "${RED}확인 실패${RESET}"
    
    # 3. 서비스 실행 상태 확인 (Homebrew)
    echo -n "   실행 상태:    "
    if command -v brew &> /dev/null; then
        if brew services list | grep "redis" | grep -q "started"; then
            echo "${GREEN}🟢 실행 중 (Homebrew Service)${RESET}"
        else
            echo "${YELLOW}⚪ 중지됨 (Homebrew Service)${RESET}"
        fi
    else
        # 간단한 포트 확인 (6379)
        if lsof -i :6379 &> /dev/null; then
             echo "${GREEN}🟢 실행 중 (Port 6379 Active)${RESET}"
        else
             echo "${YELLOW}⚪ 실행 중이지 않음 (Port 6379 Free)${RESET}"
        fi
    fi
    
    echo "----------------------------------------"

    # 4. 업데이트 확인 (Homebrew)
    if command -v brew &> /dev/null; then
        echo "${YELLOW}🔍 Homebrew로 설치된 Redis 업데이트 확인 중...${RESET}"
        if brew list --formula 2>/dev/null | grep -q "^redis$"; then
            local outdated=$(brew outdated --formula redis 2>/dev/null)
            if [[ -n "$outdated" ]]; then
                echo "${RED}🚨 업데이트가 필요합니다!${RESET}"
                echo "$outdated"
                echo ""
                echo -n "지금 업데이트하시겠습니까? (y/n) > "
                read ans
                if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
                    echo "🚀 brew upgrade redis 실행 중..."
                    brew upgrade redis
                    echo "${GREEN}✅ 업데이트 완료!${RESET}"
                else
                    echo "업데이트를 건너뜁니다."
                fi
            else
                echo "${GREEN}✅ 최신 버전을 사용 중입니다.${RESET}"
            fi
        else
            echo "ℹ️ Homebrew Formula로 설치된 Redis가 아닙니다."
        fi
    else
        echo "ℹ️ Homebrew가 없어서 업데이트 확인을 건너뜁니다."
    fi

    echo ""
    echo "엔터를 누르면 돌아갑니다."
    read -k 1
}

# Shell 서브메뉴
function _seongmin_shell() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${PINK}🐚 [ Shell 명령어 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} sz     - 설정 새로고침 (reload)"
        echo "  ${CYAN}[2]${RESET} zshrc  - code ~/.zshrc"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) clear; source ~/.zshrc; echo "✅ 설정 새로고침 완료!"; read -k 1 ;;
            2) code ~/.zshrc; return ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# 버전 확인 서브메뉴
function _seongmin_version() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    clear
    echo "${CYAN}�� [ 설치된 버전 정보 ]${RESET}"
    echo ""
    echo "${YELLOW}[ 언어 & 런타임 ]${RESET}"
    echo -n "   Python:  "; python3 --version 2>/dev/null || echo "❌ 설치 안됨"
    echo -n "   Node.js: "; node --version 2>/dev/null || echo "❌ 설치 안됨"
    echo -n "   Java:    "; java --version 2>&1 | head -1 || echo "❌ 설치 안됨"
    echo ""
    echo "${GREEN}[ 패키지 관리자 ]${RESET}"
    echo -n "   pip:      "; pip3 --version 2>/dev/null | awk '{print $2}' || echo "❌ 설치 안됨"
    echo -n "   npm:      "; npm --version 2>/dev/null || echo "❌ 설치 안됨"
    echo -n "   Homebrew: "; brew --version 2>/dev/null | head -1 || echo "❌ 설치 안됨"
    echo ""
    echo "${CYAN}[ 개발 도구 ]${RESET}"
    echo -n "   Git:    "; git --version 2>/dev/null || echo "❌ 설치 안됨"
    echo -n "   Docker: "; docker --version 2>/dev/null || echo "❌ 설치 안됨"
    echo -n "   Redis:  "; redis-server --version 2>/dev/null | awk '{print $3}' || echo "❌ 설치 안됨"
    echo ""
    echo "${PINK}[ 쉘 ]${RESET}"
    echo -n "   Zsh:    "; zsh --version 2>/dev/null || echo "❌ 설치 안됨"
    echo ""
    echo "${YELLOW}아무 키나 누르면 돌아가요...${RESET}"
    read -k 1
}

# 프론트엔드 서브메뉴
function _seongmin_frontend() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${PINK}🎨 [ 프론트엔드 프로젝트 생성 ]${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} vite    - Vite 프로젝트 생성 (React, Vue, Svelte 등)"
        echo "  ${CYAN}[2]${RESET} next    - Next.js 프로젝트 생성"
        echo "  ${CYAN}[3]${RESET} react   - React (CRA) 프로젝트 생성 (Legacy)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) 
                clear
                echo "${YELLOW}⚡ Vite 프로젝트를 생성합니다...${RESET}"
                echo "명령어: npm create vite@latest"
                npm create vite@latest
                echo ""
                echo "✅ 완료되면 cd <project-name> && npm install && npm run dev 하세요!"
                read -k 1 
                ;;
            2) 
                clear
                echo "${YELLOW}▲ Next.js 프로젝트를 생성합니다...${RESET}"
                echo "명령어: npx create-next-app@latest"
                npx create-next-app@latest
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${YELLOW}⚛️ Create React App으로 프로젝트를 생성합니다...${RESET}"
                echo "명령어: npx create-react-app"
                echo -n "프로젝트 이름 입력: "
                read proj_name
                if [[ -n "$proj_name" ]]; then
                    npx create-react-app "$proj_name"
                else
                    echo "${RED}프로젝트 이름을 입력해야 합니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Jenkins 서브메뉴
function _seongmin_jenkins() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' BLUE='\033[1;34m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${YELLOW}🔧 [ Jenkins 명령어 - 카테고리 선택 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 🚀 서비스 관리 (Service Control)"
        echo "  ${GREEN}[2]${RESET} 📋 Job 관리 (Job Management)"
        echo "  ${GREEN}[3]${RESET} 🔨 빌드 관리 (Build Control)"
        echo "  ${GREEN}[4]${RESET} 🔐 인증 및 설정 (Auth & Config)"
        echo "  ${GREEN}[5]${RESET} 📊 시스템 정보 (System Info)"
        echo "  ${GREEN}[6]${RESET} 🔌 플러그인 관리 (Plugin Management)"
        echo "  ${CYAN}[0]${RESET} ⬅️  메인 메뉴로"
        echo ""
        echo -n "  선택 > "
        read choice

        case $choice in
            1) _seongmin_jenkins_service ;;
            2) _seongmin_jenkins_job ;;
            3) _seongmin_jenkins_build ;;
            4) _seongmin_jenkins_auth ;;
            5) _seongmin_jenkins_info ;;
            6) _seongmin_jenkins_plugin ;;
            0|q|Q) return ;;
            *) echo "${RED}  잘못된 번호! 😅${RESET}"; sleep 1 ;;
        esac
    done
}

# Jenkins 서비스 관리
function _seongmin_jenkins_service() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🚀 [ Jenkins - 서비스 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} Jenkins 서비스 시작 (Homebrew)"
        echo "      ${YELLOW}→ brew services start jenkins-lts${RESET}"
        echo "      설명: Homebrew로 설치된 Jenkins LTS 버전을 시작합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} Jenkins 서비스 중지 (Homebrew)"
        echo "      ${YELLOW}→ brew services stop jenkins-lts${RESET}"
        echo "      설명: Jenkins 서비스를 안전하게 중지합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} Jenkins 서비스 재시작 (Homebrew)"
        echo "      ${YELLOW}→ brew services restart jenkins-lts${RESET}"
        echo "      설명: Jenkins를 재시작합니다. 설정 변경 후 필요합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} Jenkins 서비스 상태 확인"
        echo "      ${YELLOW}→ brew services list | grep jenkins${RESET}"
        echo "      설명: 현재 Jenkins 서비스의 실행 상태를 확인합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} Jenkins 웹 UI 열기"
        echo "      ${YELLOW}→ open http://localhost:8080${RESET}"
        echo "      설명: 브라우저에서 Jenkins 대시보드를 엽니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}🚀 Jenkins 서비스 시작 중...${RESET}"
                echo "실행 명령어: brew services start jenkins-lts"
                echo ""
                brew services start jenkins-lts
                echo ""
                echo "${GREEN}✅ 완료! http://localhost:8080 에서 접속 가능합니다.${RESET}"
                read -k 1 
                ;;
            2) 
                clear
                echo "${RED}🛑 Jenkins 서비스 중지 중...${RESET}"
                echo "실행 명령어: brew services stop jenkins-lts"
                echo ""
                brew services stop jenkins-lts
                echo ""
                echo "${GREEN}✅ Jenkins 서비스가 중지되었습니다.${RESET}"
                read -k 1 
                ;;
            3) 
                clear
                echo "${YELLOW}🔄 Jenkins 서비스 재시작 중...${RESET}"
                echo "실행 명령어: brew services restart jenkins-lts"
                echo ""
                brew services restart jenkins-lts
                echo ""
                echo "${GREEN}✅ Jenkins가 재시작되었습니다.${RESET}"
                read -k 1 
                ;;
            4) 
                clear
                echo "${CYAN}📊 Jenkins 서비스 상태 확인${RESET}"
                echo "실행 명령어: brew services list | grep jenkins"
                echo ""
                brew services list | grep jenkins
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${CYAN}🌐 Jenkins 웹 UI 열기${RESET}"
                echo "실행 명령어: open http://localhost:8080"
                echo ""
                open http://localhost:8080
                echo "${GREEN}✅ 브라우저에서 Jenkins를 열었습니다.${RESET}"
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Jenkins Job 관리
function _seongmin_jenkins_job() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}📋 [ Jenkins - Job 관리 (jenkins-cli 사용) ]${RESET}"
        echo ""
        echo "  ${YELLOW}ℹ️  jenkins-cli.jar가 필요합니다.${RESET}"
        echo "  ${YELLOW}   다운로드: http://localhost:8080/jnlpJars/jenkins-cli.jar${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 모든 Job 목록 보기"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ list-jobs${RESET}"
        echo "      설명: Jenkins에 등록된 모든 Job의 이름을 출력합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} Job 상세 정보 보기"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ get-job <job명>${RESET}"
        echo "      설명: 특정 Job의 XML 설정을 확인합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} Job 활성화"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ enable-job <job명>${RESET}"
        echo "      설명: 비활성화된 Job을 다시 활성화합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} Job 비활성화"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ disable-job <job명>${RESET}"
        echo "      설명: Job을 일시적으로 비활성화합니다 (빌드 불가)."
        echo ""
        echo "  ${GREEN}[5]${RESET} Job 삭제"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ delete-job <job명>${RESET}"
        echo "      설명: ⚠️ Job을 완전히 삭제합니다. 복구 불가!"
        echo ""
        echo "  ${GREEN}[6]${RESET} Job 설정 백업 (XML 내보내기)"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ get-job <job명> > job_backup.xml${RESET}"
        echo "      설명: Job 설정을 XML 파일로 백업합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}📋 모든 Job 목록${RESET}"
                echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ list-jobs"
                echo ""
                if [[ -f "jenkins-cli.jar" ]]; then
                    java -jar jenkins-cli.jar -s http://localhost:8080/ list-jobs
                else
                    echo "${RED}❌ jenkins-cli.jar 파일을 찾을 수 없습니다.${RESET}"
                    echo "다음 명령어로 다운로드하세요:"
                    echo "curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar"
                fi
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}🔍 Job 상세 정보 보기${RESET}"
                echo -n "Job 이름 입력: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ get-job $job_name"
                    echo ""
                    java -jar jenkins-cli.jar -s http://localhost:8080/ get-job "$job_name" 2>/dev/null | head -50
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}✅ Job 활성화${RESET}"
                echo -n "활성화할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ enable-job $job_name"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ enable-job "$job_name"
                    echo "${GREEN}✅ $job_name Job이 활성화되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${YELLOW}⏸️ Job 비활성화${RESET}"
                echo -n "비활성화할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ disable-job $job_name"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ disable-job "$job_name"
                    echo "${YELLOW}⏸️ $job_name Job이 비활성화되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${RED}🗑️ Job 삭제 (⚠️ 주의!)${RESET}"
                echo -n "삭제할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo -n "${RED}정말 '$job_name' Job을 삭제하시겠습니까? (y/n): ${RESET}"
                    read confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ delete-job $job_name"
                        java -jar jenkins-cli.jar -s http://localhost:8080/ delete-job "$job_name"
                        echo "${RED}🗑️ $job_name Job이 삭제되었습니다.${RESET}"
                    else
                        echo "취소되었습니다."
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${GREEN}💾 Job 설정 백업${RESET}"
                echo -n "백업할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    local backup_file="${job_name}_backup.xml"
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ get-job $job_name > $backup_file"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ get-job "$job_name" > "$backup_file"
                    echo "${GREEN}✅ $backup_file 파일로 백업되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Jenkins 빌드 관리
function _seongmin_jenkins_build() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🔨 [ Jenkins - 빌드 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 빌드 실행"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ build <job명>${RESET}"
        echo "      설명: 특정 Job의 빌드를 즉시 시작합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 빌드 실행 (파라미터 포함)"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ build <job명> -p KEY=VALUE${RESET}"
        echo "      설명: 파라미터와 함께 빌드를 실행합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 빌드 대기열 확인"
        echo "      ${YELLOW}→ curl -s http://localhost:8080/queue/api/json | jq '.items[].task.name'${RESET}"
        echo "      설명: 현재 대기 중인 빌드 목록을 확인합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 마지막 빌드 상태 확인"
        echo "      ${YELLOW}→ curl -s http://localhost:8080/job/<job명>/lastBuild/api/json | jq '.result'${RESET}"
        echo "      설명: 특정 Job의 마지막 빌드 결과를 확인합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 빌드 중지"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ stop-builds <job명>${RESET}"
        echo "      설명: 실행 중인 특정 Job의 빌드를 중지합니다."
        echo ""
        echo "  ${GREEN}[6]${RESET} 콘솔 출력 보기 (마지막 빌드)"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ console <job명>${RESET}"
        echo "      설명: 마지막 빌드의 콘솔 로그를 출력합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}🚀 빌드 실행${RESET}"
                echo -n "빌드할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ build $job_name"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ build "$job_name"
                    echo "${GREEN}✅ $job_name 빌드가 시작되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}🚀 파라미터 빌드 실행${RESET}"
                echo -n "빌드할 Job 이름: "
                read job_name
                echo -n "파라미터 (예: BRANCH=main ENV=prod): "
                read params
                if [[ -n "$job_name" ]]; then
                    local param_args=""
                    for param in $params; do
                        param_args="$param_args -p $param"
                    done
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ build $job_name $param_args"
                    eval "java -jar jenkins-cli.jar -s http://localhost:8080/ build $job_name $param_args"
                    echo "${GREEN}✅ $job_name 빌드가 시작되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${CYAN}📋 빌드 대기열 확인${RESET}"
                echo "실행 명령어: curl -s http://localhost:8080/queue/api/json | jq '.items[].task.name'"
                echo ""
                if command -v jq &> /dev/null; then
                    curl -s http://localhost:8080/queue/api/json | jq '.items[].task.name'
                else
                    echo "${YELLOW}jq가 설치되어 있지 않아 원본 JSON을 출력합니다.${RESET}"
                    curl -s http://localhost:8080/queue/api/json
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${CYAN}📊 마지막 빌드 상태 확인${RESET}"
                echo -n "확인할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: curl -s http://localhost:8080/job/$job_name/lastBuild/api/json"
                    echo ""
                    if command -v jq &> /dev/null; then
                        local result=$(curl -s "http://localhost:8080/job/$job_name/lastBuild/api/json" | jq -r '.result // "IN_PROGRESS"')
                        local number=$(curl -s "http://localhost:8080/job/$job_name/lastBuild/api/json" | jq -r '.number')
                        echo "빌드 번호: #$number"
                        echo -n "결과: "
                        case $result in
                            SUCCESS) echo "${GREEN}✅ SUCCESS${RESET}" ;;
                            FAILURE) echo "${RED}❌ FAILURE${RESET}" ;;
                            UNSTABLE) echo "${YELLOW}⚠️ UNSTABLE${RESET}" ;;
                            ABORTED) echo "${YELLOW}🛑 ABORTED${RESET}" ;;
                            *) echo "${CYAN}🔄 $result${RESET}" ;;
                        esac
                    else
                        curl -s "http://localhost:8080/job/$job_name/lastBuild/api/json"
                    fi
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${RED}🛑 빌드 중지${RESET}"
                echo -n "중지할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ stop-builds $job_name"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ stop-builds "$job_name"
                    echo "${RED}🛑 $job_name의 빌드가 중지되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            6) 
                clear
                echo "${CYAN}📜 콘솔 출력 보기${RESET}"
                echo -n "확인할 Job 이름: "
                read job_name
                if [[ -n "$job_name" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ console $job_name"
                    echo ""
                    java -jar jenkins-cli.jar -s http://localhost:8080/ console "$job_name" 2>/dev/null | tail -100
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Jenkins 인증 및 설정
function _seongmin_jenkins_auth() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🔐 [ Jenkins - 인증 및 설정 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 초기 관리자 비밀번호 확인"
        echo "      ${YELLOW}→ cat ~/.jenkins/secrets/initialAdminPassword${RESET}"
        echo "      설명: Jenkins 첫 설치 시 필요한 초기 비밀번호입니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} jenkins-cli.jar 다운로드"
        echo "      ${YELLOW}→ curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar${RESET}"
        echo "      설명: Jenkins CLI 도구를 현재 디렉토리에 다운로드합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} API 토큰으로 CLI 인증 설정"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token who-am-i${RESET}"
        echo "      설명: API 토큰을 사용하여 CLI 명령어를 인증합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} Jenkins 설정 디렉토리 열기"
        echo "      ${YELLOW}→ open ~/.jenkins${RESET}"
        echo "      설명: Jenkins 홈 디렉토리를 Finder에서 엽니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} Jenkins 로그 보기"
        echo "      ${YELLOW}→ tail -f ~/Library/Logs/Homebrew/jenkins-lts/current${RESET}"
        echo "      설명: Jenkins 실시간 로그를 확인합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}🔑 초기 관리자 비밀번호${RESET}"
                echo "실행 명령어: cat ~/.jenkins/secrets/initialAdminPassword"
                echo ""
                if [[ -f ~/.jenkins/secrets/initialAdminPassword ]]; then
                    echo "비밀번호: ${YELLOW}$(cat ~/.jenkins/secrets/initialAdminPassword)${RESET}"
                else
                    echo "${RED}❌ 초기 비밀번호 파일을 찾을 수 없습니다.${RESET}"
                    echo "이미 초기 설정을 완료했거나 다른 위치에 Jenkins가 설치되어 있을 수 있습니다."
                fi
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📥 jenkins-cli.jar 다운로드${RESET}"
                echo "실행 명령어: curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar"
                echo ""
                curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
                if [[ -f "jenkins-cli.jar" ]]; then
                    echo "${GREEN}✅ jenkins-cli.jar 다운로드 완료!${RESET}"
                    ls -la jenkins-cli.jar
                else
                    echo "${RED}❌ 다운로드 실패. Jenkins가 실행 중인지 확인하세요.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}🔐 API 토큰 인증 테스트${RESET}"
                echo -n "사용자 이름: "
                read username
                echo -n "API 토큰: "
                read -s token
                echo ""
                if [[ -n "$username" && -n "$token" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $username:***** who-am-i"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth "$username:$token" who-am-i
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}📂 Jenkins 설정 디렉토리 열기${RESET}"
                echo "실행 명령어: open ~/.jenkins"
                open ~/.jenkins 2>/dev/null || echo "${RED}❌ ~/.jenkins 디렉토리를 찾을 수 없습니다.${RESET}"
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}📜 Jenkins 로그 보기 (Ctrl+C로 종료)${RESET}"
                echo "실행 명령어: tail -f ~/Library/Logs/Homebrew/jenkins-lts/current"
                echo ""
                if [[ -f ~/Library/Logs/Homebrew/jenkins-lts/current ]]; then
                    tail -f ~/Library/Logs/Homebrew/jenkins-lts/current
                else
                    echo "${YELLOW}Homebrew 로그 파일을 찾을 수 없습니다.${RESET}"
                    echo "다른 경로 시도: cat ~/.jenkins/jenkins.log"
                    cat ~/.jenkins/jenkins.log 2>/dev/null | tail -50
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

# Jenkins 시스템 정보
function _seongmin_jenkins_info() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    clear
    echo "${CYAN}📊 [ Jenkins - 시스템 정보 ]${RESET}"
    echo ""
    
    # 1. 설치 확인
    echo "${YELLOW}🔍 Jenkins 설치 상태${RESET}"
    echo "----------------------------------------"
    
    if brew list --formula 2>/dev/null | grep -q "jenkins-lts"; then
        echo "${GREEN}✅ jenkins-lts (Homebrew Formula)${RESET}"
        echo -n "   버전: "
        brew info jenkins-lts 2>/dev/null | head -1
    elif brew list --cask 2>/dev/null | grep -q "jenkins"; then
        echo "${GREEN}✅ jenkins (Homebrew Cask)${RESET}"
    else
        echo "${YELLOW}⚠️ Homebrew로 설치된 Jenkins를 찾을 수 없습니다.${RESET}"
    fi
    echo ""
    
    # 2. 서비스 상태
    echo "${YELLOW}🚀 서비스 상태${RESET}"
    echo "----------------------------------------"
    brew services list 2>/dev/null | grep jenkins || echo "Jenkins 서비스를 찾을 수 없습니다."
    echo ""
    
    # 3. Jenkins 버전 (API)
    echo "${YELLOW}📋 Jenkins 버전 (API 확인)${RESET}"
    echo "----------------------------------------"
    local version=$(curl -s -I http://localhost:8080 2>/dev/null | grep -i "X-Jenkins:" | awk '{print $2}')
    if [[ -n "$version" ]]; then
        echo "Jenkins 버전: ${GREEN}$version${RESET}"
    else
        echo "${RED}Jenkins에 연결할 수 없습니다. 서비스가 실행 중인지 확인하세요.${RESET}"
    fi
    echo ""
    
    # 4. Java 버전
    echo "${YELLOW}☕ Java 버전${RESET}"
    echo "----------------------------------------"
    java -version 2>&1 | head -1
    echo ""
    
    # 5. 디스크 사용량
    echo "${YELLOW}💾 Jenkins 홈 디렉토리 사용량${RESET}"
    echo "----------------------------------------"
    if [[ -d ~/.jenkins ]]; then
        du -sh ~/.jenkins 2>/dev/null
    else
        echo "~/.jenkins 디렉토리를 찾을 수 없습니다."
    fi
    
    echo ""
    echo "${YELLOW}엔터를 누르면 돌아갑니다...${RESET}"
    read -k 1
}

# Jenkins 플러그인 관리
function _seongmin_jenkins_plugin() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${CYAN}🔌 [ Jenkins - 플러그인 관리 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 설치된 플러그인 목록"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins${RESET}"
        echo "      설명: 현재 설치된 모든 플러그인과 버전을 표시합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 플러그인 설치"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin <plugin-id>${RESET}"
        echo "      설명: 새 플러그인을 설치합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 업데이트 가능한 플러그인 확인"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins | grep -v "(" | awk '{ print \$1 }'${RESET}"
        echo "      설명: 업데이트가 필요한 플러그인을 확인합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 안전한 재시작 (플러그인 적용)"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ safe-restart${RESET}"
        echo "      설명: 실행 중인 빌드 완료 후 Jenkins를 재시작합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 플러그인 비활성화"
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ disable-plugin <plugin-id>${RESET}"
        echo "      설명: 특정 플러그인을 비활성화합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}🔌 설치된 플러그인 목록${RESET}"
                echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins"
                echo ""
                if [[ -f "jenkins-cli.jar" ]]; then
                    java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins | column -t
                else
                    echo "${RED}❌ jenkins-cli.jar 파일을 찾을 수 없습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📦 플러그인 설치${RESET}"
                echo "일반적으로 많이 사용되는 플러그인:"
                echo "  - git, github, docker-plugin, pipeline-stage-view"
                echo "  - blueocean, kubernetes, slack, email-extension"
                echo ""
                echo -n "설치할 플러그인 ID (예: git): "
                read plugin_id
                if [[ -n "$plugin_id" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin $plugin_id"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin "$plugin_id"
                    echo "${GREEN}✅ $plugin_id 플러그인 설치 완료!${RESET}"
                    echo "${YELLOW}⚠️ 적용하려면 Jenkins를 재시작하세요.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${CYAN}🔄 업데이트 가능한 플러그인 확인${RESET}"
                echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins"
                echo ""
                if [[ -f "jenkins-cli.jar" ]]; then
                    echo "플러그인 목록 (업데이트 가능 여부 확인):"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins 2>/dev/null | head -30
                else
                    echo "${RED}❌ jenkins-cli.jar 파일을 찾을 수 없습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${YELLOW}🔄 안전한 재시작${RESET}"
                echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ safe-restart"
                echo ""
                echo -n "실행 중인 빌드 완료 후 Jenkins를 재시작하시겠습니까? (y/n): "
                read confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    java -jar jenkins-cli.jar -s http://localhost:8080/ safe-restart
                    echo "${GREEN}✅ 안전한 재시작이 예약되었습니다.${RESET}"
                else
                    echo "취소되었습니다."
                fi
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${YELLOW}⏸️ 플러그인 비활성화${RESET}"
                echo -n "비활성화할 플러그인 ID: "
                read plugin_id
                if [[ -n "$plugin_id" ]]; then
                    echo "실행 명령어: java -jar jenkins-cli.jar -s http://localhost:8080/ disable-plugin $plugin_id"
                    java -jar jenkins-cli.jar -s http://localhost:8080/ disable-plugin "$plugin_id"
                    echo "${YELLOW}⏸️ $plugin_id 플러그인이 비활성화되었습니다.${RESET}"
                fi
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}

