$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\fluent-package\\msi\\repositories\\fluent-package-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

# Remove property logs (/lp) since they are large.
$logOptions = "/liwearucmo"

$process = Start-Process msiexec -ArgumentList "/i", $msi, "/quiet", $logOptions, "installer.log", "OPTLOCATION=""C:\opt with space""" -Wait -NoNewWindow -PassThru

if ($process.ExitCode -ne 0) {
    Get-Content installer.log
    Write-Host ".msi failed with exit code: $($process.ExitCode)."
    [Environment]::Exit(1)
}

