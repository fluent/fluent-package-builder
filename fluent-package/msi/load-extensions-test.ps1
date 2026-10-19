$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\fluent-package\\msi\\repositories\\fluent-package-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait -NoNewWindow

# DLLs must be found in the package, not in MSYS2 or other tools on PATH.
$ENV:PATH = "C:\Windows\System32;C:\Windows"

C:\opt\fluent\bin\ruby.exe C:\fluentd\fluent-package\msi\load-extensions-test.rb
if ($LASTEXITCODE -ne 0) {
    [Environment]::Exit($LASTEXITCODE)
}
