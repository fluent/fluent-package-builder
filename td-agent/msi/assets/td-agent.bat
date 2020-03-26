@echo off
set TD_AGENT_TOPDIR=%~dp0\..
set PATH="%~dp0";%PATH%
set FLUENT_CONF=%TD_AGENT_TOPDIR%\etc\td-agent\td-agent.conf
set FLUENT_PLUGIN=%TD_AGENT_TOPDIR%\etc\td-agent\plugin
"%TD_AGENT_TOPDIR%\bin\fluentd" %*
