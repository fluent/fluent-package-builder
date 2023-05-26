@echo off
if "%~nx0" == "td-agent.bat" (
  set FLUENT_PACKAGE_TOPDIR=%~dp0..\
  set TD_AGENT_TOPDIR=%~dp0..\..\td-agent
) else (
  set FLUENT_PACKAGE_TOPDIR=%~dp0
  set TD_AGENT_TOPDIR=%~dp0..\td-agent
)
set PATH=%FLUENT_PACKAGE_TOPDIR%bin;%PATH%
set PATH=%FLUENT_PACKAGE_TOPDIR%;%PATH%
set FLUENT_CONF=%TD_AGENT_TOPDIR%\etc\td-agent\td-agent.conf
set FLUENT_PLUGIN=%TD_AGENT_TOPDIR%\etc\td-agent\plugin
set FLUENT_PACKAGE_VERSION=%FLUENT_PACKAGE_TOPDIR%\bin\fluent-package-version.rb
for %%p in (%*) do (
    if "%%p"=="--version" (
        ruby "%FLUENT_PACKAGE_VERSION%"
        goto last
    )
)
"%FLUENT_PACKAGE_TOPDIR%\bin\fluentd" %*

:last
