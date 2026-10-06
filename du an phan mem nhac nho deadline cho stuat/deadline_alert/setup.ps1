# setup.ps1 — Tự động giải nén Flutter SDK và cài packages
# Chạy: PowerShell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "=== DeadlineAlert Setup Script ===" -ForegroundColor Cyan

# Step 1: Extract Flutter SDK
$zipFile = "$env:TEMP\flutter.zip"
$flutterDir = "C:\flutter"

if (Test-Path $zipFile) {
    Write-Host "`n[1/3] Giải nén Flutter SDK..." -ForegroundColor Yellow
    if (-not (Test-Path "$flutterDir\bin\flutter.bat")) {
        Expand-Archive -Path $zipFile -DestinationPath "C:\" -Force
        Write-Host "     ✓ Flutter SDK đã giải nén vào C:\flutter" -ForegroundColor Green
    } else {
        Write-Host "     ✓ Flutter SDK đã tồn tại" -ForegroundColor Green
    }
} else {
    Write-Host "     ✗ Không tìm thấy flutter.zip. Đang tải lại..." -ForegroundColor Red
    $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.2-stable.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath "C:\" -Force
}

# Step 2: Add Flutter to PATH for this session
$env:PATH = "C:\flutter\bin;$env:PATH"
Write-Host "`n[2/3] Kiểm tra Flutter..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter.bat" --version

# Step 3: Install packages
Write-Host "`n[3/3] Cài packages Flutter..." -ForegroundColor Yellow
Set-Location "D:\du an phan mem nhac nho deadline cho stuat\deadline_alert"
& "C:\flutter\bin\flutter.bat" pub get

Write-Host "`n[4/4] Generate code (freezed + riverpod)..." -ForegroundColor Yellow
& "C:\flutter\bin\dart.bat" run build_runner build --delete-conflicting-outputs

Write-Host "`n=== Setup hoàn tất! ===" -ForegroundColor Green
Write-Host "Bước tiếp theo:"
Write-Host "  1. Mở file lib\core\constants\app_constants.dart"
Write-Host "  2. Điền Supabase URL và anon key"
Write-Host "  3. Chạy SQL migration trong Supabase dashboard"
Write-Host "  4. Kết nối thiết bị Android hoặc khởi động emulator"
Write-Host "  5. Chạy: C:\flutter\bin\flutter.bat run"
