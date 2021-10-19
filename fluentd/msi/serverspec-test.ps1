$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\fluentd\\msi\\repositories\\fluentd-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait -NoNewWindow

$ENV:PATH="C:\\opt\\fluentd\\bin;" + $ENV:PATH

fluentd --version

fluentd-gem install --no-document serverspec
$ENV:INSTALLATION_TEST=$TRUE
cd C:\fluentd; rake serverspec:windows

$exitcode = $LASTEXITCODE
if ($exitcode -ne 0) {
    [Environment]::Exit($exitcode)
}
