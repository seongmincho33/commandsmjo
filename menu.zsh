# 🌸 성민이의 소중한 명령어 메뉴판 (인터랙티브 버전!)

# ═══════════════════════════════════════════════════════════════
# 메뉴 자체 버전
# ═══════════════════════════════════════════════════════════════
SEONGMIN_MENU_VERSION="2.2.0"

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

# ═══════════════════════════════════════════════════════════════
# 🚪 취소 가능한 입력 (q/Q/빈 줄 = 취소)
#
# 사용법:
#   _seongmin_input "패키지 이름" || { _seongmin_cancelled; continue; }
#   local pkg="$REPLY"
#
#   # 기본값 사용 시
#   _seongmin_input "포트" "3000" || { _seongmin_cancelled; continue; }
#   local port="$REPLY"
#
# 반환:
#   0 = OK, $REPLY 에 값
#   1 = 취소됨 (호출자가 continue/return)
# ═══════════════════════════════════════════════════════════════
_seongmin_input() {
    _seongmin_init_colors
    local prompt="${1:-입력}"
    local default="${2:-}"
    if [[ -n "$default" ]]; then
        echo -n "  ${prompt} ${MAGENTA}[기본: ${default}]${RESET} ${YELLOW}(q/엔터=취소)${RESET} > "
    else
        echo -n "  ${prompt} ${YELLOW}(q/엔터=취소)${RESET} > "
    fi
    read REPLY
    case "$REPLY" in
        q|Q) return 1 ;;
        "")
            if [[ -n "$default" ]]; then
                REPLY="$default"
                return 0
            else
                return 1
            fi
            ;;
        *) return 0 ;;
    esac
}

# 취소 메시지 (호출 후 짧은 sleep)
_seongmin_cancelled() {
    _seongmin_init_colors
    echo "  ${YELLOW}↩️  취소되었습니다.${RESET}"
    sleep 0.4
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

# ═══════════════════════════════════════════════════════════════
# 🎨 dps 도움말
# ═══════════════════════════════════════════════════════════════
_seongmin_dps_help() {
    _seongmin_init_colors
    echo "${GREEN}🎨 dps — Pretty docker ps${RESET}"
    echo ""
    echo "${YELLOW}사용법:${RESET}"
    echo "  dps                       실행 중인 컨테이너 (예쁘게)"
    echo "  dps -a                    중지된 것 포함"
    echo "  dps --json                JSON 출력 (jq 있으면 배열로)"
    echo ""
    echo "${YELLOW}필터:${RESET}"
    echo "  dps --status=exited       상태 필터 (running/exited/paused/restarting/created/dead)"
    echo "  dps --name=PATTERN        이름 부분 일치"
    echo "  dps --health=unhealthy    헬스체크 필터 (healthy/unhealthy/starting)"
    echo "  dps --label=key=val       라벨 필터"
    echo "  dps --filter KEY=VAL      raw docker filter (다른 모든 필터)"
    echo ""
    echo "${YELLOW}예시:${RESET}"
    echo "  dps --status=exited                   # 종료된 컨테이너만"
    echo "  dps --name=bundok                     # 이름에 bundok 포함"
    echo "  dps --health=unhealthy                # 헬스 안 좋은 것만"
    echo "  dps --json | jq '.[].Names'           # 이름만 추출"
    echo "  dps -h                                # 이 도움말"
}

# ═══════════════════════════════════════════════════════════════
# 🎨 dimg 도움말
# ═══════════════════════════════════════════════════════════════
_seongmin_dimg_help() {
    _seongmin_init_colors
    echo "${GREEN}🎨 dimg — Pretty docker images${RESET}"
    echo ""
    echo "${YELLOW}사용법:${RESET}"
    echo "  dimg                      이미지 목록 (size별 색상)"
    echo "  dimg -a                   중간 빌드 레이어 포함"
    echo "  dimg --json               JSON 출력"
    echo "  dimg --dangling           👻 dangling (<none>) 이미지만"
    echo "  dimg --reference=PATTERN  ref 패턴 매칭 (예: postgres*)"
    echo "  dimg --filter KEY=VAL     raw docker filter"
    echo ""
    echo "${YELLOW}크기 색상:${RESET}"
    echo "  🟢 < 100MB    🔵 < 500MB    🟡 < 1GB    🔴 ≥ 1GB    👻 dangling"
}

# ═══════════════════════════════════════════════════════════════
# 🎨 예쁜 docker ps
#   - IPv4/IPv6 dedup, 시간 압축, 헬스 이모지, 상태 색상
#   - 자동 width (tput cols)
#   - JSON 모드 (--json)
#   - 필터 (--status, --name, --health, --label, --filter)
# ═══════════════════════════════════════════════════════════════
_seongmin_docker_ps_pretty() {
    _seongmin_init_colors

    if ! docker info &> /dev/null; then
        echo "${RED}❌ Docker daemon이 실행되지 않습니다.${RESET}"
        if _seongmin_is_macos; then
            echo "${YELLOW}💡 Docker Desktop 실행: open -a Docker${RESET}"
        else
            echo "${YELLOW}💡 sudo systemctl start docker${RESET}"
        fi
        return 1
    fi

    # 인자 파싱
    local show_all=""
    local json_mode=""
    local -a filters
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--all|all) show_all="-a" ;;
            --json|-j)    json_mode="1" ;;
            --status=*)
                local sval="${1#--status=}"
                filters+=("--filter" "status=$sval")
                # exited/created/dead 등은 -a 필요
                case "$sval" in
                    running|paused|restarting) ;;
                    *) show_all="-a" ;;
                esac
                ;;
            --name=*)    filters+=("--filter" "name=${1#--name=}") ;;
            --health=*)  filters+=("--filter" "health=${1#--health=}") ;;
            --label=*)   filters+=("--filter" "label=${1#--label=}") ;;
            --network=*) filters+=("--filter" "network=${1#--network=}") ;;
            --volume=*)  filters+=("--filter" "volume=${1#--volume=}") ;;
            --filter)
                shift
                [[ -n "$1" ]] && filters+=("--filter" "$1")
                ;;
            -h|--help) _seongmin_dps_help; return 0 ;;
            *) ;; # 알 수 없는 인자 무시
        esac
        shift
    done

    # JSON 모드: docker 자체 JSON 출력 활용
    if [[ -n "$json_mode" ]]; then
        if command -v jq &> /dev/null; then
            docker ps $show_all "${filters[@]}" --format json | jq -s '.'
        else
            docker ps $show_all "${filters[@]}" --format json
        fi
        return 0
    fi

    # 터미널 폭에 따라 컬럼 너비 동적 계산
    local cols=""
    cols=$(tput cols 2>/dev/null) || cols=120
    local avail=$((cols - 10))
    local name_w=$(( avail * 18 / 100 ))
    local image_w=$(( avail * 25 / 100 ))
    local status_w=$(( avail * 20 / 100 ))
    local ports_w=$(( avail * 25 / 100 ))
    local id_w=12
    (( name_w   < 12 )) && name_w=12
    (( name_w   > 30 )) && name_w=30
    (( image_w  < 14 )) && image_w=14
    (( image_w  > 38 )) && image_w=38
    (( status_w < 14 )) && status_w=14
    (( status_w > 24 )) && status_w=24
    (( ports_w  < 12 )) && ports_w=12
    (( ports_w  > 32 )) && ports_w=32

    # 데이터 가져오기 (ASCII Unit Separator로 필드 구분)
    local SEP=$'\x1f'
    local data=""
    data=$(docker ps $show_all "${filters[@]}" --format "{{.ID}}${SEP}{{.Names}}${SEP}{{.Image}}${SEP}{{.Status}}${SEP}{{.Ports}}" 2>/dev/null)

    if [[ -z "$data" ]]; then
        echo "${YELLOW}🌙 조건에 맞는 컨테이너가 없어요.${RESET}"
        if [[ -z "$show_all" && ${#filters[@]} -eq 0 ]]; then
            echo "${CYAN}💡 중지된 것 포함하려면: dps -a${RESET}"
        fi
        return 0
    fi

    local total=0
    total=$(echo "$data" | grep -c '^')

    # 헤더
    echo ""
    printf "  ${CYAN}%-3s %-${name_w}s %-${image_w}s %-${status_w}s %-${ports_w}s %-${id_w}s${RESET}\n" \
        "" "NAME" "IMAGE" "STATUS" "PORTS" "ID"
    local sep_total=$((3 + name_w + image_w + status_w + ports_w + id_w + 5))
    local sep_line=""
    sep_line=$(printf "%${sep_total}s" "" | tr ' ' '-' | sed 's/-/─/g')
    printf "  ${CYAN}%s${RESET}\n" "$sep_line"

    # 데이터 행
    while IFS=$SEP read -r id name image cstatus ports; do
        local short_id="${id:0:12}"
        local emoji=""
        local status_color=""
        case "$cstatus" in
            Up*"(healthy)"*)   emoji="🟢"; status_color="$GREEN"  ;;
            Up*"(unhealthy)"*) emoji="🟠"; status_color="$YELLOW" ;;
            Up*"(starting)"*)  emoji="🟡"; status_color="$YELLOW" ;;
            Up*)               emoji="🟢"; status_color="$GREEN"  ;;
            Exited*)           emoji="🔴"; status_color="$RED"    ;;
            Restarting*)       emoji="🔄"; status_color="$YELLOW" ;;
            Paused*)           emoji="⏸ "; status_color="$YELLOW" ;;
            Created*)          emoji="⚪"; status_color="$RESET"  ;;
            Dead*)             emoji="💀"; status_color="$RED"    ;;
            *)                 emoji="❓"; status_color="$RESET"  ;;
        esac

        local short_status=""
        short_status=$(echo "$cstatus" | sed -E '
            s/ minutes?/m/g
            s/ hours?/h/g
            s/ days?/d/g
            s/ seconds?/s/g
            s/ weeks?/w/g
            s/ months?/mo/g
            s/Less than a second/<1s/g
            s/About an /~1/g
            s/About a /~1/g
            s/ \(healthy\)/ ✓/g
            s/ \(unhealthy\)/ ✗/g
            s/ \(starting\)/ ⏳/g
        ')

        local clean_ports="-"
        if [[ -n "$ports" ]]; then
            clean_ports=$(echo "$ports" | awk -F', ' '
            {
                out = ""
                n = 0
                for (i=1; i<=NF; i++) {
                    s = $i
                    sub(/^[[:space:]]+/, "", s)
                    sub(/^[0-9.]+:/, "", s)
                    sub(/^\[::\]:/, "", s)
                    if (!(s in seen)) {
                        seen[s] = 1
                        if (s ~ /^[0-9]+->[0-9]+\//) {
                            split(s, a, "->")
                            split(a[2], b, "/")
                            if (a[1] == b[1]) {
                                pretty = ":" a[1] "/" b[2]
                            } else {
                                pretty = ":" a[1] "→" b[1] "/" b[2]
                            }
                        } else {
                            pretty = s
                        }
                        out = out (n>0 ? "," : "") pretty
                        n++
                    }
                }
                print out
            }')
        fi

        # 동적 width로 자르기
        local short_name="${name:0:$name_w}"
        local short_image="${image:0:$image_w}"
        local trunc_status="${short_status:0:$status_w}"
        local trunc_ports="${clean_ports:0:$ports_w}"
        if (( ${#image} > image_w )); then short_image="${image:0:$((image_w - 3))}..."; fi
        if (( ${#clean_ports} > ports_w )); then trunc_ports="${clean_ports:0:$((ports_w - 3))}..."; fi

        printf "  %-3s ${MAGENTA}%-${name_w}s${RESET} %-${image_w}s ${status_color}%-${status_w}s${RESET} ${CYAN}%-${ports_w}s${RESET} ${YELLOW}%-${id_w}s${RESET}\n" \
            "$emoji" "$short_name" "$short_image" "$trunc_status" "$trunc_ports" "$short_id"
    done <<< "$data"

    printf "  ${CYAN}%s${RESET}\n" "$sep_line"
    if [[ ${#filters[@]} -gt 0 ]]; then
        echo "  ${GREEN}총 ${total}개${RESET}  ${YELLOW}🔍 필터 적용됨${RESET}  ${CYAN}(${cols} cols)${RESET}"
    else
        echo "  ${GREEN}총 ${total}개${RESET}  ${CYAN}(${cols} cols)${RESET}"
    fi
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 🎨 예쁜 docker images
#   - size별 색상 (🟢🔵🟡🔴), dangling 표시 (👻)
#   - 시간 압축, 자동 width, JSON 모드, 필터
# ═══════════════════════════════════════════════════════════════
_seongmin_docker_images_pretty() {
    _seongmin_init_colors

    if ! docker info &> /dev/null; then
        echo "${RED}❌ Docker daemon이 실행되지 않습니다.${RESET}"
        return 1
    fi

    local show_all=""
    local json_mode=""
    local -a filters
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--all|all)     show_all="-a" ;;
            --json|-j)        json_mode="1" ;;
            --dangling)       filters+=("--filter" "dangling=true") ;;
            --reference=*)    filters+=("--filter" "reference=${1#--reference=}") ;;
            --label=*)        filters+=("--filter" "label=${1#--label=}") ;;
            --filter)
                shift
                [[ -n "$1" ]] && filters+=("--filter" "$1")
                ;;
            -h|--help) _seongmin_dimg_help; return 0 ;;
            *) ;;
        esac
        shift
    done

    # JSON 모드
    if [[ -n "$json_mode" ]]; then
        if command -v jq &> /dev/null; then
            docker images $show_all "${filters[@]}" --format json | jq -s '.'
        else
            docker images $show_all "${filters[@]}" --format json
        fi
        return 0
    fi

    # 컬럼 너비 동적 계산
    local cols=""
    cols=$(tput cols 2>/dev/null) || cols=120
    local avail=$((cols - 10))
    local repo_w=$(( avail * 45 / 100 ))
    local size_w=10
    local created_w=14
    local id_w=12
    (( repo_w < 22 )) && repo_w=22
    (( repo_w > 55 )) && repo_w=55

    local SEP=$'\x1f'
    local data=""
    data=$(docker images $show_all "${filters[@]}" --format "{{.Repository}}${SEP}{{.Tag}}${SEP}{{.ID}}${SEP}{{.CreatedSince}}${SEP}{{.Size}}" 2>/dev/null)

    if [[ -z "$data" ]]; then
        echo "${YELLOW}🌙 조건에 맞는 이미지가 없어요.${RESET}"
        return 0
    fi

    local total=0
    total=$(echo "$data" | grep -c '^')

    # 헤더
    echo ""
    printf "  ${CYAN}%-3s %-${repo_w}s %-${size_w}s %-${created_w}s %-${id_w}s${RESET}\n" \
        "" "REPOSITORY:TAG" "SIZE" "CREATED" "ID"
    local sep_total=$((3 + repo_w + size_w + created_w + id_w + 4))
    local sep_line=""
    sep_line=$(printf "%${sep_total}s" "" | tr ' ' '-' | sed 's/-/─/g')
    printf "  ${CYAN}%s${RESET}\n" "$sep_line"

    local total_size_mb=0
    local dangling_count=0

    while IFS=$SEP read -r repo tag image_id created size; do
        local short_id="${image_id:0:12}"
        local repo_tag="${repo}:${tag}"
        local emoji="📦"
        local size_color="$GREEN"
        local repo_color="$RESET"

        # Dangling 이미지 체크
        local is_dangling=0
        if [[ "$repo" == "<none>" || "$tag" == "<none>" ]]; then
            is_dangling=1
            ((dangling_count++))
            repo_color="$YELLOW"
        fi

        # Size를 MB로 환산
        local size_mb=""
        size_mb=$(echo "$size" | awk '{
            n = $0 + 0
            if ($0 ~ /GB/)        print int(n * 1024)
            else if ($0 ~ /MB/)   print int(n)
            else if ($0 ~ /[kK]B/) print int(n / 1024 + 0.5)
            else                  print 0
        }')

        # Size 색상 + 이모지
        if (( is_dangling )); then
            emoji="👻"
            size_color="$YELLOW"
        elif (( size_mb >= 1024 )); then
            emoji="🔴"; size_color="$RED"
        elif (( size_mb >= 500 )); then
            emoji="🟡"; size_color="$YELLOW"
        elif (( size_mb >= 100 )); then
            emoji="🔵"; size_color="$CYAN"
        else
            emoji="🟢"; size_color="$GREEN"
        fi

        total_size_mb=$((total_size_mb + size_mb))

        # 시간 압축
        local short_created=""
        short_created=$(echo "$created" | sed -E '
            s/ minutes? ago/m/g
            s/ hours? ago/h/g
            s/ days? ago/d/g
            s/ weeks? ago/w/g
            s/ months? ago/mo/g
            s/ years? ago/y/g
            s/About an /~1/g
            s/About a /~1/g
        ')

        # 잘라내기
        local short_repo="${repo_tag}"
        if (( ${#repo_tag} > repo_w )); then
            short_repo="${repo_tag:0:$((repo_w - 3))}..."
        fi

        printf "  %-3s ${repo_color}%-${repo_w}s${RESET} ${size_color}%-${size_w}s${RESET} ${CYAN}%-${created_w}s${RESET} ${YELLOW}%-${id_w}s${RESET}\n" \
            "$emoji" "$short_repo" "$size" "$short_created" "$short_id"
    done <<< "$data"

    printf "  ${CYAN}%s${RESET}\n" "$sep_line"

    # 총 용량 계산
    local total_size_str=""
    if (( total_size_mb >= 1024 )); then
        total_size_str=$(awk -v mb="$total_size_mb" 'BEGIN { printf "%.1f GB", mb/1024 }')
    else
        total_size_str="${total_size_mb} MB"
    fi

    if (( dangling_count > 0 )); then
        echo "  ${GREEN}총 ${total}개${RESET}  ${CYAN}용량: ${total_size_str}${RESET}  ${YELLOW}👻 dangling: ${dangling_count}개${RESET}"
    else
        echo "  ${GREEN}총 ${total}개${RESET}  ${CYAN}용량: ${total_size_str}${RESET}"
    fi
    echo ""
}

# brew 명령 가능 여부 (Linux에는 거의 없음)
_seongmin_check_brew() {
    _seongmin_require_cmd brew "https://brew.sh"
}

# 진행률 바 — 0-100 입력 → ▓▓▓░░░ 같은 시각화
_seongmin_bar() {
    local pct=${1:-0}
    local width=${2:-10}
    (( pct < 0 )) && pct=0
    (( pct > 100 )) && pct=100
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

# 임계값 기반 색상 (≥80 빨강, ≥60 노랑, 그 외 초록)
_seongmin_bar_color() {
    local pct=${1:-0}
    _seongmin_init_colors
    if   (( pct >= 80 )); then echo -n "$RED"
    elif (( pct >= 60 )); then echo -n "$YELLOW"
    else                       echo -n "$GREEN"
    fi
}

# 바이트 → 사람 친화적 단위
_seongmin_human_bytes() {
    local bytes=${1:-0}
    awk -v b="$bytes" 'BEGIN {
        if (b >= 1099511627776) printf "%.1fT", b/1099511627776
        else if (b >= 1073741824) printf "%.1fG", b/1073741824
        else if (b >= 1048576) printf "%.1fM", b/1048576
        else if (b >= 1024) printf "%.1fK", b/1024
        else printf "%dB", b
    }'
}

# ═══════════════════════════════════════════════════════════════
# 🐧 Linux Distro 감지 + 환경 헬퍼
# ═══════════════════════════════════════════════════════════════

# 글로벌: $SEONGMIN_DISTRO_ID, $SEONGMIN_DISTRO_FAMILY, $SEONGMIN_DISTRO_NAME, $SEONGMIN_DISTRO_VERSION
_seongmin_detect_distro() {
    SEONGMIN_DISTRO_ID="unknown"
    SEONGMIN_DISTRO_NAME="Unknown OS"
    SEONGMIN_DISTRO_VERSION="?"
    SEONGMIN_DISTRO_ID_LIKE=""

    if [[ -f /etc/os-release ]]; then
        SEONGMIN_DISTRO_ID=$(awk -F= '/^ID=/{gsub(/"/,"",$2); print $2; exit}' /etc/os-release 2>/dev/null)
        SEONGMIN_DISTRO_NAME=$(awk -F= '/^NAME=/{gsub(/"/,"",$2); print $2; exit}' /etc/os-release 2>/dev/null)
        SEONGMIN_DISTRO_VERSION=$(awk -F= '/^VERSION_ID=/{gsub(/"/,"",$2); print $2; exit}' /etc/os-release 2>/dev/null)
        SEONGMIN_DISTRO_ID_LIKE=$(awk -F= '/^ID_LIKE=/{gsub(/"/,"",$2); print $2; exit}' /etc/os-release 2>/dev/null)
    elif _seongmin_is_macos; then
        SEONGMIN_DISTRO_ID="macos"
        SEONGMIN_DISTRO_NAME="macOS"
        SEONGMIN_DISTRO_VERSION=$(sw_vers -productVersion 2>/dev/null)
    fi

    SEONGMIN_DISTRO_FAMILY=$(_seongmin_distro_family_resolve)
}

# Family 분류 (debian|rhel|suse|alpine|arch|macos|unknown)
_seongmin_distro_family_resolve() {
    case "$SEONGMIN_DISTRO_ID" in
        ubuntu|debian|linuxmint|pop|elementary|kali|raspbian|deepin|zorin) echo "debian" ;;
        rhel|rocky|almalinux|centos|fedora|ol|amzn|amazon) echo "rhel" ;;
        opensuse-leap|opensuse-tumbleweed|opensuse|sles|sled) echo "suse" ;;
        alpine) echo "alpine" ;;
        arch|manjaro|endeavouros|garuda) echo "arch" ;;
        macos) echo "macos" ;;
        *)
            case "$SEONGMIN_DISTRO_ID_LIKE" in
                *debian*) echo "debian" ;;
                *rhel*|*fedora*|*centos*) echo "rhel" ;;
                *suse*) echo "suse" ;;
                *arch*) echo "arch" ;;
                *) echo "unknown" ;;
            esac
            ;;
    esac
}

# 컨테이너 안인지 (Docker/Podman/LXC)
_seongmin_in_container() {
    [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || \
    grep -qE 'docker|kubepods|lxc|containerd' /proc/1/cgroup 2>/dev/null
}

# WSL 안인지
_seongmin_in_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null || \
    grep -qi wsl /proc/version 2>/dev/null
}

# sudo 사용 가능?
_seongmin_has_sudo() {
    command -v sudo &>/dev/null && sudo -n true 2>/dev/null
}

# Distro 이모지
_seongmin_distro_emoji() {
    case "$SEONGMIN_DISTRO_FAMILY" in
        debian) echo "🦊" ;;
        rhel)   echo "🎩" ;;
        suse)   echo "🦎" ;;
        alpine) echo "🏔" ;;
        arch)   echo "🏛" ;;
        macos)  echo "🍎" ;;
        *)      echo "🐧" ;;
    esac
}

# 명령어 표시 + 실행 확인 (Linux 시스템 메뉴의 핵심 헬퍼)
# 사용법: _seongmin_run_or_show "sudo dnf install -y nginx"
_seongmin_run_or_show() {
    _seongmin_init_colors
    local cmd="$*"
    [[ -z "$cmd" ]] && return 1

    echo ""
    echo "  ${YELLOW}▶ 명령어:${RESET} ${CYAN}${cmd}${RESET}"
    echo ""

    # macOS면 실행 못 시킴 (참고만)
    if _seongmin_is_macos; then
        echo "  ${MAGENTA}💡 macOS 환경 — 명령어만 표시합니다.${RESET}"
        echo "  ${CYAN}   클립보드 복사하려면 [c] / 그냥 보기 [엔터]${RESET}"
        echo -n "  > "
        local ans=""
        read ans
        if [[ "$ans" == "c" || "$ans" == "C" ]]; then
            echo "$cmd" | pbcopy 2>/dev/null && echo "  ${GREEN}✅ 클립보드 복사됨${RESET}"
        fi
        return 0
    fi

    # Linux: 실행 여부 묻기
    echo -n "  ${YELLOW}지금 실행할까요? (y/N) >${RESET} "
    local ans=""
    read ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        echo ""
        eval "$cmd"
        local rc=$?
        echo ""
        if [[ $rc -eq 0 ]]; then
            echo "  ${GREEN}✅ 완료 (exit 0)${RESET}"
        else
            echo "  ${RED}❌ 실패 (exit $rc)${RESET}"
        fi
    else
        echo "  ${CYAN}↩️  실행하지 않음 — 위 명령어를 직접 사용하세요.${RESET}"
    fi
}

# 명령어만 출력 (실행 안 함, cheatsheet 등에서 사용)
_seongmin_show_cmd() {
    _seongmin_init_colors
    local label="$1"
    local cmd="$2"
    printf "  ${CYAN}%-20s${RESET} ${YELLOW}%s${RESET}\n" "$label" "$cmd"
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

        # 예쁜 docker ps (별도 명령어)
        dps|dockerps)
            _seongmin_docker_ps_pretty ${=args}
            return
            ;;

        # 예쁜 docker images
        dimg|dockerimages|images)
            _seongmin_docker_images_pretty ${=args}
            return
            ;;

        # 🔧 시니어 모드 직접 명령
        dash|dashboard)
            _seongmin_senior_dash
            return
            ;;
        pid|process)
            _seongmin_senior_pid ${=args}
            return
            ;;
        snip|snippet|cheat)
            _seongmin_senior_snip ${=args}
            return
            ;;
        health|healthcheck)
            _seongmin_senior_health
            return
            ;;
        kernel|oom|incident)
            _seongmin_senior_kernel
            return
            ;;

        # 🐧 Linux 시스템 관리 직접 명령
        linux|distro)
            _seongmin_detect_distro
            _seongmin_linux
            return
            ;;
        pkg|package)
            _seongmin_detect_distro
            _seongmin_linux_pkg
            return
            ;;
        svc|service)
            _seongmin_detect_distro
            _seongmin_linux_service
            return
            ;;
        fw|firewall)
            _seongmin_detect_distro
            _seongmin_linux_firewall
            return
            ;;
        cheat|cheatsheet)
            _seongmin_detect_distro
            _seongmin_linux_cheatsheet
            return
            ;;
        translate|xlate|convert)
            _seongmin_detect_distro
            _seongmin_linux_translator
            return
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
    echo "  dps         │ dxk dps [-a/--status=/--name=/--health=/--json]"
    echo "  dimg        │ dxk dimg [-a/--dangling/--reference=/--json]"
    echo ""
    echo "${RED}🔧 시니어 모드 (외워서 못 만드는 것들):${RESET}"
    echo "  dash        │ dxk dash       ${CYAN}🚨 운영 대시보드 (CPU/MEM/DISK/Top)${RESET}"
    echo "  pid         │ dxk pid <PID|name>  ${CYAN}🔬 프로세스 forensics${RESET}"
    echo "  snip        │ dxk snip [search/add/edit/list]  ${CYAN}📚 cheatsheet${RESET}"
    echo "  health      │ dxk health     ${CYAN}🩺 SSL/디스크/Docker 헬스 체크${RESET}"
    echo "  kernel      │ dxk kernel     ${CYAN}🆘 OOM/auth fail/reboot 이력${RESET}"
    echo ""
    echo "${BLUE}🐧 Linux 시스템 관리:${RESET}"
    echo "  linux       │ dxk linux      ${CYAN}🐧 메인 메뉴 (자동 distro 감지)${RESET}"
    echo "  pkg         │ dxk pkg        ${CYAN}📦 패키지 관리 (apt/dnf/zypper/...)${RESET}"
    echo "  svc         │ dxk svc        ${CYAN}⚙️  서비스 (systemd/OpenRC)${RESET}"
    echo "  fw          │ dxk fw         ${CYAN}🔥 방화벽 (ufw/firewalld/iptables)${RESET}"
    echo "  cheat       │ dxk cheat      ${CYAN}📚 distro별 cheatsheet${RESET}"
    echo "  translate   │ dxk translate  ${CYAN}🔍 명령어 변환기 (apt → dnf 등)${RESET}"
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
# 메뉴 자체 업데이트 (dxk update)
#   - install.sh가 menu.zsh만 복사하므로 ~/.zsh_menu/.git는 없음
#   - 대신 소스 git 저장소(~/Documents/zsh_seongmin 등)에서 pull
#   - .source_path 파일에 소스 경로 기록 (없으면 자동 탐색 / 사용자 입력)
# ═══════════════════════════════════════════════════════════════
_seongmin_self_update() {
    _seongmin_init_colors
    local install_dir="${HOME}/.zsh_menu"
    local src=""

    echo "${CYAN}🔄 DX Kit 업데이트 확인 중...${RESET}"
    echo ""

    # 1) 설치 폴더 자체가 git 저장소? (clone 방식 설치한 경우)
    if [[ -d "$install_dir/.git" ]]; then
        src="$install_dir"
    fi

    # 2) .source_path 파일에서 소스 경로 읽기
    if [[ -z "$src" && -f "$install_dir/.source_path" ]]; then
        local recorded
        recorded=$(cat "$install_dir/.source_path" 2>/dev/null)
        if [[ -n "$recorded" && -d "$recorded/.git" ]]; then
            src="$recorded"
        fi
    fi

    # 3) 일반적 위치 자동 탐색
    if [[ -z "$src" ]]; then
        local cand
        for cand in \
            "$HOME/Documents/zsh_seongmin" \
            "$HOME/zsh_seongmin" \
            "$HOME/code/zsh_seongmin" \
            "$HOME/dev/zsh_seongmin" \
            "$HOME/projects/zsh_seongmin" \
            "$HOME/Documents/dx-kit" \
            "$HOME/dx-kit"
        do
            if [[ -d "$cand/.git" && -f "$cand/menu.zsh" ]]; then
                src="$cand"
                break
            fi
        done
    fi

    # 4) 그래도 못 찾으면 사용자에게 묻기
    if [[ -z "$src" ]]; then
        echo "${YELLOW}⚠️  소스 git 저장소를 찾지 못했어요.${RESET}"
        echo "${CYAN}   git clone 받은 폴더 경로를 알려주세요.${RESET}"
        echo "${CYAN}   (예: ~/Documents/zsh_seongmin)${RESET}"
        echo -n "   경로 > "
        local user_path
        read user_path
        # ~ 확장
        user_path="${user_path/#\~/$HOME}"
        if [[ ! -d "$user_path/.git" || ! -f "$user_path/menu.zsh" ]]; then
            echo "${RED}❌ '$user_path' 는 유효한 소스 폴더가 아니에요.${RESET}"
            echo "${YELLOW}   menu.zsh + .git/ 둘 다 있어야 합니다.${RESET}"
            return 1
        fi
        src="$user_path"
        # 다음 실행에 쓰도록 저장
        mkdir -p "$install_dir"
        echo "$src" > "$install_dir/.source_path"
        echo "${GREEN}✅ 소스 경로 저장됨: $src${RESET}"
        echo ""
    fi

    echo "${CYAN}📦 소스:${RESET} $src"
    echo "${CYAN}📌 현재:${RESET} v${SEONGMIN_MENU_VERSION}"
    echo ""

    # 5) 소스에서 fetch + pull
    (
        cd "$src" || exit 1
        echo "${CYAN}🌐 원격 저장소 확인 중...${RESET}"
        git fetch --quiet 2>&1

        local behind ahead
        behind=$(git rev-list HEAD..@{upstream} --count 2>/dev/null || echo 0)
        ahead=$(git rev-list @{upstream}..HEAD --count 2>/dev/null || echo 0)

        if (( ahead > 0 )); then
            echo "${YELLOW}⚠️  로컬에 ${ahead}개의 미푸시 커밋이 있습니다.${RESET}"
            echo "${YELLOW}   ($src 에서 git push 먼저 하시거나 stash 하세요)${RESET}"
        fi

        if [[ "$behind" == "0" ]]; then
            echo "${GREEN}✅ 이미 최신입니다.${RESET}"
            # 그래도 install_dir의 menu.zsh가 오래됐을 수 있으니 동기화 검사
            if ! cmp -s "$src/menu.zsh" "$install_dir/menu.zsh" 2>/dev/null; then
                echo "${YELLOW}🔄 설치 폴더의 menu.zsh가 소스와 달라요. 다시 복사합니다.${RESET}"
                cp "$src/menu.zsh" "$install_dir/menu.zsh"
                echo "${GREEN}✅ 동기화 완료${RESET}"
            fi
        else
            echo "${YELLOW}🆕 ${behind}개의 새 커밋이 있습니다.${RESET}"
            git log --oneline HEAD..@{upstream} | head -5 | sed 's/^/   /'
            echo ""
            echo -n "지금 업데이트할까요? (y/N) > "
            local ans
            read ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                if git pull; then
                    cp "$src/menu.zsh" "$install_dir/menu.zsh"
                    echo "${GREEN}✅ 업데이트 완료!${RESET}"
                    echo "${CYAN}💡 적용하려면 새 터미널을 열거나 'source ~/.zshrc' 실행${RESET}"
                else
                    echo "${RED}❌ git pull 실패. 충돌 가능성이 있어요.${RESET}"
                fi
            else
                echo "${YELLOW}취소됨.${RESET}"
            fi
        fi
    )
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
        echo "  ${RED}[ Senior / SRE (v2.1) ]${RESET}  ${YELLOW}— 외워서 못 만드는 것들${RESET}"
        echo "  ${CYAN}[17]${RESET} 🔧 운영 모드 (dash/pid/network/db/k8s/snip 등 10개)"
        echo ""
        echo "  ${BLUE}[ Linux 시스템 (v2.2) ]${RESET}  ${YELLOW}— Ubuntu/RHEL/SUSE/Alpine/Arch${RESET}"
        echo "  ${CYAN}[18]${RESET} 🐧 Linux 시스템 관리 (pkg/service/fw/cheatsheet/변환기)"
        echo ""
        echo "  ${MAGENTA}[s]${RESET} 🔍 메뉴 검색  ${MAGENTA}[u]${RESET} 🔄 자체 업데이트  ${MAGENTA}[v]${RESET} ℹ️  버전"
        echo "  ${CYAN}[0]${RESET} 🚪 나가기"
        echo ""
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo "  ${YELLOW}💡 팁:${RESET} 어떤 입력 화면에서든 ${YELLOW}q${RESET} 또는 ${YELLOW}엔터${RESET}만 누르면 취소"
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
            17) _seongmin_senior ;;
            18) _seongmin_linux ;;
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
                _seongmin_input "커밋 메시지" || { _seongmin_cancelled; continue; }
                local msg="$REPLY"
                echo "실행: git commit -m \"$msg\""
                git commit -m "$msg"
                _seongmin_pause
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
                _seongmin_input "커밋 메시지" || { _seongmin_cancelled; continue; }
                local msg="$REPLY"
                echo "실행: git add . && git commit -m \"$msg\" && git push"
                git add . && git commit -m "$msg" && git push && \
                    echo "${GREEN}✅ 완료${RESET}"
                _seongmin_pause
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
                _seongmin_input "타입 선택 (1-9)" || { _seongmin_cancelled; continue; }
                local ctype="$REPLY"
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
                    *) _seongmin_cancelled; continue ;;
                esac
                _seongmin_input "스코프 (예: api)" "" || { _seongmin_cancelled; continue; }
                local scope="$REPLY"
                _seongmin_input "커밋 메시지" || { _seongmin_cancelled; continue; }
                local msg="$REPLY"
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
                _seongmin_input "선택" || { _seongmin_cancelled; continue; }
                local ao="$REPLY"
                case $ao in
                    1)
                        _seongmin_input "새 메시지" || { _seongmin_cancelled; continue; }
                        git commit --amend -m "$REPLY"
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
                _seongmin_input "기술 스택" || { _seongmin_cancelled; continue; }
                local stacks="$REPLY"
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
                _seongmin_input "이동할 브랜치명" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                echo "실행: git checkout $br"
                git checkout "$br"
                _seongmin_pause
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
                _seongmin_input "확인할 커밋 해시" || { _seongmin_cancelled; continue; }
                local hash="$REPLY"
                echo "실행: git show $hash"
                git show "$hash"
                _seongmin_pause
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
                _seongmin_input "새 브랜치 이름" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                echo "실행: git checkout -b $br"
                git checkout -b "$br"
                _seongmin_pause
                ;;
            2)
                clear
                echo "${YELLOW}🗑️ 브랜치 삭제 (안전)${RESET}"
                echo "현재 브랜치 목록:"
                git branch
                echo ""
                _seongmin_input "삭제할 브랜치 이름" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                echo "실행: git branch -d $br"
                git branch -d "$br"
                _seongmin_pause
                ;;
            3)
                clear
                echo "${RED}🔥 브랜치 강제 삭제${RESET}"
                echo "현재 브랜치 목록:"
                git branch
                echo ""
                _seongmin_input "강제 삭제할 브랜치 이름" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                if _seongmin_confirm_dangerous "git branch -D $br"; then
                    echo "실행: git branch -D $br"
                    git branch -D "$br"
                fi
                _seongmin_pause
                ;;
            4)
                clear
                echo "${GREEN}🤝 브랜치 병합${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                echo "병합 가능한 브랜치:"
                git branch
                echo ""
                _seongmin_input "병합할 브랜치 이름" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                echo "실행: git merge $br"
                git merge "$br"
                _seongmin_pause
                ;;
            5)
                clear
                echo "${GREEN}✏️ 브랜치 이름 변경${RESET}"
                echo "현재 브랜치: $(git branch --show-current)"
                echo ""
                _seongmin_input "새로운 브랜치 이름" || { _seongmin_cancelled; continue; }
                local new_name="$REPLY"
                echo "실행: git branch -m $new_name"
                git branch -m "$new_name"
                echo "${GREEN}✅ 변경됨${RESET}"
                _seongmin_pause
                ;;
            6)
                clear
                echo "${RED}🌐 원격 브랜치 삭제${RESET}"
                echo "원격 브랜치 목록:"
                git branch -r
                echo ""
                _seongmin_input "삭제할 원격 브랜치 이름 (origin/ 제외)" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                if _seongmin_confirm_dangerous "git push origin --delete $br"; then
                    echo "실행: git push origin --delete $br"
                    git push origin --delete "$br"
                fi
                _seongmin_pause
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
                _seongmin_input "저장할 메시지" || { _seongmin_cancelled; continue; }
                local msg="$REPLY"
                echo "실행: git stash push -m \"$msg\""
                git stash push -m "$msg"
                _seongmin_pause
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
                _seongmin_input "삭제할 stash 번호 (예: 0)" || { _seongmin_cancelled; continue; }
                local num="$REPLY"
                echo "실행: git stash drop stash@{$num}"
                git stash drop "stash@{$num}"
                _seongmin_pause
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
                _seongmin_input "되돌릴 파일명" || { _seongmin_cancelled; continue; }
                local filename="$REPLY"
                if true; then
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
                _seongmin_input "unstage할 파일명 (전체는: .)" || { _seongmin_cancelled; continue; }
                local filename="$REPLY"
                if true; then
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
                _seongmin_input "되돌릴 커밋 해시" || { _seongmin_cancelled; continue; }
                local hash="$REPLY"
                if true; then
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
                _seongmin_input "Clone할 URL" || { _seongmin_cancelled; continue; }
                local url="$REPLY"
                if true; then
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
                _seongmin_input "원격 저장소 URL" || { _seongmin_cancelled; continue; }
                local url="$REPLY"
                if true; then
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
                _seongmin_input "새로운 URL" || { _seongmin_cancelled; continue; }
                local url="$REPLY"
                if true; then
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
                _seongmin_input "푸시할 브랜치명" "$(git branch --show-current)" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
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
                _seongmin_input "체리픽할 커밋 해시" || { _seongmin_cancelled; continue; }
                local hash="$REPLY"
                if true; then
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
                _seongmin_input "리베이스할 브랜치명" || { _seongmin_cancelled; continue; }
                local br="$REPLY"
                if true; then
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
                _seongmin_input "수정할 커밋 개수" || { _seongmin_cancelled; continue; }
                local num="$REPLY"
                echo "실행: git rebase -i HEAD~$num"
                git rebase -i "HEAD~$num"
                _seongmin_pause
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
                _seongmin_input "태그명 (예: v1.0.0)" || { _seongmin_cancelled; continue; }
                local tag_name="$REPLY"
                _seongmin_input "태그 메시지" || { _seongmin_cancelled; continue; }
                local tag_msg="$REPLY"
                echo "실행: git tag -a $tag_name -m \"$tag_msg\""
                git tag -a "$tag_name" -m "$tag_msg"
                echo "${GREEN}✅ 태그 생성됨${RESET}"
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
        echo "  ${CYAN}[1]${RESET}  가상환경 생성             ${CYAN}python3 -m venv venv${RESET}"
        echo "  ${CYAN}[2]${RESET}  가상환경 활성화           ${CYAN}source venv/bin/activate${RESET}"
        echo "  ${CYAN}[3]${RESET}  가상환경 비활성화         ${CYAN}deactivate${RESET}"
        echo "  ${CYAN}[4]${RESET}  새 프로젝트 시작 (venv+pip+upgrade 한방)"
        echo "  ${CYAN}[5]${RESET}  기존 프로젝트 셋업 (활성화 + requirements 설치)"
        echo "  ${CYAN}[12]${RESET} 가상환경 목록 (pyvenv.cfg 검색)"
        echo ""
        echo "  ${YELLOW}[ 패키지 ]${RESET}"
        echo "  ${CYAN}[6]${RESET}  설치된 패키지            ${CYAN}pip list${RESET}"
        echo "  ${CYAN}[7]${RESET}  업데이트 가능 패키지     ${CYAN}pip list --outdated${RESET}"
        echo "  ${CYAN}[8]${RESET}  requirements.txt 저장   ${CYAN}pip freeze > requirements.txt${RESET}"
        echo "  ${CYAN}[10]${RESET} requirements.txt 설치   ${CYAN}pip install -r requirements.txt${RESET}"
        echo "  ${CYAN}[11]${RESET} Python 버전 확인       ${CYAN}python3 --version${RESET}"
        echo ""
        echo "  ${YELLOW}[ 실행 & 도구 ]${RESET}"
        echo "  ${CYAN}[9]${RESET}  간단 웹서버 실행        ${CYAN}python3 -m http.server${RESET}"
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
                _seongmin_input "사용할 Python 버전 (숫자, 0=시스템기본)" "0" || { _seongmin_cancelled; continue; }
                local py_choice="$REPLY"

                local selected_python="python3"

                if [[ "$py_choice" == "0" ]]; then
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
                _seongmin_input "📁 가상환경 폴더 이름" "venv" || { _seongmin_cancelled; continue; }
                local venv_name="$REPLY"
                
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
                _seongmin_input "📁 가상환경 폴더 이름" "venv" || { _seongmin_cancelled; continue; }
                local venv_name="$REPLY"
                
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
                _seongmin_input "📁 가상환경 폴더 이름" "venv" || { _seongmin_cancelled; continue; }
                local venv_name="$REPLY"
                
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
        echo "  ${CYAN}[1]${RESET} 설치된 Java 버전 목록    ${CYAN}jenv versions${RESET}"
        echo "  ${CYAN}[2]${RESET} 현재 Java 버전           ${CYAN}java --version${RESET}"
        echo "  ${CYAN}[3]${RESET} 🏃 단일 파일 실행         ${CYAN}java Main.java${RESET}"
        echo "  ${CYAN}[4]${RESET} 🐘 Gradle (Build/Run)"
        echo "  ${CYAN}[5]${RESET} 🪶 Maven (Build/Run)"
        echo "  ${CYAN}[6]${RESET} 🔄 Java 버전 전환 (jenv global/local/shell)"
        echo "  ${CYAN}[7]${RESET} 🧐 프로젝트 버전 확인 (build.gradle / pom.xml)"
        echo "  ${CYAN}[8]${RESET} 🔪 포트 점유 프로세스 종료 (lsof -ti :PORT)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "  실행할 번호 > "
        read subchoice
        
        case $subchoice in
            1) clear; jenv versions; echo ""; read -k 1 ;;
            2) clear; java --version; echo ""; read -k 1 ;;
            3)
                clear
                _seongmin_input "🏃 실행할 자바 파일명(예: Main.java)" || { _seongmin_cancelled; continue; }
                local f="$REPLY"
                if true; then
                    # Java 11+ : 단일 파일 직접 실행 가능 (`java Main.java`)
                    # 그 이전 버전: javac 후 java
                    if java --version 2>&1 | head -1 | grep -qE 'version "(1[1-9]|[2-9][0-9])'; then
                        echo "▶ java $f"
                        java "$f"
                    else
                        local cls="${f%.java}"
                        echo "▶ javac $f && java $cls"
                        javac "$f" && java "$cls"
                    fi
                fi
                echo ""
                read -k 1
                ;;
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
        echo "  ${CYAN}[1]${RESET} Clean Build       ${CYAN}./gradlew clean build${RESET}"
        echo "  ${CYAN}[2]${RESET} Spring Boot Run   ${CYAN}./gradlew bootRun${RESET}"
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
        echo "  ${CYAN}[1]${RESET} Clean Install     ${CYAN}mvn clean install${RESET}"
        echo "  ${CYAN}[2]${RESET} Spring Boot Run   ${CYAN}mvn spring-boot:run${RESET}"
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
        echo "${CYAN}변경할 버전 (예: 17, 11.0, corretto64-17)${RESET}"
        echo ""
        _seongmin_input "버전" || { _seongmin_cancelled; return; }
        local ver="$REPLY"

        echo ""
        echo "${GREEN}어떤 범위로 적용할까요?${RESET}"
        echo "  ${CYAN}[1]${RESET} Global  (모든 터미널 기본값 변경)"
        echo "  ${CYAN}[2]${RESET} Local   (현재 디렉토리에만 적용 - .java-version 생성)"
        echo "  ${CYAN}[3]${RESET} Shell   (현재 터미널 창에만 임시 적용)"
        echo "  ${CYAN}[0]${RESET} 취소"
        echo ""
        _seongmin_input "범위 선택" || { _seongmin_cancelled; continue; }
        local scope="$REPLY"

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
    
    _seongmin_input "확인할 포트 번호" || { _seongmin_cancelled; return; }
    local port_num="$REPLY"

    if ! [[ "$port_num" =~ ^[0-9]+$ ]]; then
        echo "${RED}❌ 숫자만 입력해주세요.${RESET}"
        _seongmin_pause
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
                _seongmin_input "검색어" || { _seongmin_cancelled; continue; }
                local kw="$REPLY"
                echo ""
                echo "실행: brew search $kw"
                echo ""
                brew search "$kw"
                _seongmin_pause
                ;;
            2)
                clear
                echo "${GREEN}📥 Brew 설치${RESET}"
                _seongmin_input "설치할 패키지 이름" || { _seongmin_cancelled; continue; }
                local pkg="$REPLY"
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
                _seongmin_input "제거할 패키지 이름" || { _seongmin_cancelled; continue; }
                local pkg="$REPLY"
                if _seongmin_confirm_dangerous "brew uninstall $pkg"; then
                    brew uninstall "$pkg"
                fi
                _seongmin_pause
                ;;
            4)
                clear
                echo "${GREEN}ℹ️  Brew 패키지 정보${RESET}"
                _seongmin_input "패키지 이름" || { _seongmin_cancelled; continue; }
                local pkg="$REPLY"
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
                _seongmin_input "저장 경로" "./Brewfile" || { _seongmin_cancelled; continue; }
                local path="$REPLY"
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
                _seongmin_input "컨테이너 이름 또는 ID" || { _seongmin_cancelled; continue; }
                local cname="$REPLY"
                echo "실행: docker logs -f --tail 100 $cname (Ctrl+C로 종료)"
                docker logs -f --tail 100 "$cname"
                ;;
            9)
                clear
                echo "${CYAN}💻 컨테이너 진입${RESET}"
                docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
                echo ""
                _seongmin_input "컨테이너 이름 또는 ID" || { _seongmin_cancelled; continue; }
                local cname="$REPLY"
                _seongmin_input "셸 (예: bash)" "sh" || { _seongmin_cancelled; continue; }
                local shell_type="$REPLY"
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
                echo "${GREEN}📦 실행 중인 컨테이너 목록 (예쁜 버전)${RESET}"
                _seongmin_docker_ps_pretty
                echo "${CYAN}💡 원본 출력이 필요하면: docker ps${RESET}"
                _seongmin_pause
                ;;
            2)
                clear
                echo "${GREEN}📦 모든 컨테이너 목록 (예쁜 버전)${RESET}"
                _seongmin_docker_ps_pretty all
                echo "${CYAN}💡 원본 출력이 필요하면: docker ps -a${RESET}"
                _seongmin_pause
                ;;
            3)
                clear
                echo "${GREEN}▶️ 컨테이너 시작${RESET}"
                echo "현재 중지된 컨테이너:"
                docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                _seongmin_input "시작할 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                echo "실행: docker start $container_name"
                docker start "$container_name" && echo "${GREEN}✅ 시작됨${RESET}"
                _seongmin_pause
                ;;
            4)
                clear
                echo "${YELLOW}⏹️ 컨테이너 중지${RESET}"
                echo "현재 실행 중인 컨테이너:"
                docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                _seongmin_input "중지할 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                echo "실행: docker stop $container_name"
                docker stop "$container_name" && echo "${GREEN}✅ 중지됨${RESET}"
                _seongmin_pause
                ;;
            5)
                clear
                echo "${YELLOW}🔄 컨테이너 재시작${RESET}"
                echo "현재 컨테이너 목록:"
                docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                _seongmin_input "재시작할 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                echo "실행: docker restart $container_name"
                docker restart "$container_name" && echo "${GREEN}✅ 재시작됨${RESET}"
                _seongmin_pause
                ;;
            6)
                clear
                echo "${RED}🗑️ 컨테이너 삭제${RESET}"
                echo "현재 중지된 컨테이너:"
                docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                echo ""
                _seongmin_input "삭제할 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                if _seongmin_confirm_dangerous "docker rm $container_name"; then
                    docker rm "$container_name" && echo "${GREEN}✅ 삭제됨${RESET}"
                fi
                _seongmin_pause
                ;;
            7)
                clear
                echo "${CYAN}📜 컨테이너 로그 보기${RESET}"
                echo "현재 실행 중인 컨테이너:"
                docker ps --format "table {{.Names}}\t{{.Image}}"
                echo ""
                _seongmin_input "로그를 볼 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                echo "실행: docker logs -f --tail 100 $container_name (Ctrl+C로 종료)"
                echo ""
                docker logs -f --tail 100 "$container_name"
                ;;
            8)
                clear
                echo "${CYAN}🔌 컨테이너 내부 접속${RESET}"
                echo "현재 실행 중인 컨테이너:"
                docker ps --format "table {{.Names}}\t{{.Image}}"
                echo ""
                _seongmin_input "접속할 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                echo "실행: docker exec -it $container_name /bin/bash (bash 없으면 sh)"
                echo ""
                docker exec -it "$container_name" /bin/bash 2>/dev/null || docker exec -it "$container_name" /bin/sh
                ;;
            9)
                clear
                echo "${CYAN}🔍 컨테이너 상세 정보${RESET}"
                _seongmin_input "확인할 컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                echo "실행: docker inspect $container_name"
                echo ""
                docker inspect "$container_name" | head -50
                echo "... (상위 50줄만 표시)"
                _seongmin_pause
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
                echo "${GREEN}🖼️  이미지 목록 (예쁜 버전)${RESET}"
                _seongmin_docker_images_pretty
                echo "${CYAN}💡 dangling만 보려면: dimg --dangling${RESET}"
                _seongmin_pause
                ;;
            2)
                clear
                echo "${GREEN}📥 이미지 다운로드 (Pull)${RESET}"
                echo "예시: nginx, redis:latest, python:3.11-slim"
                echo ""
                _seongmin_input "다운로드할 이미지 (이미지명:태그)" || { _seongmin_cancelled; continue; }
                local image_name="$REPLY"
                echo "실행: docker pull $image_name"
                echo ""
                docker pull "$image_name"
                _seongmin_pause
                ;;
            3)
                clear
                echo "${GREEN}▶️ 이미지로 컨테이너 실행${RESET}"
                echo "로컬 이미지 목록:"
                docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
                echo ""
                _seongmin_input "실행할 이미지명" || { _seongmin_cancelled; continue; }
                local image_name="$REPLY"
                _seongmin_input "컨테이너 이름" || { _seongmin_cancelled; continue; }
                local container_name="$REPLY"
                _seongmin_input "포트 매핑 (예: 8080:80)" "" || { _seongmin_cancelled; continue; }
                local port_map="$REPLY"
                local port_opt=""
                [[ -n "$port_map" ]] && port_opt="-p $port_map"
                echo "실행: docker run -d --name $container_name $port_opt $image_name"
                eval "docker run -d --name $container_name $port_opt $image_name" && \
                    echo "${GREEN}✅ 컨테이너 생성됨${RESET}"
                _seongmin_pause
                ;;
            4)
                clear
                echo "${RED}🗑️ 이미지 삭제${RESET}"
                echo "현재 이미지 목록:"
                docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}"
                echo ""
                _seongmin_input "삭제할 이미지명 또는 ID" || { _seongmin_cancelled; continue; }
                local image_name="$REPLY"
                if _seongmin_confirm_dangerous "docker rmi $image_name"; then
                    echo "실행: docker rmi $image_name"
                    docker rmi "$image_name"
                fi
                _seongmin_pause
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
                    _seongmin_pause
                    continue
                fi
                echo ""
                _seongmin_input "이미지 태그명 (예: myapp:latest)" || { _seongmin_cancelled; continue; }
                local tag_name="$REPLY"
                echo "실행: docker build -t $tag_name ."
                echo ""
                docker build -t "$tag_name" .
                _seongmin_pause
                ;;
            6)
                clear
                echo "${CYAN}🏷️ 이미지 태그 변경${RESET}"
                echo "현재 이미지 목록:"
                docker images --format "table {{.Repository}}:{{.Tag}}"
                echo ""
                _seongmin_input "원본 이미지명:태그" || { _seongmin_cancelled; continue; }
                local source_image="$REPLY"
                _seongmin_input "새 이미지명:태그" || { _seongmin_cancelled; continue; }
                local target_image="$REPLY"
                echo "실행: docker tag $source_image $target_image"
                docker tag "$source_image" "$target_image" && \
                    echo "${GREEN}✅ 태그 추가됨${RESET}"
                _seongmin_pause
                ;;
            7)
                clear
                echo "${CYAN}📜 이미지 히스토리${RESET}"
                _seongmin_input "확인할 이미지명" || { _seongmin_cancelled; continue; }
                local image_name="$REPLY"
                echo "실행: docker history $image_name"
                echo ""
                docker history "$image_name"
                _seongmin_pause
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
                _seongmin_input "생성할 볼륨 이름" || { _seongmin_cancelled; continue; }
                local vol_name="$REPLY"
                docker volume create "$vol_name" && echo "${GREEN}✅ 생성됨${RESET}"
                _seongmin_pause
                ;;
            3)
                clear
                echo "${RED}🗑️ 볼륨 삭제${RESET}"
                echo "현재 볼륨 목록:"
                docker volume ls
                echo ""
                _seongmin_input "삭제할 볼륨 이름" || { _seongmin_cancelled; continue; }
                local vol_name="$REPLY"
                if _seongmin_confirm_dangerous "docker volume rm $vol_name"; then
                    docker volume rm "$vol_name"
                fi
                _seongmin_pause
                ;;
            4)
                clear
                echo "${GREEN}🌐 네트워크 목록${RESET}"
                docker network ls
                _seongmin_pause
                ;;
            5)
                clear
                echo "${GREEN}➕ 네트워크 생성${RESET}"
                _seongmin_input "생성할 네트워크 이름" || { _seongmin_cancelled; continue; }
                local net_name="$REPLY"
                docker network create "$net_name" && echo "${GREEN}✅ 생성됨${RESET}"
                _seongmin_pause
                ;;
            6)
                clear
                echo "${CYAN}🔍 네트워크 상세 정보${RESET}"
                echo "현재 네트워크 목록:"
                docker network ls
                echo ""
                _seongmin_input "확인할 네트워크 이름" || { _seongmin_cancelled; continue; }
                local net_name="$REPLY"
                docker network inspect "$net_name"
                _seongmin_pause
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
                _seongmin_input "alias 검색어 (전체 보려면 그냥 엔터)" "" || { _seongmin_cancelled; continue; }
                local kw="$REPLY"
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
                _seongmin_input "환경변수 검색어" || { _seongmin_cancelled; continue; }
                local kw="$REPLY"
                env | grep -i "$kw"
                _seongmin_pause
                ;;
            8)
                clear
                _seongmin_input "history 검색어" || { _seongmin_cancelled; continue; }
                local kw="$REPLY"
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
                _seongmin_input "변경할 셸 경로 (예: /bin/zsh)" || { _seongmin_cancelled; continue; }
                local newshell="$REPLY"
                chsh -s "$newshell"
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
                    _seongmin_input "프로젝트 이름" || { _seongmin_cancelled; continue; }
                    npx create-react-app "$REPLY"
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
                _seongmin_input "Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ get-job "$job_name" 2>/dev/null | head -50
                _seongmin_pause
                ;;
            3)
                clear
                echo "${GREEN}✅ Job 활성화${RESET}"
                _seongmin_input "활성화할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ enable-job "$job_name" && \
                    echo "${GREEN}✅ ${job_name} 활성화됨${RESET}"
                _seongmin_pause
                ;;
            4)
                clear
                echo "${YELLOW}⏸️ Job 비활성화${RESET}"
                _seongmin_input "비활성화할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ disable-job "$job_name" && \
                    echo "${YELLOW}⏸️ ${job_name} 비활성화됨${RESET}"
                _seongmin_pause
                ;;
            5)
                clear
                echo "${RED}🗑️ Job 삭제 (⚠️ 주의!)${RESET}"
                _seongmin_input "삭제할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                if _seongmin_confirm_dangerous "delete-job $job_name"; then
                    java -jar jenkins-cli.jar -s http://localhost:8080/ delete-job "$job_name" && \
                        echo "${RED}🗑️ ${job_name} 삭제됨${RESET}"
                fi
                _seongmin_pause
                ;;
            6)
                clear
                echo "${GREEN}💾 Job 설정 백업${RESET}"
                _seongmin_input "백업할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                local backup_file="${job_name}_backup.xml"
                java -jar jenkins-cli.jar -s http://localhost:8080/ get-job "$job_name" > "$backup_file" && \
                    echo "${GREEN}✅ ${backup_file} 백업됨${RESET}"
                _seongmin_pause
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
                _seongmin_input "빌드할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ build "$job_name" && \
                    echo "${GREEN}✅ ${job_name} 빌드 시작${RESET}"
                _seongmin_pause
                ;;
            2)
                clear
                echo "${GREEN}🚀 파라미터 빌드 실행${RESET}"
                _seongmin_input "빌드할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                _seongmin_input "파라미터 (예: BRANCH=main ENV=prod)" || { _seongmin_cancelled; continue; }
                local params="$REPLY"
                local param_args=""
                for param in $params; do
                    param_args="$param_args -p $param"
                done
                eval "java -jar jenkins-cli.jar -s http://localhost:8080/ build $job_name $param_args" && \
                    echo "${GREEN}✅ ${job_name} 빌드 시작${RESET}"
                _seongmin_pause
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
                _seongmin_input "확인할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                if command -v jq &> /dev/null; then
                    local result=$(curl -s "http://localhost:8080/job/$job_name/lastBuild/api/json" | jq -r '.result // "IN_PROGRESS"')
                    local number=$(curl -s "http://localhost:8080/job/$job_name/lastBuild/api/json" | jq -r '.number')
                    echo "빌드 번호: #$number"
                    echo -n "결과: "
                    case $result in
                        SUCCESS)  echo "${GREEN}✅ SUCCESS${RESET}" ;;
                        FAILURE)  echo "${RED}❌ FAILURE${RESET}" ;;
                        UNSTABLE) echo "${YELLOW}⚠️ UNSTABLE${RESET}" ;;
                        ABORTED)  echo "${YELLOW}🛑 ABORTED${RESET}" ;;
                        *)        echo "${CYAN}🔄 $result${RESET}" ;;
                    esac
                else
                    curl -s "http://localhost:8080/job/$job_name/lastBuild/api/json"
                fi
                _seongmin_pause
                ;;
            5)
                clear
                echo "${RED}🛑 빌드 중지${RESET}"
                _seongmin_input "중지할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ stop-builds "$job_name" && \
                    echo "${RED}🛑 ${job_name} 빌드 중지됨${RESET}"
                _seongmin_pause
                ;;
            6)
                clear
                echo "${CYAN}📜 콘솔 출력 보기${RESET}"
                _seongmin_input "확인할 Job 이름" || { _seongmin_cancelled; continue; }
                local job_name="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ console "$job_name" 2>/dev/null | tail -100
                _seongmin_pause
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
                _seongmin_input "사용자 이름" || { _seongmin_cancelled; continue; }
                local username="$REPLY"
                echo -n "API 토큰 (입력 숨김): "
                read -s token
                echo ""
                [[ -z "$token" ]] && { _seongmin_cancelled; continue; }
                java -jar jenkins-cli.jar -s http://localhost:8080/ -auth "$username:$token" who-am-i
                _seongmin_pause
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
                _seongmin_input "설치할 플러그인 ID (예: git)" || { _seongmin_cancelled; continue; }
                local plugin_id="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin "$plugin_id" && {
                    echo "${GREEN}✅ ${plugin_id} 설치 완료${RESET}"
                    echo "${YELLOW}⚠️ 적용하려면 Jenkins 재시작 필요${RESET}"
                }
                _seongmin_pause
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
                _seongmin_input "비활성화할 플러그인 ID" || { _seongmin_cancelled; continue; }
                local plugin_id="$REPLY"
                java -jar jenkins-cli.jar -s http://localhost:8080/ disable-plugin "$plugin_id" && \
                    echo "${YELLOW}⏸️ ${plugin_id} 비활성화됨${RESET}"
                _seongmin_pause
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
                _seongmin_input "이메일 주소" || { _seongmin_cancelled; continue; }
                local email="$REPLY"
                _seongmin_input "키 파일 이름" "id_ed25519" || { _seongmin_cancelled; continue; }
                local keyname="$REPLY"
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
                _seongmin_input "추가할 키 경로" "$HOME/.ssh/id_ed25519" || { _seongmin_cancelled; continue; }
                local kpath="$REPLY"
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
                _seongmin_input "원격 (예: user@host)" || { _seongmin_cancelled; continue; }
                local remote="$REPLY"
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
                _seongmin_input "테스트 대상" "git@github.com" || { _seongmin_cancelled; continue; }
                local host="$REPLY"
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
                _seongmin_input "ping 대상" "google.com" || { _seongmin_cancelled; continue; }
                local host="$REPLY"
                ping -c 4 "$host"
                _seongmin_pause
                ;;
            2)
                clear
                _seongmin_input "도메인 (예: github.com)" || { _seongmin_cancelled; continue; }
                local d="$REPLY"
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
                _seongmin_input "URL" || { _seongmin_cancelled; continue; }
                local url="$REPLY"
                echo "${CYAN}── 헤더 ──${RESET}"
                curl -sI "$url"
                echo ""
                echo "${CYAN}── 응답 시간 ──${RESET}"
                curl -s -o /dev/null -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTotal: %{time_total}s\nStatus: %{http_code}\n" "$url"
                _seongmin_pause
                ;;
            4)
                clear
                _seongmin_input "포트 번호" || { _seongmin_cancelled; continue; }
                local port="$REPLY"
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
                _seongmin_input "traceroute 대상" || { _seongmin_cancelled; continue; }
                local t="$REPLY"
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
                _seongmin_input "도메인" "google.com" || { _seongmin_cancelled; continue; }
                local d="$REPLY"
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
    _seongmin_input "프로젝트 이름" || { _seongmin_cancelled; return; }
    local pname="$REPLY"

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
    _seongmin_input "프로젝트 이름" || { _seongmin_cancelled; return; }
    local pname="$REPLY"

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
                _seongmin_input "포트 번호 (예: 3000, 8080)" || { _seongmin_cancelled; continue; }
                local port="$REPLY"
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
                _seongmin_input "비밀번호 길이" "16" || { _seongmin_cancelled; continue; }
                local len="$REPLY"
                local pwd=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$len")
                echo "${GREEN}🔐 비밀번호:${RESET} $pwd"
                if _seongmin_is_macos; then echo "$pwd" | pbcopy; echo "(클립보드 복사됨)"; fi
                _seongmin_pause
                ;;
            3)
                clear
                echo "  [1] 인코딩  [2] 디코딩"
                _seongmin_input "선택" || { _seongmin_cancelled; continue; }
                local mode="$REPLY"
                _seongmin_input "문자열" || { _seongmin_cancelled; continue; }
                local input="$REPLY"
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
                _seongmin_input "선택" || { _seongmin_cancelled; continue; }
                local mode="$REPLY"
                _seongmin_input "문자열" || { _seongmin_cancelled; continue; }
                local input="$REPLY"
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


# ═══════════════════════════════════════════════════════════════
# 🔧 시니어 모드 (메뉴 17 — 운영자/SRE 페르소나)
# ═══════════════════════════════════════════════════════════════

# ─── 디스패처 ───
function _seongmin_senior() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "운영 모드 (Senior / SRE)" "🔧"
        echo "  ${YELLOW}[ 한눈에 보기 ]${RESET}"
        echo "  ${CYAN}[1]${RESET}  🚨 운영 대시보드 (CPU/MEM/DISK/Docker/Listen/Top)"
        echo "  ${CYAN}[2]${RESET}  🩺 헬스 체크 (SSL 만료/DNS/Backup/SMART)"
        echo ""
        echo "  ${YELLOW}[ 깊은 분석 ]${RESET}"
        echo "  ${CYAN}[3]${RESET}  🔬 프로세스 forensics (lsof/limits/env/cmdline)"
        echo "  ${CYAN}[4]${RESET}  🌐 네트워크 deep dive (ss/tcpdump/mtr/curl-w/cert)"
        echo "  ${CYAN}[5]${RESET}  📜 로그 power tools (journalctl/multi-tail/freq)"
        echo "  ${CYAN}[6]${RESET}  💾 디스크/IO 분석 (du/iostat/docker df)"
        echo ""
        echo "  ${YELLOW}[ 데이터/오케스트레이션 ]${RESET}"
        echo "  ${CYAN}[7]${RESET}  🐘 PostgreSQL 운영 진단 쿼리"
        echo "  ${CYAN}[8]${RESET}  ⚓ Kubernetes 운영 도구 (ctx/ns/events/why-fail)"
        echo ""
        echo "  ${YELLOW}[ 사건 분석 / 컬렉션 ]${RESET}"
        echo "  ${CYAN}[9]${RESET}  🆘 커널 이벤트 (OOM/auth fail/reboot/systemd-failed)"
        echo "  ${CYAN}[10]${RESET} 📚 Snippet 라이브러리 (cheatsheet)"
        echo ""
        echo "  ${CYAN}[0]${RESET}  ⬅️  돌아가기"
        echo ""
        echo "  ${MAGENTA}💡 직접 실행:${RESET} ${YELLOW}dxk dash${RESET} / ${YELLOW}dxk pid <PID>${RESET} / ${YELLOW}dxk snip${RESET} / ${YELLOW}dxk health${RESET}"
        echo ""
        echo -n "  선택 > "
        read sub
        case $sub in
            1)  _seongmin_senior_dash;    _seongmin_pause ;;
            2)  _seongmin_senior_health;  _seongmin_pause ;;
            3)  _seongmin_senior_pid_menu ;;
            4)  _seongmin_senior_network ;;
            5)  _seongmin_senior_logs ;;
            6)  _seongmin_senior_disk ;;
            7)  _seongmin_senior_db ;;
            8)  _seongmin_senior_k8s ;;
            9)  _seongmin_senior_kernel; _seongmin_pause ;;
            10) _seongmin_senior_snip_menu ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된 번호${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 1️⃣  운영 대시보드 (dxk dash)
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_dash() {
    _seongmin_init_colors

    local hostname now uptime_str load
    hostname=$(uname -n)
    now=$(date "+%Y-%m-%d %H:%M:%S")
    uptime_str=$(uptime)
    load=$(echo "$uptime_str" | sed -E 's/.*load averages?: //; s/,/ /g')

    # CPU%
    local cpu_pct=0
    if _seongmin_is_macos; then
        cpu_pct=$(top -l 1 -n 0 2>/dev/null | awk -F'[: %,]+' '/CPU usage/ {print int($3 + $5); exit}')
    else
        cpu_pct=$(top -bn1 2>/dev/null | awk '/Cpu\(s\)/ {gsub("us,",""); printf "%d", $2; exit}')
    fi
    [[ -z "$cpu_pct" ]] && cpu_pct=0

    # 메모리
    local mem_pct=0 mem_used="?" mem_total="?"
    if _seongmin_is_macos; then
        local total_b page_size active wired
        total_b=$(sysctl -n hw.memsize 2>/dev/null)
        page_size=$(sysctl -n hw.pagesize 2>/dev/null)
        active=$(vm_stat 2>/dev/null | awk '/Pages active/ {gsub("\\.",""); print $3}')
        wired=$(vm_stat 2>/dev/null | awk '/Pages wired down/ {gsub("\\.",""); print $4}')
        if [[ -n "$total_b" && -n "$page_size" && -n "$active" ]]; then
            local used_b=$(( (active + ${wired:-0}) * page_size ))
            mem_pct=$(( used_b * 100 / total_b ))
            mem_used=$(awk -v b="$used_b" 'BEGIN{printf "%.1fG", b/1073741824}')
            mem_total=$(awk -v b="$total_b" 'BEGIN{printf "%.1fG", b/1073741824}')
        fi
    else
        local mem_data
        mem_data=$(free -m 2>/dev/null | awk '/^Mem/ {print $2, $3}')
        if [[ -n "$mem_data" ]]; then
            local total_m used_m
            total_m=$(echo "$mem_data" | awk '{print $1}')
            used_m=$(echo "$mem_data" | awk '{print $2}')
            mem_pct=$(( used_m * 100 / total_m ))
            mem_used=$(awk -v m="$used_m" 'BEGIN{printf "%.1fG", m/1024}')
            mem_total=$(awk -v m="$total_m" 'BEGIN{printf "%.1fG", m/1024}')
        fi
    fi

    # 디스크 (root)
    local disk_pct=0 disk_avail="?"
    local disk_data
    disk_data=$(df -h / 2>/dev/null | tail -1)
    if [[ -n "$disk_data" ]]; then
        disk_pct=$(echo "$disk_data" | awk '{gsub("%",""); print $5}')
        disk_avail=$(echo "$disk_data" | awk '{print $4}')
    fi

    # 헤더
    clear
    echo ""
    echo "  ${BLUE}🖥  ${hostname}${RESET}    ${CYAN}${now}${RESET}"
    echo "  ${CYAN}⏱  ${uptime_str}${RESET}" | sed 's/.*up /     uptime: /' | sed 's/, *load.*//'
    echo "  ${CYAN}📊 load avg:${RESET} ${load}"
    echo "  ${CYAN}─────────────────────────────────────────────────────────────────────${RESET}"

    # CPU/MEM/DISK 바
    local cpu_bar mem_bar disk_bar cpu_c mem_c disk_c
    cpu_bar=$(_seongmin_bar "$cpu_pct" 12)
    mem_bar=$(_seongmin_bar "$mem_pct" 12)
    disk_bar=$(_seongmin_bar "$disk_pct" 12)
    cpu_c=$(_seongmin_bar_color "$cpu_pct")
    mem_c=$(_seongmin_bar_color "$mem_pct")
    disk_c=$(_seongmin_bar_color "$disk_pct")

    printf "  CPU:  ${cpu_c}%s${RESET} %3d%%\n" "$cpu_bar" "$cpu_pct"
    printf "  MEM:  ${mem_c}%s${RESET} %3d%%   %s / %s\n" "$mem_bar" "$mem_pct" "$mem_used" "$mem_total"
    printf "  DISK: ${disk_c}%s${RESET} %3d%%   %s 남음 (/)\n" "$disk_bar" "$disk_pct" "$disk_avail"
    echo ""

    # Docker
    if command -v docker &>/dev/null && docker info &>/dev/null; then
        local d_total d_unhealthy d_exited
        d_total=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
        d_unhealthy=$(docker ps --filter "health=unhealthy" -q 2>/dev/null | wc -l | tr -d ' ')
        d_exited=$(docker ps -a --filter "status=exited" -q 2>/dev/null | wc -l | tr -d ' ')
        local d_msg="  ${CYAN}🐳 Docker:${RESET} ${GREEN}${d_total}${RESET} running"
        (( d_unhealthy > 0 )) && d_msg+=", ${RED}${d_unhealthy} unhealthy ⚠️${RESET}"
        (( d_exited > 0 ))    && d_msg+=", ${YELLOW}${d_exited} exited${RESET}"
        echo "$d_msg"
    fi

    # Listening 포트
    local listen_str=""
    if _seongmin_is_macos; then
        listen_str=$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {n=split($9,a,":"); printf ":%s(%s) ", a[n], $1}' | tr ' ' '\n' | sort -u | tr '\n' ' ')
    else
        listen_str=$(ss -tlnpH 2>/dev/null | awk '{n=split($4,a,":"); printf ":%s ", a[n]}' | tr ' ' '\n' | sort -un | tr '\n' ' ')
    fi
    if [[ -n "$listen_str" ]]; then
        local truncated="${listen_str:0:90}"
        [[ ${#listen_str} -gt 90 ]] && truncated="${truncated}..."
        echo "  ${CYAN}🌐 Listen:${RESET} $truncated"
    fi
    echo ""

    # Top CPU/MEM
    echo "  ${CYAN}🔥 Top CPU 5${RESET}"
    if _seongmin_is_macos; then
        ps -Aro "pcpu,comm" 2>/dev/null | tail -n +2 | sort -rn | head -5 | \
            awk 'NF>=2 && $1+0 > 0 {pcpu=$1; $1=""; sub(/^ /,""); cmd=$0; sub(".*/","",cmd); if(length(cmd)>32) cmd=substr(cmd,1,32); printf "     %-32s  %5s%%\n", cmd, pcpu}'
    else
        ps -eo pcpu,comm --sort=-pcpu --no-headers 2>/dev/null | head -5 | \
            awk '$1+0 > 0 {printf "     %-32s  %5s%%\n", $2, $1}'
    fi
    echo ""
    echo "  ${CYAN}🔥 Top MEM 5${RESET}"
    if _seongmin_is_macos; then
        ps -Amo "rss,comm" 2>/dev/null | tail -n +2 | sort -rn | head -5 | \
            awk 'NF>=2 && $1+0 > 0 {rss=$1; $1=""; sub(/^ /,""); cmd=$0; sub(".*/","",cmd); if(length(cmd)>32) cmd=substr(cmd,1,32); printf "     %-32s  %.2fG\n", cmd, rss/1024/1024}'
    else
        ps -eo rss,comm --sort=-rss --no-headers 2>/dev/null | head -5 | \
            awk '{printf "     %-32s  %.2fG\n", $2, $1/1024/1024}'
    fi

    # OOM kills (Linux)
    if _seongmin_is_linux; then
        local oom_count
        oom_count=$(dmesg 2>/dev/null | grep -ciE "killed.*(out of memory|oom)" || echo 0)
        if (( oom_count > 0 )); then
            echo ""
            echo "  ${RED}🚨 OOM kill 감지: ${oom_count}건 (dmesg)${RESET}"
        fi
    fi

    echo ""
    echo "  ${CYAN}─────────────────────────────────────────────────────────────────────${RESET}"
}

# ═══════════════════════════════════════════════════════════════
# 2️⃣  헬스 체크 (dxk health)
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_health() {
    _seongmin_init_colors
    clear
    _seongmin_header "헬스 체크" "🩺"

    # 인터넷
    echo "${CYAN}🌐 인터넷 연결${RESET}"
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        echo "   ${GREEN}✅ DNS 서버 (8.8.8.8) 응답${RESET}"
    else
        echo "   ${RED}❌ DNS 서버 무응답${RESET}"
    fi
    if ping -c 1 -W 2 google.com &>/dev/null; then
        echo "   ${GREEN}✅ DNS 해석 정상${RESET}"
    else
        echo "   ${RED}❌ DNS 해석 실패${RESET}"
    fi
    echo ""

    # 디스크 임박 (실제 디스크만 — devfs/synthetic/simulator 제외)
    echo "${CYAN}💾 디스크 사용률 (90% 초과 중 실제 마운트만)${RESET}"
    local disk_warnings
    disk_warnings=$(df -h 2>/dev/null | awk 'NR>1 && $5+0 >= 90 {print}' | \
        grep -vE 'devfs|/System/Volumes|CoreSimulator|/private/var/vm|map auto_home|/run/user' || true)
    if [[ -n "$disk_warnings" ]]; then
        echo "$disk_warnings" | while IFS= read -r line; do
            echo "   ${RED}$line${RESET}"
        done
    else
        echo "   ${GREEN}✅ 모든 실 마운트 안전${RESET}"
    fi
    echo ""

    # SSL 인증서 만료 체크
    echo "${CYAN}🔒 SSL 인증서 만료${RESET}"
    local cert_file="$HOME/.zsh_menu/health_domains"
    if [[ ! -f "$cert_file" ]]; then
        mkdir -p "$HOME/.zsh_menu"
        cat > "$cert_file" <<'DEFAULT'
google.com
github.com
DEFAULT
        echo "   ${YELLOW}💡 도메인 목록 생성됨: ${cert_file}${RESET}"
        echo "   ${YELLOW}   원하는 도메인 추가 후 다시 실행하세요.${RESET}"
    else
        while IFS= read -r dom; do
            [[ -z "$dom" || "$dom" =~ ^# ]] && continue
            local exp_date
            exp_date=$(echo | timeout 3 openssl s_client -servername "$dom" -connect "$dom:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
            if [[ -z "$exp_date" ]]; then
                echo "   ${RED}❌ ${dom}: 연결 실패${RESET}"
                continue
            fi
            local exp_epoch now_epoch days_left
            if _seongmin_is_macos; then
                exp_epoch=$(date -j -f "%b %d %T %Y %Z" "$exp_date" +%s 2>/dev/null)
            else
                exp_epoch=$(date -d "$exp_date" +%s 2>/dev/null)
            fi
            now_epoch=$(date +%s)
            days_left=$(( (exp_epoch - now_epoch) / 86400 ))
            if (( days_left < 14 )); then
                echo "   ${RED}🚨 ${dom}: ${days_left}일 남음 (긴급!)${RESET}"
            elif (( days_left < 30 )); then
                echo "   ${YELLOW}⚠️  ${dom}: ${days_left}일 남음${RESET}"
            else
                echo "   ${GREEN}✅ ${dom}: ${days_left}일 남음${RESET}"
            fi
        done < "$cert_file"
    fi
    echo ""

    # systemd 실패 (Linux)
    if _seongmin_is_linux && command -v systemctl &>/dev/null; then
        echo "${CYAN}⚙️  systemd 실패 서비스${RESET}"
        local failed
        failed=$(systemctl --failed --no-legend 2>/dev/null | wc -l | tr -d ' ')
        if (( failed > 0 )); then
            echo "   ${RED}❌ ${failed}개 서비스 실패${RESET}"
            systemctl --failed --no-legend 2>/dev/null | head -5 | sed 's/^/      /'
        else
            echo "   ${GREEN}✅ 모든 서비스 정상${RESET}"
        fi
        echo ""
    fi

    # Docker 헬스
    if command -v docker &>/dev/null && docker info &>/dev/null; then
        echo "${CYAN}🐳 Docker 헬스${RESET}"
        local unhealthy
        unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null)
        if [[ -n "$unhealthy" ]]; then
            echo "   ${RED}❌ Unhealthy:${RESET}"
            echo "$unhealthy" | sed 's/^/      /'
        else
            echo "   ${GREEN}✅ 모든 컨테이너 healthy${RESET}"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# 3️⃣  프로세스 forensics (dxk pid <PID|name>)
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_pid() {
    _seongmin_init_colors
    local target="$1"
    if [[ -z "$target" ]]; then
        echo "${YELLOW}사용법: dxk pid <PID|name>${RESET}"
        return 1
    fi

    # name이면 pidof로 PID 찾기
    local pid
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        pid="$target"
    else
        if command -v pidof &>/dev/null; then
            pid=$(pidof "$target" | awk '{print $1}')
        fi
        [[ -z "$pid" ]] && pid=$(pgrep -f "$target" | head -1)
        if [[ -z "$pid" ]]; then
            echo "${RED}❌ '$target' 프로세스를 찾을 수 없어요.${RESET}"
            return 1
        fi
        echo "${CYAN}'$target' → PID $pid 매칭${RESET}"
        echo ""
    fi

    # 존재 확인
    if ! ps -p "$pid" &>/dev/null; then
        echo "${RED}❌ PID $pid 존재 안 함${RESET}"
        return 1
    fi

    echo "${BLUE}━━━ 프로세스 forensics: PID $pid ━━━${RESET}"
    echo ""

    # 1. 기본 정보
    echo "${CYAN}📋 기본 정보 (ps)${RESET}"
    ps -p "$pid" -o pid,ppid,user,start,etime,pcpu,pmem,rss,command 2>/dev/null | sed 's/^/   /'
    echo ""

    # 2. 명령행
    echo "${CYAN}💬 명령행${RESET}"
    if [[ -r "/proc/$pid/cmdline" ]]; then
        tr '\0' ' ' < "/proc/$pid/cmdline" | sed 's/^/   /'; echo ""
    else
        ps -p "$pid" -o command= 2>/dev/null | sed 's/^/   /'
    fi
    echo ""

    # 3. 작업 디렉토리
    echo "${CYAN}📁 작업 디렉토리 (cwd)${RESET}"
    if [[ -L "/proc/$pid/cwd" ]]; then
        readlink "/proc/$pid/cwd" | sed 's/^/   /'
    else
        lsof -p "$pid" -d cwd 2>/dev/null | tail -1 | awk '{print $NF}' | sed 's/^/   /'
    fi
    echo ""

    # 4. 환경 변수 (선택적)
    if [[ -r "/proc/$pid/environ" ]]; then
        echo "${CYAN}🌍 환경 변수${RESET}"
        tr '\0' '\n' < "/proc/$pid/environ" | head -10 | sed 's/^/   /'
        local total_env=$(tr '\0' '\n' < "/proc/$pid/environ" | wc -l | tr -d ' ')
        if (( total_env > 10 )); then
            echo "   ${YELLOW}... ($total_env개 중 10개만 표시)${RESET}"
        fi
        echo ""
    fi

    # 5. 리소스 한계
    if [[ -r "/proc/$pid/limits" ]]; then
        echo "${CYAN}🚧 리소스 한계 (limits)${RESET}"
        head -5 "/proc/$pid/limits" | sed 's/^/   /'
        echo ""
    elif _seongmin_is_macos; then
        echo "${CYAN}🚧 리소스 한계 (launchctl)${RESET}"
        ulimit -a | head -8 | sed 's/^/   /'
        echo ""
    fi

    # 6. 열린 파일/소켓 요약 (lsof)
    if command -v lsof &>/dev/null; then
        echo "${CYAN}🔓 열린 자원 (lsof 요약)${RESET}"
        local lsof_data
        lsof_data=$(lsof -p "$pid" 2>/dev/null)
        if [[ -n "$lsof_data" ]]; then
            local files_count tcp_count udp_count regfiles
            files_count=$(echo "$lsof_data" | wc -l | tr -d ' ')
            tcp_count=$(echo "$lsof_data" | grep -c "TCP")
            udp_count=$(echo "$lsof_data" | grep -c "UDP")
            regfiles=$(echo "$lsof_data" | awk '$5=="REG"' | wc -l | tr -d ' ')
            echo "   총 파일 디스크립터: $files_count"
            echo "   TCP 소켓:           $tcp_count"
            echo "   UDP 소켓:           $udp_count"
            echo "   일반 파일 (REG):    $regfiles"
            echo ""
            echo "   ${YELLOW}TCP 연결 (10개):${RESET}"
            echo "$lsof_data" | grep TCP | head -10 | awk '{print "      " $9, $10}'
        fi
        echo ""
    fi

    # 7. 자식 프로세스
    echo "${CYAN}👶 자식 프로세스${RESET}"
    if command -v pstree &>/dev/null; then
        pstree -p "$pid" 2>/dev/null | head -20 | sed 's/^/   /'
    else
        pgrep -P "$pid" | while read -r child; do
            ps -p "$child" -o pid,command 2>/dev/null | tail -1 | sed 's/^/   /'
        done
    fi
}

# 메뉴에서 호출 시
function _seongmin_senior_pid_menu() {
    _seongmin_init_colors
    clear
    _seongmin_header "프로세스 Forensics" "🔬"
    _seongmin_input "PID 또는 프로세스 이름" || { _seongmin_cancelled; return; }
    local tgt="$REPLY"
    echo ""
    _seongmin_senior_pid "$tgt"
    _seongmin_pause
}

# ═══════════════════════════════════════════════════════════════
# 4️⃣  네트워크 deep dive (시니어용)
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_network() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "Network Deep Dive (Senior)" "🌐"
        echo "  ${CYAN}[1]${RESET} 🚪 Listen 포트 + 프로세스 (ss/lsof)"
        echo "  ${CYAN}[2]${RESET} 📡 HTTP 타이밍 분석 (DNS/TCP/TLS/TTFB/Total)"
        echo "  ${CYAN}[3]${RESET} 🔒 SSL 인증서 체인 검증"
        echo "  ${CYAN}[4]${RESET} 🛣  mtr 네트워크 추적 (ping + traceroute 융합)"
        echo "  ${CYAN}[5]${RESET} 📦 tcpdump 프리셋 (port/host)"
        echo "  ${CYAN}[6]${RESET} 🌍 다중 호스트 ping (배치)"
        echo "  ${CYAN}[7]${RESET} 🧪 DNS 일관성 (NS 서버별 응답 비교)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "선택 > "
        read s
        case $s in
            1)
                clear
                echo "${CYAN}🚪 Listen 포트 + 프로세스${RESET}"
                if _seongmin_is_macos; then
                    lsof -nP -iTCP -sTCP:LISTEN | awk 'NR==1 || NR>1' | column -t | head -40
                else
                    ss -tlnpH 2>/dev/null || netstat -tlnp 2>/dev/null
                fi
                _seongmin_pause
                ;;
            2)
                clear
                echo -n "URL: "; read url
                [[ -z "$url" ]] && continue
                echo ""
                echo "${CYAN}📡 HTTP 타이밍 분석${RESET}"
                curl -w "\
DNS Lookup:    %{time_namelookup}s
TCP Connect:   %{time_connect}s
TLS Handshake: %{time_appconnect}s
TTFB:          %{time_starttransfer}s
Total:         %{time_total}s
Status:        %{http_code}
Size:          %{size_download} bytes
Speed:         %{speed_download} B/s
" -o /dev/null -s "$url"
                _seongmin_pause
                ;;
            3)
                clear
                echo -n "도메인 (예: github.com): "; read d
                [[ -z "$d" ]] && continue
                echo ""
                echo "${CYAN}🔒 SSL 인증서 체인${RESET}"
                echo | openssl s_client -servername "$d" -connect "$d":443 -showcerts 2>/dev/null \
                    | openssl x509 -noout -text 2>/dev/null | grep -E "Subject:|Issuer:|Not Before|Not After|DNS:" | head -20
                _seongmin_pause
                ;;
            4)
                clear
                echo -n "대상 (호스트): "; read h
                [[ -z "$h" ]] && continue
                if command -v mtr &>/dev/null; then
                    mtr -r -c 5 "$h"
                else
                    echo "${YELLOW}mtr 설치 필요: brew install mtr${RESET}"
                    echo "${CYAN}대신 traceroute 실행${RESET}"
                    traceroute "$h"
                fi
                _seongmin_pause
                ;;
            5)
                clear
                echo "${CYAN}📦 tcpdump 프리셋${RESET}"
                echo "  [1] port 80          [2] port 443"
                echo "  [3] 특정 host         [4] 특정 IP의 dst"
                echo -n "선택 > "; read tcho
                case $tcho in
                    1) sudo tcpdump -i any -nn 'port 80' -c 50 ;;
                    2) sudo tcpdump -i any -nn 'port 443' -c 50 ;;
                    3) echo -n "host: "; read h; sudo tcpdump -i any -nn "host $h" -c 50 ;;
                    4) echo -n "IP: "; read i; sudo tcpdump -i any -nn "dst $i" -c 50 ;;
                esac
                _seongmin_pause
                ;;
            6)
                clear
                echo "${CYAN}🌍 다중 호스트 ping${RESET}"
                echo "호스트들 (스페이스 구분, 예: google.com github.com):"
                read -r hosts
                for h in ${=hosts}; do
                    if ping -c 1 -W 2 "$h" &>/dev/null; then
                        local rtt
                        rtt=$(ping -c 1 -W 2 "$h" 2>/dev/null | awk -F'time=' '/time=/ {print $2; exit}')
                        echo "  ${GREEN}✅ $h${RESET}  $rtt"
                    else
                        echo "  ${RED}❌ $h${RESET}  no response"
                    fi
                done
                _seongmin_pause
                ;;
            7)
                clear
                echo -n "도메인: "; read d
                [[ -z "$d" ]] && continue
                echo "${CYAN}🧪 DNS 일관성 (3개 resolver 비교)${RESET}"
                for ns in 8.8.8.8 1.1.1.1 9.9.9.9; do
                    local result
                    result=$(dig @"$ns" +short "$d" | tr '\n' ' ')
                    printf "  ${YELLOW}@%-9s${RESET} %s\n" "$ns" "$result"
                done
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 5️⃣  로그 power tools
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_logs() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "로그 Power Tools" "📜"
        echo "  ${CYAN}[1]${RESET} 📰 journalctl 시간 필터 (Linux)"
        echo "  ${CYAN}[2]${RESET} 🔥 에러만 (priority=err) 최근 1h"
        echo "  ${CYAN}[3]${RESET} 📚 다중 파일 tail -F"
        echo "  ${CYAN}[4]${RESET} 📊 빈도 분석 (어떤 라인이 제일 많이?)"
        echo "  ${CYAN}[5]${RESET} 🎯 패턴 + 컨텍스트 (-C N)"
        echo "  ${CYAN}[6]${RESET} 🍎 macOS log show (시스템 로그)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "선택 > "; read s
        case $s in
            1)
                if ! command -v journalctl &>/dev/null; then
                    echo "${YELLOW}journalctl은 Linux 전용 (systemd)${RESET}"
                    _seongmin_pause; continue
                fi
                _seongmin_input "시간 (예: '1 hour ago')" "1 hour ago" || { _seongmin_cancelled; continue; }
                local since="$REPLY"
                _seongmin_input "단위 (예: nginx.service, 비우면 전체)" "" || { _seongmin_cancelled; continue; }
                local unit="$REPLY"
                if [[ -n "$unit" ]]; then
                    journalctl --since "$since" -u "$unit" --no-pager | tail -100
                else
                    journalctl --since "$since" --no-pager | tail -100
                fi
                _seongmin_pause
                ;;
            2)
                if command -v journalctl &>/dev/null; then
                    journalctl --since "1 hour ago" --priority=err --no-pager | tail -50
                else
                    echo "${YELLOW}macOS는 'log show --predicate ...' 사용${RESET}"
                    log show --last 1h --predicate 'eventMessage contains "error"' 2>/dev/null | tail -30
                fi
                _seongmin_pause
                ;;
            3)
                clear
                echo "tail할 파일들 (스페이스 구분):"
                read -r files
                [[ -z "$files" ]] && continue
                tail -F ${=files}
                ;;
            4)
                clear
                echo -n "분석할 로그 파일: "; read lf
                [[ ! -f "$lf" ]] && { echo "${RED}파일 없음${RESET}"; _seongmin_pause; continue; }
                echo ""
                echo "${CYAN}📊 가장 빈번한 라인 Top 20${RESET}"
                sort "$lf" | uniq -c | sort -rn | head -20
                _seongmin_pause
                ;;
            5)
                clear
                echo -n "파일: "; read f
                [[ ! -f "$f" ]] && continue
                echo -n "패턴: "; read p
                echo -n "컨텍스트 라인 수 (기본 3): "; read n
                [[ -z "$n" ]] && n=3
                grep -n -C "$n" --color=auto "$p" "$f" | head -100
                _seongmin_pause
                ;;
            6)
                if _seongmin_is_macos; then
                    echo "최근 5분 시스템 로그 (errors+faults):"
                    log show --last 5m --predicate 'messageType == 16 OR messageType == 17' 2>/dev/null | head -50
                else
                    echo "${YELLOW}macOS 전용${RESET}"
                fi
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 6️⃣  디스크/IO 분석
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_disk() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "Disk / IO 분석" "💾"
        echo "  ${CYAN}[1]${RESET} 📂 큰 디렉토리 Top 20 (du -sh)"
        echo "  ${CYAN}[2]${RESET} 📊 마운트 사용률 (df -h)"
        echo "  ${CYAN}[3]${RESET} 🔥 I/O 부하 (iostat -x 1)"
        echo "  ${CYAN}[4]${RESET} 🐳 Docker 디스크 사용 (system df -v)"
        echo "  ${CYAN}[5]${RESET} 🔍 N MB 이상 큰 파일 찾기"
        echo "  ${CYAN}[6]${RESET} 📜 큰 로그 파일 찾기 (/var/log)"
        echo "  ${CYAN}[7]${RESET} 🗑  디스크 청소 후보 안내"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "선택 > "; read s
        case $s in
            1)
                clear
                echo -n "분석할 경로 (기본: 현재): "; read p
                [[ -z "$p" ]] && p="."
                echo "${CYAN}📂 ${p} 큰 디렉토리 Top 20${RESET}"
                du -sh "$p"/* 2>/dev/null | sort -hr | head -20
                _seongmin_pause
                ;;
            2) clear; df -h | head -20; _seongmin_pause ;;
            3)
                if command -v iostat &>/dev/null; then
                    echo "${YELLOW}Ctrl+C로 종료${RESET}"
                    iostat -x 1
                else
                    echo "${YELLOW}iostat 미설치 (brew install sysstat)${RESET}"
                    _seongmin_pause
                fi
                ;;
            4)
                clear
                if docker info &>/dev/null; then
                    docker system df -v | head -50
                fi
                _seongmin_pause
                ;;
            5)
                clear
                echo -n "경로: "; read p
                [[ -z "$p" ]] && p="."
                echo -n "최소 크기 MB (기본 100): "; read mb
                [[ -z "$mb" ]] && mb=100
                find "$p" -type f -size +"${mb}"M 2>/dev/null | head -30 | while read -r f; do
                    local size_b
                    size_b=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null)
                    printf "  %s  %s\n" "$(_seongmin_human_bytes "$size_b")" "$f"
                done | sort -rh
                _seongmin_pause
                ;;
            6)
                clear
                echo "${CYAN}📜 /var/log 큰 파일${RESET}"
                if [[ -d /var/log ]]; then
                    sudo du -h /var/log/* 2>/dev/null | sort -hr | head -20
                fi
                _seongmin_pause
                ;;
            7)
                clear
                echo "${CYAN}🗑  청소 후보 (수동 확인 필수)${RESET}"
                echo ""
                echo "${YELLOW}1. node_modules 디렉토리:${RESET}"
                find . -name node_modules -type d -prune 2>/dev/null | head -5 | sed 's/^/   /'
                echo ""
                echo "${YELLOW}2. __pycache__ 디렉토리:${RESET}"
                find . -name __pycache__ -type d -prune 2>/dev/null | head -5 | sed 's/^/   /'
                echo ""
                if command -v docker &>/dev/null; then
                    echo "${YELLOW}3. Docker 빌드 캐시:${RESET}  docker builder prune"
                fi
                if command -v brew &>/dev/null; then
                    echo "${YELLOW}4. Homebrew 캐시:${RESET}  brew cleanup -s"
                fi
                if command -v npm &>/dev/null; then
                    echo "${YELLOW}5. npm 캐시:${RESET}  npm cache clean --force"
                fi
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 7️⃣  PostgreSQL 운영 진단 쿼리
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_db() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "PostgreSQL 운영 진단" "🐘"
        echo "  ${YELLOW}연결 정보 (env):${RESET}"
        echo "    PGHOST=${PGHOST:-localhost}  PGPORT=${PGPORT:-5432}"
        echo "    PGUSER=${PGUSER:-$USER}  PGDATABASE=${PGDATABASE:-postgres}"
        echo ""
        echo "  ${CYAN}[1]${RESET} 🏃 활성 쿼리 (pg_stat_activity)"
        echo "  ${CYAN}[2]${RESET} 🐌 슬로우 쿼리 Top 20 (pg_stat_statements)"
        echo "  ${CYAN}[3]${RESET} 📦 테이블 크기 Top 20"
        echo "  ${CYAN}[4]${RESET} 🔒 락 충돌"
        echo "  ${CYAN}[5]${RESET} 💉 idle in transaction (오래 걸린 트랜잭션)"
        echo "  ${CYAN}[6]${RESET} 🔌 연결 수 (DB별)"
        echo "  ${CYAN}[7]${RESET} 📊 캐시 적중률"
        echo "  ${CYAN}[8]${RESET} ⚰️  쿼리 종료 (PID 입력)"
        echo "  ${CYAN}[9]${RESET} 📋 쿼리들 클립보드로 복사 (실행 안 함)"
        echo "  ${CYAN}[0]${RESET} ⬅️  돌아가기"
        echo ""
        echo -n "선택 > "; read s

        local query=""
        case $s in
            1) query="SELECT pid, usename, state, wait_event_type, wait_event,
                     EXTRACT(EPOCH FROM now() - query_start)::int AS duration_s,
                     LEFT(query, 80) AS query
                     FROM pg_stat_activity
                     WHERE state != 'idle' AND pid != pg_backend_pid()
                     ORDER BY duration_s DESC LIMIT 20;" ;;
            2) query="SELECT LEFT(query, 80) AS query, calls,
                     ROUND(mean_exec_time::numeric, 2) AS mean_ms,
                     ROUND(total_exec_time::numeric, 2) AS total_ms
                     FROM pg_stat_statements
                     ORDER BY mean_exec_time DESC LIMIT 20;" ;;
            3) query="SELECT schemaname, relname,
                     pg_size_pretty(pg_total_relation_size(C.oid)) AS total,
                     pg_size_pretty(pg_relation_size(C.oid)) AS rel,
                     pg_size_pretty(pg_indexes_size(C.oid)) AS idx
                     FROM pg_class C
                     LEFT JOIN pg_namespace N ON N.oid = C.relnamespace
                     WHERE relkind='r' AND N.nspname NOT IN ('pg_catalog','information_schema')
                     ORDER BY pg_total_relation_size(C.oid) DESC LIMIT 20;" ;;
            4) query="SELECT pid, usename, locktype, mode, granted,
                     LEFT(query, 60) AS query
                     FROM pg_locks L JOIN pg_stat_activity A ON L.pid = A.pid
                     WHERE NOT granted
                     ORDER BY pid;" ;;
            5) query="SELECT pid, usename, state,
                     EXTRACT(EPOCH FROM now() - state_change)::int AS idle_s,
                     LEFT(query, 80)
                     FROM pg_stat_activity
                     WHERE state = 'idle in transaction'
                     ORDER BY idle_s DESC;" ;;
            6) query="SELECT datname, count(*) AS conns
                     FROM pg_stat_activity
                     GROUP BY datname ORDER BY conns DESC;" ;;
            7) query="SELECT datname,
                     ROUND(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS cache_hit_pct,
                     blks_hit, blks_read
                     FROM pg_stat_database
                     WHERE datname IS NOT NULL
                     ORDER BY blks_hit + blks_read DESC LIMIT 10;" ;;
            8)
                echo -n "종료할 PID: "; read kp
                [[ -z "$kp" ]] && continue
                if _seongmin_confirm_dangerous "SELECT pg_terminate_backend($kp)"; then
                    query="SELECT pg_terminate_backend($kp);"
                else
                    continue
                fi
                ;;
            9)
                clear
                cat <<'SQL_END' | (_seongmin_is_macos && pbcopy || tee)
-- 활성 쿼리
SELECT pid, usename, state, wait_event, query_start, LEFT(query,80)
FROM pg_stat_activity WHERE state != 'idle';

-- 슬로우 쿼리
SELECT LEFT(query,80), calls, mean_exec_time FROM pg_stat_statements
ORDER BY mean_exec_time DESC LIMIT 20;

-- 테이블 크기
SELECT relname, pg_size_pretty(pg_total_relation_size(oid))
FROM pg_class WHERE relkind='r' ORDER BY pg_total_relation_size(oid) DESC LIMIT 20;

-- 락 충돌
SELECT pid, locktype, mode, granted, LEFT(query,60)
FROM pg_locks JOIN pg_stat_activity USING(pid) WHERE NOT granted;
SQL_END
                _seongmin_is_macos && echo "${GREEN}✅ 쿼리들 클립보드 복사됨${RESET}"
                _seongmin_pause
                continue
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        if [[ -n "$query" ]]; then
            if ! command -v psql &>/dev/null; then
                echo "${RED}psql 미설치 — 쿼리만 출력합니다:${RESET}"
                echo "$query"
            else
                clear
                echo "${CYAN}실행할 쿼리:${RESET}"
                echo "$query" | head -10
                echo ""
                echo "${YELLOW}─── 결과 ───${RESET}"
                psql -c "$query" 2>&1 | head -40
            fi
            _seongmin_pause
        fi
    done
}

# ═══════════════════════════════════════════════════════════════
# 8️⃣  Kubernetes 운영 도구
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_k8s() {
    _seongmin_init_colors
    if ! command -v kubectl &>/dev/null; then
        echo "${RED}kubectl 미설치${RESET}"
        echo "${YELLOW}brew install kubectl${RESET}"
        _seongmin_pause
        return 1
    fi
    while true; do
        clear
        _seongmin_header "Kubernetes 운영" "⚓"
        local ctx ns
        ctx=$(kubectl config current-context 2>/dev/null)
        ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        [[ -z "$ns" ]] && ns="default"
        echo "  ${YELLOW}현재 컨텍스트:${RESET} ${GREEN}${ctx}${RESET}  ${YELLOW}네임스페이스:${RESET} ${GREEN}${ns}${RESET}"
        echo ""
        echo "  ${CYAN}[1]${RESET} 🔄 컨텍스트 전환"
        echo "  ${CYAN}[2]${RESET} 📂 네임스페이스 전환"
        echo "  ${CYAN}[3]${RESET} 📦 Pod 상태 (재시작/나이/상태)"
        echo "  ${CYAN}[4]${RESET} 📊 Pod 자원 사용 (top pods)"
        echo "  ${CYAN}[5]${RESET} 🚨 Pod 왜 죽었지? (events + describe + logs)"
        echo "  ${CYAN}[6]${RESET} 🔍 ConfigMap/Secret diff"
        echo "  ${CYAN}[7]${RESET} 📜 모든 events (최근)"
        echo "  ${CYAN}[8]${RESET} 🚪 Service → Endpoint 매핑"
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "선택 > "; read s
        case $s in
            1)
                kubectl config get-contexts
                echo -n "전환할 컨텍스트: "; read c
                [[ -n "$c" ]] && kubectl config use-context "$c"
                _seongmin_pause
                ;;
            2)
                kubectl get ns
                echo -n "전환할 네임스페이스: "; read n
                [[ -n "$n" ]] && kubectl config set-context --current --namespace="$n"
                _seongmin_pause
                ;;
            3)
                clear
                kubectl get pods -o custom-columns="NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,AGE:.metadata.creationTimestamp,IMAGE:.spec.containers[*].image"
                _seongmin_pause
                ;;
            4)
                kubectl top pods --containers 2>&1 | head -30
                _seongmin_pause
                ;;
            5)
                kubectl get pods
                echo -n "분석할 Pod 이름: "; read p
                [[ -z "$p" ]] && continue
                echo "${CYAN}━━━ describe ━━━${RESET}"
                kubectl describe pod "$p" | head -50
                echo "${CYAN}━━━ events ━━━${RESET}"
                kubectl get events --field-selector involvedObject.name="$p" --sort-by='.lastTimestamp' | tail -10
                echo "${CYAN}━━━ logs (last 50) ━━━${RESET}"
                kubectl logs "$p" --tail=50 2>&1
                echo "${CYAN}━━━ logs --previous (이전 컨테이너) ━━━${RESET}"
                kubectl logs "$p" --previous --tail=20 2>&1 | head -20
                _seongmin_pause
                ;;
            6)
                kubectl get cm,secret
                echo -n "kind/name 1: "; read t1
                echo -n "kind/name 2: "; read t2
                diff <(kubectl get "$t1" -o yaml) <(kubectl get "$t2" -o yaml) | head -60
                _seongmin_pause
                ;;
            7)
                kubectl get events --sort-by='.lastTimestamp' | tail -30
                _seongmin_pause
                ;;
            8)
                kubectl get svc,endpoints | head -30
                _seongmin_pause
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 9️⃣  커널/시스템 사건 추적
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_kernel() {
    _seongmin_init_colors
    clear
    _seongmin_header "커널/시스템 이벤트" "🆘"

    # OOM
    echo "${CYAN}🚨 OOM Kill / Out of Memory${RESET}"
    if _seongmin_is_linux; then
        local oom
        oom=$(dmesg 2>/dev/null | grep -iE "killed process|out of memory|invoked oom-killer" | tail -10)
        if [[ -n "$oom" ]]; then
            echo "$oom" | sed 's/^/  /'
        else
            echo "  ${GREEN}✅ 최근 OOM 없음${RESET}"
        fi
    else
        echo "  ${YELLOW}macOS: log show --predicate 'eventMessage contains \"low memory\"'${RESET}"
        log show --last 1h --predicate 'eventMessage contains "memory pressure"' 2>/dev/null | head -5
    fi
    echo ""

    # 재부팅 이력
    echo "${CYAN}🔄 시스템 재부팅 이력${RESET}"
    if command -v who &>/dev/null; then
        who -b 2>/dev/null | sed 's/^/  /'
    fi
    if _seongmin_is_linux && command -v last &>/dev/null; then
        last -x reboot 2>/dev/null | head -5 | sed 's/^/  /'
    fi
    echo ""

    # 로그인 실패
    echo "${CYAN}🔐 인증/로그인 실패${RESET}"
    if _seongmin_is_linux; then
        if command -v lastb &>/dev/null; then
            sudo lastb 2>/dev/null | head -10 | sed 's/^/  /'
        elif command -v journalctl &>/dev/null; then
            journalctl _COMM=sshd --since "1 day ago" 2>/dev/null | grep -i "fail\|invalid" | tail -10 | sed 's/^/  /'
        fi
    else
        log show --last 1h --predicate 'subsystem == "com.apple.opendirectoryd"' 2>/dev/null | grep -i fail | head -5
    fi
    echo ""

    # systemd 실패
    if _seongmin_is_linux && command -v systemctl &>/dev/null; then
        echo "${CYAN}⚙️  systemd 실패 서비스${RESET}"
        systemctl --failed --no-legend 2>/dev/null | head -10 | sed 's/^/  /'
        echo ""
    fi

    # sudo 활동
    echo "${CYAN}👤 최근 sudo 사용${RESET}"
    if _seongmin_is_linux; then
        if command -v journalctl &>/dev/null; then
            journalctl _COMM=sudo --since "1 day ago" 2>/dev/null | tail -5 | sed 's/^/  /'
        else
            grep sudo /var/log/auth.log 2>/dev/null | tail -5 | sed 's/^/  /'
        fi
    else
        log show --last 1d --predicate 'process == "sudo"' 2>/dev/null | tail -5
    fi
}

# ═══════════════════════════════════════════════════════════════
# 🔟  Snippet Library (cheatsheet 관리)
# ═══════════════════════════════════════════════════════════════
function _seongmin_senior_snip() {
    _seongmin_init_colors
    local snip_dir="$HOME/.zsh_menu/snippets"
    mkdir -p "$snip_dir"

    # 초기 샘플 생성
    if [[ ! -f "$snip_dir/system.md" ]]; then
        cat > "$snip_dir/system.md" <<'SAMPLE'
# 시스템 운영 cheatsheet

## CPU/메모리/디스크
top -o cpu                                  # CPU 정렬
ps aux --sort=-%mem | head                  # 메모리 정렬
du -sh */ | sort -hr | head                 # 큰 디렉토리

## 네트워크
ss -tulpn                                   # 모던 netstat
lsof -i :PORT                               # 포트 점유 확인
curl -w '@curl-format.txt' URL              # 타이밍 분석

## 프로세스
pidof PROCESS                               # PID 찾기
pstree -p PID                               # 자식 트리
cat /proc/PID/environ | tr '\0' '\n'        # 환경변수
SAMPLE
    fi
    if [[ ! -f "$snip_dir/git.md" ]]; then
        cat > "$snip_dir/git.md" <<'SAMPLE'
# Git cheatsheet

git log --oneline --graph --decorate --all  # 전체 그래프
git reflog                                  # 작업 히스토리 (복구용)
git diff @{1.day.ago}..HEAD                 # 1일 전 대비
git log --since='1 week ago' --stat         # 최근 1주 통계
git bisect start && git bisect bad          # 이분 탐색
git stash list -p                           # stash 내용 미리보기
SAMPLE
    fi

    local cmd="$1"
    shift
    case "$cmd" in
        ""|search|find|s)
            if command -v fzf &>/dev/null; then
                # fzf 인터랙티브 검색
                local sel
                sel=$(grep -rn '' "$snip_dir" 2>/dev/null | grep -v "^[^:]*:[0-9]*:#" | grep -v '^$' | \
                      fzf --ansi --preview "echo {} | sed 's/^[^:]*://'" --preview-window=down:3:wrap)
                if [[ -n "$sel" ]]; then
                    # 명령어만 추출 (`#` 주석 제거)
                    local cmd_only
                    cmd_only=$(echo "$sel" | sed 's/^[^:]*:[0-9]*://' | sed 's/[[:space:]]*#.*//' )
                    echo "$cmd_only"
                    if _seongmin_is_macos; then
                        echo -n "$cmd_only" | pbcopy
                        echo "${GREEN}✅ 클립보드 복사됨${RESET}"
                    fi
                fi
            else
                local kw="$*"
                if [[ -z "$kw" ]]; then
                    # 전체 보여주기
                    for f in "$snip_dir"/*.md; do
                        echo "${CYAN}━━━ $(basename "$f" .md) ━━━${RESET}"
                        cat "$f"
                        echo ""
                    done
                else
                    grep -rn --color=auto -i "$kw" "$snip_dir" 2>/dev/null
                fi
            fi
            ;;
        list|ls)
            ls -la "$snip_dir"
            ;;
        edit|e)
            local cat="${1:-system}"
            ${EDITOR:-vi} "$snip_dir/${cat}.md"
            ;;
        add|a)
            local cat="${1:-system}"
            shift
            local entry="$*"
            if [[ -z "$entry" ]]; then
                echo -n "추가할 명령어: "; read entry
            fi
            [[ -z "$entry" ]] && return
            echo "$entry" >> "$snip_dir/${cat}.md"
            echo "${GREEN}✅ ${cat}.md에 추가됨${RESET}"
            ;;
        cat)
            local cat="${1:-system}"
            cat "$snip_dir/${cat}.md" 2>/dev/null || echo "${RED}없음${RESET}"
            ;;
        help|-h|--help)
            echo "${GREEN}📚 dxk snip — Snippet Library${RESET}"
            echo ""
            echo "${YELLOW}사용법:${RESET}"
            echo "  dxk snip [search] [키워드]    검색 (fzf 있으면 인터랙티브)"
            echo "  dxk snip list                 카테고리 파일 목록"
            echo "  dxk snip edit [카테고리]      에디터로 열기"
            echo "  dxk snip add [카테고리] [내용] 명령어 추가"
            echo "  dxk snip cat [카테고리]       카테고리 전체 보기"
            echo ""
            echo "${YELLOW}저장 위치:${RESET} $snip_dir"
            ;;
        *)
            # 기본: 키워드로 보고 검색
            local kw="$cmd $*"
            grep -rn --color=auto -i "$kw" "$snip_dir" 2>/dev/null
            ;;
    esac
}

# 메뉴에서 호출
function _seongmin_senior_snip_menu() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "Snippet Library" "📚"
        local snip_dir="$HOME/.zsh_menu/snippets"
        echo "  ${YELLOW}저장 위치:${RESET} $snip_dir"
        echo "  ${YELLOW}카테고리 파일:${RESET}"
        ls "$snip_dir" 2>/dev/null | sed 's/^/    /'
        echo ""
        echo "  ${CYAN}[1]${RESET} 🔍 검색 (fzf)"
        echo "  ${CYAN}[2]${RESET} 📋 키워드 검색"
        echo "  ${CYAN}[3]${RESET} ➕ 명령어 추가"
        echo "  ${CYAN}[4]${RESET} 📝 카테고리 편집 (vi)"
        echo "  ${CYAN}[5]${RESET} 📖 카테고리 전체 보기"
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "선택 > "; read s
        case $s in
            1) _seongmin_senior_snip search; _seongmin_pause ;;
            2)
                echo -n "키워드: "; read kw
                _seongmin_senior_snip search "$kw"
                _seongmin_pause
                ;;
            3)
                echo -n "카테고리 (system/git/...): "; read cat
                echo -n "명령어 (한 줄): "; read entry
                _seongmin_senior_snip add "$cat" "$entry"
                _seongmin_pause
                ;;
            4)
                echo -n "카테고리: "; read cat
                _seongmin_senior_snip edit "$cat"
                ;;
            5)
                echo -n "카테고리: "; read cat
                _seongmin_senior_snip cat "$cat"
                _seongmin_pause
                ;;
            0|q|Q) return ;;
        esac
    done
}


# ═══════════════════════════════════════════════════════════════
# 🐧 Linux 시스템 관리 (메뉴 18 — 신규 v2.2)
# ═══════════════════════════════════════════════════════════════

# 메인 디스패처
function _seongmin_linux() {
    _seongmin_init_colors
    _seongmin_detect_distro

    while true; do
        clear
        local emoji=$(_seongmin_distro_emoji)
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo "      ${emoji} Linux 시스템 관리 — DX Kit"
        echo "${PINK}✨ ============================================== ✨${RESET}"
        echo ""
        echo "  ${CYAN}감지된 시스템:${RESET} ${GREEN}${SEONGMIN_DISTRO_NAME} ${SEONGMIN_DISTRO_VERSION}${RESET} ${YELLOW}(${SEONGMIN_DISTRO_FAMILY} 계열)${RESET}"

        # 환경 경고
        if _seongmin_in_container; then
            echo "  ${RED}⚠️  컨테이너 환경 감지 — systemctl 등 일부 명령 동작 안 할 수 있음${RESET}"
        fi
        if _seongmin_in_wsl; then
            echo "  ${MAGENTA}💡 WSL 환경 감지${RESET}"
        fi
        if _seongmin_is_macos; then
            echo "  ${YELLOW}🍎 macOS — 명령어 실행 X, 참고 + 클립보드 복사만 가능${RESET}"
        fi
        echo ""

        echo "  ${YELLOW}[ 자동 — 이 시스템 ]${RESET}"
        echo "  ${CYAN}[1]${RESET} 📦 패키지 관리"
        echo "  ${CYAN}[2]${RESET} ⚙️  서비스 관리 (systemd/OpenRC)"
        echo "  ${CYAN}[3]${RESET} 🔥 방화벽"
        echo "  ${CYAN}[4]${RESET} 👤 사용자/그룹"
        echo "  ${CYAN}[5]${RESET} 📡 네트워크"
        echo "  ${CYAN}[6]${RESET} 📜 로그/저널"
        echo "  ${CYAN}[7]${RESET} 🛡️  보안 (SELinux/AppArmor)"
        echo "  ${CYAN}[8]${RESET} 🚀 부팅/커널"
        echo "  ${CYAN}[9]${RESET} 🗄  저장소 (repo) 관리"
        echo ""
        echo "  ${YELLOW}[ 참조 — OS 상관없이 ]${RESET}"
        echo "  ${CYAN}[10]${RESET} 📚 배포판별 cheatsheet"
        echo "  ${CYAN}[11]${RESET} 🔍 명령어 변환기 (apt → dnf 등)"
        echo ""
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "  선택 > "
        read sub

        case $sub in
            1)  _seongmin_linux_pkg ;;
            2)  _seongmin_linux_service ;;
            3)  _seongmin_linux_firewall ;;
            4)  _seongmin_linux_users ;;
            5)  _seongmin_linux_network ;;
            6)  _seongmin_linux_logs ;;
            7)  _seongmin_linux_security ;;
            8)  _seongmin_linux_boot ;;
            9)  _seongmin_linux_repo ;;
            10) _seongmin_linux_cheatsheet ;;
            11) _seongmin_linux_translator ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1 ;;
        esac
    done
}

# ───────────────────────────────────────────────────────────────
# 📦 1. 패키지 관리
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_pkg() {
    _seongmin_init_colors
    local fam="$SEONGMIN_DISTRO_FAMILY"
    local pm="알 수 없음"
    case "$fam" in
        debian) pm="apt" ;;
        rhel)   pm="dnf" ;;
        suse)   pm="zypper" ;;
        alpine) pm="apk" ;;
        arch)   pm="pacman" ;;
    esac

    while true; do
        clear
        _seongmin_header "패키지 관리 (${pm})" "📦"
        echo "  ${CYAN}[1]${RESET}  🔍 검색          (search)"
        echo "  ${CYAN}[2]${RESET}  📥 설치          (install)"
        echo "  ${CYAN}[3]${RESET}  🗑  제거          (remove)"
        echo "  ${CYAN}[4]${RESET}  ℹ️  정보          (info)"
        echo "  ${CYAN}[5]${RESET}  🆙 인덱스 업데이트 (refresh)"
        echo "  ${CYAN}[6]${RESET}  🚀 전체 업그레이드 (upgrade)"
        echo "  ${CYAN}[7]${RESET}  🧐 파일 → 어느 패키지가 소유?"
        echo "  ${CYAN}[8]${RESET}  📋 패키지 → 설치한 파일 목록"
        echo "  ${CYAN}[9]${RESET}  🧹 캐시 정리"
        echo "  ${CYAN}[10]${RESET} 📊 설치된 패키지 수"
        echo "  ${CYAN}[0]${RESET}  ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case $s in
            1)
                _seongmin_input "검색할 패키지 이름" || { _seongmin_cancelled; continue; }
                local p="$REPLY"
                case "$fam" in
                    debian) cmd="apt search $p" ;;
                    rhel)   cmd="dnf search $p" ;;
                    suse)   cmd="zypper se $p" ;;
                    alpine) cmd="apk search $p" ;;
                    arch)   cmd="pacman -Ss $p" ;;
                    *)      cmd="# 알 수 없는 distro: 검색 명령 없음" ;;
                esac
                ;;
            2)
                _seongmin_input "설치할 패키지 이름" || { _seongmin_cancelled; continue; }
                local p="$REPLY"
                case "$fam" in
                    debian) cmd="sudo apt install -y $p" ;;
                    rhel)   cmd="sudo dnf install -y $p" ;;
                    suse)   cmd="sudo zypper install -y $p" ;;
                    alpine) cmd="sudo apk add $p" ;;
                    arch)   cmd="sudo pacman -S --noconfirm $p" ;;
                esac
                ;;
            3)
                _seongmin_input "제거할 패키지 이름" || { _seongmin_cancelled; continue; }
                local p="$REPLY"
                case "$fam" in
                    debian) cmd="sudo apt remove -y $p" ;;
                    rhel)   cmd="sudo dnf remove -y $p" ;;
                    suse)   cmd="sudo zypper rm -y $p" ;;
                    alpine) cmd="sudo apk del $p" ;;
                    arch)   cmd="sudo pacman -R --noconfirm $p" ;;
                esac
                if ! _seongmin_confirm_dangerous "$cmd"; then continue; fi
                ;;
            4)
                _seongmin_input "정보 볼 패키지 이름" || { _seongmin_cancelled; continue; }
                local p="$REPLY"
                case "$fam" in
                    debian) cmd="apt show $p" ;;
                    rhel)   cmd="dnf info $p" ;;
                    suse)   cmd="zypper info $p" ;;
                    alpine) cmd="apk info $p" ;;
                    arch)   cmd="pacman -Si $p" ;;
                esac
                ;;
            5)
                case "$fam" in
                    debian) cmd="sudo apt update" ;;
                    rhel)   cmd="sudo dnf check-update" ;;
                    suse)   cmd="sudo zypper ref" ;;
                    alpine) cmd="sudo apk update" ;;
                    arch)   cmd="sudo pacman -Sy" ;;
                esac
                ;;
            6)
                case "$fam" in
                    debian) cmd="sudo apt upgrade -y" ;;
                    rhel)   cmd="sudo dnf upgrade -y" ;;
                    suse)   cmd="sudo zypper up -y" ;;
                    alpine) cmd="sudo apk upgrade" ;;
                    arch)   cmd="sudo pacman -Su --noconfirm" ;;
                esac
                ;;
            7)
                _seongmin_input "파일 경로 (예: /usr/bin/ls)" || { _seongmin_cancelled; continue; }
                local f="$REPLY"
                case "$fam" in
                    debian) cmd="dpkg -S $f" ;;
                    rhel)   cmd="rpm -qf $f" ;;
                    suse)   cmd="rpm -qf $f" ;;
                    alpine) cmd="apk info -W $f" ;;
                    arch)   cmd="pacman -Qo $f" ;;
                esac
                ;;
            8)
                _seongmin_input "패키지 이름" || { _seongmin_cancelled; continue; }
                local p="$REPLY"
                case "$fam" in
                    debian) cmd="dpkg -L $p" ;;
                    rhel)   cmd="rpm -ql $p" ;;
                    suse)   cmd="rpm -ql $p" ;;
                    alpine) cmd="apk info -L $p" ;;
                    arch)   cmd="pacman -Ql $p" ;;
                esac
                ;;
            9)
                case "$fam" in
                    debian) cmd="sudo apt clean && sudo apt autoclean" ;;
                    rhel)   cmd="sudo dnf clean all" ;;
                    suse)   cmd="sudo zypper clean -a" ;;
                    alpine) cmd="sudo rm -rf /var/cache/apk/*" ;;
                    arch)   cmd="sudo pacman -Sc --noconfirm" ;;
                esac
                ;;
            10)
                case "$fam" in
                    debian) cmd="dpkg -l | grep '^ii' | wc -l" ;;
                    rhel)   cmd="rpm -qa | wc -l" ;;
                    suse)   cmd="rpm -qa | wc -l" ;;
                    alpine) cmd="apk list --installed | wc -l" ;;
                    arch)   cmd="pacman -Q | wc -l" ;;
                esac
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# ⚙️ 2. 서비스 관리 (systemd 위주, Alpine은 OpenRC)
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_service() {
    _seongmin_init_colors
    local is_openrc=0
    [[ "$SEONGMIN_DISTRO_FAMILY" == "alpine" ]] && is_openrc=1

    while true; do
        clear
        if (( is_openrc )); then
            _seongmin_header "서비스 관리 (OpenRC)" "⚙️"
            echo "  ${CYAN}[1]${RESET} 🟢 시작           (rc-service NAME start)"
            echo "  ${CYAN}[2]${RESET} 🔴 중지           (rc-service NAME stop)"
            echo "  ${CYAN}[3]${RESET} 🔄 재시작         (rc-service NAME restart)"
            echo "  ${CYAN}[4]${RESET} 🔍 상태           (rc-service NAME status)"
            echo "  ${CYAN}[5]${RESET} 🚀 부팅 시 시작   (rc-update add NAME default)"
            echo "  ${CYAN}[6]${RESET} 🚪 부팅 시 제거   (rc-update del NAME default)"
            echo "  ${CYAN}[7]${RESET} 📋 서비스 목록    (rc-service --list)"
        else
            _seongmin_header "서비스 관리 (systemd)" "⚙️"
            echo "  ${CYAN}[1]${RESET}  🟢 시작           (systemctl start)"
            echo "  ${CYAN}[2]${RESET}  🔴 중지           (systemctl stop)"
            echo "  ${CYAN}[3]${RESET}  🔄 재시작         (systemctl restart)"
            echo "  ${CYAN}[4]${RESET}  🔍 상태           (systemctl status)"
            echo "  ${CYAN}[5]${RESET}  🚀 부팅 시 시작   (systemctl enable)"
            echo "  ${CYAN}[6]${RESET}  🚪 부팅 시 제거   (systemctl disable)"
            echo "  ${CYAN}[7]${RESET}  📋 활성 서비스    (systemctl list-units)"
            echo "  ${CYAN}[8]${RESET}  ❌ 실패 서비스    (systemctl --failed)"
            echo "  ${CYAN}[9]${RESET}  📜 서비스 로그    (journalctl -u NAME -n 100)"
            echo "  ${CYAN}[10]${RESET} ⏱️  부팅 시간 분석 (systemd-analyze blame)"
            echo "  ${CYAN}[11]${RESET} 🎬 데몬 리로드    (systemctl daemon-reload)"
        fi
        echo "  ${CYAN}[0]${RESET}  ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        if (( is_openrc )); then
            case $s in
                1) _seongmin_input "시작할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo rc-service $REPLY start" ;;
                2) _seongmin_input "중지할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo rc-service $REPLY stop" ;;
                3) _seongmin_input "재시작할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo rc-service $REPLY restart" ;;
                4) _seongmin_input "상태 볼 서비스" || { _seongmin_cancelled; continue; }; cmd="rc-service $REPLY status" ;;
                5) _seongmin_input "부팅 시 시작할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo rc-update add $REPLY default" ;;
                6) _seongmin_input "제거할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo rc-update del $REPLY default" ;;
                7) cmd="rc-service --list" ;;
                0|q|Q) return ;;
                *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
            esac
        else
            case $s in
                1)  _seongmin_input "시작할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo systemctl start $REPLY" ;;
                2)  _seongmin_input "중지할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo systemctl stop $REPLY" ;;
                3)  _seongmin_input "재시작할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo systemctl restart $REPLY" ;;
                4)  _seongmin_input "상태 볼 서비스" || { _seongmin_cancelled; continue; }; cmd="systemctl status $REPLY" ;;
                5)  _seongmin_input "부팅 시 시작할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo systemctl enable --now $REPLY" ;;
                6)  _seongmin_input "제거할 서비스" || { _seongmin_cancelled; continue; }; cmd="sudo systemctl disable --now $REPLY" ;;
                7)  cmd="systemctl list-units --type=service --state=running" ;;
                8)  cmd="systemctl --failed" ;;
                9)  _seongmin_input "로그 볼 서비스" || { _seongmin_cancelled; continue; }; cmd="journalctl -u $REPLY -n 100 --no-pager" ;;
                10) cmd="systemd-analyze blame | head -20" ;;
                11) cmd="sudo systemctl daemon-reload" ;;
                0|q|Q) return ;;
                *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
            esac
        fi

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 🔥 3. 방화벽 (ufw / firewalld / iptables 자동 감지)
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_firewall() {
    _seongmin_init_colors
    # 어떤 방화벽이 깔려있는지 감지
    local fw="iptables"
    if command -v ufw &>/dev/null; then
        fw="ufw"
    elif command -v firewall-cmd &>/dev/null; then
        fw="firewalld"
    fi

    while true; do
        clear
        _seongmin_header "방화벽 (${fw})" "🔥"
        case "$fw" in
            ufw)
                echo "  ${CYAN}[1]${RESET} 🔍 상태 확인        (ufw status verbose)"
                echo "  ${CYAN}[2]${RESET} 🟢 활성화           (ufw enable)"
                echo "  ${CYAN}[3]${RESET} 🔴 비활성화         (ufw disable)"
                echo "  ${CYAN}[4]${RESET} ➕ 포트 허용         (ufw allow PORT)"
                echo "  ${CYAN}[5]${RESET} ➖ 포트 차단         (ufw deny PORT)"
                echo "  ${CYAN}[6]${RESET} 🗑  규칙 삭제         (ufw delete)"
                echo "  ${CYAN}[7]${RESET} 📋 번호 매긴 규칙    (ufw status numbered)"
                echo "  ${CYAN}[8]${RESET} 🔄 리셋 (모든 규칙 삭제)"
                ;;
            firewalld)
                echo "  ${CYAN}[1]${RESET} 🔍 상태             (firewall-cmd --state)"
                echo "  ${CYAN}[2]${RESET} 📋 활성 zone        (firewall-cmd --get-active-zones)"
                echo "  ${CYAN}[3]${RESET} ➕ 포트 허용 (영구)  (--add-port=PORT/tcp --permanent)"
                echo "  ${CYAN}[4]${RESET} ➖ 포트 제거 (영구)  (--remove-port)"
                echo "  ${CYAN}[5]${RESET} ➕ 서비스 허용       (--add-service=NAME)"
                echo "  ${CYAN}[6]${RESET} 🔄 reload (영구→적용)"
                echo "  ${CYAN}[7]${RESET} 📋 zone 상세        (--list-all)"
                echo "  ${CYAN}[8]${RESET} 🔁 firewalld 재시작 (systemctl restart)"
                ;;
            iptables)
                echo "  ${CYAN}[1]${RESET} 🔍 규칙 보기        (iptables -L -n -v)"
                echo "  ${CYAN}[2]${RESET} ➕ 포트 허용         (iptables -A INPUT -p tcp --dport PORT -j ACCEPT)"
                echo "  ${CYAN}[3]${RESET} 💾 규칙 저장         (iptables-save > /etc/iptables/rules.v4)"
                echo "  ${CYAN}[4]${RESET} 🗑  모든 규칙 삭제    (iptables -F)"
                ;;
        esac
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case "$fw" in
            ufw)
                case $s in
                    1) cmd="sudo ufw status verbose" ;;
                    2) cmd="sudo ufw enable" ;;
                    3) cmd="sudo ufw disable" ;;
                    4) _seongmin_input "허용할 포트 (예: 80, 80/tcp)" || { _seongmin_cancelled; continue; }; cmd="sudo ufw allow $REPLY" ;;
                    5) _seongmin_input "차단할 포트" || { _seongmin_cancelled; continue; }; cmd="sudo ufw deny $REPLY" ;;
                    6) _seongmin_input "삭제할 규칙 (예: 'allow 80/tcp')" || { _seongmin_cancelled; continue; }; cmd="sudo ufw delete $REPLY" ;;
                    7) cmd="sudo ufw status numbered" ;;
                    8) if _seongmin_confirm_dangerous "ufw reset"; then cmd="sudo ufw reset"; else continue; fi ;;
                    0|q|Q) return ;;
                    *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
                esac
                ;;
            firewalld)
                case $s in
                    1) cmd="sudo firewall-cmd --state" ;;
                    2) cmd="sudo firewall-cmd --get-active-zones" ;;
                    3)
                        _seongmin_input "포트 (예: 80, 443)" || { _seongmin_cancelled; continue; }
                        local p="$REPLY"
                        _seongmin_input "프로토콜" "tcp" || { _seongmin_cancelled; continue; }
                        cmd="sudo firewall-cmd --permanent --add-port=${p}/${REPLY} && sudo firewall-cmd --reload"
                        ;;
                    4)
                        _seongmin_input "포트" || { _seongmin_cancelled; continue; }
                        local p="$REPLY"
                        cmd="sudo firewall-cmd --permanent --remove-port=${p}/tcp && sudo firewall-cmd --reload"
                        ;;
                    5) _seongmin_input "서비스 (예: http, https, ssh)" || { _seongmin_cancelled; continue; }; cmd="sudo firewall-cmd --permanent --add-service=$REPLY && sudo firewall-cmd --reload" ;;
                    6) cmd="sudo firewall-cmd --reload" ;;
                    7) cmd="sudo firewall-cmd --list-all" ;;
                    8) cmd="sudo systemctl restart firewalld" ;;
                    0|q|Q) return ;;
                    *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
                esac
                ;;
            iptables)
                case $s in
                    1) cmd="sudo iptables -L -n -v" ;;
                    2) _seongmin_input "포트" || { _seongmin_cancelled; continue; }; cmd="sudo iptables -A INPUT -p tcp --dport $REPLY -j ACCEPT" ;;
                    3) cmd="sudo iptables-save | sudo tee /etc/iptables/rules.v4" ;;
                    4) if _seongmin_confirm_dangerous "iptables -F"; then cmd="sudo iptables -F"; else continue; fi ;;
                    0|q|Q) return ;;
                    *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
                esac
                ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 👤 4. 사용자/그룹 관리
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_users() {
    _seongmin_init_colors
    # sudo group 이름은 distro별 다름
    local sudo_group="sudo"
    case "$SEONGMIN_DISTRO_FAMILY" in
        rhel|suse) sudo_group="wheel" ;;
    esac

    while true; do
        clear
        _seongmin_header "사용자/그룹 관리" "👤"
        echo "  ${CYAN}[1]${RESET}  👤 사용자 추가             (useradd -m -s /bin/bash USER)"
        echo "  ${CYAN}[2]${RESET}  🗑  사용자 삭제             (userdel -r USER)"
        echo "  ${CYAN}[3]${RESET}  🔑 비밀번호 변경            (passwd USER)"
        echo "  ${CYAN}[4]${RESET}  🔒 계정 잠금                (usermod -L USER)"
        echo "  ${CYAN}[5]${RESET}  🔓 계정 잠금 해제            (usermod -U USER)"
        echo "  ${CYAN}[6]${RESET}  ➕ 그룹에 추가              (usermod -aG GROUP USER)"
        echo "  ${CYAN}[7]${RESET}  ➖ 그룹에서 제거            (gpasswd -d USER GROUP)"
        echo "  ${CYAN}[8]${RESET}  🛡  관리자 권한 부여 (${sudo_group})  (usermod -aG ${sudo_group} USER)"
        echo "  ${CYAN}[9]${RESET}  ℹ️  사용자 정보              (id / groups / getent)"
        echo "  ${CYAN}[10]${RESET} 📋 모든 사용자 목록         (cat /etc/passwd | awk)"
        echo "  ${CYAN}[11]${RESET} 📋 모든 그룹 목록           (cat /etc/group | awk)"
        echo "  ${CYAN}[12]${RESET} ⏰ 마지막 로그인            (last / lastlog)"
        echo "  ${CYAN}[0]${RESET}  ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case $s in
            1)
                _seongmin_input "사용자 이름" || { _seongmin_cancelled; continue; }
                cmd="sudo useradd -m -s /bin/bash $REPLY && sudo passwd $REPLY"
                ;;
            2)
                _seongmin_input "삭제할 사용자" || { _seongmin_cancelled; continue; }
                local u="$REPLY"
                if _seongmin_confirm_dangerous "userdel -r $u"; then cmd="sudo userdel -r $u"; else continue; fi
                ;;
            3) _seongmin_input "비밀번호 바꿀 사용자" || { _seongmin_cancelled; continue; }; cmd="sudo passwd $REPLY" ;;
            4) _seongmin_input "잠글 사용자" || { _seongmin_cancelled; continue; }; cmd="sudo usermod -L $REPLY" ;;
            5) _seongmin_input "잠금 해제할 사용자" || { _seongmin_cancelled; continue; }; cmd="sudo usermod -U $REPLY" ;;
            6)
                _seongmin_input "사용자" || { _seongmin_cancelled; continue; }
                local u="$REPLY"
                _seongmin_input "그룹" || { _seongmin_cancelled; continue; }
                cmd="sudo usermod -aG $REPLY $u"
                ;;
            7)
                _seongmin_input "사용자" || { _seongmin_cancelled; continue; }
                local u="$REPLY"
                _seongmin_input "그룹" || { _seongmin_cancelled; continue; }
                cmd="sudo gpasswd -d $u $REPLY"
                ;;
            8) _seongmin_input "관리자 권한 줄 사용자" || { _seongmin_cancelled; continue; }; cmd="sudo usermod -aG $sudo_group $REPLY" ;;
            9) _seongmin_input "정보 볼 사용자" || { _seongmin_cancelled; continue; }; cmd="id $REPLY && echo '---' && groups $REPLY && echo '---' && getent passwd $REPLY" ;;
            10) cmd="awk -F: '\$3>=1000 && \$1!=\"nobody\" {print \$1}' /etc/passwd" ;;
            11) cmd="awk -F: '{print \$1}' /etc/group | sort" ;;
            12) cmd="last | head -20" ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 📡 5. 네트워크
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_network() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "네트워크" "📡"
        echo "  ${CYAN}[1]${RESET}  📋 모든 IP 주소         (ip addr)"
        echo "  ${CYAN}[2]${RESET}  🛣️  라우팅 테이블         (ip route)"
        echo "  ${CYAN}[3]${RESET}  🌐 DNS 설정 보기         (cat /etc/resolv.conf)"
        echo "  ${CYAN}[4]${RESET}  🔌 인터페이스 목록       (ip link)"
        echo "  ${CYAN}[5]${RESET}  🟢 인터페이스 켜기       (ip link set X up)"
        echo "  ${CYAN}[6]${RESET}  🔴 인터페이스 끄기       (ip link set X down)"
        echo "  ${CYAN}[7]${RESET}  📊 네트워크 통계         (ss -s)"
        echo "  ${CYAN}[8]${RESET}  🚪 LISTEN 포트          (ss -tlnp)"
        echo "  ${CYAN}[9]${RESET}  📡 활성 연결            (ss -tunap)"
        case "$SEONGMIN_DISTRO_FAMILY" in
            debian) echo "  ${CYAN}[10]${RESET} 📝 netplan 적용         (netplan apply)" ;;
            rhel)   echo "  ${CYAN}[10]${RESET} 📝 NetworkManager 재시작 (systemctl restart NetworkManager)" ;;
            suse)   echo "  ${CYAN}[10]${RESET} 📝 wicked 다시 시작     (wicked ifreload all)" ;;
        esac
        echo "  ${CYAN}[11]${RESET} 🌍 외부 IP             (curl ifconfig.me)"
        echo "  ${CYAN}[0]${RESET}  ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case $s in
            1)  cmd="ip addr" ;;
            2)  cmd="ip route" ;;
            3)  cmd="cat /etc/resolv.conf" ;;
            4)  cmd="ip link" ;;
            5)  _seongmin_input "켤 인터페이스 (예: eth0)" || { _seongmin_cancelled; continue; }; cmd="sudo ip link set $REPLY up" ;;
            6)  _seongmin_input "끌 인터페이스" || { _seongmin_cancelled; continue; }; cmd="sudo ip link set $REPLY down" ;;
            7)  cmd="ss -s" ;;
            8)  cmd="sudo ss -tlnp" ;;
            9)  cmd="sudo ss -tunap" ;;
            10)
                case "$SEONGMIN_DISTRO_FAMILY" in
                    debian) cmd="sudo netplan apply" ;;
                    rhel)   cmd="sudo systemctl restart NetworkManager" ;;
                    suse)   cmd="sudo wicked ifreload all" ;;
                    *)      cmd="# 네트워크 재시작 명령은 distro별 다름" ;;
                esac
                ;;
            11) cmd="curl -s ifconfig.me && echo" ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 📜 6. 로그/저널
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_logs() {
    _seongmin_init_colors
    # distro별 시스템 로그 파일
    local syslog="/var/log/syslog"
    local authlog="/var/log/auth.log"
    case "$SEONGMIN_DISTRO_FAMILY" in
        rhel|suse) syslog="/var/log/messages"; authlog="/var/log/secure" ;;
        alpine) syslog="/var/log/messages"; authlog="/var/log/messages" ;;
    esac

    while true; do
        clear
        _seongmin_header "로그/저널" "📜"
        echo "  ${YELLOW}[ systemd journal ]${RESET}"
        echo "  ${CYAN}[1]${RESET}  📜 최근 로그              (journalctl -xe)"
        echo "  ${CYAN}[2]${RESET}  🔥 에러만 (1시간)         (journalctl -p err --since \"1 hour ago\")"
        echo "  ${CYAN}[3]${RESET}  🔍 서비스별              (journalctl -u NAME)"
        echo "  ${CYAN}[4]${RESET}  📡 실시간 follow         (journalctl -f)"
        echo "  ${CYAN}[5]${RESET}  📅 시간 범위 + 단위      (journalctl --since/-u)"
        echo "  ${CYAN}[6]${RESET}  💾 디스크 사용량         (journalctl --disk-usage)"
        echo "  ${CYAN}[7]${RESET}  🧹 오래된 로그 정리      (journalctl --vacuum-time=7d)"
        echo ""
        echo "  ${YELLOW}[ 전통 로그 파일 ]${RESET}"
        echo "  ${CYAN}[8]${RESET}  📜 시스템 로그           (tail -f ${syslog})"
        echo "  ${CYAN}[9]${RESET}  🔐 인증 로그             (tail -f ${authlog})"
        echo "  ${CYAN}[10]${RESET} 🔍 dmesg (커널 메시지)   (dmesg -T)"
        echo "  ${CYAN}[0]${RESET}  ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case $s in
            1)  cmd="journalctl -xe --no-pager | tail -100" ;;
            2)  cmd="journalctl -p err --since \"1 hour ago\" --no-pager" ;;
            3)  _seongmin_input "서비스 이름" || { _seongmin_cancelled; continue; }; cmd="journalctl -u $REPLY --no-pager | tail -100" ;;
            4)  cmd="journalctl -f" ;;
            5)
                _seongmin_input "기간 (예: '1 hour ago')" "1 hour ago" || { _seongmin_cancelled; continue; }
                local since="$REPLY"
                _seongmin_input "서비스 (비우면 전체)" "" || { _seongmin_cancelled; continue; }
                if [[ -n "$REPLY" ]]; then
                    cmd="journalctl --since \"$since\" -u $REPLY --no-pager | tail -100"
                else
                    cmd="journalctl --since \"$since\" --no-pager | tail -100"
                fi
                ;;
            6)  cmd="journalctl --disk-usage" ;;
            7)
                _seongmin_input "보관 기간 (예: 7d, 1month)" "7d" || { _seongmin_cancelled; continue; }
                cmd="sudo journalctl --vacuum-time=$REPLY"
                ;;
            8)  cmd="sudo tail -f $syslog" ;;
            9)  cmd="sudo tail -f $authlog" ;;
            10) cmd="dmesg -T | tail -50" ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 🛡 7. 보안 (SELinux / AppArmor 자동 감지)
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_security() {
    _seongmin_init_colors
    local sec="none"
    if command -v getenforce &>/dev/null && getenforce &>/dev/null; then
        sec="selinux"
    elif command -v aa-status &>/dev/null; then
        sec="apparmor"
    fi

    while true; do
        clear
        _seongmin_header "보안 (${sec})" "🛡"
        case "$sec" in
            selinux)
                echo "  ${CYAN}[1]${RESET} 🔍 모드 확인          (getenforce)"
                echo "  ${CYAN}[2]${RESET} 📊 상세 상태          (sestatus)"
                echo "  ${CYAN}[3]${RESET} 🟡 임시 Permissive   (setenforce 0)"
                echo "  ${CYAN}[4]${RESET} 🔴 임시 Enforcing    (setenforce 1)"
                echo "  ${CYAN}[5]${RESET} 📂 파일 컨텍스트     (ls -Z PATH)"
                echo "  ${CYAN}[6]${RESET} 🔧 컨텍스트 복구     (restorecon -Rv PATH)"
                echo "  ${CYAN}[7]${RESET} 🔍 거부 로그         (ausearch -m AVC -ts recent)"
                echo "  ${CYAN}[8]${RESET} ✏️  영구 Disable 설정 (/etc/selinux/config 편집)"
                ;;
            apparmor)
                echo "  ${CYAN}[1]${RESET} 🔍 상태             (aa-status)"
                echo "  ${CYAN}[2]${RESET} 📋 프로파일 목록    (aa-status --json)"
                echo "  ${CYAN}[3]${RESET} ▶️  Enforce 모드     (aa-enforce PROFILE)"
                echo "  ${CYAN}[4]${RESET} ⏸️  Complain 모드    (aa-complain PROFILE)"
                echo "  ${CYAN}[5]${RESET} 📜 로그 확인        (dmesg | grep -i apparmor)"
                echo "  ${CYAN}[6]${RESET} 🔁 service 재시작   (systemctl restart apparmor)"
                ;;
            none)
                echo "  ${YELLOW}이 시스템에는 SELinux/AppArmor가 활성화되지 않았습니다.${RESET}"
                echo ""
                echo "  ${CYAN}[1]${RESET} 📚 SELinux 안내"
                echo "  ${CYAN}[2]${RESET} 📚 AppArmor 안내"
                ;;
        esac
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case "$sec" in
            selinux)
                case $s in
                    1) cmd="getenforce" ;;
                    2) cmd="sestatus" ;;
                    3) cmd="sudo setenforce 0" ;;
                    4) cmd="sudo setenforce 1" ;;
                    5) _seongmin_input "경로" || { _seongmin_cancelled; continue; }; cmd="ls -Z $REPLY" ;;
                    6) _seongmin_input "복구할 경로" || { _seongmin_cancelled; continue; }; cmd="sudo restorecon -Rv $REPLY" ;;
                    7) cmd="sudo ausearch -m AVC -ts recent | tail -50" ;;
                    8) cmd="sudo \${EDITOR:-vi} /etc/selinux/config" ;;
                    0|q|Q) return ;;
                    *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
                esac
                ;;
            apparmor)
                case $s in
                    1) cmd="sudo aa-status" ;;
                    2) cmd="sudo aa-status --json | python3 -m json.tool 2>/dev/null || sudo aa-status --json" ;;
                    3) _seongmin_input "프로파일 경로" || { _seongmin_cancelled; continue; }; cmd="sudo aa-enforce $REPLY" ;;
                    4) _seongmin_input "프로파일 경로" || { _seongmin_cancelled; continue; }; cmd="sudo aa-complain $REPLY" ;;
                    5) cmd="dmesg | grep -i apparmor | tail -30" ;;
                    6) cmd="sudo systemctl restart apparmor" ;;
                    0|q|Q) return ;;
                    *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
                esac
                ;;
            none)
                case $s in
                    1) echo "${CYAN}SELinux는 RHEL/Rocky/CentOS/Fedora 기본. dnf install selinux-policy 로 활성${RESET}"; _seongmin_pause; continue ;;
                    2) echo "${CYAN}AppArmor는 Ubuntu/SUSE 기본. apt install apparmor apparmor-utils 로 활성${RESET}"; _seongmin_pause; continue ;;
                    0|q|Q) return ;;
                esac
                ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 🚀 8. 부팅/커널
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_boot() {
    _seongmin_init_colors
    # GRUB 재생성 명령은 distro별 다름
    local grub_regen=""
    case "$SEONGMIN_DISTRO_FAMILY" in
        debian) grub_regen="sudo update-grub" ;;
        rhel|suse) grub_regen="sudo grub2-mkconfig -o /boot/grub2/grub.cfg" ;;
        arch) grub_regen="sudo grub-mkconfig -o /boot/grub/grub.cfg" ;;
        alpine) grub_regen="# Alpine은 syslinux/extlinux 주로 사용 (GRUB 아님)" ;;
    esac

    while true; do
        clear
        _seongmin_header "부팅/커널" "🚀"
        echo "  ${YELLOW}[ 시스템 정보 ]${RESET}"
        echo "  ${CYAN}[1]${RESET}  🔍 커널 버전         (uname -r)"
        echo "  ${CYAN}[2]${RESET}  📊 시스템 정보       (uname -a)"
        echo "  ${CYAN}[3]${RESET}  ⏱️  부팅 시간         (uptime, who -b)"
        echo ""
        echo "  ${YELLOW}[ systemd 분석 ]${RESET}"
        echo "  ${CYAN}[4]${RESET}  ⏱  부팅 시간 분석    (systemd-analyze)"
        echo "  ${CYAN}[5]${RESET}  🐌 느린 서비스 Top   (systemd-analyze blame)"
        echo "  ${CYAN}[6]${RESET}  🔗 cri-chain         (systemd-analyze critical-chain)"
        echo ""
        echo "  ${YELLOW}[ 커널 모듈 ]${RESET}"
        echo "  ${CYAN}[7]${RESET}  📋 로드된 모듈       (lsmod)"
        echo "  ${CYAN}[8]${RESET}  ℹ️  모듈 정보         (modinfo)"
        echo "  ${CYAN}[9]${RESET}  ➕ 모듈 로드          (modprobe)"
        echo "  ${CYAN}[10]${RESET} ➖ 모듈 언로드        (modprobe -r)"
        echo ""
        echo "  ${YELLOW}[ GRUB ]${RESET}"
        echo "  ${CYAN}[11]${RESET} 🔄 GRUB 재생성       (${grub_regen:-distro별 다름})"
        echo "  ${CYAN}[12]${RESET} ✏️  GRUB 설정 편집    (\${EDITOR:-vi} /etc/default/grub)"
        echo ""
        echo "  ${YELLOW}[ 설치된 커널 ]${RESET}"
        echo "  ${CYAN}[13]${RESET} 📋 설치된 커널 목록"
        echo "  ${CYAN}[0]${RESET}  ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case $s in
            1)  cmd="uname -r" ;;
            2)  cmd="uname -a" ;;
            3)  cmd="uptime && echo --- && who -b" ;;
            4)  cmd="systemd-analyze" ;;
            5)  cmd="systemd-analyze blame | head -20" ;;
            6)  cmd="systemd-analyze critical-chain" ;;
            7)  cmd="lsmod | head -30" ;;
            8)  _seongmin_input "모듈 이름" || { _seongmin_cancelled; continue; }; cmd="modinfo $REPLY" ;;
            9)  _seongmin_input "로드할 모듈" || { _seongmin_cancelled; continue; }; cmd="sudo modprobe $REPLY" ;;
            10) _seongmin_input "언로드할 모듈" || { _seongmin_cancelled; continue; }; cmd="sudo modprobe -r $REPLY" ;;
            11) cmd="$grub_regen" ;;
            12) cmd="sudo \${EDITOR:-vi} /etc/default/grub" ;;
            13)
                case "$SEONGMIN_DISTRO_FAMILY" in
                    debian) cmd="dpkg -l | grep linux-image" ;;
                    rhel|suse) cmd="rpm -qa | grep -E '^kernel'" ;;
                    arch) cmd="pacman -Q | grep -E '^linux'" ;;
                    alpine) cmd="apk list --installed | grep linux" ;;
                    *) cmd="# 설치된 커널 명령은 distro별 다름" ;;
                esac
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 🗄 9. 저장소 (Repo) 관리
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_repo() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "저장소 (Repo) 관리" "🗄"
        case "$SEONGMIN_DISTRO_FAMILY" in
            debian)
                echo "  ${CYAN}[1]${RESET} 📋 활성 저장소 목록    (apt-cache policy)"
                echo "  ${CYAN}[2]${RESET} 📂 sources.list 보기  (cat /etc/apt/sources.list)"
                echo "  ${CYAN}[3]${RESET} 📂 추가 저장소 폴더   (ls /etc/apt/sources.list.d/)"
                echo "  ${CYAN}[4]${RESET} ➕ PPA 추가           (add-apt-repository)"
                echo "  ${CYAN}[5]${RESET} ➖ PPA 제거           (add-apt-repository --remove)"
                echo "  ${CYAN}[6]${RESET} 🔑 GPG 키 임포트      (gpg --dearmor)"
                ;;
            rhel)
                echo "  ${CYAN}[1]${RESET} 📋 저장소 목록         (dnf repolist)"
                echo "  ${CYAN}[2]${RESET} 📂 저장소 파일들       (ls /etc/yum.repos.d/)"
                echo "  ${CYAN}[3]${RESET} ➕ 저장소 추가 (URL)   (dnf config-manager --add-repo)"
                echo "  ${CYAN}[4]${RESET} ✅ 저장소 활성화       (dnf config-manager --enable)"
                echo "  ${CYAN}[5]${RESET} ❌ 저장소 비활성화     (dnf config-manager --disable)"
                echo "  ${CYAN}[6]${RESET} 🔑 GPG 키 임포트       (rpm --import)"
                ;;
            suse)
                echo "  ${CYAN}[1]${RESET} 📋 저장소 목록         (zypper lr)"
                echo "  ${CYAN}[2]${RESET} ➕ 저장소 추가         (zypper ar URL ALIAS)"
                echo "  ${CYAN}[3]${RESET} 🗑  저장소 제거         (zypper rr ALIAS)"
                echo "  ${CYAN}[4]${RESET} ✅ 활성화               (zypper mr -e ALIAS)"
                echo "  ${CYAN}[5]${RESET} ❌ 비활성화             (zypper mr -d ALIAS)"
                echo "  ${CYAN}[6]${RESET} 🔄 새로고침             (zypper ref)"
                ;;
            alpine)
                echo "  ${CYAN}[1]${RESET} 📂 저장소 보기        (cat /etc/apk/repositories)"
                echo "  ${CYAN}[2]${RESET} ✏️  편집               (\${EDITOR:-vi} /etc/apk/repositories)"
                echo "  ${CYAN}[3]${RESET} 🔄 새로고침          (apk update)"
                ;;
            arch)
                echo "  ${CYAN}[1]${RESET} 📂 mirrorlist 보기    (cat /etc/pacman.d/mirrorlist)"
                echo "  ${CYAN}[2]${RESET} ✏️  pacman.conf 편집  (\${EDITOR:-vi} /etc/pacman.conf)"
                echo "  ${CYAN}[3]${RESET} 🔑 키 초기화          (pacman-key --init && --populate)"
                ;;
        esac
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        local cmd=""
        case "$SEONGMIN_DISTRO_FAMILY" in
            debian)
                case $s in
                    1) cmd="apt-cache policy" ;;
                    2) cmd="cat /etc/apt/sources.list" ;;
                    3) cmd="ls /etc/apt/sources.list.d/" ;;
                    4) _seongmin_input "PPA (예: ppa:kelleyk/emacs)" || { _seongmin_cancelled; continue; }; cmd="sudo add-apt-repository -y $REPLY && sudo apt update" ;;
                    5) _seongmin_input "제거할 PPA" || { _seongmin_cancelled; continue; }; cmd="sudo add-apt-repository --remove -y $REPLY" ;;
                    6) _seongmin_input "GPG 키 URL" || { _seongmin_cancelled; continue; }; cmd="curl -fsSL $REPLY | sudo gpg --dearmor -o /usr/share/keyrings/custom.gpg" ;;
                    0|q|Q) return ;;
                esac
                ;;
            rhel)
                case $s in
                    1) cmd="dnf repolist" ;;
                    2) cmd="ls /etc/yum.repos.d/" ;;
                    3) _seongmin_input "저장소 URL" || { _seongmin_cancelled; continue; }; cmd="sudo dnf config-manager --add-repo $REPLY" ;;
                    4) _seongmin_input "활성화할 저장소 ID" || { _seongmin_cancelled; continue; }; cmd="sudo dnf config-manager --enable $REPLY" ;;
                    5) _seongmin_input "비활성화할 저장소 ID" || { _seongmin_cancelled; continue; }; cmd="sudo dnf config-manager --disable $REPLY" ;;
                    6) _seongmin_input "GPG 키 URL" || { _seongmin_cancelled; continue; }; cmd="sudo rpm --import $REPLY" ;;
                    0|q|Q) return ;;
                esac
                ;;
            suse)
                case $s in
                    1) cmd="zypper lr" ;;
                    2)
                        _seongmin_input "URL" || { _seongmin_cancelled; continue; }
                        local u="$REPLY"
                        _seongmin_input "Alias" || { _seongmin_cancelled; continue; }
                        cmd="sudo zypper ar $u $REPLY"
                        ;;
                    3) _seongmin_input "제거할 Alias" || { _seongmin_cancelled; continue; }; cmd="sudo zypper rr $REPLY" ;;
                    4) _seongmin_input "활성화 Alias" || { _seongmin_cancelled; continue; }; cmd="sudo zypper mr -e $REPLY" ;;
                    5) _seongmin_input "비활성화 Alias" || { _seongmin_cancelled; continue; }; cmd="sudo zypper mr -d $REPLY" ;;
                    6) cmd="sudo zypper ref" ;;
                    0|q|Q) return ;;
                esac
                ;;
            alpine)
                case $s in
                    1) cmd="cat /etc/apk/repositories" ;;
                    2) cmd="sudo \${EDITOR:-vi} /etc/apk/repositories" ;;
                    3) cmd="sudo apk update" ;;
                    0|q|Q) return ;;
                esac
                ;;
            arch)
                case $s in
                    1) cmd="cat /etc/pacman.d/mirrorlist" ;;
                    2) cmd="sudo \${EDITOR:-vi} /etc/pacman.conf" ;;
                    3) cmd="sudo pacman-key --init && sudo pacman-key --populate" ;;
                    0|q|Q) return ;;
                esac
                ;;
            *) echo "${YELLOW}이 distro의 저장소 관리는 미구현${RESET}"; _seongmin_pause; return ;;
        esac

        [[ -n "$cmd" ]] && _seongmin_run_or_show "$cmd"
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 📚 10. Cheatsheet — 5개 distro 비교표
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_cheatsheet() {
    _seongmin_init_colors
    while true; do
        clear
        _seongmin_header "배포판별 Cheatsheet" "📚"
        echo "  ${CYAN}[1]${RESET} 📦 패키지 관리"
        echo "  ${CYAN}[2]${RESET} ⚙️  서비스 관리"
        echo "  ${CYAN}[3]${RESET} 🔥 방화벽"
        echo "  ${CYAN}[4]${RESET} 👤 사용자/그룹"
        echo "  ${CYAN}[5]${RESET} 📡 네트워크"
        echo "  ${CYAN}[6]${RESET} 📜 로그 위치"
        echo "  ${CYAN}[0]${RESET} ⬅️"
        echo ""
        echo -n "  선택 > "
        read s

        clear
        case $s in
            1)
                _seongmin_header "패키지 관리 비교" "📦"
                echo ""
                echo "  ${YELLOW}🔍 검색${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "apt search PKG"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "dnf search PKG"
                _seongmin_show_cmd "🦎 SUSE" "zypper se PKG"
                _seongmin_show_cmd "🏔 Alpine" "apk search PKG"
                _seongmin_show_cmd "🏛 Arch" "pacman -Ss PKG"
                echo ""
                echo "  ${YELLOW}📥 설치${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt install -y PKG"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "sudo dnf install -y PKG"
                _seongmin_show_cmd "🦎 SUSE" "sudo zypper install -y PKG"
                _seongmin_show_cmd "🏔 Alpine" "sudo apk add PKG"
                _seongmin_show_cmd "🏛 Arch" "sudo pacman -S --noconfirm PKG"
                echo ""
                echo "  ${YELLOW}🗑  제거${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt remove PKG"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "sudo dnf remove PKG"
                _seongmin_show_cmd "🦎 SUSE" "sudo zypper rm PKG"
                _seongmin_show_cmd "🏔 Alpine" "sudo apk del PKG"
                _seongmin_show_cmd "🏛 Arch" "sudo pacman -R PKG"
                echo ""
                echo "  ${YELLOW}🆙 업그레이드${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt update && sudo apt upgrade"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "sudo dnf upgrade"
                _seongmin_show_cmd "🦎 SUSE" "sudo zypper up"
                _seongmin_show_cmd "🏔 Alpine" "sudo apk update && sudo apk upgrade"
                _seongmin_show_cmd "🏛 Arch" "sudo pacman -Syu"
                echo ""
                echo "  ${YELLOW}🧐 파일 → 어느 패키지?${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "dpkg -S /path/to/file"
                _seongmin_show_cmd "🎩/🦎 RPM 계열" "rpm -qf /path/to/file"
                _seongmin_show_cmd "🏔 Alpine" "apk info -W /path/to/file"
                _seongmin_show_cmd "🏛 Arch" "pacman -Qo /path/to/file"
                ;;
            2)
                _seongmin_header "서비스 관리 비교" "⚙️"
                echo ""
                echo "  ${GREEN}대부분 systemd라 명령어 동일 (Alpine만 OpenRC 다름)${RESET}"
                echo ""
                echo "  ${YELLOW}🟢 시작 / 🔴 중지 / 🔄 재시작${RESET}"
                _seongmin_show_cmd "systemd" "sudo systemctl start|stop|restart NAME"
                _seongmin_show_cmd "🏔 Alpine OpenRC" "sudo rc-service NAME start|stop|restart"
                echo ""
                echo "  ${YELLOW}🚀 부팅 시 시작${RESET}"
                _seongmin_show_cmd "systemd" "sudo systemctl enable --now NAME"
                _seongmin_show_cmd "🏔 Alpine" "sudo rc-update add NAME default"
                echo ""
                echo "  ${YELLOW}📋 활성 서비스 목록${RESET}"
                _seongmin_show_cmd "systemd" "systemctl list-units --type=service"
                _seongmin_show_cmd "🏔 Alpine" "rc-service --list"
                ;;
            3)
                _seongmin_header "방화벽 비교" "🔥"
                echo ""
                echo "  ${YELLOW}🔍 상태${RESET}"
                _seongmin_show_cmd "🦊 Ubuntu (ufw)" "sudo ufw status verbose"
                _seongmin_show_cmd "🎩 RHEL (firewalld)" "sudo firewall-cmd --state"
                _seongmin_show_cmd "🦎 SUSE (firewalld)" "sudo firewall-cmd --list-all"
                _seongmin_show_cmd "Low-level" "sudo iptables -L -n -v"
                echo ""
                echo "  ${YELLOW}➕ 포트 80 허용${RESET}"
                _seongmin_show_cmd "🦊 ufw" "sudo ufw allow 80/tcp"
                _seongmin_show_cmd "🎩 firewalld" "sudo firewall-cmd --permanent --add-port=80/tcp && sudo firewall-cmd --reload"
                _seongmin_show_cmd "iptables" "sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
                echo ""
                echo "  ${YELLOW}💾 영구 적용${RESET}"
                _seongmin_show_cmd "🦊 ufw" "(자동)"
                _seongmin_show_cmd "🎩 firewalld" "--permanent 플래그 + --reload"
                _seongmin_show_cmd "iptables" "iptables-save > /etc/iptables/rules.v4"
                ;;
            4)
                _seongmin_header "사용자/그룹 비교" "👤"
                echo ""
                echo "  ${GREEN}대부분의 명령은 공통 (sudo 그룹만 distro별 다름)${RESET}"
                echo ""
                echo "  ${YELLOW}👤 사용자 추가${RESET}"
                _seongmin_show_cmd "공통" "sudo useradd -m -s /bin/bash USER && sudo passwd USER"
                _seongmin_show_cmd "🦊 Debian wrapper" "sudo adduser USER (인터랙티브)"
                echo ""
                echo "  ${YELLOW}🛡 관리자 권한 부여${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo usermod -aG sudo USER"
                _seongmin_show_cmd "🎩 RHEL/SUSE" "sudo usermod -aG wheel USER"
                _seongmin_show_cmd "🏔 Alpine" "sudo addgroup USER wheel"
                ;;
            5)
                _seongmin_header "네트워크 비교" "📡"
                echo ""
                echo "  ${YELLOW}📋 IP 주소 / 라우팅${RESET}"
                _seongmin_show_cmd "공통 (modern)" "ip addr / ip route / ss -tlnp"
                _seongmin_show_cmd "Legacy" "ifconfig / route -n / netstat -tlnp"
                echo ""
                echo "  ${YELLOW}📝 네트워크 설정 위치${RESET}"
                _seongmin_show_cmd "🦊 Ubuntu 18+" "/etc/netplan/*.yaml + sudo netplan apply"
                _seongmin_show_cmd "🦊 Debian" "/etc/network/interfaces"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "nmcli + /etc/NetworkManager/system-connections/"
                _seongmin_show_cmd "🦎 SUSE" "/etc/sysconfig/network/ifcfg-* + wicked"
                _seongmin_show_cmd "🏔 Alpine" "/etc/network/interfaces"
                ;;
            6)
                _seongmin_header "로그 파일 위치" "📜"
                echo ""
                echo "  ${YELLOW}📜 시스템 로그${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "/var/log/syslog"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "/var/log/messages"
                _seongmin_show_cmd "🦎 SUSE" "/var/log/messages"
                _seongmin_show_cmd "🏔 Alpine" "/var/log/messages"
                echo ""
                echo "  ${YELLOW}🔐 인증/sudo 로그${RESET}"
                _seongmin_show_cmd "🦊 Debian/Ubuntu" "/var/log/auth.log"
                _seongmin_show_cmd "🎩 RHEL/Rocky" "/var/log/secure"
                _seongmin_show_cmd "🦎 SUSE" "/var/log/messages"
                echo ""
                echo "  ${YELLOW}📡 systemd journal (대부분 공통)${RESET}"
                _seongmin_show_cmd "공통" "journalctl -xe / -u SERVICE / -f"
                _seongmin_show_cmd "디스크" "journalctl --disk-usage"
                ;;
            0|q|Q) return ;;
            *) echo "${RED}잘못된${RESET}"; sleep 1; continue ;;
        esac

        echo ""
        _seongmin_pause
    done
}

# ───────────────────────────────────────────────────────────────
# 🔍 11. 명령어 변환기
# ───────────────────────────────────────────────────────────────
function _seongmin_linux_translator() {
    _seongmin_init_colors
    clear
    _seongmin_header "명령어 변환기" "🔍"
    echo "${CYAN}한 distro 명령을 입력하면 모든 distro로 변환합니다.${RESET}"
    echo "${CYAN}예: apt install nginx, dnf upgrade, zypper se vim, apk add curl${RESET}"
    echo ""
    _seongmin_input "명령어" || { _seongmin_cancelled; return; }
    local input="$REPLY"

    # 첫 토큰: 패키지 매니저 식별
    local pm_token=$(echo "$input" | awk '{print $1}')
    local rest=$(echo "$input" | cut -d' ' -f2-)

    # 액션 식별 (install/remove/search/upgrade)
    local action=""
    local pkg=""
    case "$pm_token" in
        apt|apt-get)
            local act=$(echo "$rest" | awk '{print $1}')
            pkg=$(echo "$rest" | awk '{$1=""; print substr($0,2)}')
            case "$act" in
                install)         action="install" ;;
                remove|purge)    action="remove" ;;
                search)          action="search" ;;
                show)            action="info" ;;
                update)          action="refresh" ;;
                upgrade|dist-upgrade|full-upgrade) action="upgrade" ;;
                clean|autoclean) action="clean" ;;
            esac
            ;;
        dnf|yum)
            local act=$(echo "$rest" | awk '{print $1}')
            pkg=$(echo "$rest" | awk '{$1=""; print substr($0,2)}')
            case "$act" in
                install)            action="install" ;;
                remove|erase)       action="remove" ;;
                search)             action="search" ;;
                info)               action="info" ;;
                check-update)       action="refresh" ;;
                upgrade|update)     action="upgrade" ;;
                clean)              action="clean" ;;
            esac
            ;;
        zypper)
            local act=$(echo "$rest" | awk '{print $1}')
            pkg=$(echo "$rest" | awk '{$1=""; print substr($0,2)}')
            case "$act" in
                in|install)         action="install" ;;
                rm|remove)          action="remove" ;;
                se|search)          action="search" ;;
                info)               action="info" ;;
                ref|refresh)        action="refresh" ;;
                up|update|dup)      action="upgrade" ;;
                clean)              action="clean" ;;
            esac
            ;;
        apk)
            local act=$(echo "$rest" | awk '{print $1}')
            pkg=$(echo "$rest" | awk '{$1=""; print substr($0,2)}')
            case "$act" in
                add|install)        action="install" ;;
                del|remove)         action="remove" ;;
                search)             action="search" ;;
                info)               action="info" ;;
                update)             action="refresh" ;;
                upgrade)            action="upgrade" ;;
            esac
            ;;
        pacman)
            local act=$(echo "$rest" | awk '{print $1}')
            pkg=$(echo "$rest" | awk '{$1=""; print substr($0,2)}')
            case "$act" in
                -S|-Sy)             action="install" ;;
                -R|-Rs)             action="remove" ;;
                -Ss)                action="search" ;;
                -Si|-Q)             action="info" ;;
                -Sy)                action="refresh" ;;
                -Su|-Syu)           action="upgrade" ;;
                -Sc)                action="clean" ;;
            esac
            ;;
        *)
            echo "${YELLOW}⚠️  알 수 없는 패키지 매니저 토큰: '$pm_token'${RESET}"
            echo "${CYAN}지원: apt, dnf, yum, zypper, apk, pacman${RESET}"
            _seongmin_pause
            return
            ;;
    esac

    # 패키지 인자 정리
    pkg=$(echo "$pkg" | sed -E 's/^[[:space:]]*-[a-zA-Z]+[[:space:]]*//; s/^[[:space:]]+//; s/[[:space:]]+$//')

    if [[ -z "$action" ]]; then
        echo "${YELLOW}⚠️  액션을 식별 못 했습니다.${RESET}"
        echo "${CYAN}예시: apt install nginx, dnf upgrade${RESET}"
        _seongmin_pause
        return
    fi

    # 액션을 명령어로 변환
    echo ""
    echo "  ${GREEN}원본:${RESET} ${input}"
    echo "  ${GREEN}분석:${RESET} action=${action}, pkg=${pkg:-(없음)}"
    echo "  ${CYAN}─────────────────────────────────────────${RESET}"

    local p="${pkg:-PKG}"
    case "$action" in
        install)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt install -y $p"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "sudo dnf install -y $p"
            _seongmin_show_cmd "🦎 SUSE"          "sudo zypper install -y $p"
            _seongmin_show_cmd "🏔 Alpine"        "sudo apk add $p"
            _seongmin_show_cmd "🏛 Arch"          "sudo pacman -S --noconfirm $p"
            ;;
        remove)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt remove -y $p"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "sudo dnf remove -y $p"
            _seongmin_show_cmd "🦎 SUSE"          "sudo zypper rm -y $p"
            _seongmin_show_cmd "🏔 Alpine"        "sudo apk del $p"
            _seongmin_show_cmd "🏛 Arch"          "sudo pacman -R --noconfirm $p"
            ;;
        search)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "apt search $p"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "dnf search $p"
            _seongmin_show_cmd "🦎 SUSE"          "zypper se $p"
            _seongmin_show_cmd "🏔 Alpine"        "apk search $p"
            _seongmin_show_cmd "🏛 Arch"          "pacman -Ss $p"
            ;;
        info)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "apt show $p"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "dnf info $p"
            _seongmin_show_cmd "🦎 SUSE"          "zypper info $p"
            _seongmin_show_cmd "🏔 Alpine"        "apk info $p"
            _seongmin_show_cmd "🏛 Arch"          "pacman -Si $p"
            ;;
        refresh)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt update"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "sudo dnf check-update"
            _seongmin_show_cmd "🦎 SUSE"          "sudo zypper ref"
            _seongmin_show_cmd "🏔 Alpine"        "sudo apk update"
            _seongmin_show_cmd "🏛 Arch"          "sudo pacman -Sy"
            ;;
        upgrade)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt upgrade -y"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "sudo dnf upgrade -y"
            _seongmin_show_cmd "🦎 SUSE"          "sudo zypper up -y"
            _seongmin_show_cmd "🏔 Alpine"        "sudo apk upgrade"
            _seongmin_show_cmd "🏛 Arch"          "sudo pacman -Syu --noconfirm"
            ;;
        clean)
            _seongmin_show_cmd "🦊 Debian/Ubuntu" "sudo apt clean"
            _seongmin_show_cmd "🎩 RHEL/Rocky"    "sudo dnf clean all"
            _seongmin_show_cmd "🦎 SUSE"          "sudo zypper clean -a"
            _seongmin_show_cmd "🏔 Alpine"        "sudo rm -rf /var/cache/apk/*"
            _seongmin_show_cmd "🏛 Arch"          "sudo pacman -Sc --noconfirm"
            ;;
    esac

    echo ""
    if [[ "$SEONGMIN_DISTRO_FAMILY" != "macos" && "$SEONGMIN_DISTRO_FAMILY" != "unknown" ]]; then
        echo "  ${MAGENTA}💡 현재 시스템(${SEONGMIN_DISTRO_FAMILY})에 맞는 명령어로 실행하려면 [1] 메뉴 사용${RESET}"
    fi
    _seongmin_pause
}


# 단축 명령어 alias
# dxk = DX Kit (1순위)
# gg  = 레거시 호환 (계속 유지)
alias dxk="seongmin"
alias gg="seongmin"

# 🎨 예쁜 docker ps / images (개별 단축 명령)
alias dps="_seongmin_docker_ps_pretty"
alias dimg="_seongmin_docker_images_pretty"

# 🔧 시니어/운영 단축 명령
alias dash="_seongmin_senior_dash"
alias snip="_seongmin_senior_snip"

# 🐧 Linux 시스템 단축 명령 (단, 시작 시 distro 감지 한 번 하도록 wrapper)
linux() { _seongmin_detect_distro; _seongmin_linux "$@"; }
pkg()   { _seongmin_detect_distro; _seongmin_linux_pkg "$@"; }
svc()   { _seongmin_detect_distro; _seongmin_linux_service "$@"; }
fw()    { _seongmin_detect_distro; _seongmin_linux_firewall "$@"; }
cheat() { _seongmin_detect_distro; _seongmin_linux_cheatsheet "$@"; }
xlate() { _seongmin_detect_distro; _seongmin_linux_translator "$@"; }
