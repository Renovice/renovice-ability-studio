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
set "EDITOR_EXE=%WORKSPACE_ROOT%work\builds\ability-editor\current\bin\renovice_ability_editor.exe"
cd /d "%EDITOR_ROOT%"

if not exist "%EDITOR_EXE%" (
    call "build_editor.bat"
    if errorlevel 1 exit /b 1
)

start "RENOVICE Ability Editor" "%EDITOR_EXE%"
exit /b 0
