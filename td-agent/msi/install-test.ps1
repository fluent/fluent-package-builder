$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\td-agent\\msi\\repositories\\td-agent-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait -NoNewWindow

$ENV:PATH="C:\\opt\\td-agent\\bin;" + $ENV:PATH

td-agent --version

td-agent-gem install serverspec
$ENV:INSTALLATION_TEST=$TRUE
cd C:\fluentd; rake serverspec:windows
