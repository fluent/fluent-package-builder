$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\fluentd\\msi\\repositories\\fluentd-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait -NoNewWindow

$ENV:PATH="C:\\opt\\fluentd\\bin;" + $ENV:PATH

fluentd --version

$msi -Match "fluentd-([0-9\.]+)-.+\.msi"
$name = "Fluentd v" + $matches[1]
Write-Host "Uninstalling ...${name}"
Get-CimInstance -Class Win32_Product -Filter "Name='${name}'" | Invoke-CimMethod -MethodName Uninstall
$exitcode = $LASTEXITCODE
if ($exitcode -ne 0) {
    [Environment]::Exit($exitcode)
}
Write-Host "Succeeded to uninstall ${name}"

# fluentd.conf should not be removed
$conf = (Get-ChildItem -Path "c:\\opt" -Filter "fluentd.conf" -Recurse -Name)
if ($conf -ne "fluentd\etc\fluentd\fluentd.conf") {
  Write-Host "Failed to find fluentd.conf: <${conf}>"
  [Environment]::Exit(1)
}
Write-Host "Succeeded to find fluentd.conf"

# fluentd.log should not be removed
$conf = (Get-ChildItem -Path "c:\\opt" -Filter "fluentd.log" -Recurse -Name)
if ($conf -ne "fluentd\fluentd.log") {
  Write-Host "Failed to find fluentd.log: <${conf}>"
  [Environment]::Exit(1)
}
Write-Host "Succeeded to find fluentd.log"
