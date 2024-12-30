@echo off

:: Configuration variables
set "memory_dump=itest.mem"
set "process_to_extract=firefox.exe"
set "file_type_to_extract=jpg"
set "extracted_dir=extracted"

:: Check for Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in the PATH.
    exit /b 1
)

:: Check for foremost.exe
if not exist "foremost.exe" (
    echo Error: 'foremost.exe' is missing in the current directory.
    exit /b 1
)

:: Extract process PIDs from the memory dump
echo Extracting PIDs for process: %process_to_extract%
for /f "tokens=*" %%i in ('python vol.py -f "%memory_dump%" windows.pslist.PsList 2^>nul ^| findstr "%process_to_extract%" ^| for /f "tokens=1 delims=^t" %%j in ("%%i") do @echo %%j') do (
    set "processes=!processes! %%i"
)

:: Check if any PIDs were found
if "%processes%"=="" (
    echo No processes found for '%process_to_extract%'. Exiting.
    exit /b 1
)

:: Dump memory for each PID
echo Found %count% processes. Dumping memory...
for %%PID in (%processes%) do (
    echo Dumping memory for PID: %%PID
    python vol.py -f "%memory_dump%" windows.memmap.Memmap --dump --pid "%%PID" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Warning: Failed to dump memory for PID %%PID.
    )
)

:: Gather .dmp files
for %%f **.

