# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🚀 Seongmin's Menu Installer                           ║
# ║                          Windows PowerShell 전용                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# 색상 출력 함수
function Write-ColorOutput {
    param([string]$Color, [string]$Message)
    switch ($Color) {
        "Green"  { Write-Host $Message -ForegroundColor Green }
        "Red"    { Write-Host $Message -ForegroundColor Red }
        "Yellow" { Write-Host $Message -ForegroundColor Yellow }
        "Cyan"   { Write-Host $Message -ForegroundColor Cyan }
        default  { Write-Host $Message }
    }
}

function Show-Banner {
    Write-Host ""
    Write-ColorOutput "Cyan" "╔═══════════════════════════════════════════════════════════╗"
    Write-Host "║      🎉 " -NoNewline; Write-ColorOutput "Green" "Seongmin's PowerShell Menu Installer" -NoNewline; Write-Host "         ║"
    Write-ColorOutput "Cyan" "║         Git, Python, Docker 명령어 메뉴                     ║"
    Write-ColorOutput "Cyan" "╚═══════════════════════════════════════════════════════════╝"
    Write-Host ""
}

function Write-Success { param([string]$Message); Write-ColorOutput "Green" "✅ $Message" }
function Write-Info { param([string]$Message); Write-ColorOutput "Cyan" "ℹ️  $Message" }
function Write-Warning { param([string]$Message); Write-ColorOutput "Yellow" "⚠️  $Message" }
function Write-Error { param([string]$Message); Write-ColorOutput "Red" "❌ $Message" }

# 변수 설정
$InstallDir = "$env:USERPROFILE\.powershell_menu"
$MenuFile = "menu_windows.ps1"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProfilePath = $PROFILE

# PowerShell 메뉴 파일 생성
function Create-MenuFile {
    $MenuContent = @'
# Seongmin's PowerShell Menu - Windows Edition

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║        🚀 Seongmin's Dev Menu (Windows)                ║" -ForegroundColor Yellow
    Write-Host "  ╠════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "  ║   [1] 🐙 Git 명령어                                    ║" -ForegroundColor Green
    Write-Host "  ║   [2] 🐍 Python 가상환경                               ║" -ForegroundColor Green
    Write-Host "  ║   [3] ☕ Java 명령어                                    ║" -ForegroundColor Green
    Write-Host "  ║   [4] 🍫 Chocolatey 패키지                             ║" -ForegroundColor Green
    Write-Host "  ║   [5] 🐳 Docker 컨테이너                               ║" -ForegroundColor Green
    Write-Host "  ║   [6] 📂 파일 & 폴더                                   ║" -ForegroundColor Green
    Write-Host "  ║   [7] ⚙️  시스템 정보                                   ║" -ForegroundColor Green
    Write-Host "  ║   [8] 📚 초보자 가이드                                 ║" -ForegroundColor Yellow
    Write-Host "  ║   [0] ❌ 종료                                          ║" -ForegroundColor Red
    Write-Host "  ╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Git 메뉴
function Show-GitMenu {
    while ($true) {
        Clear-Host
        Write-Host "  🐙 [ Git 명령어 ]" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] git status - 현재 상태 확인" -ForegroundColor Green
        Write-Host "  [2] git add . - 모든 변경사항 추가" -ForegroundColor Green
        Write-Host "  [3] git commit - 커밋하기" -ForegroundColor Green
        Write-Host "  [4] git push - 푸시하기" -ForegroundColor Green
        Write-Host "  [5] git pull - 풀하기" -ForegroundColor Green
        Write-Host "  [6] git log - 로그 보기" -ForegroundColor Green
        Write-Host "  [7] git branch - 브랜치 목록" -ForegroundColor Green
        Write-Host "  [8] 한번에 커밋&푸시" -ForegroundColor Yellow
        Write-Host "  [9] 브랜치 생성 후 이동" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { git status; Read-Host "Enter" }
            "2" { git add .; Write-Host "✅ 완료!" -ForegroundColor Green; Read-Host "Enter" }
            "3" { $msg = Read-Host "커밋 메시지"; git commit -m "$msg"; Read-Host "Enter" }
            "4" { git push; Read-Host "Enter" }
            "5" { git pull; Read-Host "Enter" }
            "6" { git log --oneline -20; Read-Host "Enter" }
            "7" { git branch -a; Read-Host "Enter" }
            "8" { $msg = Read-Host "커밋 메시지"; git add .; git commit -m "$msg"; git push; Read-Host "Enter" }
            "9" { $br = Read-Host "브랜치명"; git checkout -b $br; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# Python 메뉴
function Show-PythonMenu {
    while ($true) {
        Clear-Host
        Write-Host "  🐍 [ Python 가상환경 ]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  [1] 가상환경 생성" -ForegroundColor Green
        Write-Host "  [2] 가상환경 활성화" -ForegroundColor Green
        Write-Host "  [3] 가상환경 비활성화" -ForegroundColor Green
        Write-Host "  [4] pip list" -ForegroundColor Green
        Write-Host "  [5] pip install -r requirements.txt" -ForegroundColor Green
        Write-Host "  [6] pip freeze > requirements.txt" -ForegroundColor Green
        Write-Host "  [7] Python 버전 확인" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { $n = Read-Host "이름(기본:venv)"; if(!$n){$n="venv"}; python -m venv $n; Write-Host "✅ 완료!" -ForegroundColor Green; Read-Host "Enter" }
            "2" { if(Test-Path ".\venv\Scripts\Activate.ps1"){ & .\venv\Scripts\Activate.ps1 }else{ Write-Host "❌ venv 없음" -ForegroundColor Red }; Read-Host "Enter" }
            "3" { deactivate; Read-Host "Enter" }
            "4" { pip list; Read-Host "Enter" }
            "5" { pip install -r requirements.txt; Read-Host "Enter" }
            "6" { pip freeze > requirements.txt; Write-Host "✅ 완료!" -ForegroundColor Green; Read-Host "Enter" }
            "7" { python --version; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# Java 메뉴
function Show-JavaMenu {
    while ($true) {
        Clear-Host
        Write-Host "  ☕ [ Java 명령어 ]" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  [1] Java 버전 확인" -ForegroundColor Green
        Write-Host "  [2] JAVA_HOME 확인" -ForegroundColor Green
        Write-Host "  [3] gradlew build" -ForegroundColor Green
        Write-Host "  [4] gradlew bootRun" -ForegroundColor Green
        Write-Host "  [5] mvn clean install" -ForegroundColor Green
        Write-Host "  [6] mvn spring-boot:run" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { java -version; Read-Host "Enter" }
            "2" { Write-Host "JAVA_HOME: $env:JAVA_HOME"; Read-Host "Enter" }
            "3" { .\gradlew.bat clean build; Read-Host "Enter" }
            "4" { .\gradlew.bat bootRun; Read-Host "Enter" }
            "5" { mvn clean install; Read-Host "Enter" }
            "6" { mvn spring-boot:run; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# Chocolatey 메뉴 (Windows용 패키지 관리자)
function Show-ChocoMenu {
    while ($true) {
        Clear-Host
        Write-Host "  🍫 [ Chocolatey 패키지 관리 ]" -ForegroundColor DarkYellow
        Write-Host ""
        Write-Host "  [1] 설치된 패키지 목록" -ForegroundColor Green
        Write-Host "  [2] 패키지 검색" -ForegroundColor Green
        Write-Host "  [3] 패키지 설치" -ForegroundColor Green
        Write-Host "  [4] 패키지 업그레이드" -ForegroundColor Green
        Write-Host "  [5] 모든 패키지 업그레이드" -ForegroundColor Yellow
        Write-Host "  [6] 패키지 삭제" -ForegroundColor Red
        Write-Host "  [7] Chocolatey 설치 확인" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { choco list --local-only; Read-Host "Enter" }
            "2" { $s = Read-Host "검색어"; choco search $s; Read-Host "Enter" }
            "3" { $p = Read-Host "패키지명"; choco install $p -y; Read-Host "Enter" }
            "4" { $p = Read-Host "패키지명"; choco upgrade $p -y; Read-Host "Enter" }
            "5" { choco upgrade all -y; Read-Host "Enter" }
            "6" { $p = Read-Host "패키지명"; choco uninstall $p -y; Read-Host "Enter" }
            "7" { choco --version; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# Docker 메뉴
function Show-DockerMenu {
    while ($true) {
        Clear-Host
        Write-Host "  🐳 [ Docker 컨테이너 ]" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] docker ps" -ForegroundColor Green
        Write-Host "  [2] docker ps -a" -ForegroundColor Green
        Write-Host "  [3] docker images" -ForegroundColor Green
        Write-Host "  [4] docker-compose up -d" -ForegroundColor Green
        Write-Host "  [5] docker-compose down" -ForegroundColor Green
        Write-Host "  [6] docker system df" -ForegroundColor Green
        Write-Host "  [7] docker system prune" -ForegroundColor Yellow
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { docker ps; Read-Host "Enter" }
            "2" { docker ps -a; Read-Host "Enter" }
            "3" { docker images; Read-Host "Enter" }
            "4" { docker-compose up -d; Read-Host "Enter" }
            "5" { docker-compose down; Read-Host "Enter" }
            "6" { docker system df; Read-Host "Enter" }
            "7" { $c = Read-Host "정리? (y/n)"; if($c -eq "y"){ docker system prune -f }; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# 파일/폴더 메뉴
function Show-FileMenu {
    while ($true) {
        Clear-Host
        Write-Host "  📂 [ 파일 & 폴더 ]" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  [1] 파일 목록" -ForegroundColor Green
        Write-Host "  [2] 숨김 파일 포함" -ForegroundColor Green
        Write-Host "  [3] 파일 찾기" -ForegroundColor Green
        Write-Host "  [4] 탐색기 열기" -ForegroundColor Green
        Write-Host "  [5] VS Code 열기" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { Get-ChildItem | Format-Table -AutoSize; Read-Host "Enter" }
            "2" { Get-ChildItem -Force | Format-Table -AutoSize; Read-Host "Enter" }
            "3" { $p = Read-Host "파일명"; Get-ChildItem -Recurse -Filter $p; Read-Host "Enter" }
            "4" { explorer . }
            "5" { code . }
            "0" { return }
        }
    }
}

# 시스템 메뉴
function Show-SystemMenu {
    while ($true) {
        Clear-Host
        Write-Host "  ⚙️  [ 시스템 정보 ]" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1] 시스템 정보" -ForegroundColor Green
        Write-Host "  [2] IP 주소" -ForegroundColor Green
        Write-Host "  [3] 디스크 사용량" -ForegroundColor Green
        Write-Host "  [4] PATH 환경변수" -ForegroundColor Green
        Write-Host "  [5] 버전 확인 (Node/Python/Java)" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { Get-ComputerInfo | Select-Object CsName, WindowsVersion, OsArchitecture; Read-Host "Enter" }
            "2" { Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" } | Select-Object InterfaceAlias, IPAddress; Read-Host "Enter" }
            "3" { Get-PSDrive -PSProvider FileSystem | Format-Table Name, Used, Free -AutoSize; Read-Host "Enter" }
            "4" { $env:PATH -split ";"; Read-Host "Enter" }
            "5" { Write-Host "Node:"; node --version; Write-Host "Python:"; python --version; Write-Host "Java:"; java -version; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# 초보자 가이드
function Show-TutorialMenu {
    while ($true) {
        Clear-Host
        Write-Host "  📚 [ 초보자 가이드 ]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  [1] Git이란?" -ForegroundColor Green
        Write-Host "  [2] 가상환경이란?" -ForegroundColor Green
        Write-Host "  [3] Docker란?" -ForegroundColor Green
        Write-Host "  [4] Chocolatey란?" -ForegroundColor Green
        Write-Host "  [0] 돌아가기" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { Clear-Host; Write-Host "Git은 버전 관리 시스템입니다.`nCtrl+Z처럼 코드를 이전으로 되돌릴 수 있어요!`n`n기본 흐름: git add . -> git commit -m '메시지' -> git push" -ForegroundColor Cyan; Read-Host "Enter" }
            "2" { Clear-Host; Write-Host "가상환경은 프로젝트별 독립 공간입니다.`n패키지가 섞이지 않게 해줘요!`n`n생성: python -m venv venv`n활성화: .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow; Read-Host "Enter" }
            "3" { Clear-Host; Write-Host "Docker는 컨테이너 기술입니다.`n어디서든 같은 환경으로 실행할 수 있어요!`n`n주요 명령어: docker ps, docker images" -ForegroundColor Cyan; Read-Host "Enter" }
            "4" { Clear-Host; Write-Host "Chocolatey는 Windows 패키지 관리자입니다.`nmacOS의 Homebrew와 같은 역할이에요!`n`n설치: choco install 패키지명" -ForegroundColor DarkYellow; Read-Host "Enter" }
            "0" { return }
        }
    }
}

# 메인 루프
function Start-DevMenu {
    while ($true) {
        Show-Menu
        $choice = Read-Host "  선택"
        switch ($choice) {
            "1" { Show-GitMenu }
            "2" { Show-PythonMenu }
            "3" { Show-JavaMenu }
            "4" { Show-ChocoMenu }
            "5" { Show-DockerMenu }
            "6" { Show-FileMenu }
            "7" { Show-SystemMenu }
            "8" { Show-TutorialMenu }
            "0" { Write-Host "`n  👋 안녕히 가세요!`n" -ForegroundColor Cyan; return }
        }
    }
}

Set-Alias -Name gg -Value Start-DevMenu -Scope Global
Write-Host "✅ Seongmin's Dev Menu 로드 완료! 'gg'로 실행하세요." -ForegroundColor Green
'@

    return $MenuContent
}

# 설치 진행
function Install-Menu {
    Show-Banner
    
    Write-Host "설치를 진행하시겠습니까? (y/n)" -ForegroundColor Yellow
    $response = Read-Host
    
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "설치가 취소되었습니다."
        return
    }
    
    Write-Host ""
    
    # 설치 디렉토리 생성
    Write-Info "설치 디렉토리 생성 중..."
    if (Test-Path $InstallDir) {
        Write-Warning "기존 설치가 발견되었습니다. 업데이트합니다."
        Remove-Item -Path $InstallDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Success "디렉토리 생성 완료: $InstallDir"
    
    # 메뉴 파일 생성
    Write-Info "메뉴 파일 생성 중..."
    $MenuContent = Create-MenuFile
    $MenuContent | Out-File -FilePath "$InstallDir\$MenuFile" -Encoding UTF8
    Write-Success "메뉴 파일 생성 완료"
    
    # PowerShell Profile 설정
    Write-Info "PowerShell Profile 설정 중..."
    
    # Profile 파일이 없으면 생성
    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
        Write-Info "Profile 파일 생성됨: $ProfilePath"
    }
    
    # 백업
    Copy-Item $ProfilePath "$ProfilePath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Success "Profile 백업 완료"
    
    # 이미 추가되어 있는지 확인
    $profileContent = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($profileContent -match "Seongmin's PowerShell Menu") {
        Write-Warning "이미 설정되어 있습니다. 업데이트합니다."
        $profileContent = $profileContent -replace "# Seongmin's PowerShell Menu[\s\S]*?menu_windows\.ps1`"", ""
        $profileContent | Out-File $ProfilePath -Encoding UTF8
    }
    
    # 새 설정 추가
    Add-Content -Path $ProfilePath -Value ""
    Add-Content -Path $ProfilePath -Value "# Seongmin's PowerShell Menu"
    Add-Content -Path $ProfilePath -Value ". `"$InstallDir\$MenuFile`""
    
    Write-Success "Profile 설정 완료"
    
    # 완료 메시지
    Write-Host ""
    Write-ColorOutput "Green" "╔═══════════════════════════════════════════════════════════╗"
    Write-Host "║            🎉 " -NoNewline -ForegroundColor Green
    Write-Host "설치가 완료되었습니다!" -NoNewline -ForegroundColor White
    Write-Host "                       ║" -ForegroundColor Green
    Write-ColorOutput "Green" "╚═══════════════════════════════════════════════════════════╝"
    Write-Host ""
    Write-ColorOutput "Cyan" "📌 사용 방법:"
    Write-Host ""
    Write-Host "   1. 새 PowerShell 창을 열거나 다음 명령어 실행:"
    Write-Host "      " -NoNewline; Write-ColorOutput "Yellow" ". $ProfilePath"
    Write-Host ""
    Write-Host "   2. 메뉴 실행:"
    Write-Host "      " -NoNewline; Write-ColorOutput "Yellow" "gg"
    Write-Host "      또는  " -NoNewline; Write-ColorOutput "Yellow" "Start-DevMenu"
    Write-Host ""
    Write-ColorOutput "Cyan" "📚 포함된 기능:"
    Write-Host "   • 🐙 Git 명령어"
    Write-Host "   • 🐍 Python 가상환경 관리"
    Write-Host "   • 🐳 Docker 컨테이너 관리"
    Write-Host "   • 📂 파일 & 폴더 도구"
    Write-Host "   • ⚙️  시스템 정보"
    Write-Host ""
    Write-ColorOutput "Green" "즐거운 개발 되세요! 🚀"
    Write-Host ""
}

# 삭제 함수
function Uninstall-Menu {
    Write-Info "Seongmin's PowerShell Menu 삭제 중..."
    
    if (Test-Path $InstallDir) {
        Remove-Item -Path $InstallDir -Recurse -Force
        Write-Success "설치 디렉토리 삭제 완료"
    }
    
    if (Test-Path $ProfilePath) {
        $content = Get-Content $ProfilePath -Raw
        $content = $content -replace "# Seongmin's PowerShell Menu[\s\S]*?menu_windows\.ps1`"", ""
        $content | Out-File $ProfilePath -Encoding UTF8
        Write-Success "Profile 설정 제거 완료"
    }
    
    Write-Host ""
    Write-Success "삭제가 완료되었습니다."
    Write-Host "새 PowerShell 창을 열어주세요."
    Write-Host ""
}

# 메인 실행
if ($args -contains "--uninstall" -or $args -contains "-u") {
    Uninstall-Menu
} else {
    Install-Menu
}
