@echo on
title Fluent-package post migration script

if exist "%~dp0..\..\td-agent" (
  setlocal enabledelayedexpansion
  sc query state=inactive | findstr fluentdwinsvc
  if !ERRORLEVEL! == 1 (
    @rem NOTE: If the service is not stopped here, it is a BUG.
    @rem This state can cause fatal problems with the installation, so we should cancel this process.
    @rem (If trying to stop it by the command such as `$ net stop fluentdwinsvc`, it can fail as "The service is starting or stopping.  Please try again later.".)
    echo "WARN: Active fluentdwinsvc service is detected. This is unexpected. Migration process has been canceled."
    exit /b 1
  )
  endlocal

  if not exist "%~dp0..\etc\fluent" (
    echo "Create c:\opt\fluent\etc\fluent directory"
    mkdir "%~dp0..\etc\fluent"
  )

  if exist "%~dp0..\..\td-agent\etc\td-agent\td-agent.conf" (
    echo "Migrate c:\opt\td-agent\etc\td-agent.conf"
    move /Y "%~dp0..\..\td-agent\etc\td-agent\td-agent.conf" "%~dp0..\etc\fluent\td-agent.conf"
    echo "Migrate td-agent.conf to c:\opt\fluent\etc\fluent\fluentd.conf"
    copy /Y "%~dp0..\etc\fluent\td-agent.conf" "%~dp0..\etc\fluent\fluentd.conf"
  )

  @rem NOTE: do not migrate log files not to lose log accidentally

  echo "Migrate c:\opt\td-agent\etc\td-agent\* files"
  for %%f in (%~dp0..\..\td-agent\etc\td-agent\*) do (
    move /Y %%f "%~dp0..\etc\fluent\"
  )
  if not exist "%~dp0..\etc\fluent\plugin" (
    mkdir "%~dp0..\etc\fluent\plugin"
  )
  echo "Migrate c:\opt\td-agent\etc\plugin directory"
  for /d %%d in (%~dp0..\..\td-agent\etc\plugin\*) do (
    move /Y %%d "%~dp0..\etc\fluent\plugin\"
  )

  echo "Ensure remaining files under td-agent"
  tree /F %~dp0..\..\td-agent

  @rem create symbolic link to c:\opt\fluent (we can't use hardlink for directory)
  if exist "%~dp0..\..\td-agent\etc\td-agent" (
    rmdir /S /Q "%~dp0..\..\td-agent\etc\td-agent"
  )
  echo "Create symlink c:\opt\td-agent\etc\td-agent to c:\opt\fluent\etc\fluent"
  mklink /D %~dp0..\..\td-agent\etc\td-agent %~dp0..\..\fluent\etc\fluent
)
