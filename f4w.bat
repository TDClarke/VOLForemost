@echo off
rem This script processes .dmp files in the current directory and extracts specified file types.

rem Set variables for memory dump, target process, file type to extract, and output directory
set "memory_dump=itest.mem"
set "process_to_extract=firefox.exe"
set "file_type_to_extract=jpg"
set "extracted_dir=extracted"

rem Enable delayed expansion for handling variables inside loops
setlocal enabledelayedexpansion

rem Initialize a variable to hold the list of .dmp files
set "dmp_files="

rem Loop through all .dmp files in the current directory and build the list
for %%f in (*.dmp) do (
    set "dmp_files=!dmp_files! %%f"
)

rem Check if no .dmp files were found
if "%dmp_files%"=="" (
    echo No .dmp files found in current directory. Something went wrong.
    exit /b 1
)

rem Check if foremost.exe exists in the current directory
if not exist foremost.exe (
    echo foremost.exe not found in the current directory. Please ensure it is present.
    exit /b 1
)

rem Create the output directory if it doesn't exist
if not exist "%extracted_dir%" (
    mkdir "%extracted_dir%"
)

rem Extract the specified file types from the .dmp files using foremost
echo Extracting files of type "%file_type_to_extract%" to directory "%extracted_dir%".
foremost.exe -t %file_type_to_extract% -o %extracted_dir% %dmp_files%

rem Check if the extraction was successful
if %errorlevel% neq 0 (
    echo Foremost extraction failed. Check the logs for more details.
    exit /b 1
)

echo Extraction completed successfully.
