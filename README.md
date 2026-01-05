# 🚀 Seongmin's Dev Menu

개발 작업을 더 쉽게! Git, Python, Docker, Homebrew 등 자주 사용하는 명령어들을 메뉴 형태로 제공합니다.

## ✨ 기능

- 🐙 **Git** - 커밋, 푸시, 브랜치 관리 + 초보자 가이드
- 🐍 **Python** - 가상환경 생성/활성화, 패키지 관리
- 🐳 **Docker** - 컨테이너, 이미지, Compose 관리
- 🍺 **Homebrew** - 패키지 업데이트, 정리
- ☕ **Java** - jenv 버전 관리, Gradle/Maven
- 그 외 다양한 개발 도구들

## 📦 설치 방법

### macOS / Linux

```bash
# 1. 저장소 클론
git clone https://github.com/your-username/zsh_seongmin.git
cd zsh_seongmin

# 2. 설치 스크립트 실행
chmod +x install.sh
./install.sh

# 3. 터미널 재시작 또는
source ~/.zshrc
```

### Windows (PowerShell)

```powershell
# 1. 저장소 클론
git clone https://github.com/your-username/zsh_seongmin.git
cd zsh_seongmin

# 2. 실행 정책 변경 (필요한 경우)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. 설치 스크립트 실행
.\install_windows.ps1

# 4. PowerShell 재시작
```

## 🎮 사용 방법

터미널에서 `gg` 입력:

```bash
gg
```

## 📸 스크린샷

```
  ╔════════════════════════════════════════════════════════╗
  ║        🚀 Seongmin's Dev Menu                          ║
  ╠════════════════════════════════════════════════════════╣
  ║                                                        ║
  ║   [1] 🐙 Git 명령어                                    ║
  ║   [2] 🐍 Python 가상환경                               ║
  ║   [3] ☕ Java 명령어                                    ║
  ║   [4] 🍺 Homebrew 관리                                 ║
  ║   [5] 🐳 Docker 컨테이너                               ║
  ║   [0] ❌ 종료                                          ║
  ║                                                        ║
  ╚════════════════════════════════════════════════════════╝
```

## 🗑️ 삭제 방법

### macOS / Linux
```bash
./install.sh --uninstall
```

### Windows
```powershell
.\install_windows.ps1 --uninstall
```

## 📁 파일 구조

```
zsh_seongmin/
├── menu.zsh           # 메인 메뉴 스크립트 (macOS/Linux)
├── install.sh         # macOS/Linux 설치 스크립트
├── install_windows.ps1 # Windows 설치 스크립트
└── README.md          # 이 파일
```

## 🤝 기여

Pull Request와 Issue는 언제나 환영입니다!

## 📜 라이선스

MIT License
