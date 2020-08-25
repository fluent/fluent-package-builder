$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\td-agent\\msi\\repositories\\td-agent-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait -NoNewWindow

$ENV:PATH="C:\\opt\\td-agent\\bin;" + $ENV:PATH

td-agent --version

td-agent-gem install serverspec
$application = (Get-ChildItem -Path "c:\\opt" -Filter "find_installed_application.ps1" -Recurse -Name)
$destination = (Get-Item (Join-Path "c:\\opt" $application)).DirectoryName
Copy-Item "C:\\fluentd\\serverspec\\find_installed_gem.ps1" $destination
$ENV:INSTALLATION_TEST=$TRUE
cd C:\fluentd; rake serverspec:windows

$exitcode = $LASTEXITCODE
if ($exitcode -ne 0) {
    [Environment]::Exit($exitcode)
}
