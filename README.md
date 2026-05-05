# 🚀 DX Kit — Developer Experience Kit

> **터미널 명령어가 헷갈리시나요?** Git, Python, Docker… 외울 게 너무 많죠.
> DX Kit은 자주 쓰는 명령어들을 **번호만 누르면** 실행되도록 만들어줍니다.
> 터미널에서 `dxk` 한 번이면 끝! ✨
>
> *(이전 사용자: `gg` 명령도 계속 사용 가능합니다)*

---

## 🎯 누가 쓰면 좋을까요?

- 💻 **터미널 초보자** — Git/Docker 명령어를 다 외우기 어려운 분
- ⚡ **타이핑이 귀찮은 분** — 자주 쓰는 명령을 메뉴로 빠르게
- 🧑‍🏫 **가르치는 분** — 학생/주니어에게 명령어 흐름을 보여줄 때
- 🎨 **개발 환경 통일** — 팀원 모두가 같은 명령어 셋을 쓰고 싶을 때

---

## ✨ 어떤 기능이 있나요?

### 🛠 개발 도구 (16개 카테고리)

| 카테고리 | 내용 |
|---|---|
| 🐙 **Git** | 커밋, 푸시, 브랜치 + **Conventional Commits**, **gh PR 생성**, **.gitignore 자동 생성**, 초보자 가이드 |
| 🐍 **Python** | venv, pip, **uv 지원**, **pytest**, **ruff**, Jupyter, `__pycache__` 정리 |
| 🐳 **Docker** | 컨테이너/이미지/Compose + **daemon 사전 체크**, **stats**, **logs -f**, **exec** |
| 🍺 **Homebrew** | **install/uninstall/search/info/doctor/outdated/leaves/bundle** 모두 지원 |
| ☕ **Java** | jenv, Gradle, Maven, 포트 정리 |
| 🎨 **Frontend** | Vite/Next/**Astro**/**Remix**/**Nuxt**/**SvelteKit** + **bun**, dev/build/lint, node_modules 청소 |
| 🔴 **Redis** | macOS/**Linux systemd 자동 분기**, PING, KEYS, INFO, FLUSHDB |
| 🐚 **Shell** | PATH 분석, alias/env/history 검색, dotfile 백업, oh-my-zsh |
| 🔍 **버전 체크** | Go/Rust/Ruby/PHP/Bun/Deno/kubectl/terraform/aws 등 30+ 도구 |
| 🔧 **Jenkins / 🤖 Claude Code** |

### ⭐ 신규 카테고리 (v2.0)

| 카테고리 | 내용 |
|---|---|
| 🔐 **SSH 키 관리** | keygen, ssh-add, ssh-copy-id, config 편집, 클립보드 복사 |
| 🌐 **Network 진단** | ping, dig, curl 응답시간, 포트 확인, 공인/로컬 IP, SSL 만료일 |
| 🆕 **새 프로젝트 시작** | Python(uv 우선)/Frontend/일반 — git init + README + .gitignore 자동 |
| 🆘 **응급 처치** | 포트 충돌, Docker 죽음, 디스크 부족, git 망함 등 상황별 가이드 |
| 🧪 **유틸 도구** | UUID, 비밀번호 생성, Base64, URL encode, JSON 포매팅, 해시, 타임스탬프 변환 |

### 🐧 Linux 시스템 관리 (v2.2) — 5개 distro 지원

배포판마다 명령어가 다 달라서 헷갈릴 때 (apt vs dnf vs zypper vs apk vs pacman). **자동 감지 + cheatsheet + 변환기**.

| 도구 | 설명 | 직접 호출 |
|---|---|---|
| 📦 **패키지 관리** | search/install/remove/info/upgrade — 5개 distro 자동 분기 | `dxk pkg` |
| ⚙️ **서비스 관리** | systemd / OpenRC 자동 감지 | `dxk svc` |
| 🔥 **방화벽** | ufw / firewalld / iptables 자동 감지 | `dxk fw` |
| 👤 **사용자/그룹** | sudo vs wheel 그룹 자동 처리 | (메뉴 18→4) |
| 📡 **네트워크** | netplan / NetworkManager / wicked 분기 | (메뉴 18→5) |
| 📜 **로그/저널** | journalctl + 전통 로그 (syslog vs messages) | (메뉴 18→6) |
| 🛡 **보안** | SELinux (RHEL) / AppArmor (Ubuntu) 자동 감지 | (메뉴 18→7) |
| 🚀 **부팅/커널** | systemd-analyze, GRUB 재생성 (distro별) | (메뉴 18→8) |
| 🗄 **저장소 관리** | PPA / dnf config-manager / zypper repo | (메뉴 18→9) |
| 📚 **Cheatsheet** | 5개 distro × 6개 카테고리 비교표 | `dxk cheat` |
| 🔍 **변환기** | "apt install nginx" → 모든 distro 명령어 | `dxk translate` |

> 💡 **macOS 호환**: 명령어 표시 + 클립보드 복사 가능 (실행은 Linux 환경에서만).
> 💡 **자동 감지**: `/etc/os-release` 파싱해서 Ubuntu/Rocky/SUSE/Alpine/Arch 자동 인식.

### 🔧 Senior / SRE 모드 (v2.1) — 외워서 못 만드는 것들

여러 명령을 조합해야 답이 나오는 작업들. 새벽 3시 알람용.

| 도구 | 설명 | 직접 호출 |
|---|---|---|
| 🚨 **운영 대시보드** | CPU/MEM/DISK 바 + Docker + Listen + Top 5 + OOM | `dxk dash` |
| 🩺 **헬스 체크** | 인터넷, 디스크 90%↑, SSL 만료, systemd, Docker unhealthy | `dxk health` |
| 🔬 **프로세스 forensics** | ps + cmdline + cwd + env + limits + lsof + pstree 통합 | `dxk pid <PID\|name>` |
| 🌐 **Network deep dive** | ss, HTTP timing, SSL chain, mtr, tcpdump, multi-ping, DNS 일관성 | (메뉴 17→4) |
| 📜 **Log power tools** | journalctl 필터, multi-file tail, **빈도 분석** (sort/uniq), context grep | (메뉴 17→5) |
| 💾 **Disk/IO 분석** | du Top 20, iostat, docker system df, big file finder | (메뉴 17→6) |
| 🐘 **PostgreSQL 진단** | 활성 쿼리, 슬로우 (pg_stat_statements), 락, idle TX, 캐시 적중률 | (메뉴 17→7) |
| ⚓ **Kubernetes 운영** | ctx/ns 전환, pod top, "왜 죽었나" 통합, configmap diff | (메뉴 17→8) |
| 🆘 **커널 이벤트** | OOM, 재부팅, auth fail, systemd failed, 최근 sudo | `dxk kernel` |
| 📚 **Snippet 라이브러리** | fzf 검색 가능한 cheatsheet (markdown 카테고리별) | `dxk snip` |

> 💡 시니어 분들이 "외워서 손이 가는" 명령어들이 아니라, *명령 5~10개를 조합해야 답이 나오는* 작업들을 모았습니다.

### 🔧 메타 명령

```bash
dxk                    # 인터랙티브 메뉴
dxk --version          # 버전 확인
dxk --help             # 통합 도움말
dxk search <키워드>     # 메뉴 항목 검색
dxk update             # DX Kit 자체 업데이트 (git pull)
```

> 🔒 **안전장치**: `git push --force`, `rm -rf`, `docker prune`, `FLUSHDB`, `brew uninstall` 등 위험한 명령은 **실행 전에 한 번 더 물어봅니다**.
> 🎨 **NO_COLOR 지원**: 환경변수 `NO_COLOR=1` 설정 시 색상 비활성화 (표준 관례).

---

## 📦 설치하기

### 🍎 macOS

macOS는 기본 셸이 zsh라서 **추가 설치 없이** 바로 진행할 수 있습니다.

```bash
git clone https://github.com/your-username/zsh_seongmin.git
cd zsh_seongmin
chmod +x install.sh
./install.sh
```

### 🐧 Linux (Rocky / Ubuntu / Debian / Arch 등)

> 💡 이 메뉴는 **zsh**로 동작합니다. Linux는 보통 zsh가 없으니 먼저 설치해주세요.
>
> **걱정 마세요!** 로그인 셸을 zsh로 바꾸지 않아도 됩니다. bash를 그대로 쓰다가 메뉴가 필요할 때만 `zsh` 입력해서 들어가면 됩니다.

#### 1단계: zsh 설치 (배포판별)

| 배포판 | 명령어 |
|---|---|
| Rocky / RHEL / CentOS / Fedora / AlmaLinux | `sudo dnf install -y zsh` |
| Ubuntu / Debian / Mint | `sudo apt install -y zsh` |
| Arch / Manjaro | `sudo pacman -S zsh` |
| openSUSE | `sudo zypper install -y zsh` |
| Alpine | `sudo apk add zsh` |

> 💾 **용량은 약 5MB 정도**입니다. 부담 없어요.

#### 2단계: 설치 스크립트 실행

```bash
git clone https://github.com/your-username/zsh_seongmin.git
cd zsh_seongmin
chmod +x install.sh
./install.sh
```

설치 스크립트가 알아서:
- ✅ zsh 설치 여부 확인 (없으면 친절하게 안내)
- ✅ `~/.zsh_menu/` 에 메뉴 파일 복사
- ✅ `~/.zshrc` 에 자동 등록 (없으면 새로 생성)
- ✅ 기존 `.zshrc` 백업 (`~/.zshrc.backup.YYYYMMDD_HHMMSS`)

### 🪟 Windows (PowerShell)

```powershell
git clone https://github.com/your-username/zsh_seongmin.git
cd zsh_seongmin

# 처음 사용 시 한 번만 실행
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

.\install_windows.ps1
```

---

## 🎯 철학

> **이 도구는 명령어를 외우게 하지 않습니다. 익히게 도와줍니다.**

- ✅ 메뉴는 **진짜 명령어**(`python3 -m venv venv`)를 표시 — alias가 아니라
- ✅ 익숙해지면 메뉴 없이 직접 칠 수 있게 됨 = **메뉴를 안 쓰게 만드는 게 좋은 메뉴**
- ✅ 다른 컴퓨터/서버 SSH 들어가도 그대로 통함 (이식성)
- ❌ 의미 없는 약자(`pv`, `gs`, `bi`)를 강요하지 않음

> *"메뉴는 자전거의 보조 바퀴 같은 거예요. 처음에는 도움 되지만, 결국 떼고 달리는 게 목표."*

---

## 🎮 사용법

### 메뉴로 사용하기 (기본)

터미널에서 그냥 `dxk` 입력:

```bash
dxk
```

```
  ╔════════════════════════════════════════════════════════╗
  ║        🚀 DX Kit — Developer Experience Kit            ║
  ╠════════════════════════════════════════════════════════╣
  ║   [1] 🐙 Git           [2] 🐍 Python                    ║
  ║   [3] ☕ Java           [4] 🍺 Homebrew                 ║
  ║   [5] 🐳 Docker        [6] 🔴 Redis                     ║
  ║   ...                                                   ║
  ║   [12] 🔐 SSH          [13] 🌐 Network                  ║
  ║   [14] 🆕 새 프로젝트   [15] 🆘 응급 처치                ║
  ║   [16] 🧪 유틸                                          ║
  ║   [s] 검색  [u] 업데이트  [v] 버전  [0] 종료              ║
  ╚════════════════════════════════════════════════════════╝
```

번호만 입력하면 다음 메뉴로 이동! 🪄

### ⚡ 직접 실행 모드 (고급)

메뉴 안 거치고 바로 실행하고 싶다면:

```bash
dxk git status      # git status 실행
dxk docker ps       # docker ps 실행
dxk brew update     # brew update 실행
dxk help            # 직접 실행 모드 도움말
```

> 💡 **별칭**: `dxk`와 `gg` 둘 다 동작합니다. 손가락이 익숙한 쪽을 쓰세요.

---

## 🐧 Linux의 bash 사용자라면

설치는 끝났는데 `dxk`가 안 된다면, 지금 셸이 bash라서 그래요. 이렇게 쓰세요:

```bash
zsh        # ← zsh로 진입 (한 번만)
dxk        # ← 메뉴 사용
exit       # ← 끝나면 exit으로 다시 bash로
```

> 💡 매번 `zsh` 치는 게 귀찮다면, 로그인 셸을 zsh로 바꿔도 됩니다:
> ```bash
> chsh -s $(which zsh)
> ```
> (다시 로그아웃→로그인 필요)

---

## 🩹 문제 해결 (FAQ)

<details>
<summary><b>Q. 설치했는데 <code>dxk: command not found</code> 라고 나와요</b></summary>

새 터미널을 열거나, 아래 명령으로 설정을 다시 불러오세요:
```bash
source ~/.zshrc
```
그래도 안 되면 zsh로 진입했는지 확인:
```bash
echo $SHELL   # /bin/zsh 또는 /usr/bin/zsh 가 나와야 함
```
</details>

<details>
<summary><b>Q. install.sh를 더블클릭했는데 텍스트 에디터가 열려요</b></summary>

Linux 파일 관리자는 보안상 `.sh` 파일을 더블클릭으로 실행하지 않습니다. **터미널을 열고 실행**해주세요:
```bash
cd ~/Downloads/zsh_seongmin   # 다운받은 위치
chmod +x install.sh
./install.sh
```
</details>

<details>
<summary><b>Q. Permission denied 에러가 나요</b></summary>

스크립트에 실행 권한이 없어서 그래요:
```bash
chmod +x install.sh
./install.sh
```
</details>

<details>
<summary><b>Q. zsh를 설치했는데 install.sh가 또 zsh가 없다고 해요</b></summary>

설치 후 새 터미널을 열어보세요. 그래도 안 되면 PATH 확인:
```bash
which zsh
# 결과가 안 나오면 zsh가 정말로 설치 안 된 것
```
</details>

<details>
<summary><b>Q. 기존 .zshrc 설정이 사라질까봐 걱정돼요</b></summary>

설치 스크립트가 자동으로 백업합니다:
```
~/.zshrc.backup.20260505_153022
```
문제가 생기면 이 파일로 복원하시면 됩니다.
</details>

<details>
<summary><b>Q. 메뉴를 어떻게 빠져나오나요?</b></summary>

각 메뉴에서 `0` 또는 `q` 입력 → 종료 / 상위 메뉴.
</details>

---

## 🗑️ 삭제하기

### macOS / Linux
```bash
./install.sh --uninstall
```

### Windows
```powershell
.\install_windows.ps1 --uninstall
```

> ✅ `~/.zsh_menu/` 디렉토리와 `~/.zshrc`의 등록 라인이 깔끔하게 제거됩니다.
> ❌ zsh 자체는 삭제되지 않으니 안심하세요.

---

## 📁 파일 구조

```
zsh_seongmin/
├── menu.zsh             # 🧠 메인 메뉴 (모든 기능 통합)
├── install.sh           # 🍎🐧 macOS/Linux 설치 스크립트
├── install_windows.ps1  # 🪟 Windows 설치 스크립트
├── ROADMAP.md           # 🗺️ 단계별 개선 계획
└── README.md            # 👋 이 파일
```

> 💡 **v2.1부터 alias 파일들(git.zsh, python.zsh 등)을 모두 제거했습니다.**
> 의미 없는 약자(`pv`, `gs`, `bi`...)를 외우는 비용보다 **진짜 명령어를 익히는 게 더 가치 있다**고 판단했어요.
> 메뉴는 진짜 명령어(`python3 -m venv venv`)를 그대로 보여주므로, 메뉴를 익히면 곧 메뉴 없이도 쓸 수 있게 됩니다.

---

## 🤝 기여하기

Pull Request, Issue, 별점(⭐) 모두 환영입니다!
새로운 명령어를 추가하고 싶으시면 부담 없이 PR 보내주세요.

---

## 📜 라이선스

MIT License — 자유롭게 쓰시고 수정하세요.

---

<p align="center">
  Made with ☕ by Seongmin · 즐거운 개발 되세요! 🚀
</p>
