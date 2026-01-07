# ==========================================================
# Seongmin's Dev Menu Installer
# ==========================================================

# 1. 색상 출력 함수 (안전한 문자열 위주로 수정)
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

# 2. 경로 설정
$InstallDir = "$env:USERPROFILE\.powershell_menu"
$MenuFile = "menu_windows.ps1"
$ProfilePath = $PROFILE

# 3. 메뉴 파일 생성 함수
# (특수 공백을 제거하고 가장 안전한 구조로 작성했습니다)
function Create-MenuFile {
    $c = '
function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ==========================================" -ForegroundColor Cyan
    Write-Host "  🚀 Seongmin Dev Menu (Windows)" -ForegroundColor Yellow
    Write-Host "  ==========================================" -ForegroundColor Cyan
    Write-Host "  [1] Git Command" -ForegroundColor Green
    Write-Host "  [2] Python Venv" -ForegroundColor Green
    Write-Host "  [3] Java Command" -ForegroundColor Green
    Write-Host "  [4] Chocolatey" -ForegroundColor Green
    Write-Host "  [5] Docker" -ForegroundColor Green
    Write-Host "  [6] File & Folder" -ForegroundColor Green
    Write-Host "  [7] System Info" -ForegroundColor Green
    Write-Host "  [0] Exit" -ForegroundColor Red
    Write-Host "  ==========================================" -ForegroundColor Cyan
}

function Start-DevMenu {
    while ($true) {
        Show-Menu
        $choice = Read-Host "  Select Number"
        switch ($choice) {
            "1" { git status; Read-Host "Press Enter..." }
            "2" { python --version; Read-Host "Press Enter..." }
            "3" { java -version; Read-Host "Press Enter..." }
            "4" { choco --version; Read-Host "Press Enter..." }
            "5" { docker ps; Read-Host "Press Enter..." }
            "6" { explorer .; Read-Host "Press Enter..." }
            "7" { Get-ComputerInfo | Select-Object CsName, WindowsVersion; Read-Host "Press Enter..." }
            "0" { Write-Host "Bye!"; return }
            default { Write-Host "Wrong Number!" -ForegroundColor Red; Start-Sleep -s 1 }
        }
    }
}
Set-Alias -Name gg -Value Start-DevMenu -Scope Global
'
    return $c
}

# 4. 설치 로직
function Install-Main {
    Write-Host "--- Start Installation ---" -ForegroundColor Cyan
    
    if (!(Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $Content = Create-MenuFile
    # UTF8 대신 Default 인코딩을 사용하여 시스템 호환성 높임
    $Content | Out-File -FilePath "$InstallDir\$MenuFile" -Encoding Default
    
    # Profile 설정
    if (!(Test-Path $ProfilePath)) {
        $parent = Split-Path $ProfilePath
        if (!(Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force }
        New-Item -ItemType File -Path $ProfilePath -Force
    }

    $setup = "`n. `"$InstallDir\$MenuFile`""
    Add-Content -Path $ProfilePath -Value $setup
    
    Write-Host ""
    Write-Host "✅ Installation Complete!" -ForegroundColor Green
    Write-Host "Please restart PowerShell or type: . `$PROFILE" -ForegroundColor Yellow
}

Install-Main