@echo off
title Fluent-package post install script
if not "%~dp0" == "C:\opt\fluent\bin\" (
   "%~dp0gem" pristine --only-executables --all
)
