@echo off
REM Install T-Sense open-core dependencies (Windows)
REM Requires: Python 3.12+

cd /d "%~dp0"

echo === T-Sense Open Core Setup ===

REM Check Python version (require 3.12+)
python --version 2>nul || (
    echo Error: Python not found. Install from https://python.org
    exit /b 1
)

for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do set "PYVER=%%v"
for /f "tokens=1,2 delims=." %%a in ("%PYVER%") do set "PYMAJOR=%%a"& set "PYMINOR=%%b"

if %PYMAJOR% lss 3 (
    echo Error: Python 3.12+ required. Found %PYVER%. Install from https://python.org
    exit /b 1
)
if %PYMAJOR% equ 3 if %PYMINOR% lss 12 (
    echo Error: Python 3.12+ required. Found %PYVER%. Install from https://python.org
    exit /b 1
)

echo Found Python %PYVER%

if "%T_SENSE_SETUP_SKIP_INSTALL%"=="1" (
    echo Skipping dependency install because T_SENSE_SETUP_SKIP_INSTALL=1.
    goto configure_scanner
)

if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo Error: Failed to activate .venv.
    exit /b 1
)

python -m pip --version >nul 2>nul
if errorlevel 1 (
    echo pip not found in venv; bootstrapping with ensurepip...
    python -m ensurepip --upgrade >nul
    if errorlevel 1 (
        echo Error: failed to bootstrap pip with ensurepip.
        exit /b 1
    )
)

echo Installing pinned core dependencies...
python -m pip install --upgrade pip --quiet
python -m pip install -r requirements.txt --quiet

echo Installing optional pinned LLM dependencies (openai for summarize.py)...
python -m pip install -r requirements-llm.txt --quiet 2>nul || echo   ^(openai not installed - summarize.py will need it later^)

set "TELETHON_VERSION="
for /f "delims=" %%v in ('python -c "import telethon; print(telethon.__version__)" 2^>nul') do set "TELETHON_VERSION=%%v"
if "%TELETHON_VERSION%"=="" (
    echo Error: telethon not importable. Check requirements.txt and venv.
    exit /b 1
)
echo telethon %TELETHON_VERSION% OK

:configure_scanner
REM Configure T-Sense
set "T_SENSE_DIR="
if not "%T_SENSE_CONFIG_DIR%"=="" set "T_SENSE_DIR=%T_SENSE_CONFIG_DIR%"
if "%T_SENSE_DIR%"=="" set "T_SENSE_DIR=%USERPROFILE%\.config\t-sense"
set "T_SENSE_CONFIG=%T_SENSE_DIR%\config.toml"

if exist "%T_SENSE_CONFIG%" goto config_exists

if exist "%T_SENSE_DIR%" goto config_dir_ready
mkdir "%T_SENSE_DIR%"
if not errorlevel 1 goto config_dir_ready
echo Error: Failed to create config directory: %T_SENSE_DIR%
exit /b 1

:config_dir_ready
copy config.example.toml "%T_SENSE_CONFIG%" >nul
if not errorlevel 1 goto config_copied
echo Error: Failed to copy config.example.toml to %T_SENSE_CONFIG%
exit /b 1

:config_copied
echo.
echo === Next Steps ===
echo 1. Edit Telegram API credentials:
echo    %T_SENSE_CONFIG%
echo    Get your api_id and api_hash from: https://my.telegram.org/apps
echo    ^(If the form shows ERROR, see docs\getting-api-credentials.md^)
echo.
echo 2. Run a scan ^(first run will prompt for login if no session^):
echo    call .venv\Scripts\activate.bat
echo    scripts\scan.bat channel_lists\example.txt
goto config_done

:config_exists
echo T-Sense config already exists at %T_SENSE_CONFIG% - skipping.
echo To reconfigure, edit: %T_SENSE_CONFIG%

:config_done

if not exist "output" mkdir output

echo.
echo Setup complete. Next: edit config and run a scan
echo   Config:  %T_SENSE_CONFIG%
echo   Scan:    call .venv\Scripts\activate.bat ^&^& scripts\scan.bat channel_lists\example.txt
