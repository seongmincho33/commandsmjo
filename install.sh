#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🚀 Seongmin's ZSH Menu Installer                       ║
# ║                          macOS / Linux 전용                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 변수 설정
INSTALL_DIR="$HOME/.zsh_menu"
MENU_FILE="menu.zsh"

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
    echo -e "${CYAN}║${NC}      🎉 ${GREEN}Seongmin's ZSH Menu Installer${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}         Git, Python, Docker, Homebrew 명령어 메뉴        ${CYAN}║${NC}"
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
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        SHELL_RC="$HOME/.zshrc"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        if [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        else
            SHELL_RC="$HOME/.bashrc"
        fi
    else
        error "지원하지 않는 운영체제입니다: $OSTYPE"
        echo "Windows 사용자는 install_windows.ps1을 사용해주세요."
        exit 1
    fi
    info "운영체제: $OS"
    info "설정 파일: $SHELL_RC"
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
    
    # 현재 스크립트 위치에서 menu.zsh 찾기
    if [ -f "$SCRIPT_DIR/$MENU_FILE" ]; then
        cp "$SCRIPT_DIR/$MENU_FILE" "$INSTALL_DIR/"
        success "menu.zsh 복사 완료: $SCRIPT_DIR/$MENU_FILE -> $INSTALL_DIR/"
    else
        error "menu.zsh 파일을 찾을 수 없습니다: $SCRIPT_DIR/$MENU_FILE"
        echo "install.sh와 같은 디렉토리에 menu.zsh가 있어야 합니다."
        exit 1
    fi
}

# 쉘 설정 파일에 source 추가
configure_shell() {
    info "쉘 설정 파일 업데이트 중..."
    
    local source_line="# Seongmin's ZSH Menu"
    local source_cmd="source \"$INSTALL_DIR/$MENU_FILE\""
    
    # 이미 추가되어 있는지 확인
    if grep -q "Seongmin's ZSH Menu" "$SHELL_RC" 2>/dev/null; then
        warn "이미 설정되어 있습니다. 기존 설정을 업데이트합니다."
        # 기존 설정 제거
        if [[ "$OS" == "macOS" ]]; then
            sed -i '' '/# Seongmin.*ZSH Menu/,/source.*zsh_menu/d' "$SHELL_RC"
        else
            sed -i '/# Seongmin.*ZSH Menu/,/source.*zsh_menu/d' "$SHELL_RC"
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
    echo -e "      ${YELLOW}gg${NC}  또는  ${YELLOW}_seongmin_menu${NC}"
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
    
    # 쉘 설정에서 제거
    if [ -f "$SHELL_RC" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/# Seongmin.*ZSH Menu/,/source.*zsh_menu/d' "$SHELL_RC"
        else
            sed -i '/# Seongmin.*ZSH Menu/,/source.*zsh_menu/d' "$SHELL_RC"
        fi
        success "쉘 설정 제거 완료"
    fi
    
    echo ""
    success "삭제가 완료되었습니다."
    echo "터미널을 다시 시작하거나 source $SHELL_RC를 실행하세요."
    echo ""
}

# 메인 로직
main() {
    print_banner
    
    # 삭제 옵션 확인
    if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
        check_os
        uninstall
        exit 0
    fi
    
    # 설치 진행
    echo -e "${YELLOW}설치를 진행하시겠습니까? (y/n)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "설치가 취소되었습니다."
        exit 0
    fi
    
    echo ""
    check_os
    create_install_dir
    copy_files
    configure_shell
    print_complete
}

# 스크립트 실행
main "$@"
