@echo off
title Fluent-package post toast script
if exist "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" (
  if exist "%~dp0..\bin\fluent-package-post-toast.ps1" (
    "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "%~dp0..\bin\fluent-package-post-toast.ps1"
  )
)
