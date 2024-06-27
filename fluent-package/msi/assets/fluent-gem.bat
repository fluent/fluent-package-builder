@echo off
setlocal

if "%~nx0" == "td-agent-gem.bat" (
  set "FLUENT_PACKAGE_TOPDIR=%~dp0..\"
) else (
  set "FLUENT_PACKAGE_TOPDIR=%~dp0"
)
set "FLUENT_PACKAGE_BINDIR=%FLUENT_PACKAGE_TOPDIR%bin"
set PATH=%FLUENT_PACKAGE_BINDIR%;%PATH%
for /f "usebackq" %%i in (`^""%FLUENT_PACKAGE_BINDIR%\ruby.exe" -rrbconfig -e "print RbConfig::CONFIG['ruby_version']"^"`) do set RUBY_VERSION=%%i
set "GEM_HOME=%FLUENT_PACKAGE_TOPDIR%lib\ruby\gems\%RUBY_VERSION%"
set "GEM_PATH=%FLUENT_PACKAGE_TOPDIR%lib\ruby\gems\%RUBY_VERSION%"
"%FLUENT_PACKAGE_BINDIR%\fluent-gem" %*

endlocal
