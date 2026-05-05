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
