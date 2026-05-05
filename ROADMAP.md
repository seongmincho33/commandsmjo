# 🗺️ Seongmin's Dev Menu — 개선 로드맵

> 4663줄 menu.zsh의 깊이 있는 분석 결과와 단계별 개선 계획.
> 우선순위: ★★★ 즉시 / ★★ 다음 분기 / ★ 백로그

---

## 📊 한눈에 보기

| 단계 | 내용 | 상태 |
|---|---|---|
| **Phase 1** | 공통 인프라 + 최우선 누락(brew install 등) | 🟢 진행 중 |
| **Phase 2** | 카테고리별 보강 + 누락 메뉴 추가 | 🟡 일부 완료 |
| **Phase 3** | 모듈 분할 + 테스트 + i18n | ⚪ 백로그 |

---

## 🎯 Phase 1 — 즉시 개선 (★★★)

### 1.1 공통 인프라

- [x] **OS 분기 헬퍼** — `_seongmin_is_macos`, `_seongmin_is_linux`
- [x] **사전 환경 체크 헬퍼** — `_seongmin_require_cmd <cmd>`
- [x] **색상 변수 단일화** — `_seongmin_init_colors` 한 번 호출
- [x] **Breadcrumb 헤더** — `_seongmin_header "Docker > Container"`
- [x] **`gg --version`** — 메뉴 자체 버전 표시
- [x] **`gg --help`** — 통합 도움말 (직접 실행 + 메뉴)
- [x] **`gg search <키워드>`** — 메뉴 항목 검색 (fzf 있으면 활용)
- [x] **`gg update`** — 메뉴 자체 업데이트 (git pull)
- [x] **`NO_COLOR` 환경변수 존중** — 표준 관례
- [x] **`read -k 1` 메시지 통일** — "아무 키나 누르면 돌아갑니다"

### 1.2 누락 메뉴 항목 (최우선)

#### 🍺 Homebrew
- [x] `brew install <pkg>` — **핵심 누락**
- [x] `brew uninstall <pkg>`
- [x] `brew search <키워드>`
- [x] `brew info <pkg>`
- [x] `brew doctor`
- [x] `brew outdated`
- [x] `brew leaves` (최상위 패키지)
- [x] `brew bundle dump` (Brewfile 생성)

#### 🐍 Python
- [x] `uv` 자동 감지 + 사용 (pip 대체)
- [x] `pytest` 실행 메뉴
- [x] `ruff check` / `ruff format`
- [x] `__pycache__` / `.pyc` 정리
- [x] Jupyter 실행 (notebook/lab)
- [x] 메뉴 헤더에 활성 venv 표시

#### 🐙 Git
- [x] Conventional Commits prefix 선택 (feat/fix/docs/refactor/test/chore)
- [x] `gh pr create` 통합 (push 후 PR 생성)
- [x] `.gitignore` 템플릿 생성 (gitignore.io API)
- [x] 태그 관리 (생성/삭제/push)
- [x] commit amend (메시지 / 내용)

#### 🐳 Docker
- [x] **Docker daemon 사전 체크** (가장 흔한 에러)
- [x] 컨테이너 exec 빠른 진입
- [x] `docker logs -f --tail 100` 빠른 접근
- [x] `docker stats` 모니터링
- [x] Compose v1/v2 자동 감지

#### 🎨 Frontend
- [x] CRA deprecated 경고 추가
- [x] `bun create` 지원
- [x] Astro/Remix/Nuxt/SvelteKit 추가
- [x] 일상 명령(`dev`, `build`, `start`, `lint`, `test`)
- [x] 패키지 매니저 토글 (npm/yarn/pnpm/bun)
- [x] `node_modules` 정리/재설치

### 1.3 신규 카테고리 (★★★)

- [x] **🔐 SSH 키 관리** — keygen / add / copy-id / config 편집
- [x] **🌐 Network 진단** — ping / dig / netstat / lsof / curl
- [x] **🆕 새 프로젝트 시작** — mkdir + git + README + .gitignore + venv/package.json
- [x] **🆘 응급 처치** — 포트 충돌 / 디스크 가득 / Docker 죽음 등 상황별
- [x] **🧪 유틸 도구** — JSON / Base64 / UUID / URL encode / 비밀번호

### 1.4 시니어/SRE 모드 (v2.1, ★★)

- [x] **🚨 운영 대시보드** (`dxk dash`)
- [x] **🩺 헬스 체크** (`dxk health`) — SSL 만료/디스크/systemd
- [x] **🔬 프로세스 forensics** (`dxk pid`)
- [x] **🌐 Network deep dive** — ss/tcpdump/mtr/curl-w/cert chain
- [x] **📜 Log power tools** — journalctl/freq analysis
- [x] **💾 Disk/IO 분석** — du/iostat/docker df
- [x] **🐘 PostgreSQL 진단** — 활성/슬로우/락 쿼리
- [x] **⚓ Kubernetes 운영** — ctx/ns/why-fail
- [x] **🆘 커널 이벤트** — OOM/auth fail/reboot
- [x] **📚 Snippet Library** (`dxk snip`)

---

## 📋 Phase 2 — 다음 분기 (★★)

### 2.1 카테고리 보강

#### 🔴 Redis
- [ ] Linux systemd 분기 (`systemctl start redis`)
- [ ] `PING` 빠른 연결 테스트
- [ ] redis-cli 단축 명령 (KEYS / DBSIZE / INFO / FLUSHDB)
- [ ] 백업/복원 (BGSAVE)

#### ☕ Java
- [ ] SDKMAN 지원 (Linux용)
- [ ] Spring Initializr 통합
- [ ] JAR 실행 + JVM 옵션 가이드
- [ ] Gradle 확장 (test/dependencies/tasks/wrapper)
- [ ] Maven 확장 (dependency:tree/package/test)

#### 🐚 Shell
- [ ] PATH 예쁘게 보기 (`tr ':' '\n'`)
- [ ] alias / env / history 검색
- [ ] dotfile 백업/복원
- [ ] oh-my-zsh / starship 관리
- [ ] `chsh` 로그인 셸 변경

#### 🔍 버전 확인
- [ ] Go / Rust / Ruby / PHP / Bun / Deno
- [ ] kubectl / terraform / awscli / gcloud
- [ ] outdated 표시 (현재 vs 최신)
- [ ] JSON 출력 옵션

#### 🤖 Claude Code
- [ ] MCP 서버 관리
- [ ] CLAUDE.md 생성 도우미
- [ ] /agents, /skills, /hooks 안내

### 2.2 신규 카테고리 (★★)

- [ ] **📁 디스크/파일** — du -sh / 큰 파일 찾기 / 휴지통
- [ ] **🗄️ DB 클라이언트** — PostgreSQL / MySQL / MongoDB
- [ ] **⚓ Kubernetes** — kubectl 자주 쓰는 명령
- [ ] **☁️ 클라우드 CLI** — AWS/GCP/Azure 단축

### 2.3 UX 개선

- [ ] 즐겨찾기 (`~/.zsh_menu/favorites`)
- [ ] 최근 사용 표시 (메인 메뉴 상단)
- [ ] 메뉴별 호환성 마크 (✅macOS / ⚠️Linux)
- [ ] 단축키 일관성 (q/0 통일)
- [ ] 드라이런 모드 `gg --dry-run`

---

## 🏗️ Phase 3 — 백로그 (★)

### 3.1 아키텍처

- [ ] **menu.zsh 모듈 분할** — `lib/` + `menus/` 디렉토리 구조
- [ ] **사용자 설정 파일** — `~/.zsh_menu/config.zsh`
- [ ] **자동 업데이트** — `gg update` 확장 (cron 옵션)
- [ ] **테스트 (bats)** — 핵심 함수 unit test
- [ ] **i18n** — 한국어/영어 토글

### 3.2 OSS 운영

- [ ] CHANGELOG.md
- [ ] SECURITY.md
- [ ] CONTRIBUTING.md
- [ ] GitHub Actions CI (shellcheck + bats)
- [ ] Homebrew tap 배포

---

## 📝 변경 로그

### 2026-05-05 — Linux 시스템 관리 (v2.2)
- **새 메뉴 [18] 🐧 Linux 시스템 관리** — Ubuntu/RHEL/SUSE/Alpine/Arch 5개 patf 지원
- 자동 distro 감지 (`/etc/os-release` 파싱):
  - $SEONGMIN_DISTRO_ID, FAMILY, NAME, VERSION 글로벌
  - debian/rhel/suse/alpine/arch/macos/unknown 6개 family
- 환경 감지 헬퍼:
  - `_seongmin_in_container()` — Docker/Podman/LXC
  - `_seongmin_in_wsl()` — WSL2
  - `_seongmin_has_sudo()` — sudo 가능 여부
- 11개 서브메뉴:
  1. 📦 패키지 관리 — search/install/remove/info/update/upgrade/owns/files/clean (5개 distro 분기)
  2. ⚙️ 서비스 관리 — systemd / OpenRC 자동 감지 (Alpine은 OpenRC)
  3. 🔥 방화벽 — ufw / firewalld / iptables 자동 감지
  4. 👤 사용자/그룹 — sudo group은 distro별 (sudo vs wheel)
  5. 📡 네트워크 — ip addr/route/link, netplan/NetworkManager/wicked 분기
  6. 📜 로그/저널 — journalctl + 전통 로그 (syslog vs messages)
  7. 🛡 보안 — SELinux (RHEL) / AppArmor (Ubuntu/SUSE) 자동 감지
  8. 🚀 부팅/커널 — systemd-analyze, modprobe, GRUB 재생성 (distro별)
  9. 🗄 저장소 (repo) 관리 — apt PPA, dnf config-manager, zypper repo
  10. 📚 배포판별 cheatsheet — 6개 카테고리, 5개 distro 비교표
  11. 🔍 명령어 변환기 — apt/dnf/yum/zypper/apk/pacman 자동 매핑
- 핵심 헬퍼: `_seongmin_run_or_show <cmd>` — 명령어 표시 + y/N 확인 + 실행 (macOS는 클립보드 복사)
- 직접 명령: `dxk linux/pkg/svc/fw/cheat/translate`
- alias: `linux pkg svc fw cheat xlate` (모두 함수 — distro 자동 재감지)
- macOS 호환: 명령어 표시 + 클립보드 복사 가능 (실행 X)

### 2026-05-05 — UX: 취소 패턴 일괄 적용 (v2.1.3)
- 99개 데이터 입력 프롬프트 중 **85개 (86%)** 를 `_seongmin_input` 으로 변환
- 남은 14개는 모두 **메뉴 선택형 입력** (1/2/3 같은) — 이미 0/q/Q 처리됨
- 영역별 적용:
  - 🐳 Docker container/image (19): 시작/중지/재시작/삭제/로그/exec/inspect/pull/run/build/tag/history
  - 🐙 Git (30): 커밋 메시지, 브랜치 이름, 태그, URL, 커밋 해시, stash 메시지, cherry-pick
  - 🐍 Python (13): venv 이름, Python 버전, requirements 등
  - ☕ Java (5): 자바 파일명, jenv 버전/scope, 포트 번호
  - 🔧 Jenkins (12): Job 이름, 파라미터, API 토큰, 플러그인 ID
  - 🐳 Docker volume/network (4): 볼륨/네트워크 이름
  - 🐚 Shell (3): alias/env/history 검색, chsh 경로
  - 🔐 SSH (2): ssh-add 경로, ssh -T 호스트
  - 기타: Brewfile 경로, journalctl since/unit, Frontend CRA 프로젝트명
- 모든 적용된 프롬프트:
  - q/Q 입력 → 취소 (메인 메뉴로)
  - 빈 줄(엔터) → 기본값 있으면 그거, 없으면 취소
  - 일반 값 → 그대로 사용
- 위험 명령은 `_seongmin_confirm_dangerous` 로 통일 (인라인 y/n 제거)

### 2026-05-05 — UX: 일관된 "취소" 패턴 (v2.1.2)
- 이슈: 메뉴 항목 들어갔다가 빠져나오기 어려운 곳들이 있었음
  - 어떤 곳: q → 취소 ✓
  - 어떤 곳: 엔터 → 취소 ✓
  - 어떤 곳: 엔터 → 기본값으로 진행 (취소 못 함)
  - 어떤 곳: q → 그걸 값으로 사용해버림
- 해결:
  - 새 헬퍼 `_seongmin_input "프롬프트" [기본값]` — q/Q/빈 줄 = 취소 통일
  - 새 헬퍼 `_seongmin_cancelled` — "↩️ 취소되었습니다" 표시
  - 적용: brew install/uninstall/search/info, network ping/dig/curl/lsof/traceroute/cert,
          ssh keygen/copy-id, new project (Python/generic), pid forensics, emergency 포트,
          utils 비밀번호/Base64/URL
  - 메인 메뉴 헤더에 안내: "어떤 입력 화면에서든 q 또는 엔터만 누르면 취소"

### 2026-05-05 — Alias 시스템 제거 (v2.1.1)
- **8개 alias 파일 삭제**: git.zsh, python.zsh, java.zsh, docker.zsh, homebrew.zsh, redis.zsh, shell.zsh, version.zsh (총 ~84개 alias)
- 이유:
  - 의미 없는 약자(`pv`, `gs`, `bi`)는 외우는 비용 > 진짜 명령어 외우는 비용
  - 충돌 다수 발견 (`grb`: git rebase vs gradle build, `dps`: sudo docker ps vs pretty)
  - 시스템 명령 덮어쓰기 위험 (`pip='pip3'`, `pytest='python3 -m pytest'`)
  - 다른 컴퓨터에선 동작 안 함 — 이식성 없음
  - 사용자 통찰: "이걸 또 외우는 게 오바인 거 같아"
- 변경:
  - 메뉴 텍스트 정리: `[1] pv - 가상환경 생성` → `[1] 가상환경 생성  python3 -m venv venv`
  - `jarun` 함수 (java.zsh) → menu.zsh에 인라인화 (Java 11+ 단일 파일 실행)
  - README에 "철학" 섹션 추가
- 사용자 영향: 거의 없음 (install.sh는 menu.zsh만 복사했었기 때문)

### 2026-05-05 — Senior / SRE Mode (v2.1)
- 새 카테고리 [17] 🔧 운영 모드 추가 — 시니어/SRE 페르소나 타겟
- 10개 도구 구현:
  1. 🚨 운영 대시보드 (`dxk dash`) — CPU/MEM/DISK 바, Docker, Listen, Top CPU/MEM, OOM
  2. 🩺 헬스 체크 (`dxk health`) — 인터넷, 디스크, SSL 만료, systemd, Docker
  3. 🔬 프로세스 forensics (`dxk pid <PID|name>`) — ps/cmdline/cwd/env/limits/lsof/pstree
  4. 🌐 Network deep dive — ss, HTTP timing, SSL chain, mtr, tcpdump, multi-ping, DNS 일관성
  5. 📜 Log power tools — journalctl, multi-tail, frequency analysis, context grep
  6. 💾 Disk/IO 분석 — du, iostat, docker df, find by size
  7. 🐘 PostgreSQL 운영 — 활성/슬로우/락/idle/캐시 적중률 진단 쿼리
  8. ⚓ Kubernetes — ctx/ns 전환, pod top, "왜 죽었나" 통합, configmap diff
  9. 🆘 커널 이벤트 — OOM, 재부팅, auth fail, systemd failed, sudo 활동
  10. 📚 Snippet Library (`dxk snip`) — fzf 검색 + 카테고리 markdown 관리
- Direct mode: dash/pid/snip/health/kernel + alias dash/snip
- 헬퍼: bar(), bar_color(), human_bytes()

### 2026-05-05 — Pretty Docker (v2.0.x)
- `_seongmin_docker_ps_pretty` 확장: --json, --status=, --name=, --health=, --label=, --filter, auto-width
- `_seongmin_docker_images_pretty` 신규: size별 색상, dangling 표시, 자동 width
- 직접 명령: `dxk dps`, `dxk dimg`, alias `dps` `dimg`

### 2026-05-05 — Rebrand
- **`gg` → `dxk` 리네이밍 (DX Kit = Developer Experience Kit)**
- `gg`는 레거시 호환을 위해 계속 동작
- `dx`는 deno의 서브커맨드와 충돌하여 `dxk`로 결정
- 메인 메뉴/help/install.sh/README 모두 `dxk` 위주로 업데이트
- 프로젝트 이름: "Seongmin's Dev Menu" → **"DX Kit"**

### 2026-05-05 — Phase 1 첫 번째 wave
- ROADMAP.md 작성
- 공통 인프라 헬퍼 추가 (OS 분기, 환경 체크, breadcrumb)
- 최상위 명령 추가 (--version / --help / search / update)
- Homebrew 메뉴 대폭 확장 (install/uninstall/search/info/doctor/outdated/leaves/bundle)
- Python 메뉴에 uv 지원 + pytest + ruff + pycache 정리
- Git 메뉴에 Conventional Commits + gh PR + .gitignore + tag + amend
- Docker daemon 사전 체크
- Frontend 메뉴 재구성 (CRA 경고 + bun + Astro/Remix/Nuxt + 일상 명령)
- 신규 카테고리: SSH / Network / 새 프로젝트 / 응급 처치 / 유틸
- install.sh: zsh 자동 설치 안내 + Linux/Rocky 호환성

---

## 🤝 기여 가이드

새 메뉴를 추가하려면:
1. `_seongmin_<카테고리>()` 함수 작성
2. `seongmin()` 메인 디스패처에 등록
3. ROADMAP.md 체크박스 업데이트
4. 한국어 메시지 + 영어 명령어 주석 유지
5. 위험 명령은 `_seongmin_is_dangerous` 패턴에 추가
