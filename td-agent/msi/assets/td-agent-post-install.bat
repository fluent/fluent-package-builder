@echo off
title Td-agent post install script
if not "%~dp0" == "%PROGRAMFILES%\Treasure Data\TD-Agent4\bin\" (
   "%~dp0gem" pristine --only-executables --all
)
