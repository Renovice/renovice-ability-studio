@echo off
setlocal
set "WORKSPACE_ROOT=%~dp0"
:find_workspace
if exist "%WORKSPACE_ROOT%WORKSPACE.json" goto workspace_found
for %%I in ("%WORKSPACE_ROOT%..") do set "PARENT=%%~fI\"
if /I "%PARENT%"=="%WORKSPACE_ROOT%" (
    echo ERROR: Unable to locate WORKSPACE.json above %~dp0
    exit /b 1
)
set "WORKSPACE_ROOT=%PARENT%"
goto find_workspace
:workspace_found
set "EDITOR_ROOT=%WORKSPACE_ROOT%repos\apps\ability-editor"
set "BUILD_DIR=%WORKSPACE_ROOT%\work\builds\ability-editor\current"
cd /d "%EDITOR_ROOT%"

cmake -S "%EDITOR_ROOT%" -B "%BUILD_DIR%" -G Ninja -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --config Release
if errorlevel 1 exit /b 1

ctest --test-dir "%BUILD_DIR%" --output-on-failure -C Release
if errorlevel 1 exit /b 1

echo RENOVICE Ability Editor build and self-tests PASS
exit /b 0
