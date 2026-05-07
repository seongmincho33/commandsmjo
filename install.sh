#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🚀 DX Kit Installer                                    ║
# ║                  Developer Experience Kit (by Seongmin)                   ║
# ║                          macOS / Linux 전용                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 변수 설정 (기본은 zsh — main()에서 --bash 인자로 덮어씀)
INSTALL_DIR="$HOME/.zsh_menu"
MENU_FILE="menu.zsh"
TARGET_SHELL="zsh"
MARKER_COMMENT="Seongmin's ZSH Menu"

# 스크립트 디렉토리 감지 (bash와 zsh 모두 지원)
if [ -n "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$0" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi

# 함수: 배너 출력
print_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}         🎉 ${GREEN}DX Kit Installer${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       Developer Experience Kit (명령어: ${YELLOW}dxk${NC})              ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 함수: 성공 메시지
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 정보 메시지
info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# 함수: 경고 메시지
warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 함수: 에러 메시지
error() {
    echo -e "${RED}❌ $1${NC}"
}

# OS 확인
check_os() {
    IS_BASH_USER=0
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        # 현재 셸이 bash인지 확인 (안내용)
        if [ -z "$ZSH_VERSION" ]; then
            IS_BASH_USER=1
        fi
    else
        error "지원하지 않는 운영체제입니다: $OSTYPE"
        echo "Windows 사용자는 install_windows.ps1을 사용해주세요."
        exit 1
    fi

    # 타겟 셸에 맞는 rc 파일 선택
    if [ "$TARGET_SHELL" = "bash" ]; then
        if [[ "$OS" == "macOS" ]]; then
            # macOS는 보통 .bash_profile이 로그인 셸 진입점
            if [ -f "$HOME/.bashrc" ]; then
                SHELL_RC="$HOME/.bashrc"
            else
                SHELL_RC="$HOME/.bash_profile"
            fi
        else
            SHELL_RC="$HOME/.bashrc"
        fi
    else
        SHELL_RC="$HOME/.zshrc"
    fi

    info "운영체제: $OS"
    info "타겟 셸: $TARGET_SHELL"
    info "설정 파일: $SHELL_RC"
}

# 셸 설치 확인 (없으면 친절한 안내 후 종료)
check_shell() {
    if [ "$TARGET_SHELL" = "bash" ]; then
        if command -v bash >/dev/null 2>&1; then
            info "bash 발견: $(command -v bash)"
            return 0
        fi
        error "bash가 설치되어 있지 않습니다. (정말?)"
        exit 1
    fi

    if command -v zsh >/dev/null 2>&1; then
        info "zsh 발견: $(command -v zsh)"
        return 0
    fi

    echo ""
    error "이 메뉴는 zsh 기반입니다. zsh가 설치되어 있지 않습니다."
    echo ""
    echo -e "${CYAN}📦 설치 방법:${NC}"

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "$ID" in
            rocky|rhel|centos|fedora|almalinux|ol)
                echo -e "   ${YELLOW}sudo dnf install -y zsh${NC}"
                ;;
            ubuntu|debian|linuxmint|pop)
                echo -e "   ${YELLOW}sudo apt install -y zsh${NC}"
                ;;
            arch|manjaro|endeavouros)
                echo -e "   ${YELLOW}sudo pacman -S zsh${NC}"
                ;;
            opensuse*|sles)
                echo -e "   ${YELLOW}sudo zypper install -y zsh${NC}"
                ;;
            alpine)
                echo -e "   ${YELLOW}sudo apk add zsh${NC}"
                ;;
            *)
                echo -e "   배포판($ID)에 맞는 패키지 매니저로 zsh를 설치해주세요."
                ;;
        esac
    else
        echo -e "   배포판에 맞는 패키지 매니저로 zsh를 설치해주세요."
    fi

    echo ""
    echo -e "${CYAN}ℹ️  걱정 마세요:${NC}"
    echo -e "   • 로그인 셸을 바꾸지 않아도 됩니다 (bash 그대로 사용 가능)"
    echo -e "   • 메뉴를 쓰고 싶을 때만 ${YELLOW}zsh${NC} 를 입력해 진입하면 됩니다"
    echo -e "   • 디스크 사용량은 약 5MB 정도입니다"
    echo ""
    echo -e "설치 후 다시 ${YELLOW}./install.sh${NC} 를 실행해주세요."
    echo ""
    echo -e "${CYAN}또는 bash 버전으로 설치하려면:${NC}"
    echo -e "   ${YELLOW}./install.sh --bash${NC}"
    echo ""
    exit 1
}

# 설치 디렉토리 생성
create_install_dir() {
    info "설치 디렉토리 생성 중..."
    if [ -d "$INSTALL_DIR" ]; then
        warn "기존 설치가 발견되었습니다. 업데이트합니다."
        rm -rf "$INSTALL_DIR"
    fi
    mkdir -p "$INSTALL_DIR"
    success "디렉토리 생성 완료: $INSTALL_DIR"
}

# 파일 복사
copy_files() {
    info "메뉴 파일 복사 중..."
    info "소스 디렉토리: $SCRIPT_DIR"

    # 현재 스크립트 위치에서 메뉴 파일 찾기
    if [ -f "$SCRIPT_DIR/$MENU_FILE" ]; then
        cp "$SCRIPT_DIR/$MENU_FILE" "$INSTALL_DIR/"
        success "$MENU_FILE 복사 완료: $SCRIPT_DIR/$MENU_FILE -> $INSTALL_DIR/"
    else
        error "$MENU_FILE 파일을 찾을 수 없습니다: $SCRIPT_DIR/$MENU_FILE"
        echo "install.sh와 같은 디렉토리에 $MENU_FILE가 있어야 합니다."
        exit 1
    fi

    # dxk update 가 소스 git 저장소를 찾을 수 있도록 경로 기록
    echo "$SCRIPT_DIR" > "$INSTALL_DIR/.source_path"
    if [ -d "$SCRIPT_DIR/.git" ]; then
        success "소스 git 저장소 감지됨 — 'dxk update'로 자동 업데이트 가능"
    else
        warn "소스가 git 저장소가 아닙니다 — 'dxk update'는 작동하지 않습니다"
        warn "  (git clone으로 받으셨다면 .git 폴더가 있어야 합니다)"
    fi
}

# 쉘 설정 파일에 source 추가
configure_shell() {
    info "쉘 설정 파일 업데이트 중..."

    local source_line="# $MARKER_COMMENT"
    local source_cmd="source \"$INSTALL_DIR/$MENU_FILE\""
    # 설치 디렉토리 이름(.zsh_menu / .bash_menu)을 제거 매칭에 활용
    local install_basename
    install_basename="$(basename "$INSTALL_DIR")"

    # rc 파일이 없으면 새로 생성
    if [ ! -f "$SHELL_RC" ]; then
        touch "$SHELL_RC"
        success "$SHELL_RC 파일을 새로 생성했습니다"
    fi

    # 이미 추가되어 있는지 확인 (zsh / bash 양쪽 마커 모두 검사)
    if grep -qE "Seongmin's (ZSH|BASH) Menu" "$SHELL_RC" 2>/dev/null; then
        warn "이미 설정되어 있습니다. 기존 설정을 업데이트합니다."
        # 기존 설정 제거 (zsh / bash 마커 모두)
        if [[ "$OS" == "macOS" ]]; then
            sed -i '' "/# Seongmin.*ZSH Menu/,/source.*\\.zsh_menu/d" "$SHELL_RC"
            sed -i '' "/# Seongmin.*BASH Menu/,/source.*\\.bash_menu/d" "$SHELL_RC"
        else
            sed -i "/# Seongmin.*ZSH Menu/,/source.*\\.zsh_menu/d" "$SHELL_RC"
            sed -i "/# Seongmin.*BASH Menu/,/source.*\\.bash_menu/d" "$SHELL_RC"
        fi
    fi
    
    # 백업 생성
    cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%Y%m%d_%H%M%S)"
    success "설정 파일 백업 완료"
    
    # 새 설정 추가
    echo "" >> "$SHELL_RC"
    echo "$source_line" >> "$SHELL_RC"
    echo "$source_cmd" >> "$SHELL_RC"
    
    success "쉘 설정 완료"
}

# 설치 완료 메시지
print_complete() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}            🎉 ${GREEN}설치가 완료되었습니다!${NC}                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📌 사용 방법:${NC}"
    echo ""
    echo -e "   1. 새 터미널을 열거나 다음 명령어 실행:"
    echo -e "      ${YELLOW}source $SHELL_RC${NC}"
    echo ""
    echo -e "   2. 메뉴 실행:"
    echo -e "      ${YELLOW}dxk${NC}  (또는 기존 ${YELLOW}gg${NC})"
    echo ""
    echo -e "${CYAN}📚 포함된 기능:${NC}"
    echo -e "   • 🐙 Git 명령어 (+ 초보자 가이드)"
    echo -e "   • 🐍 Python 가상환경 관리"
    echo -e "   • 🐳 Docker 컨테이너/이미지 관리"
    echo -e "   • 🍺 Homebrew 패키지 관리"
    echo -e "   • ☕ Java 버전 관리"
    echo -e "   • 그 외 다양한 개발 도구들"
    echo ""
    echo -e "${GREEN}즐거운 개발 되세요! 🚀${NC}"
    echo ""
}

# 삭제 함수
uninstall() {
    echo ""
    info "Seongmin's ZSH Menu 삭제 중..."
    
    # 디렉토리 삭제
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        success "설치 디렉토리 삭제 완료"
    fi
    
    # bash 설치본도 함께 제거
    if [ -d "$HOME/.bash_menu" ]; then
        rm -rf "$HOME/.bash_menu"
        success "bash 설치 디렉토리 제거 완료"
    fi

    # 쉘 설정에서 제거 (.zshrc, .bashrc, .bash_profile 모두 정리)
    local rc
    for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
        if [ -f "$rc" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/# Seongmin.*ZSH Menu/,/source.*\.zsh_menu/d' "$rc"
                sed -i '' '/# Seongmin.*BASH Menu/,/source.*\.bash_menu/d' "$rc"
            else
                sed -i '/# Seongmin.*ZSH Menu/,/source.*\.zsh_menu/d' "$rc"
                sed -i '/# Seongmin.*BASH Menu/,/source.*\.bash_menu/d' "$rc"
            fi
        fi
    done
    success "쉘 설정 제거 완료 (.zshrc / .bashrc / .bash_profile)"
    
    echo ""
    success "삭제가 완료되었습니다."
    echo "터미널을 다시 시작하거나 source $SHELL_RC를 실행하세요."
    echo ""
}

# 사용자의 로그인 셸을 자동 감지해 TARGET_SHELL을 설정
# 우선순위: $SHELL → zsh 존재 여부 → bash fallback
auto_detect_shell() {
    local detected=""
    case "$SHELL" in
        */zsh)  detected="zsh"  ;;
        */bash) detected="bash" ;;
        *)
            # $SHELL이 비어 있거나 다른 셸인 경우 — zsh가 깔려 있으면 zsh, 아니면 bash
            if command -v zsh >/dev/null 2>&1; then
                detected="zsh"
            else
                detected="bash"
            fi
            ;;
    esac

    if [ "$detected" = "bash" ]; then
        TARGET_SHELL="bash"
        INSTALL_DIR="$HOME/.bash_menu"
        MENU_FILE="menu.bash"
        MARKER_COMMENT="Seongmin's BASH Menu"
    else
        TARGET_SHELL="zsh"
        INSTALL_DIR="$HOME/.zsh_menu"
        MENU_FILE="menu.zsh"
        MARKER_COMMENT="Seongmin's ZSH Menu"
    fi

    info "현재 셸 감지: $SHELL → 타겟: $TARGET_SHELL (--bash / --zsh 로 강제 가능)"
}

# 메인 로직
main() {
    # 인자 파싱 (--bash / --zsh / --uninstall)
    # 명시적 인자가 있으면 자동 감지를 덮어씀
    local do_uninstall=0
    local explicit_shell=0
    for arg in "$@"; do
        case "$arg" in
            --bash)
                explicit_shell=1
                TARGET_SHELL="bash"
                INSTALL_DIR="$HOME/.bash_menu"
                MENU_FILE="menu.bash"
                MARKER_COMMENT="Seongmin's BASH Menu"
                ;;
            --zsh)
                explicit_shell=1
                TARGET_SHELL="zsh"
                INSTALL_DIR="$HOME/.zsh_menu"
                MENU_FILE="menu.zsh"
                MARKER_COMMENT="Seongmin's ZSH Menu"
                ;;
            --uninstall|-u)
                do_uninstall=1
                ;;
        esac
    done

    # 명시 인자가 없으면 자동 감지
    if [ "$explicit_shell" = "0" ]; then
        auto_detect_shell
    fi

    print_banner

    # 삭제 옵션 확인
    if [ "$do_uninstall" = "1" ]; then
        check_os
        uninstall
        exit 0
    fi

    # 설치 진행
    echo -e "${YELLOW}설치를 진행하시겠습니까? (y/n) [타겟: $TARGET_SHELL]${NC}"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "설치가 취소되었습니다."
        exit 0
    fi

    echo ""
    check_os
    check_shell
    create_install_dir
    copy_files
    configure_shell
    print_complete

    # bash 사용자에게 추가 안내
    if [ "$IS_BASH_USER" = "1" ]; then
        echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║${NC}  💡 bash 사용자 안내                                       ${YELLOW}║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo -e "   • 로그인 셸은 ${GREEN}bash 그대로${NC} 유지됩니다"
        echo -e "   • 메뉴를 쓰고 싶을 때 터미널에서 ${YELLOW}zsh${NC} 입력 → ${YELLOW}gg${NC} 실행"
        echo -e "   • 빠져나오려면 ${YELLOW}exit${NC} 입력 (다시 bash로 돌아옴)"
        echo ""
    fi
    
    # 설치 완료 안내
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}        🎊 ${CYAN}설치가 모두 완료되었습니다!${NC}                      ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "   ${GREEN}dxk${NC} 명령어로 메뉴를 실행할 수 있습니다! (별칭: ${GREEN}gg${NC})"
    echo -e "   ${CYAN}dxk help${NC} 로 직접 실행 모드 도움말을 볼 수 있습니다."
    echo ""

    # 변경사항 적용을 위해 타겟 셸 재시작
    echo -e "${YELLOW}쉘을 재시작하여 변경사항을 적용합니다... ($TARGET_SHELL)${NC}"
    sleep 1
    if [ "$TARGET_SHELL" = "bash" ]; then
        if command -v bash >/dev/null 2>&1; then
            exec bash
        else
            warn "bash 실행 실패. 새 터미널을 열거나 'bash' 를 직접 실행해주세요."
        fi
    else
        if command -v zsh >/dev/null 2>&1; then
            exec zsh
        else
            warn "zsh 실행 실패. 새 터미널을 열거나 'zsh' 를 직접 실행해주세요."
        fi
    fi
}

# 스크립트 실행
main "$@"
