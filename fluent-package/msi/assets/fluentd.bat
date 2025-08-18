@echo off
setlocal

if "%~nx0" == "td-agent.bat" (
  set "FLUENT_PACKAGE_TOPDIR=%~dp0..\"
) else (
  set "FLUENT_PACKAGE_TOPDIR=%~dp0"
)

@rem Convert path separator from backslash to forwardslash
set FLUENT_PACKAGE_TOPDIR=%FLUENT_PACKAGE_TOPDIR:\=/%

set "FLUENT_PACKAGE_BINDIR=%FLUENT_PACKAGE_TOPDIR%bin"
set PATH=%FLUENT_PACKAGE_BINDIR%;%PATH%
set PATH=%FLUENT_PACKAGE_TOPDIR%;%PATH%
for /f "usebackq" %%i in (`^""%FLUENT_PACKAGE_BINDIR%\ruby.exe" -rrbconfig -e "print RbConfig::CONFIG['ruby_version']"^"`) do set RUBY_VERSION=%%i
set "GEM_HOME=%FLUENT_PACKAGE_TOPDIR%lib/ruby/gems/%RUBY_VERSION%"
set "GEM_PATH=%FLUENT_PACKAGE_TOPDIR%lib/ruby/gems/%RUBY_VERSION%"
set "FLUENT_CONF=%FLUENT_PACKAGE_TOPDIR%etc/fluent/fluentd.conf"
set "FLUENT_CONF_INCLUDE_DIR=%FLUENT_PACKAGE_TOPDIR%etc/fluent/conf.d"
set "FLUENT_PLUGIN=%FLUENT_PACKAGE_TOPDIR%etc/fluent/plugin"

setlocal enabledelayedexpansion
set "FLUENT_PACKAGE_VERSION=%FLUENT_PACKAGE_TOPDIR%bin/fluent-package-version.rb"
set PREVENT_DUPLICATE_LAUNCH=1
set HAS_SHORT_VERBOSE_OPTION=0

for %%p in (%*) do (
    if "%%p"=="--version" (
        ruby "%FLUENT_PACKAGE_VERSION%"
        goto last
    )
    if "%%p"=="-c" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="--config" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="--dry-run" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="--reg-winsvc" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="--reg-winsvc-fluentdopt" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="-h" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="--help" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="--show-plugin-config" set PREVENT_DUPLICATE_LAUNCH=0
    if "%%p"=="-v" set HAS_SHORT_VERBOSE_OPTION=1
)

@rem Abort if the fluentdwinsvc service is running and the config path is not specified.
if %PREVENT_DUPLICATE_LAUNCH% equ 1 (
    sc query fluentdwinsvc | findstr RUNNING > nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo Error: Can't start duplicate Fluentd instance with the default config.
        if %HAS_SHORT_VERBOSE_OPTION% equ 1 (
            echo.
            echo To take the version, please use '--version', not '-v' ^('--verbose'^).
        )
        echo.
        echo To start Fluentd, please do one of the following:
        echo   ^(Caution: Please be careful not to start multiple instances with the same config.^)
        echo   - Stop the Fluentd Windows service 'fluentdwinsvc'.
        echo   - Specify the config path explicitly by '-c' ^('--config'^).
        exit /b 2
    )
)
endlocal

"%FLUENT_PACKAGE_TOPDIR%bin/fluentd" %*

endlocal

:last
