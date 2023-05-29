@echo off
if "%~nx0" == "td-agent.bat" (
  set TD_AGENT_TOPDIR=%~dp0..\
) else (
  set TD_AGENT_TOPDIR=%~dp0
)
set PATH=%TD_AGENT_TOPDIR%bin;%PATH%
set PATH=%TD_AGENT_TOPDIR%;%PATH%
set FLUENT_CONF=%TD_AGENT_TOPDIR%\etc\td-agent\td-agent.conf
set FLUENT_PLUGIN=%TD_AGENT_TOPDIR%\etc\td-agent\plugin
set TD_AGENT_VERSION=%TD_AGENT_TOPDIR%\bin\fluent-package-version.rb
for %%p in (%*) do (
    if "%%p"=="--version" (
        ruby "%TD_AGENT_VERSION%"
        goto last
    )
)
"%TD_AGENT_TOPDIR%\bin\fluentd" %*

:last
