@echo off
if "%~nx0" == "td-agent.bat" (
  set FLUENT_PACKAGE_TOPDIR=%~dp0..\
) else (
  set FLUENT_PACKAGE_TOPDIR=%~dp0
)

@rem Convert path separator from backslash to forwardslash
setlocal enabledelayedexpansion
set FLUENT_PACKAGE_TOPDIR=FLUENT_PACKAGE_TOPDIR=!FLUENT_PACKAGE_TOPDIR:\=/!

set PATH=%FLUENT_PACKAGE_TOPDIR%bin;%PATH%
set PATH=%FLUENT_PACKAGE_TOPDIR%;%PATH%
set FLUENT_CONF=%FLUENT_PACKAGE_TOPDIR%/etc/fluent/fluentd.conf
set FLUENT_PLUGIN=%FLUENT_PACKAGE_TOPDIR%/etc/fluent/plugin
set FLUENT_PACKAGE_VERSION=%FLUENT_PACKAGE_TOPDIR%/bin/fluent-package-version.rb
for %%p in (%*) do (
    if "%%p"=="--version" (
        ruby "%FLUENT_PACKAGE_VERSION%"
        goto last
    )
)
"%FLUENT_PACKAGE_TOPDIR%/bin/fluentd" %*
endlocal

:last
