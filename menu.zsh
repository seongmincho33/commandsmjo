# 🌸 성민이의 소중한 명령어 메뉴판 (인터랙티브 버전!)

# ═══════════════════════════════════════════════════════════════
# 메뉴 자체 버전
# ═══════════════════════════════════════════════════════════════
SEONGMIN_MENU_VERSION="2.0.0"

# ═══════════════════════════════════════════════════════════════
# 공통 인프라 헬퍼 (Phase 1)
# ═══════════════════════════════════════════════════════════════

# 색상 변수 (NO_COLOR 환경변수 존중)
_seongmin_init_colors() {
    if [[ -n "$NO_COLOR" ]]; then
        PINK='' CYAN='' YELLOW='' GREEN='' RED='' BLUE='' MAGENTA='' RESET=''
    else
        PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
        GREEN='\033[1;32m' RED='\033[1;31m' BLUE='\033[1;34m'
        MAGENTA='\033[1;35m' RESET='\033[0m'
    fi
}

# OS 분기
_seongmin_is_macos() { [[ "$OSTYPE" == "darwin"* ]]; }
_seongmin_is_linux() { [[ "$OSTYPE" == "linux-gnu"* ]]; }

# OS 호환성 표시
_seongmin_compat_mark() {
    case "$1" in
        macos_only) echo "✅macOS" ;;
        linux_only) echo "✅Linux" ;;
        both)       echo "✅macOS ✅Linux" ;;
        macos_full) echo "✅macOS ⚠️Linux" ;;
    esac
}

# 명령어 존재 확인 + 친절한 안내
_seongmin_require_cmd() {
    local cmd="$1"
    local install_hint="$2"
    if ! command -v "$cmd" &> /dev/null; then
        _seongmin_init_colors
        echo "${RED}❌ '$cmd' 명령어를 찾을 수 없습니다.${RESET}"
        if [[ -n "$install_hint" ]]; then
            echo "${YELLOW}💡 설치 방법: $install_hint${RESET}"
        fi
        echo ""
        echo "${CYAN}아무 키나 누르면 돌아갑니다...${RESET}"
        read -k 1
        return 1
    fi
    return 0
}

# Breadcrumb 헤더
_seongmin_header() {
    _seongmin_init_colors
    local path="$1"
    local emoji="${2:-🌸}"
    echo "${PINK}✨ ============================================== ✨${RESET}"
    echo "         ${emoji} ${path}"
    echo "${PINK}✨ ============================================== ✨${RESET}"
    echo ""
}

# 일관된 "키 입력 대기" 메시지
_seongmin_pause() {
    _seongmin_init_colors
    echo ""
    echo "${CYAN}아무 키나 누르면 돌아갑니다...${RESET}"
    read -k 1
}

# Docker daemon 체크
_seongmin_check_docker() {
    if ! _seongmin_require_cmd docker "https://www.docker.com/products/docker-desktop"; then
        return 1
    fi
    if ! docker info &> /dev/null; then
        _seongmin_init_colors
        echo "${RED}❌ Docker daemon이 실행 중이 아닙니다.${RESET}"
        if _seongmin_is_macos; then
            echo "${YELLOW}💡 Docker Desktop을 실행해주세요.${RESET}"
            echo "   ${CYAN}open -a Docker${RESET} (또는 메뉴바에서)"
        else
            echo "${YELLOW}💡 sudo systemctl start docker${RESET}"
        fi
        _seongmin_pause
        return 1
    fi
    return 0
}

# Compose v1/v2 자동 감지
_seongmin_compose_cmd() {
    if docker compose version &> /dev/null; then
        echo "docker compose"
    elif command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo ""
    fi
}

# brew 명령 가능 여부 (Linux에는 거의 없음)
_seongmin_check_brew() {
    _seongmin_require_cmd brew "https://brew.sh"
}

# ═══════════════════════════════════════════════════════════════
# 직접 실행 모드 (Direct Execution Mode)
# 사용법: gg git status, gg docker ps, gg brew update 등
# ═══════════════════════════════════════════════════════════════

# 위험 명령어 확인 함수
_seongmin_confirm_dangerous() {
    local cmd="$*"
    local YELLOW='\033[1;33m'
    local RED='\033[1;31m'
    local RESET='\033[0m'

    echo ""
    echo "${RED}⚠️  주의: 위험한 명령어입니다!${RESET}"
    echo "${YELLOW}실행할 명령어: $cmd${RESET}"
    echo ""
    echo -n "정말 실행할까요? (y/N) > "
    read confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        return 0
    else
        echo "취소되었습니다."
        return 1
    fi
}

# 위험 명령어 체크 함수
_seongmin_is_dangerous() {
    local cmd="$*"

    # 위험 명령어 패턴 목록
    local dangerous_patterns=(
        "git push --force"
        "git push -f"
        "git reset --hard"
        "git clean -fd"
        "git checkout ."
        "docker system prune"
        "docker volume prune"
        "docker container prune"
        "docker image prune -a"
        "docker rm -f"
        "docker rmi -f"
        "rm -rf"
        "brew cleanup --prune=all"
        "brew uninstall"
        "FLUSHDB"
        "FLUSHALL"
        "redis-cli FLUSHDB"
        "redis-cli FLUSHALL"
        "git tag -d"
        "git push origin --delete"
    )

    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$cmd" == *"$pattern"* ]]; then
            return 0  # 위험함
        fi
    done

    return 1  # 안전함
}

# 직접 실행 함수
_seongmin_direct() {
    local category="$1"
    shift
    local args="$*"
    local full_cmd=""

    local GREEN='\033[1;32m'
    local CYAN='\033[1;36m'
    local YELLOW='\033[1;33m'
    local RED='\033[1;31m'
    local RESET='\033[0m'

    case "$category" in
        # Git 명령어
        git|g)
            full_cmd="git $args"
            ;;

        # Python 명령어
        python|py)
            full_cmd="python3 $args"
            ;;
        pip)
            full_cmd="pip3 $args"
            ;;
        venv)
            case "$args" in
                create|new)
                    full_cmd="python3 -m venv venv"
                    ;;
                activate|on)
                    echo "${GREEN}가상환경 활성화:${RESET} source venv/bin/activate"
                    source venv/bin/activate 2>/dev/null || source .venv/bin/activate 2>/dev/null || echo "${RED}venv를 찾을 수 없어요${RESET}"
                    return
                    ;;
                deactivate|off)
                    deactivate 2>/dev/null || echo "${YELLOW}활성화된 가상환경이 없어요${RESET}"
                    return
                    ;;
                *)
                    full_cmd="python3 -m venv $args"
                    ;;
            esac
            ;;

        # Java 명령어
        java|j)
            full_cmd="java $args"
            ;;
        javac)
            full_cmd="javac $args"
            ;;
        gradle|gr)
            full_cmd="./gradlew $args"
            ;;
        maven|mvn)
            full_cmd="mvn $args"
            ;;

        # Homebrew 명령어
        brew|b)
            full_cmd="brew $args"
            ;;

        # Docker 명령어
        docker|d)
            full_cmd="docker $args"
            ;;
        dc|compose)
            full_cmd="docker compose $args"
            ;;

        # Redis 명령어
        redis)
            case "$args" in
                start)
                    full_cmd="brew services start redis"
                    ;;
                stop)
                    full_cmd="brew services stop redis"
                    ;;
                cli)
                    full_cmd="redis-cli"
                    ;;
                *)
                    full_cmd="redis-cli $args"
                    ;;
            esac
            ;;

        # 버전 확인 단축키
        version|ver|v)
            echo "${CYAN}📦 버전 정보${RESET}"
            echo "─────────────────────────"
            echo "Python:  $(python3 --version 2>/dev/null || echo 'not installed')"
            echo "Node:    $(node --version 2>/dev/null || echo 'not installed')"
            echo "Java:    $(java -version 2>&1 | head -1)"
            echo "Git:     $(git --version 2>/dev/null || echo 'not installed')"
            echo "Docker:  $(docker --version 2>/dev/null || echo 'not installed')"
            echo "─────────────────────────"
            return
            ;;

        # 도움말
        help|h|--help|-h)
            _seongmin_direct_help
            return
            ;;

        # 메뉴 자체 버전
        --version|-V)
            echo "${CYAN}🌸 DX Kit${RESET} v${SEONGMIN_MENU_VERSION}  ${YELLOW}(by Seongmin)${RESET}"
            echo "OS:    $(_seongmin_is_macos && echo macOS || (_seongmin_is_linux && echo Linux) || echo "$OSTYPE")"
            echo "Shell: ${SHELL}"
            echo "명령어: ${GREEN}dxk${RESET} (또는 ${CYAN}gg${RESET})"
            return
            ;;

        # 메뉴 검색
        search|find|s)
            _seongmin_search "$args"
            return
            ;;

        # 메뉴 자체 업데이트
        update|upgrade|self-update)
            _seongmin_self_update
            return
            ;;

        # 알 수 없는 명령어
        *)
            echo "${RED}알 수 없는 카테고리: $category${RESET}"
            echo ""
            _seongmin_direct_help
            return 1
            ;;
    esac

    # 명령어 실행
    if [[ -n "$full_cmd" ]]; then
        # 위험 명령어 체크
        if _seongmin_is_dangerous "$full_cmd"; then
            if ! _seongmin_confirm_dangerous "$full_cmd"; then
                return 1
            fi
        fi

        echo "${GREEN}▶ 실행:${RESET} $full_cmd"
        echo ""
        eval "$full_cmd"
    fi
}

# 직접 실행 모드 도움말
_seongmin_direct_help() {
    local CYAN='\033[1;36m'
    local GREEN='\033[1;32m'
    local YELLOW='\033[1;33m'
    local RESET='\033[0m'

    echo "${CYAN}═══════════════════════════════════════════════════${RESET}"
    echo "        ${GREEN}🚀 직접 실행 모드 사용법${RESET}"
    echo "${CYAN}═══════════════════════════════════════════════════${RESET}"
    echo ""
    echo "${YELLOW}기본 사용법:${RESET} dxk <카테고리> <명령어>    ${CYAN}(별칭: gg)${RESET}"
    echo ""
    echo "${GREEN}지원 카테고리:${RESET}"
    echo "  git, g      │ dxk git status, dxk g pull"
    echo "  python, py  │ dxk py script.py"
    echo "  pip         │ dxk pip install requests"
    echo "  venv        │ dxk venv create, dxk venv on/off"
    echo "  docker, d   │ dxk d ps, dxk docker images"
    echo "  dc, compose │ dxk dc up -d, dxk compose down"
    echo "  brew, b     │ dxk brew update, dxk b install node"
    echo "  gradle, gr  │ dxk gr build, dxk gradle test"
    echo "  maven, mvn  │ dxk mvn clean install"
    echo "  redis       │ dxk redis start/stop/cli"
    echo "  version, v  │ dxk v (모든 버전 확인)"
    echo ""
    echo "${YELLOW}예시:${RESET}"
    echo "  dxk git status         # git status 실행"
    echo "  dxk g add .            # git add . 실행"
    echo "  dxk docker ps -a       # docker ps -a 실행"
    echo "  dxk venv on            # 가상환경 활성화"
    echo "  dxk v                  # 설치된 도구 버전 확인"
    echo ""
    echo "${GREEN}메뉴 메타 명령:${RESET}"
    echo "  dxk --version          # 메뉴 버전 표시"
    echo "  dxk search <키워드>    # 메뉴 항목 검색"
    echo "  dxk update             # DX Kit 자체 업데이트 (git pull)"
    echo ""
    echo "${CYAN}인자 없이 'dxk'만 입력하면 인터랙티브 메뉴가 열립니다.${RESET}"
    echo "${CYAN}기존 'gg' 명령도 계속 사용 가능합니다.${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 메뉴 검색 (gg search <키워드>)
# ═══════════════════════════════════════════════════════════════
_seongmin_search() {
    _seongmin_init_colors
    local keyword="$*"
    if [[ -z "$keyword" ]]; then
        echo "${YELLOW}사용법: gg search <키워드>${RESET}"
        echo "예시: gg search push"
        return 1
    fi
    local menu_file="${HOME}/.zsh_menu/menu.zsh"
    [[ ! -f "$menu_file" ]] && menu_file="${0:A:h}/menu.zsh" 2>/dev/null
    [[ ! -f "$menu_file" ]] && menu_file="$(pwd)/menu.zsh"

    if [[ ! -f "$menu_file" ]]; then
        echo "${RED}menu.zsh 파일 위치를 찾을 수 없어요.${RESET}"
        return 1
    fi

    echo "${CYAN}🔍 '${keyword}' 검색 결과:${RESET}"
    echo "${CYAN}────────────────────────────────────────${RESET}"

    # fzf 있으면 사용, 없으면 grep
    if command -v fzf &> /dev/null; then
        grep -n -i "$keyword" "$menu_file" | grep -E "^\s*[0-9]+:.*echo|^\s*[0-9]+:.*function _seongmin_" | \
            fzf --ansi --preview "echo {} | cut -d: -f2-" --preview-window=down:3:wrap
    else
        grep -n -i --color=auto "$keyword" "$menu_file" | \
            grep -E "echo \"|function _seongmin_" | head -30
        echo ""
        echo "${YELLOW}💡 fzf 설치하면 더 편해요: brew install fzf${RESET}"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 메뉴 자체 업데이트 (gg update)
# ═══════════════════════════════════════════════════════════════
_seongmin_self_update() {
    _seongmin_init_colors
    local install_dir="${HOME}/.zsh_menu"

    echo "${CYAN}🔄 DX Kit 업데이트 확인 중...${RESET}"
    echo ""

    if [[ ! -d "$install_dir/.git" ]]; then
        echo "${YELLOW}⚠️  설치 폴더가 git 저장소가 아닙니다.${RESET}"
        echo "${YELLOW}   소스에서 다시 install.sh를 실행해주세요.${RESET}"
        return 1
    fi

    cd "$install_dir" && {
        echo "${CYAN}현재 버전:${RESET} v${SEONGMIN_MENU_VERSION}"
        echo "${CYAN}원격 저장소 확인 중...${RESET}"
        git fetch --quiet 2>&1
        local behind=$(git rev-list HEAD..@{upstream} --count 2>/dev/null)
        if [[ "$behind" == "0" || -z "$behind" ]]; then
            echo "${GREEN}✅ 이미 최신 버전입니다.${RESET}"
        else
            echo "${YELLOW}🆕 ${behind}개의 새 커밋이 있습니다.${RESET}"
            echo -n "지금 업데이트할까요? (y/N) > "
            read ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                git pull && {
                    echo "${GREEN}✅ 업데이트 완료! 새 터미널을 열거나 source ~/.zshrc 하세요.${RESET}"
                }
            fi
        fi
        cd - > /dev/null
    }
}

# ═══════════════════════════════════════════════════════════════

function seongmin() {
    local PINK='\033[1;35m'
    local CYAN='\033[1;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[1;32m'
    local RED='\033[1;31m'
    local RESET='\033[0m'

    # 인자가 있으면 직접 실행 모드
    if [[ -n "$1" ]]; then
        _seongmin_direct "$@"
        return $?
    fi

    # 인자가 없으면 인터랙티브 메뉴
    while true; do
        clear
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo "      🌸 DX Kit — 성민이의 개발자 경험 도구 v${SEONGMIN_MENU_VERSION}"
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo ""
        echo "  ${YELLOW}[ 개발 도구 ]${RESET}"
        echo "  ${CYAN}[1]${RESET} 🐙 Git              ${CYAN}[2]${RESET} 🐍 Python"
        echo "  ${CYAN}[3]${RESET} ☕ Java             ${CYAN}[4]${RESET} 🍺 Homebrew"
        echo "  ${CYAN}[5]${RESET} 🐳 Docker           ${CYAN}[6]${RESET} 🔴 Redis"
        echo ""
        echo "  ${YELLOW}[ 시스템 & 기타 ]${RESET}"
        echo "  ${CYAN}[7]${RESET} 🐚 Shell            ${CYAN}[8]${RESET} 🔍 버전 확인"
        echo "  ${CYAN}[9]${RESET} 🎨 Frontend         ${CYAN}[10]${RESET} 🔧 Jenkins"
        echo "  ${CYAN}[11]${RESET} 🤖 Claude Code"
        echo ""
        echo "  ${GREEN}[ 신규 (v2.0) ]${RESET}"
        echo "  ${CYAN}[12]${RESET} 🔐 SSH 키 관리      ${CYAN}[13]${RESET} 🌐 Network 진단"
        echo "  ${CYAN}[14]${RESET} 🆕 새 프로젝트 시작 ${CYAN}[15]${RESET} 🆘 응급 처치"
        echo "  ${CYAN}[16]${RESET} 🧪 유틸 도구"
        echo ""
        echo "  ${MAGENTA}[s]${RESET} 🔍 메뉴 검색  ${MAGENTA}[u]${RESET} 🔄 자체 업데이트  ${MAGENTA}[v]${RESET} ℹ️  버전"
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
            11) _seongmin_claude ;;
            12) _seongmin_ssh ;;
            13) _seongmin_network ;;
            14) _seongmin_newproject ;;
            15) _seongmin_emergency ;;
            16) _seongmin_utils ;;
            s|S)
                echo -n "  검색 키워드 > "
                read kw
                clear
                _seongmin_search "$kw"
                _seongmin_pause
                ;;
            u|U) clear; _seongmin_self_update; _seongmin_pause ;;
            v|V) clear; _seongmin_direct --version; _seongmin_pause ;;
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
        echo "  ${MAGENTA}[8]${RESET} ✨ Conventional Commits 형식으로 커밋"
        echo "      ${YELLOW}→ feat: / fix: / docs: ...${RESET}"
        echo "      설명: 표준 형식 prefix를 골라서 커밋합니다."
        echo ""
        echo "  ${MAGENTA}[9]${RESET} ✏️  마지막 커밋 수정 (amend)"
        echo "      ${YELLOW}→ git commit --amend${RESET}"
        echo "      설명: 직전 커밋의 메시지/내용을 수정합니다."
        echo ""
        echo "  ${MAGENTA}[10]${RESET} 📜 .gitignore 템플릿 생성"
        echo "      ${YELLOW}→ gitignore.io API${RESET}"
        echo "      설명: 언어/프레임워크에 맞는 .gitignore를 생성합니다."
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
            8)
                clear
                echo "${MAGENTA}✨ Conventional Commits${RESET}"
                echo ""
                echo "  ${GREEN}[1]${RESET} feat:     ✨ 새 기능"
                echo "  ${GREEN}[2]${RESET} fix:      🐛 버그 수정"
                echo "  ${GREEN}[3]${RESET} docs:     📝 문서 변경"
                echo "  ${GREEN}[4]${RESET} style:    💄 코드 포매팅"
                echo "  ${GREEN}[5]${RESET} refactor: ♻️  리팩토링"
                echo "  ${GREEN}[6]${RESET} perf:     ⚡ 성능 개선"
                echo "  ${GREEN}[7]${RESET} test:     ✅ 테스트 추가/수정"
                echo "  ${GREEN}[8]${RESET} chore:    🔧 빌드/도구 변경"
                echo "  ${GREEN}[9]${RESET} ci:       🤖 CI 설정 변경"
                echo ""
                echo -n "타입 선택 > "
                read ctype
                local prefix=""
                case $ctype in
                    1) prefix="feat" ;;
                    2) prefix="fix" ;;
                    3) prefix="docs" ;;
                    4) prefix="style" ;;
                    5) prefix="refactor" ;;
                    6) prefix="perf" ;;
                    7) prefix="test" ;;
                    8) prefix="chore" ;;
                    9) prefix="ci" ;;
                    *) echo "취소됨"; sleep 1; continue ;;
                esac
                echo -n "스코프 (선택, 예: api): "
                read scope
                echo -n "커밋 메시지: "
                read msg
                [[ -z "$msg" ]] && { echo "메시지 필수!"; sleep 1; continue; }
                local full_msg="$prefix"
                [[ -n "$scope" ]] && full_msg="${full_msg}(${scope})"
                full_msg="${full_msg}: ${msg}"
                echo ""
                echo "실행: git commit -m \"$full_msg\""
                git commit -m "$full_msg"
                _seongmin_pause
                ;;
            9)
                clear
                echo "${MAGENTA}✏️  마지막 커밋 수정 (amend)${RESET}"
                echo ""
                git log -1 --oneline
                echo ""
                echo "  [1] 메시지만 수정"
                echo "  [2] 스테이징된 변경사항 추가하면서 amend"
                echo "  [3] 메시지 그대로, 변경사항만 추가 (--no-edit)"
                echo "  [0] 취소"
                echo -n "선택: "
                read ao
                case $ao in
                    1)
                        echo -n "새 메시지: "; read newmsg
                        [[ -n "$newmsg" ]] && git commit --amend -m "$newmsg"
                        ;;
                    2) git commit --amend ;;
                    3) git commit --amend --no-edit ;;
                esac
                _seongmin_pause
                ;;
            10)
                clear
                echo "${MAGENTA}📜 .gitignore 생성${RESET}"
                echo "예시: python, node, java, macos, vscode (콤마로 구분)"
                echo -n "기술 스택 입력: "
                read stacks
                [[ -z "$stacks" ]] && { echo "취소됨"; sleep 1; continue; }
                if [[ -f .gitignore ]]; then
                    echo "${YELLOW}⚠️  .gitignore가 이미 존재합니다.${RESET}"
                    echo -n "덮어쓸까요? (y/N): "
                    read ans
                    [[ ! "$ans" =~ ^[Yy]$ ]] && continue
                fi
                if curl -fsSL "https://www.toptal.com/developers/gitignore/api/$stacks" -o .gitignore; then
                    echo "${GREEN}✅ .gitignore 생성됨${RESET}"
                    echo "${CYAN}── 미리보기 ──${RESET}"
                    head -20 .gitignore
                    echo "..."
                else
                    echo "${RED}❌ 생성 실패. 인터넷 연결 또는 키워드 확인.${RESET}"
                fi
                _seongmin_pause
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
        echo "  ${MAGENTA}[8]${RESET} 🔀 PR 생성 (gh pr create)"
        echo "      ${YELLOW}→ GitHub CLI 필요${RESET}"
        echo "      설명: 현재 브랜치로 GitHub에 Pull Request를 만듭니다."
        echo ""
        echo "  ${MAGENTA}[9]${RESET} 🌐 PR/저장소 브라우저로 열기"
        echo "      ${YELLOW}→ gh repo view --web${RESET}"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  뒤로가기"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            8)
                clear
                if ! command -v gh &> /dev/null; then
                    echo "${RED}❌ GitHub CLI(gh) 설치 필요: brew install gh${RESET}"
                    _seongmin_pause; continue
                fi
                if ! gh auth status &> /dev/null; then
                    echo "${YELLOW}⚠️  먼저 로그인 필요: gh auth login${RESET}"
                    _seongmin_pause; continue
                fi
                echo "${MAGENTA}🔀 PR 생성${RESET}"
                local current=$(git branch --show-current)
                echo "${CYAN}현재 브랜치: $current${RESET}"
                echo ""
                # 푸시 안 됐으면 먼저 push
                if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} &> /dev/null; then
                    echo "${YELLOW}원격에 추적 브랜치가 없어요. push -u 먼저 합니다...${RESET}"
                    git push -u origin "$current"
                fi
                gh pr create
                _seongmin_pause
                ;;
            9)
                clear
                if command -v gh &> /dev/null; then
                    gh repo view --web
                else
                    echo "${RED}gh CLI 필요${RESET}"
                fi
                _seongmin_pause
                ;;
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
    _seongmin_init_colors

    while true; do
        clear
        # 활성 venv 표시
        local venv_info=""
        if [[ -n "$VIRTUAL_ENV" ]]; then
            venv_info=" ${GREEN}[활성: $(basename $VIRTUAL_ENV)]${RESET}"
        fi
        # uv 감지 표시
        local uv_badge=""
        command -v uv &> /dev/null && uv_badge=" ${MAGENTA}[uv 감지됨]${RESET}"
        echo "${YELLOW}🐍 [ Python 명령어 ]${RESET}${venv_info}${uv_badge}"
        echo ""
        echo "  ${YELLOW}[ 가상환경 ]${RESET}"
        echo "  ${CYAN}[1]${RESET}  pv     - 가상환경 생성"
        echo "  ${CYAN}[2]${RESET}  pa     - 가상환경 활성화"
        echo "  ${CYAN}[3]${RESET}  pd     - 가상환경 비활성화"
        echo "  ${CYAN}[4]${RESET}  pynew  - 새 프로젝트 시작"
        echo "  ${CYAN}[5]${RESET}  pysetup- 프로젝트 셋업"
        echo "  ${CYAN}[12]${RESET} pyvl   - 가상환경 목록"
        echo ""
        echo "  ${YELLOW}[ 패키지 ]${RESET}"
        echo "  ${CYAN}[6]${RESET}  pl     - 설치된 패키지"
        echo "  ${CYAN}[7]${RESET}  plo    - 업데이트할 패키지"
        echo "  ${CYAN}[8]${RESET}  pfr    - requirements.txt 저장 (freeze)"
        echo "  ${CYAN}[10]${RESET} pir    - requirements.txt 설치"
        echo "  ${CYAN}[11]${RESET} pyv    - 설치된 Python 버전들"
        echo ""
        echo "  ${YELLOW}[ 실행 & 도구 ]${RESET}"
        echo "  ${CYAN}[9]${RESET}  pys    - 간단 웹서버 실행"
        echo "  ${CYAN}[13]${RESET} 🧪 pytest 실행"
        echo "  ${CYAN}[14]${RESET} 🧹 ruff (포매터/린터)"
        echo "  ${CYAN}[15]${RESET} 📓 Jupyter (notebook/lab)"
        echo "  ${CYAN}[16]${RESET} 🗑  __pycache__ / .pyc 정리"
        echo "  ${CYAN}[17]${RESET} ✨ uv 사용법 안내"
        echo "  ${CYAN}[0]${RESET}  ⬅️  돌아가기"
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
                echo "설명: 가상환경을 활성화하여 독립된 Python 환경으로 진입합니다."
                echo ""
                
                # 현재 활성화된 가상환경 표시
                if [[ -n "$VIRTUAL_ENV" ]]; then
                    echo "${YELLOW}⚡ 현재 활성화된 가상환경: $(basename $VIRTUAL_ENV)${RESET}"
                    echo ""
                fi
                
                # 현재 디렉토리 및 하위에서 가상환경 찾기
                echo "${CYAN}📁 발견된 가상환경 목록:${RESET}"
                echo "----------------------------------------"
                
                local venv_list=()
                local idx=1
                
                # pyvenv.cfg 파일을 찾아서 가상환경 디렉토리 확인
                while IFS= read -r cfg_file; do
                    if [[ -n "$cfg_file" ]]; then
                        local venv_dir=$(dirname "$cfg_file")
                        local venv_name=$(basename "$venv_dir")
                        local py_version=$(grep "version" "$cfg_file" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d ' ')
                        
                        # 활성화 상태 확인
                        local venv_status=""
                        if [[ "$VIRTUAL_ENV" == "$venv_dir" ]]; then
                            venv_status="${GREEN}[활성화됨]${RESET}"
                        fi
                        
                        venv_list+=("$venv_dir")
                        echo "  ${GREEN}[$idx]${RESET} $venv_name ${CYAN}(Python $py_version)${RESET} $venv_status"
                        echo "       📍 $venv_dir"
                        ((idx++))
                    fi
                done <<< "$(find . -maxdepth 3 -name 'pyvenv.cfg' -type f 2>/dev/null)"
                
                if [[ ${#venv_list[@]} -eq 0 ]]; then
                    echo "  ${RED}❌ 가상환경을 찾을 수 없습니다.${RESET}"
                    echo "  ${YELLOW}💡 [1]번 메뉴에서 가상환경을 먼저 생성해주세요.${RESET}"
                    echo ""
                    read -k 1
                else
                    echo "----------------------------------------"
                    echo ""
                    echo -n "활성화할 가상환경 번호 선택 (0: 취소): "
                    read venv_choice
                    
                    if [[ "$venv_choice" == "0" || -z "$venv_choice" ]]; then
                        echo "${YELLOW}취소되었습니다.${RESET}"
                    elif [[ "$venv_choice" =~ ^[0-9]+$ ]] && [[ $venv_choice -ge 1 ]] && [[ $venv_choice -le ${#venv_list[@]} ]]; then
                        local selected_venv="${venv_list[$venv_choice]}"
                        local activate_script="$selected_venv/bin/activate"
                        
                        if [[ -f "$activate_script" ]]; then
                            echo ""
                            echo "실행할 명령어: ${YELLOW}source $activate_script${RESET}"
                            echo ""
                            source "$activate_script"
                            echo "${GREEN}✅ '$(basename $selected_venv)' 가상환경이 활성화되었습니다!${RESET}"
                            echo "${CYAN}💡 프롬프트 앞에 ($(basename $selected_venv)) 표시를 확인하세요.${RESET}"
                        else
                            echo "${RED}❌ 활성화 스크립트를 찾을 수 없습니다.${RESET}"
                        fi
                    else
                        echo "${RED}❌ 잘못된 번호입니다.${RESET}"
                    fi
                    read -k 1
                fi
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
            13)
                clear
                echo "${GREEN}🧪 pytest 실행${RESET}"
                if ! command -v pytest &> /dev/null; then
                    echo "${YELLOW}pytest가 설치되어 있지 않아요.${RESET}"
                    echo -n "지금 설치할까요? (y/N): "
                    read ans
                    [[ "$ans" =~ ^[Yy]$ ]] && pip install pytest
                else
                    echo "${CYAN}옵션:${RESET}"
                    echo "  [1] 전체 실행 (pytest)"
                    echo "  [2] 자세한 출력 (pytest -v)"
                    echo "  [3] 마지막 실패만 (pytest --lf)"
                    echo "  [4] 커버리지 (pytest --cov)"
                    echo -n "선택: "
                    read po
                    case $po in
                        1) pytest ;;
                        2) pytest -v ;;
                        3) pytest --lf ;;
                        4) pytest --cov ;;
                    esac
                fi
                _seongmin_pause
                ;;
            14)
                clear
                echo "${GREEN}🧹 ruff (포매터/린터)${RESET}"
                if ! command -v ruff &> /dev/null; then
                    echo "${YELLOW}ruff가 설치되어 있지 않아요.${RESET}"
                    echo -n "지금 설치할까요? (y/N): "
                    read ans
                    [[ "$ans" =~ ^[Yy]$ ]] && pip install ruff
                else
                    echo "  [1] 검사 (ruff check .)"
                    echo "  [2] 자동 수정 (ruff check --fix .)"
                    echo "  [3] 포매팅 (ruff format .)"
                    echo -n "선택: "
                    read ro
                    case $ro in
                        1) ruff check . ;;
                        2) ruff check --fix . ;;
                        3) ruff format . ;;
                    esac
                fi
                _seongmin_pause
                ;;
            15)
                clear
                echo "${GREEN}📓 Jupyter${RESET}"
                if ! command -v jupyter &> /dev/null; then
                    echo "${YELLOW}jupyter 설치 필요: pip install jupyter${RESET}"
                else
                    echo "  [1] notebook  [2] lab"
                    echo -n "선택: "
                    read jo
                    case $jo in
                        1) jupyter notebook ;;
                        2) jupyter lab ;;
                    esac
                fi
                ;;
            16)
                clear
                echo "${YELLOW}🗑  __pycache__ / .pyc 정리${RESET}"
                local count=$(find . -type d -name '__pycache__' 2>/dev/null | wc -l | tr -d ' ')
                echo "${CYAN}찾은 __pycache__ 디렉토리: $count 개${RESET}"
                if [[ "$count" -gt 0 ]]; then
                    if _seongmin_confirm_dangerous "rm -rf __pycache__"; then
                        find . -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null
                        find . -type f -name '*.pyc' -delete 2>/dev/null
                        echo "${GREEN}✅ 정리 완료${RESET}"
                    fi
                fi
                _seongmin_pause
                ;;
            17)
                clear
                echo "${MAGENTA}✨ uv — 차세대 Python 패키지 관리자${RESET}"
                echo ""
                if command -v uv &> /dev/null; then
                    echo "${GREEN}✅ 설치됨: $(uv --version)${RESET}"
                else
                    echo "${YELLOW}설치: brew install uv${RESET}"
                    echo "또는:  curl -LsSf https://astral.sh/uv/install.sh | sh"
                fi
                echo ""
                echo "${CYAN}── 자주 쓰는 uv 명령 ──${RESET}"
                echo "  uv init                # 새 프로젝트"
                echo "  uv add <pkg>           # 패키지 추가 (pip install + lock)"
                echo "  uv remove <pkg>        # 패키지 제거"
                echo "  uv sync                # 의존성 동기화"
                echo "  uv run <스크립트>      # venv 자동 활성화 + 실행"
                echo "  uv pip install <pkg>   # pip 호환 모드"
                echo "  uv venv                # venv 생성 (10배 빠름)"
                echo ""
                echo "${YELLOW}💡 pip보다 10~100배 빠르고, lock 파일이 자동 관리됩니다.${RESET}"
                _seongmin_pause
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
        echo "  ${CYAN}[8]${RESET} 🔪 포트 점유 프로세스 종료 (Kill Port Process)"
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
            8) _seongmin_java_kill_port ;;
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

# 포트 점유 프로세스 종료
function _seongmin_java_kill_port() {
    local CYAN='\033[1;36m' YELLOW='\033[1;33m' GREEN='\033[1;32m' RED='\033[1;31m' RESET='\033[0m'
    
    clear
    echo "${RED}🔪 [ 포트 점유 프로세스 종료 ]${RESET}"
    echo "설명: 특정 포트를 점유하고 있는 프로세스를 찾아 종료합니다."
    echo "      Spring Boot 등이 비정상 종료 후 포트를 점유하고 있을 때 유용합니다."
    echo ""
    
    # 자주 사용되는 포트 안내
    echo "${CYAN}💡 자주 사용되는 포트:${RESET}"
    echo "   8080 - Spring Boot / Tomcat 기본"
    echo "   3000 - React / Node.js"
    echo "   5000 - Flask"
    echo "   3306 - MySQL"
    echo "   5432 - PostgreSQL"
    echo "   6379 - Redis"
    echo ""
    
    echo -n "확인할 포트 번호 입력: "
    read port_num
    
    if [[ -z "$port_num" ]]; then
        echo "${RED}❌ 포트 번호를 입력해주세요.${RESET}"
        read -k 1
        return
    fi
    
    if ! [[ "$port_num" =~ ^[0-9]+$ ]]; then
        echo "${RED}❌ 숫자만 입력해주세요.${RESET}"
        read -k 1
        return
    fi
    
    echo ""
    echo "${YELLOW}🔍 포트 $port_num 검사 중...${RESET}"
    echo "실행 명령어: ${CYAN}lsof -i :$port_num${RESET}"
    echo ""
    echo "----------------------------------------"
    
    # lsof 결과 가져오기
    local lsof_result=$(lsof -i :$port_num 2>/dev/null)
    
    if [[ -z "$lsof_result" ]]; then
        echo "${GREEN}✅ 포트 $port_num 을 사용하는 프로세스가 없습니다!${RESET}"
        echo ""
        read -k 1
        return
    fi
    
    # 결과 출력
    echo "$lsof_result"
    echo "----------------------------------------"
    echo ""
    
    # PID 추출 (헤더 제외)
    local pids=($(echo "$lsof_result" | tail -n +2 | awk '{print $2}' | sort -u))
    
    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "${GREEN}✅ 종료할 프로세스가 없습니다.${RESET}"
        read -k 1
        return
    fi
    
    echo "${YELLOW}발견된 프로세스 PID: ${pids[*]}${RESET}"
    echo ""
    echo "  ${GREEN}[1]${RESET} 모든 프로세스 종료 (kill)"
    echo "  ${RED}[2]${RESET} 모든 프로세스 강제 종료 (kill -9)"
    echo "  ${CYAN}[3]${RESET} 개별 선택하여 종료"
    echo "  ${YELLOW}[0]${RESET} 취소"
    echo ""
    echo -n "선택: "
    read kill_choice
    
    case $kill_choice in
        1)
            echo ""
            echo "${YELLOW}프로세스 종료 중...${RESET}"
            for pid in "${pids[@]}"; do
                echo "  kill $pid"
                kill $pid 2>/dev/null
            done
            echo ""
            echo "${GREEN}✅ 종료 신호를 보냈습니다.${RESET}"
            ;;
        2)
            echo ""
            echo "${RED}프로세스 강제 종료 중...${RESET}"
            for pid in "${pids[@]}"; do
                echo "  kill -9 $pid"
                kill -9 $pid 2>/dev/null
            done
            echo ""
            echo "${GREEN}✅ 강제 종료 완료!${RESET}"
            ;;
        3)
            echo ""
            echo "${CYAN}개별 프로세스 선택:${RESET}"
            local idx=1
            for pid in "${pids[@]}"; do
                local proc_name=$(ps -p $pid -o comm= 2>/dev/null)
                echo "  [$idx] PID: $pid - $proc_name"
                ((idx++))
            done
            echo ""
            echo -n "종료할 프로세스 번호 (여러개: 1,2,3 또는 all): "
            read select_pids
            
            if [[ "$select_pids" == "all" ]]; then
                for pid in "${pids[@]}"; do
                    kill $pid 2>/dev/null
                done
                echo "${GREEN}✅ 모든 프로세스 종료 신호 전송!${RESET}"
            else
                IFS=',' read -A selected <<< "$select_pids"
                for sel in "${selected[@]}"; do
                    sel=$(echo $sel | tr -d ' ')
                    if [[ "$sel" =~ ^[0-9]+$ ]] && [[ $sel -ge 1 ]] && [[ $sel -le ${#pids[@]} ]]; then
                        local target_pid="${pids[$sel]}"
                        echo "  kill $target_pid"
                        kill $target_pid 2>/dev/null
                    fi
                done
                echo "${GREEN}✅ 선택한 프로세스 종료 신호 전송!${RESET}"
            fi
            ;;
        0|*)
            echo "${YELLOW}취소되었습니다.${RESET}"
            ;;
    esac
    
    echo ""
    read -k 1
}

# Homebrew 서브메뉴
function _seongmin_brew() {
    _seongmin_init_colors
    _seongmin_check_brew || return

    while true; do
        clear
        _seongmin_header "Homebrew" "🍺"
        echo "  ${YELLOW}[ 패키지 관리 ]${RESET}"
        echo "  ${CYAN}[1]${RESET} 🔍 검색      (brew search)"
        echo "  ${CYAN}[2]${RESET} 📥 설치      (brew install)"
        echo "  ${CYAN}[3]${RESET} 🗑  제거      (brew uninstall)"
        echo "  ${CYAN}[4]${RESET} ℹ️  정보 보기 (brew info)"
        echo ""
        echo "  ${YELLOW}[ 업데이트 & 정리 ]${RESET}"
        echo "  ${CYAN}[5]${RESET} 🆙 update + upgrade"
        echo "  ${CYAN}[6]${RESET} 📊 outdated (업데이트 가능 목록)"
        echo "  ${CYAN}[7]${RESET} 🧹 cleanup"
        echo "  ${CYAN}[8]${RESET} 🩺 doctor (상태 진단)"
        echo ""
        echo "  ${YELLOW}[ 목록 & 분석 ]${RESET}"
        echo "  ${CYAN}[9]${RESET}  📋 list (전체)"
        echo "  ${CYAN}[10]${RESET} 🌳 leaves (최상위 패키지만)"
        echo "  ${CYAN}[11]${RESET} 🎨 예쁘게 보기 (Pretty List)"
        echo "  ${CYAN}[12]${RESET} 📦 services list"
        echo "  ${CYAN}[13]${RESET} 💾 Brewfile 생성 (bundle dump)"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice

        case $subchoice in
            1)
                clear
                echo "${GREEN}🔍 Brew 검색${RESET}"
                echo -n "검색어 입력: "
                read kw
                [[ -z "$kw" ]] && { echo "취소됨"; sleep 1; continue; }
                echo ""
                echo "실행: brew search $kw"
                echo ""
                brew search "$kw"
                _seongmin_pause
                ;;
            2)
                clear
                echo "${GREEN}📥 Brew 설치${RESET}"
                echo -n "설치할 패키지 이름: "
                read pkg
                [[ -z "$pkg" ]] && { echo "취소됨"; sleep 1; continue; }
                echo -n "Cask 인가요? (앱 설치) (y/N): "
                read is_cask
                if [[ "$is_cask" =~ ^[Yy]$ ]]; then
                    echo "실행: brew install --cask $pkg"
                    brew install --cask "$pkg"
                else
                    echo "실행: brew install $pkg"
                    brew install "$pkg"
                fi
                _seongmin_pause
                ;;
            3)
                clear
                echo "${RED}🗑  Brew 제거${RESET}"
                echo -n "제거할 패키지 이름: "
                read pkg
                [[ -z "$pkg" ]] && { echo "취소됨"; sleep 1; continue; }
                if _seongmin_confirm_dangerous "brew uninstall $pkg"; then
                    brew uninstall "$pkg"
                fi
                _seongmin_pause
                ;;
            4)
                clear
                echo "${GREEN}ℹ️  Brew 패키지 정보${RESET}"
                echo -n "패키지 이름: "
                read pkg
                [[ -z "$pkg" ]] && { echo "취소됨"; sleep 1; continue; }
                echo ""
                brew info "$pkg"
                _seongmin_pause
                ;;
            5)
                clear
                echo "${GREEN}🆙 Update + Upgrade${RESET}"
                brew update && brew upgrade
                _seongmin_pause
                ;;
            6)
                clear
                echo "${GREEN}📊 업데이트 가능한 패키지${RESET}"
                local outdated=$(brew outdated)
                if [[ -z "$outdated" ]]; then
                    echo "${GREEN}✅ 모든 패키지가 최신 상태입니다.${RESET}"
                else
                    echo "$outdated"
                    echo ""
                    echo -n "지금 모두 업그레이드할까요? (y/N): "
                    read ans
                    if [[ "$ans" =~ ^[Yy]$ ]]; then
                        brew upgrade
                    fi
                fi
                _seongmin_pause
                ;;
            7) clear; brew cleanup; echo "${GREEN}✅ 정리 완료!${RESET}"; _seongmin_pause ;;
            8) clear; brew doctor; _seongmin_pause ;;
            9) clear; brew list; _seongmin_pause ;;
            10)
                clear
                echo "${GREEN}🌳 최상위 패키지 (의존성 아닌 것)${RESET}"
                echo "${CYAN}── 다른 패키지가 의존하지 않는 패키지들 ──${RESET}"
                brew leaves
                local count=$(brew leaves | wc -l | tr -d ' ')
                echo ""
                echo "${CYAN}총 ${count}개${RESET}"
                _seongmin_pause
                ;;
            11) _seongmin_brew_pretty_list ;;
            12) clear; brew services list; _seongmin_pause ;;
            13)
                clear
                echo "${GREEN}💾 Brewfile 생성${RESET}"
                echo "현재 설치된 패키지를 Brewfile로 저장합니다 (이주/백업용)"
                echo -n "저장 경로 (기본: ./Brewfile): "
                read path
                [[ -z "$path" ]] && path="./Brewfile"
                brew bundle dump --file="$path" --force
                echo "${GREEN}✅ $path 생성됨${RESET}"
                echo "${CYAN}복원 명령: brew bundle install --file=$path${RESET}"
                _seongmin_pause
                ;;
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
    _seongmin_init_colors
    _seongmin_check_docker || return

    while true; do
        clear
        _seongmin_header "Docker" "🐳"
        echo "  ${GREEN}[1]${RESET} 📦 컨테이너 관리 (Container)"
        echo "  ${GREEN}[2]${RESET} 🖼️  이미지 관리 (Image)"
        echo "  ${GREEN}[3]${RESET} 🎼 Docker Compose"
        echo "  ${GREEN}[4]${RESET} 💾 볼륨 & 네트워크 (Volume & Network)"
        echo "  ${GREEN}[5]${RESET} 🔧 시스템 관리 (System)"
        echo "  ${GREEN}[6]${RESET} 📊 상태 및 버전 확인 (Status)"
        echo "  ${GREEN}[7]${RESET} 📡 실시간 모니터링 (stats)"
        echo "  ${GREEN}[8]${RESET} 📜 로그 따라가기 (logs -f)"
        echo "  ${GREEN}[9]${RESET} 💻 컨테이너 진입 (exec sh)"
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
            7)
                clear
                echo "${CYAN}📡 docker stats (Ctrl+C로 종료)${RESET}"
                docker stats
                ;;
            8)
                clear
                echo "${CYAN}📜 컨테이너 로그 따라가기${RESET}"
                docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
                echo ""
                echo -n "컨테이너 이름 또는 ID: "
                read cname
                [[ -z "$cname" ]] && continue
                echo "실행: docker logs -f --tail 100 $cname (Ctrl+C로 종료)"
                docker logs -f --tail 100 "$cname"
                ;;
            9)
                clear
                echo "${CYAN}💻 컨테이너 진입${RESET}"
                docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
                echo ""
                echo -n "컨테이너 이름 또는 ID: "
                read cname
                [[ -z "$cname" ]] && continue
                echo -n "셸 (기본 sh, 예: bash): "
                read shell_type
                [[ -z "$shell_type" ]] && shell_type="sh"
                echo "실행: docker exec -it $cname $shell_type"
                docker exec -it "$cname" "$shell_type"
                ;;
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
    _seongmin_init_colors

    # OS별 시작/중지 명령
    local start_cmd stop_cmd restart_cmd
    if _seongmin_is_macos && command -v brew &> /dev/null; then
        start_cmd="brew services start redis"
        stop_cmd="brew services stop redis"
        restart_cmd="brew services restart redis"
    else
        start_cmd="sudo systemctl start redis"
        stop_cmd="sudo systemctl stop redis"
        restart_cmd="sudo systemctl restart redis"
    fi

    while true; do
        clear
        _seongmin_header "Redis" "🔴"
        echo "  ${YELLOW}[ 서비스 관리 ]${RESET}"
        echo "  ${CYAN}[1]${RESET} 시작        (${start_cmd})"
        echo "  ${CYAN}[2]${RESET} 중지        (${stop_cmd})"
        echo "  ${CYAN}[3]${RESET} 재시작      (${restart_cmd})"
        echo ""
        echo "  ${YELLOW}[ 연결 & 진단 ]${RESET}"
        echo "  ${CYAN}[4]${RESET} 🏓 PING 테스트 (redis-cli ping)"
        echo "  ${CYAN}[5]${RESET} 💻 redis-cli 진입"
        echo "  ${CYAN}[6]${RESET} 🧐 상태 및 버전 확인"
        echo ""
        echo "  ${YELLOW}[ 데이터 조회 ]${RESET}"
        echo "  ${CYAN}[7]${RESET} 🔑 KEYS * (모든 키, 운영DB 주의)"
        echo "  ${CYAN}[8]${RESET} 📏 DBSIZE (키 개수)"
        echo "  ${CYAN}[9]${RESET} 📊 INFO memory (메모리 정보)"
        echo "  ${CYAN}[10]${RESET} 🚨 FLUSHDB (현재 DB 비우기 - 위험!)"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice

        case $subchoice in
            1) clear; eval "$start_cmd"; _seongmin_pause ;;
            2) clear; eval "$stop_cmd"; _seongmin_pause ;;
            3) clear; eval "$restart_cmd"; _seongmin_pause ;;
            4)
                clear
                echo "${GREEN}🏓 Redis PING 테스트${RESET}"
                local result=$(redis-cli ping 2>&1)
                if [[ "$result" == "PONG" ]]; then
                    echo "${GREEN}✅ PONG — Redis 연결 정상!${RESET}"
                else
                    echo "${RED}❌ 응답 실패: $result${RESET}"
                fi
                _seongmin_pause
                ;;
            5) clear; echo "${CYAN}redis-cli (exit로 나가기)${RESET}"; redis-cli ;;
            6) _seongmin_redis_check ;;
            7)
                clear
                echo "${YELLOW}🔑 모든 키 조회${RESET}"
                echo "${RED}⚠️  운영 DB에서는 KEYS * 사용 자제! (SCAN 권장)${RESET}"
                echo ""
                redis-cli KEYS '*'
                _seongmin_pause
                ;;
            8) clear; echo "${GREEN}📏 DBSIZE${RESET}"; redis-cli DBSIZE; _seongmin_pause ;;
            9) clear; redis-cli INFO memory; _seongmin_pause ;;
            10)
                clear
                if _seongmin_confirm_dangerous "redis-cli FLUSHDB"; then
                    redis-cli FLUSHDB
                    echo "${GREEN}✅ FLUSHDB 완료${RESET}"
                fi
                _seongmin_pause
                ;;
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
    _seongmin_init_colors

    while true; do
        clear
        _seongmin_header "Shell" "🐚"
        echo "  ${YELLOW}[ 설정 ]${RESET}"
        echo "  ${CYAN}[1]${RESET}  🔄 ~/.zshrc 새로고침"
        echo "  ${CYAN}[2]${RESET}  📝 ~/.zshrc 편집"
        echo "  ${CYAN}[3]${RESET}  📝 ~/.bashrc 편집"
        echo "  ${CYAN}[4]${RESET}  💾 dotfile 백업 (~/.zshrc, ~/.bashrc 등)"
        echo ""
        echo "  ${YELLOW}[ 환경 정보 ]${RESET}"
        echo "  ${CYAN}[5]${RESET}  🛣  PATH 예쁘게 보기"
        echo "  ${CYAN}[6]${RESET}  🏷  alias 목록"
        echo "  ${CYAN}[7]${RESET}  🌍 환경변수 검색 (env grep)"
        echo "  ${CYAN}[8]${RESET}  📜 history 검색"
        echo "  ${CYAN}[9]${RESET}  🐚 현재 셸 정보"
        echo ""
        echo "  ${YELLOW}[ 도구 ]${RESET}"
        echo "  ${CYAN}[10]${RESET} 🌟 oh-my-zsh 업데이트"
        echo "  ${CYAN}[11]${RESET} ⚙️  로그인 셸 변경 (chsh)"
        echo "  ${CYAN}[0]${RESET}  ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read sub

        case $sub in
            1) clear; source ~/.zshrc 2>/dev/null && echo "${GREEN}✅ 새로고침 완료${RESET}" || echo "${RED}오류 발생${RESET}"; _seongmin_pause ;;
            2) ${EDITOR:-vi} ~/.zshrc ;;
            3) ${EDITOR:-vi} ~/.bashrc ;;
            4)
                clear
                local backup_dir="$HOME/.dotfile_backup_$(date +%Y%m%d_%H%M%S)"
                mkdir -p "$backup_dir"
                for f in .zshrc .bashrc .profile .vimrc .gitconfig .ssh/config; do
                    [[ -f "$HOME/$f" ]] && cp "$HOME/$f" "$backup_dir/" 2>/dev/null
                done
                echo "${GREEN}✅ 백업 완료: $backup_dir${RESET}"
                ls -la "$backup_dir"
                _seongmin_pause
                ;;
            5)
                clear
                echo "${GREEN}🛣 PATH 분석${RESET}"
                echo "$PATH" | tr ':' '\n' | nl
                _seongmin_pause
                ;;
            6)
                clear
                echo -n "검색어 (비우면 전체): "
                read kw
                if [[ -z "$kw" ]]; then
                    alias | head -50
                    echo ""
                    echo "${YELLOW}(상위 50개만 표시)${RESET}"
                else
                    alias | grep -i "$kw"
                fi
                _seongmin_pause
                ;;
            7)
                clear
                echo -n "검색어: "
                read kw
                [[ -z "$kw" ]] && continue
                env | grep -i "$kw"
                _seongmin_pause
                ;;
            8)
                clear
                echo -n "검색어: "
                read kw
                [[ -z "$kw" ]] && continue
                history 1 | grep -i "$kw" | tail -30
                _seongmin_pause
                ;;
            9)
                clear
                echo "${GREEN}🐚 현재 셸 정보${RESET}"
                echo "  SHELL:      $SHELL"
                echo "  ZSH_VERSION: ${ZSH_VERSION:-N/A}"
                echo "  BASH_VERSION: ${BASH_VERSION:-N/A}"
                echo "  TERM:       $TERM"
                echo "  USER:       $USER"
                echo "  HOME:       $HOME"
                _seongmin_pause
                ;;
            10)
                clear
                if [[ -d "$HOME/.oh-my-zsh" ]]; then
                    "$HOME/.oh-my-zsh/tools/upgrade.sh"
                else
                    echo "${YELLOW}oh-my-zsh가 설치되어 있지 않습니다.${RESET}"
                    echo "설치: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
                fi
                _seongmin_pause
                ;;
            11)
                clear
                echo "${YELLOW}⚙️  로그인 셸 변경${RESET}"
                echo "현재 셸: $SHELL"
                echo "사용 가능: $(cat /etc/shells | grep -v '^#')"
                echo ""
                echo -n "변경할 셸 경로 (예: /bin/zsh, 빈 줄로 취소): "
                read newshell
                [[ -n "$newshell" ]] && chsh -s "$newshell"
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 번호${RESET}"; sleep 1 ;;
        esac
    done
}

# 버전 확인 서브메뉴
function _seongmin_version() {
    _seongmin_init_colors

    # 헬퍼: 버전 출력
    _vline() {
        local label="$1"
        local cmd="$2"
        printf "   %-13s " "$label"
        eval "$cmd" 2>/dev/null || echo "${RED}❌ 설치 안됨${RESET}"
    }

    clear
    _seongmin_header "설치된 버전 정보" "🔍"
    echo "${YELLOW}[ 언어 & 런타임 ]${RESET}"
    _vline "Python:"  "python3 --version"
    _vline "Node.js:" "node --version"
    _vline "Java:"    "java --version 2>&1 | head -1"
    _vline "Go:"      "go version"
    _vline "Rust:"    "rustc --version"
    _vline "Ruby:"    "ruby --version"
    _vline "PHP:"     "php --version 2>&1 | head -1"
    _vline "Bun:"     "bun --version"
    _vline "Deno:"    "deno --version 2>&1 | head -1"
    echo ""
    echo "${GREEN}[ 패키지 관리자 ]${RESET}"
    _vline "pip:"      "pip3 --version | awk '{print \$2}'"
    _vline "uv:"       "uv --version"
    _vline "npm:"      "npm --version"
    _vline "yarn:"     "yarn --version"
    _vline "pnpm:"     "pnpm --version"
    _vline "Homebrew:" "brew --version | head -1"
    _vline "cargo:"    "cargo --version"
    echo ""
    echo "${CYAN}[ 개발 & 인프라 도구 ]${RESET}"
    _vline "Git:"        "git --version"
    _vline "gh (GitHub):" "gh --version | head -1"
    _vline "Docker:"     "docker --version"
    _vline "kubectl:"    "kubectl version --client --short 2>/dev/null || kubectl version --client 2>&1 | head -1"
    _vline "terraform:"  "terraform version | head -1"
    _vline "aws:"        "aws --version 2>&1"
    _vline "gcloud:"     "gcloud --version 2>&1 | head -1"
    _vline "Redis:"      "redis-server --version | awk '{print \$3}'"
    _vline "PostgreSQL:" "psql --version"
    _vline "MySQL:"      "mysql --version"
    echo ""
    echo "${PINK}[ 셸 ]${RESET}"
    _vline "Zsh:"  "zsh --version"
    _vline "Bash:" "bash --version | head -1"
    _vline "fish:" "fish --version"
    echo ""
    _seongmin_pause
}

# 프론트엔드 서브메뉴
function _seongmin_frontend() {
    _seongmin_init_colors

    # 패키지 매니저 자동 감지 (현재 프로젝트 기준)
    local pm="npm"
    if [[ -f "bun.lockb" ]]; then pm="bun"
    elif [[ -f "pnpm-lock.yaml" ]]; then pm="pnpm"
    elif [[ -f "yarn.lock" ]]; then pm="yarn"
    fi

    while true; do
        clear
        _seongmin_header "Frontend (감지된 PM: $pm)" "🎨"
        echo "  ${YELLOW}[ 프로젝트 생성 ]${RESET}"
        echo "  ${CYAN}[1]${RESET}  ⚡ Vite (React/Vue/Svelte/Solid 등)"
        echo "  ${CYAN}[2]${RESET}  ▲  Next.js"
        echo "  ${CYAN}[3]${RESET}  🚀 Astro (Content sites)"
        echo "  ${CYAN}[4]${RESET}  💚 Nuxt (Vue)"
        echo "  ${CYAN}[5]${RESET}  🎵 SvelteKit"
        echo "  ${CYAN}[6]${RESET}  🎸 Remix"
        echo "  ${CYAN}[7]${RESET}  ⚛️  Create React App ${RED}(Deprecated)${RESET}"
        echo ""
        echo "  ${YELLOW}[ 일상 명령 (현재 프로젝트) ]${RESET}"
        echo "  ${CYAN}[8]${RESET}  📜 package.json scripts 보기"
        echo "  ${CYAN}[9]${RESET}  🚀 dev 실행 ($pm run dev)"
        echo "  ${CYAN}[10]${RESET} 🏗  build ($pm run build)"
        echo "  ${CYAN}[11]${RESET} ✅ test ($pm test 또는 run test)"
        echo "  ${CYAN}[12]${RESET} 🧹 lint ($pm run lint)"
        echo "  ${CYAN}[13]${RESET} 📥 install (의존성 설치)"
        echo ""
        echo "  ${YELLOW}[ 정리 & 도구 ]${RESET}"
        echo "  ${CYAN}[14]${RESET} 🗑  node_modules 삭제 + 재설치"
        echo "  ${CYAN}[15]${RESET} 🔄 패키지 매니저 변경 (npm/yarn/pnpm/bun)"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice

        case $subchoice in
            1)
                clear
                echo "${YELLOW}⚡ Vite 프로젝트 생성${RESET}"
                if [[ "$pm" == "bun" ]]; then
                    bun create vite
                elif [[ "$pm" == "pnpm" ]]; then
                    pnpm create vite
                elif [[ "$pm" == "yarn" ]]; then
                    yarn create vite
                else
                    npm create vite@latest
                fi
                _seongmin_pause
                ;;
            2) clear; npx create-next-app@latest; _seongmin_pause ;;
            3) clear; npm create astro@latest; _seongmin_pause ;;
            4) clear; npx nuxi@latest init; _seongmin_pause ;;
            5) clear; npm create svelte@latest; _seongmin_pause ;;
            6) clear; npx create-remix@latest; _seongmin_pause ;;
            7)
                clear
                echo "${RED}⚠️  Create React App은 React 공식이 더 이상 권장하지 않습니다.${RESET}"
                echo "${YELLOW}대안: Vite + React (메뉴 1번) 또는 Next.js (메뉴 2번)${RESET}"
                echo ""
                echo -n "그래도 진행할까요? (y/N): "
                read ans
                if [[ "$ans" =~ ^[Yy]$ ]]; then
                    echo -n "프로젝트 이름: "
                    read proj_name
                    [[ -n "$proj_name" ]] && npx create-react-app "$proj_name"
                fi
                _seongmin_pause
                ;;
            8)
                clear
                if [[ -f "package.json" ]]; then
                    echo "${GREEN}📜 package.json scripts:${RESET}"
                    if command -v jq &> /dev/null; then
                        jq -r '.scripts | to_entries[] | "  \(.key): \(.value)"' package.json
                    else
                        grep -A 50 '"scripts"' package.json | sed -n '/{/,/}/p' | head -30
                    fi
                else
                    echo "${RED}❌ 현재 디렉토리에 package.json이 없습니다.${RESET}"
                fi
                _seongmin_pause
                ;;
            9)  clear; echo "▶ $pm run dev"; $pm run dev ;;
            10) clear; echo "▶ $pm run build"; $pm run build; _seongmin_pause ;;
            11)
                clear
                if [[ "$pm" == "npm" || "$pm" == "yarn" ]]; then
                    $pm test
                else
                    $pm run test
                fi
                _seongmin_pause
                ;;
            12) clear; $pm run lint; _seongmin_pause ;;
            13) clear; $pm install; _seongmin_pause ;;
            14)
                clear
                echo "${RED}🗑  node_modules 삭제 + 재설치${RESET}"
                if [[ -d "node_modules" ]]; then
                    if _seongmin_confirm_dangerous "rm -rf node_modules"; then
                        rm -rf node_modules
                        echo "${YELLOW}🔄 재설치 중...${RESET}"
                        $pm install
                        echo "${GREEN}✅ 완료${RESET}"
                    fi
                else
                    echo "${YELLOW}node_modules가 없습니다.${RESET}"
                fi
                _seongmin_pause
                ;;
            15)
                clear
                echo "${YELLOW}패키지 매니저 선택:${RESET}"
                echo "  [1] npm   [2] yarn   [3] pnpm   [4] bun"
                echo -n "선택 > "
                read pm_choice
                case $pm_choice in
                    1) pm="npm" ;;
                    2) pm="yarn" ;;
                    3) pm="pnpm" ;;
                    4) pm="bun" ;;
                esac
                echo "${GREEN}✅ 현재 패키지 매니저: $pm${RESET}"
                _seongmin_pause
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
        echo "      ${YELLOW}→ java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins | grep -v '(' | awk '{ print \$1 }'${RESET}"
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

# Claude Code 서브메뉴
function _seongmin_claude() {
    local PINK='\033[1;35m' CYAN='\033[1;36m' YELLOW='\033[1;33m'
    local GREEN='\033[1;32m' RED='\033[1;31m' BLUE='\033[1;34m' RESET='\033[0m'
    
    while true; do
        clear
        echo "${PINK}🤖 [ Claude Code 명령어 ]${RESET}"
        echo ""
        echo "  ${GREEN}[1]${RESET} 🆙 Claude Code 업그레이드"
        echo "      ${YELLOW}→ brew upgrade claude-code${RESET}"
        echo "      설명: Homebrew를 통해 Claude Code를 최신 버전으로 업그레이드합니다."
        echo ""
        echo "  ${GREEN}[2]${RESET} 📋 현재 버전 확인"
        echo "      ${YELLOW}→ claude --version${RESET}"
        echo "      설명: 설치된 Claude Code의 현재 버전을 확인합니다."
        echo ""
        echo "  ${GREEN}[3]${RESET} 🔍 Homebrew 패키지 정보"
        echo "      ${YELLOW}→ brew info claude-code${RESET}"
        echo "      설명: Claude Code 패키지 정보와 설치 경로를 확인합니다."
        echo ""
        echo "  ${GREEN}[4]${RESET} 🩺 Claude 상태 확인"
        echo "      ${YELLOW}→ claude doctor${RESET}"
        echo "      설명: Claude Code 설치 상태 및 문제를 진단합니다."
        echo ""
        echo "  ${GREEN}[5]${RESET} 🚀 Claude Code 실행"
        echo "      ${YELLOW}→ claude${RESET}"
        echo "      설명: Claude Code를 실행합니다."
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  선택 > "
        read sub
        
        case $sub in
            1) 
                clear
                echo "${GREEN}🆙 Claude Code 업그레이드${RESET}"
                echo "실행 명령어: brew upgrade claude-code"
                echo ""
                brew upgrade claude-code
                echo ""
                echo "${GREEN}✅ 업그레이드 완료!${RESET}"
                echo ""
                read -k 1 
                ;;
            2) 
                clear
                echo "${GREEN}📋 Claude Code 버전 확인${RESET}"
                echo "실행 명령어: claude --version"
                echo ""
                claude --version
                echo ""
                read -k 1 
                ;;
            3) 
                clear
                echo "${GREEN}🔍 Homebrew 패키지 정보${RESET}"
                echo "실행 명령어: brew info claude-code"
                echo ""
                brew info claude-code
                echo ""
                read -k 1 
                ;;
            4) 
                clear
                echo "${GREEN}🩺 Claude 상태 확인${RESET}"
                echo "실행 명령어: claude doctor"
                echo ""
                claude doctor
                echo ""
                read -k 1 
                ;;
            5) 
                clear
                echo "${GREEN}🚀 Claude Code 실행${RESET}"
                echo "실행 명령어: claude"
                echo ""
                claude
                echo ""
                read -k 1 
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택입니다.${RESET}"; sleep 1 ;;
        esac
    done
}


# ═══════════════════════════════════════════════════════════════
# 🔐 SSH 키 관리 (메뉴 12 - 신규)
# ═══════════════════════════════════════════════════════════════
function _seongmin_ssh() {
    _seongmin_init_colors

    while true; do
        clear
        _seongmin_header "SSH 키 관리" "🔐"
        echo "  ${CYAN}[1]${RESET}  📋 내 SSH 키 목록 (~/.ssh)"
        echo "  ${CYAN}[2]${RESET}  🆕 새 SSH 키 생성 (ssh-keygen ed25519)"
        echo "  ${CYAN}[3]${RESET}  📤 공개키 클립보드 복사"
        echo "  ${CYAN}[4]${RESET}  🔌 ssh-agent에 키 추가 (ssh-add)"
        echo "  ${CYAN}[5]${RESET}  📜 ssh-agent에 등록된 키 보기 (ssh-add -l)"
        echo "  ${CYAN}[6]${RESET}  🚀 원격 서버에 공개키 복사 (ssh-copy-id)"
        echo "  ${CYAN}[7]${RESET}  ⚙️  ~/.ssh/config 편집"
        echo "  ${CYAN}[8]${RESET}  🧪 SSH 연결 테스트 (ssh -T git@github.com)"
        echo "  ${CYAN}[9]${RESET}  🔍 known_hosts 확인"
        echo "  ${CYAN}[0]${RESET}  ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read sub

        case $sub in
            1)
                clear
                echo "${GREEN}📋 ~/.ssh 파일 목록${RESET}"
                if [[ -d "$HOME/.ssh" ]]; then
                    ls -la "$HOME/.ssh"
                else
                    echo "${YELLOW}~/.ssh 디렉토리가 없습니다.${RESET}"
                fi
                _seongmin_pause
                ;;
            2)
                clear
                echo "${GREEN}🆕 새 SSH 키 생성 (ed25519 권장)${RESET}"
                echo -n "이메일 주소 입력: "
                read email
                [[ -z "$email" ]] && { echo "취소됨"; sleep 1; continue; }
                echo -n "키 파일 이름 (기본: id_ed25519): "
                read keyname
                [[ -z "$keyname" ]] && keyname="id_ed25519"
                ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/$keyname"
                echo ""
                echo "${GREEN}✅ ~/.ssh/$keyname 생성됨${RESET}"
                echo "${CYAN}공개키: ~/.ssh/${keyname}.pub${RESET}"
                _seongmin_pause
                ;;
            3)
                clear
                echo "${GREEN}📤 공개키 클립보드 복사${RESET}"
                local pubs=("$HOME"/.ssh/*.pub)
                if [[ ! -e "${pubs[1]}" ]]; then
                    echo "${RED}공개키 파일이 없습니다.${RESET}"
                    _seongmin_pause; continue
                fi
                local idx=1
                for p in "${pubs[@]}"; do
                    echo "  [$idx] $(basename "$p")"
                    ((idx++))
                done
                echo -n "선택: "
                read pick
                local target="${pubs[$pick]}"
                if [[ -f "$target" ]]; then
                    if _seongmin_is_macos; then
                        pbcopy < "$target"
                        echo "${GREEN}✅ 클립보드에 복사됨 ($(basename $target))${RESET}"
                    elif command -v xclip &> /dev/null; then
                        xclip -sel clip < "$target"
                        echo "${GREEN}✅ 클립보드에 복사됨${RESET}"
                    else
                        echo "${YELLOW}클립보드 도구 없음. 내용:${RESET}"
                        cat "$target"
                    fi
                fi
                _seongmin_pause
                ;;
            4)
                clear
                echo "${GREEN}🔌 ssh-add${RESET}"
                ls "$HOME"/.ssh/id_* 2>/dev/null | grep -v ".pub"
                echo -n "추가할 키 경로 (기본: ~/.ssh/id_ed25519): "
                read kpath
                [[ -z "$kpath" ]] && kpath="$HOME/.ssh/id_ed25519"
                if _seongmin_is_macos; then
                    ssh-add --apple-use-keychain "$kpath"
                else
                    ssh-add "$kpath"
                fi
                _seongmin_pause
                ;;
            5) clear; echo "${GREEN}📜 ssh-agent 등록된 키${RESET}"; ssh-add -l; _seongmin_pause ;;
            6)
                clear
                echo "${GREEN}🚀 ssh-copy-id (원격에 공개키 복사)${RESET}"
                echo -n "원격 (예: user@host): "
                read remote
                [[ -z "$remote" ]] && { echo "취소됨"; sleep 1; continue; }
                ssh-copy-id "$remote"
                _seongmin_pause
                ;;
            7)
                clear
                [[ ! -f "$HOME/.ssh/config" ]] && touch "$HOME/.ssh/config"
                ${EDITOR:-vi} "$HOME/.ssh/config"
                ;;
            8)
                clear
                echo "${GREEN}🧪 SSH 연결 테스트${RESET}"
                echo -n "테스트 대상 (기본: git@github.com): "
                read host
                [[ -z "$host" ]] && host="git@github.com"
                ssh -T "$host"
                _seongmin_pause
                ;;
            9)
                clear
                echo "${GREEN}🔍 known_hosts${RESET}"
                if [[ -f "$HOME/.ssh/known_hosts" ]]; then
                    wc -l "$HOME/.ssh/known_hosts"
                    echo ""
                    head -20 "$HOME/.ssh/known_hosts"
                fi
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 🌐 Network 진단 (메뉴 13 - 신규)
# ═══════════════════════════════════════════════════════════════
function _seongmin_network() {
    _seongmin_init_colors

    while true; do
        clear
        _seongmin_header "Network 진단" "🌐"
        echo "  ${CYAN}[1]${RESET}  🏓 ping (응답 속도 측정)"
        echo "  ${CYAN}[2]${RESET}  🔍 dig (DNS 조회)"
        echo "  ${CYAN}[3]${RESET}  🌐 curl로 응답 확인"
        echo "  ${CYAN}[4]${RESET}  🔌 포트 점유 확인 (lsof -i :PORT)"
        echo "  ${CYAN}[5]${RESET}  🚪 열린 포트 전체 목록"
        echo "  ${CYAN}[6]${RESET}  📡 내 공인 IP 확인"
        echo "  ${CYAN}[7]${RESET}  🏠 내 로컬 IP 확인"
        echo "  ${CYAN}[8]${RESET}  🛣  traceroute (경로 추적)"
        echo "  ${CYAN}[9]${RESET}  📊 네트워크 인터페이스"
        echo "  ${CYAN}[10]${RESET} 🚦 SSL 인증서 만료일 확인"
        echo "  ${CYAN}[0]${RESET}  ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read sub

        case $sub in
            1)
                clear
                echo -n "ping 대상 (기본: google.com): "
                read host
                [[ -z "$host" ]] && host="google.com"
                ping -c 4 "$host"
                _seongmin_pause
                ;;
            2)
                clear
                echo -n "도메인: "
                read d
                [[ -z "$d" ]] && continue
                if command -v dig &> /dev/null; then
                    dig +short "$d"
                    echo "---"
                    dig "$d" | head -30
                else
                    nslookup "$d"
                fi
                _seongmin_pause
                ;;
            3)
                clear
                echo -n "URL: "
                read url
                [[ -z "$url" ]] && continue
                echo "${CYAN}── 헤더 ──${RESET}"
                curl -sI "$url"
                echo ""
                echo "${CYAN}── 응답 시간 ──${RESET}"
                curl -s -o /dev/null -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTotal: %{time_total}s\nStatus: %{http_code}\n" "$url"
                _seongmin_pause
                ;;
            4)
                clear
                echo -n "포트 번호: "
                read port
                [[ -z "$port" ]] && continue
                if lsof -i ":$port" 2>/dev/null; then
                    echo ""
                    echo "${YELLOW}💡 프로세스 종료: kill -9 <PID>${RESET}"
                else
                    echo "${GREEN}✅ 포트 $port 는 비어있습니다.${RESET}"
                fi
                _seongmin_pause
                ;;
            5)
                clear
                if _seongmin_is_macos; then
                    netstat -an -p tcp | grep LISTEN | head -30
                else
                    ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null
                fi
                _seongmin_pause
                ;;
            6)
                clear
                echo -n "${GREEN}공인 IP: ${RESET}"
                curl -s https://ifconfig.me
                echo ""
                _seongmin_pause
                ;;
            7)
                clear
                if _seongmin_is_macos; then
                    ipconfig getifaddr en0 2>/dev/null
                    ipconfig getifaddr en1 2>/dev/null
                else
                    hostname -I 2>/dev/null || ip addr show | grep "inet " | grep -v 127.0.0.1
                fi
                _seongmin_pause
                ;;
            8)
                clear
                echo -n "대상: "
                read t
                [[ -z "$t" ]] && continue
                traceroute "$t"
                _seongmin_pause
                ;;
            9)
                clear
                if _seongmin_is_macos; then
                    ifconfig | head -50
                else
                    ip addr 2>/dev/null || ifconfig
                fi
                _seongmin_pause
                ;;
            10)
                clear
                echo -n "도메인 (기본: google.com): "
                read d
                [[ -z "$d" ]] && d="google.com"
                echo | openssl s_client -servername "$d" -connect "$d":443 2>/dev/null | \
                    openssl x509 -noout -dates -subject
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 🆕 새 프로젝트 시작 (메뉴 14 - 신규)
# ═══════════════════════════════════════════════════════════════
function _seongmin_newproject() {
    _seongmin_init_colors

    clear
    _seongmin_header "새 프로젝트 시작" "🆕"
    echo "  ${YELLOW}프로젝트 종류를 선택해주세요:${RESET}"
    echo "  ${CYAN}[1]${RESET} 🐍 Python"
    echo "  ${CYAN}[2]${RESET} 🎨 Frontend (Vite/Next/Astro 등 → Frontend 메뉴)"
    echo "  ${CYAN}[3]${RESET} 📦 일반 (디렉토리 + git + README + .gitignore만)"
    echo "  ${CYAN}[0]${RESET} ⬅️  취소"
    echo ""
    echo -n "  선택 > "
    read kind

    case $kind in
        1) _seongmin_newproject_python ;;
        2) _seongmin_frontend ;;
        3) _seongmin_newproject_generic ;;
        *) return ;;
    esac
}

_seongmin_newproject_python() {
    _seongmin_init_colors
    clear
    _seongmin_header "새 Python 프로젝트" "🐍"
    echo -n "프로젝트 이름: "
    read pname
    [[ -z "$pname" ]] && return

    mkdir -p "$pname" || return
    cd "$pname" || return

    # uv 우선, 없으면 venv
    if command -v uv &> /dev/null; then
        echo "${GREEN}✨ uv 발견 — 빠르게 셋업합니다.${RESET}"
        uv init
    else
        python3 -m venv venv
        echo "venv 생성 완료. (활성화: source venv/bin/activate)"
    fi

    # README
    cat > README.md << EOF
# $pname

## 설치
\`\`\`bash
source venv/bin/activate
pip install -r requirements.txt
\`\`\`
EOF

    # .gitignore (Python 표준)
    cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
venv/
.venv/
env/
.env
*.egg-info/
dist/
build/
.pytest_cache/
.mypy_cache/
.ruff_cache/
.coverage
.DS_Store
.idea/
.vscode/
EOF

    # git init
    if command -v git &> /dev/null; then
        git init -q
        git add -A
        echo "${GREEN}✅ git 초기화 완료${RESET}"
    fi

    echo ""
    echo "${GREEN}✅ 프로젝트 생성 완료: $(pwd)${RESET}"
    echo "${CYAN}다음 단계:${RESET}"
    echo "  cd $pname"
    if command -v uv &> /dev/null; then
        echo "  uv add <패키지>"
    else
        echo "  source venv/bin/activate"
        echo "  pip install <패키지>"
    fi
    _seongmin_pause
}

_seongmin_newproject_generic() {
    _seongmin_init_colors
    clear
    echo -n "프로젝트 이름: "
    read pname
    [[ -z "$pname" ]] && return

    mkdir -p "$pname" || return
    cd "$pname" || return

    cat > README.md << EOF
# $pname

TODO: 프로젝트 설명을 적어주세요.
EOF

    cat > .gitignore << 'EOF'
.DS_Store
.env
.idea/
.vscode/
node_modules/
*.log
EOF

    git init -q 2>/dev/null

    echo "${GREEN}✅ 생성 완료: $(pwd)${RESET}"
    _seongmin_pause
}

# ═══════════════════════════════════════════════════════════════
# 🆘 응급 처치 (메뉴 15 - 신규)
# ═══════════════════════════════════════════════════════════════
function _seongmin_emergency() {
    _seongmin_init_colors

    while true; do
        clear
        _seongmin_header "응급 처치" "🆘"
        echo "  ${YELLOW}자주 마주치는 문제 상황별 가이드:${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} 🔌 포트가 이미 사용 중 (Address already in use)"
        echo "  ${CYAN}[2]${RESET} 🐳 Docker daemon이 응답하지 않음"
        echo "  ${CYAN}[3]${RESET} 💾 디스크 공간 부족"
        echo "  ${CYAN}[4]${RESET} 🐢 시스템이 너무 느림 (CPU/RAM 확인)"
        echo "  ${CYAN}[5]${RESET} 🔥 좀비 프로세스 정리"
        echo "  ${CYAN}[6]${RESET} 🌐 인터넷 연결 진단"
        echo "  ${CYAN}[7]${RESET} 🐙 git 망함 — 마지막 안전한 상태로"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  선택 > "
        read sub

        case $sub in
            1)
                clear
                echo "${YELLOW}🔌 포트 점유 해결${RESET}"
                echo -n "포트 번호 (예: 3000, 8080): "
                read port
                [[ -z "$port" ]] && continue
                local pids=$(lsof -ti :"$port" 2>/dev/null)
                if [[ -z "$pids" ]]; then
                    echo "${GREEN}✅ 포트 $port 는 비어있습니다.${RESET}"
                else
                    echo "${RED}점유 중인 PID: $pids${RESET}"
                    lsof -i :"$port"
                    echo ""
                    echo -n "강제 종료할까요? (y/N): "
                    read ans
                    if [[ "$ans" =~ ^[Yy]$ ]]; then
                        echo "$pids" | xargs kill -9
                        echo "${GREEN}✅ 종료됨${RESET}"
                    fi
                fi
                _seongmin_pause
                ;;
            2)
                clear
                echo "${YELLOW}🐳 Docker 응급 처치${RESET}"
                if docker info &> /dev/null; then
                    echo "${GREEN}✅ Docker daemon 정상 작동 중${RESET}"
                else
                    echo "${RED}❌ Docker daemon 응답 없음${RESET}"
                    echo ""
                    if _seongmin_is_macos; then
                        echo "${CYAN}해결책:${RESET}"
                        echo "  1. Docker Desktop 앱 실행 확인"
                        echo "  2. 메뉴바 고래 아이콘이 안정 상태인지"
                        echo "  3. 재시작: open -a Docker"
                        echo ""
                        echo -n "Docker Desktop 실행할까요? (y/N): "
                        read ans
                        [[ "$ans" =~ ^[Yy]$ ]] && open -a Docker
                    else
                        echo "${CYAN}해결책:${RESET}"
                        echo "  sudo systemctl status docker"
                        echo "  sudo systemctl start docker"
                    fi
                fi
                _seongmin_pause
                ;;
            3)
                clear
                echo "${YELLOW}💾 디스크 공간${RESET}"
                df -h | head -5
                echo ""
                echo "${CYAN}현재 디렉토리 큰 폴더 Top 10:${RESET}"
                du -sh */ 2>/dev/null | sort -hr | head -10
                echo ""
                echo "${YELLOW}💡 흔한 청소 후보:${RESET}"
                echo "  • node_modules (Frontend 메뉴 → 14)"
                echo "  • Docker 캐시: docker system prune -a"
                echo "  • Homebrew: brew cleanup"
                echo "  • npm 캐시: npm cache clean --force"
                _seongmin_pause
                ;;
            4)
                clear
                echo "${YELLOW}🐢 시스템 부하 확인${RESET}"
                if command -v htop &> /dev/null; then
                    htop
                elif command -v top &> /dev/null; then
                    top
                fi
                ;;
            5)
                clear
                echo "${YELLOW}🔥 좀비 프로세스${RESET}"
                if _seongmin_is_macos; then
                    ps aux | awk '$8=="Z"'
                else
                    ps aux | awk '$8=="Z"'
                fi
                _seongmin_pause
                ;;
            6)
                clear
                echo "${YELLOW}🌐 인터넷 연결 진단${RESET}"
                echo -n "DNS (8.8.8.8): "
                if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
                    echo "${GREEN}✅${RESET}"
                else
                    echo "${RED}❌${RESET}"
                fi
                echo -n "DNS 해석 (google.com): "
                if ping -c 1 -W 2 google.com &> /dev/null; then
                    echo "${GREEN}✅${RESET}"
                else
                    echo "${RED}❌ DNS 문제 가능성${RESET}"
                fi
                _seongmin_pause
                ;;
            7)
                clear
                echo "${YELLOW}🐙 git 응급${RESET}"
                if [[ ! -d .git ]]; then
                    echo "${RED}현재 디렉토리는 git 저장소가 아닙니다.${RESET}"
                    _seongmin_pause; continue
                fi
                echo "${CYAN}현재 상태:${RESET}"
                git status -s
                echo ""
                echo "${CYAN}복구 옵션:${RESET}"
                echo "  [1] 모든 변경 사항 stash로 안전하게 보관"
                echo "  [2] 마지막 커밋으로 되돌리기 (변경사항 버림 — 위험!)"
                echo "  [3] reflog로 직전 상태 보기"
                echo "  [0] 취소"
                echo -n "선택: "
                read e
                case $e in
                    1) git stash push -m "emergency $(date +%Y%m%d_%H%M%S)" ;;
                    2)
                        if _seongmin_confirm_dangerous "git reset --hard HEAD"; then
                            git reset --hard HEAD
                        fi
                        ;;
                    3) git reflog | head -20 ;;
                esac
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 🧪 유틸 도구 (메뉴 16 - 신규)
# ═══════════════════════════════════════════════════════════════
function _seongmin_utils() {
    _seongmin_init_colors

    while true; do
        clear
        _seongmin_header "유틸 도구" "🧪"
        echo "  ${CYAN}[1]${RESET} 🔢 UUID 생성"
        echo "  ${CYAN}[2]${RESET} 🔐 비밀번호 생성 (랜덤)"
        echo "  ${CYAN}[3]${RESET} 📦 Base64 인코딩/디코딩"
        echo "  ${CYAN}[4]${RESET} 🌐 URL 인코딩/디코딩"
        echo "  ${CYAN}[5]${RESET} 📋 JSON 포매팅 (jq)"
        echo "  ${CYAN}[6]${RESET} 🕒 현재 타임스탬프"
        echo "  ${CYAN}[7]${RESET} 🔢 타임스탬프 ↔ 날짜 변환"
        echo "  ${CYAN}[8]${RESET} #️⃣  해시 생성 (md5/sha1/sha256)"
        echo "  ${CYAN}[9]${RESET} 🔡 대소문자/케이스 변환"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  선택 > "
        read sub

        case $sub in
            1)
                clear
                if command -v uuidgen &> /dev/null; then
                    local u=$(uuidgen)
                    echo "${GREEN}🔢 UUID:${RESET} $u"
                    if _seongmin_is_macos; then echo "$u" | pbcopy; echo "(클립보드 복사됨)"; fi
                fi
                _seongmin_pause
                ;;
            2)
                clear
                echo -n "길이 (기본: 16): "
                read len
                [[ -z "$len" ]] && len=16
                local pwd=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$len")
                echo "${GREEN}🔐 비밀번호:${RESET} $pwd"
                if _seongmin_is_macos; then echo "$pwd" | pbcopy; echo "(클립보드 복사됨)"; fi
                _seongmin_pause
                ;;
            3)
                clear
                echo "  [1] 인코딩  [2] 디코딩"
                echo -n "선택: "; read mode
                echo -n "문자열: "; read input
                if [[ "$mode" == "1" ]]; then
                    echo "${GREEN}결과:${RESET} $(echo -n "$input" | base64)"
                else
                    echo "${GREEN}결과:${RESET} $(echo -n "$input" | base64 -d)"
                fi
                _seongmin_pause
                ;;
            4)
                clear
                echo "  [1] 인코딩  [2] 디코딩"
                echo -n "선택: "; read mode
                echo -n "문자열: "; read input
                if command -v python3 &> /dev/null; then
                    if [[ "$mode" == "1" ]]; then
                        python3 -c "import urllib.parse; print(urllib.parse.quote('$input'))"
                    else
                        python3 -c "import urllib.parse; print(urllib.parse.unquote('$input'))"
                    fi
                fi
                _seongmin_pause
                ;;
            5)
                clear
                if ! command -v jq &> /dev/null; then
                    echo "${RED}jq가 필요합니다. brew install jq${RESET}"
                    _seongmin_pause; continue
                fi
                echo "JSON 입력 후 Ctrl+D:"
                local input=$(cat)
                echo "$input" | jq .
                _seongmin_pause
                ;;
            6)
                clear
                local epoch=$(date +%s)
                echo "${GREEN}Epoch:${RESET} $epoch"
                echo "${GREEN}ISO:${RESET}   $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                echo "${GREEN}로컬:${RESET}  $(date)"
                _seongmin_pause
                ;;
            7)
                clear
                echo "  [1] timestamp → 날짜  [2] 날짜 → timestamp"
                echo -n "선택: "; read mode
                if [[ "$mode" == "1" ]]; then
                    echo -n "epoch: "; read e
                    if _seongmin_is_macos; then
                        date -r "$e"
                    else
                        date -d @"$e"
                    fi
                else
                    echo -n "날짜 (예: 2026-05-05 12:00:00): "; read d
                    if _seongmin_is_macos; then
                        date -j -f "%Y-%m-%d %H:%M:%S" "$d" +%s
                    else
                        date -d "$d" +%s
                    fi
                fi
                _seongmin_pause
                ;;
            8)
                clear
                echo -n "문자열: "; read input
                echo "${GREEN}MD5:   ${RESET} $(echo -n "$input" | md5 2>/dev/null || echo -n "$input" | md5sum | awk '{print $1}')"
                echo "${GREEN}SHA1:  ${RESET} $(echo -n "$input" | shasum -a 1 | awk '{print $1}')"
                echo "${GREEN}SHA256:${RESET} $(echo -n "$input" | shasum -a 256 | awk '{print $1}')"
                _seongmin_pause
                ;;
            9)
                clear
                echo -n "문자열: "; read input
                echo "${GREEN}대문자:${RESET} $(echo "$input" | tr '[:lower:]' '[:upper:]')"
                echo "${GREEN}소문자:${RESET} $(echo "$input" | tr '[:upper:]' '[:lower:]')"
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 선택${RESET}"; sleep 1 ;;
        esac
    done
}


# 단축 명령어 alias
# dxk = DX Kit (1순위)
# gg  = 레거시 호환 (계속 유지)
alias dxk="seongmin"
alias gg="seongmin"
