@echo off
if "%~nx0" == "td-agent.bat" (
  set "FLUENT_PACKAGE_TOPDIR=%~dp0..\"
) else (
  set "FLUENT_PACKAGE_TOPDIR=%~dp0"
)

@rem Convert path separator from backslash to forwardslash
setlocal enabledelayedexpansion
set FLUENT_PACKAGE_TOPDIR=!FLUENT_PACKAGE_TOPDIR:\=/!

set PATH=%FLUENT_PACKAGE_TOPDIR%bin;%PATH%
set PATH=%FLUENT_PACKAGE_TOPDIR%;%PATH%
set "FLUENT_CONF=%FLUENT_PACKAGE_TOPDIR%etc/fluent/fluentd.conf"
set "FLUENT_PLUGIN=%FLUENT_PACKAGE_TOPDIR%etc/fluent/plugin"
set "FLUENT_PACKAGE_VERSION=%FLUENT_PACKAGE_TOPDIR%bin/fluent-package-version.rb"
set FLUENT_FORCE_RUN=0
set FLUENT_ARGS=
for %%p in (%*) do (
    if "%%p"=="--version" (
        ruby "%FLUENT_PACKAGE_VERSION%"
        goto last
    )
    if "%%p"=="--force-running-multiple-instance" (
        set /a FLUENT_FORCE_RUN=1
    ) else (
        set "FLUENT_ARGS=!FLUENT_ARGS! %%p"
    )
)

@rem Abort if the fluentdwinsvc service is running without --force option.
sc query fluentdwinsvc | findstr RUNNING > nul
if !ERRORLEVEL! equ 0 (
    if %FLUENT_FORCE_RUN% equ 1 (
        goto noguard
    ) else (
        echo Error: can't start duplicate Fluentd instance. Use --force-running-multiple-instance option explicitly.
        exit /b 2
    )
)

:noguard
"%FLUENT_PACKAGE_TOPDIR%/bin/fluentd" %FLUENT_ARGS%
endlocal

:last
