$ErrorActionPreference = 'Stop'

$msi = ((Get-Item "C:\\fluentd\\fluent-package\\msi\\repositories\\fluent-package-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Write-Host "Installing ${msi} ..."

Start-Process msiexec -ArgumentList "/i", $msi, "/quiet" -Wait -NoNewWindow
$initialStatus = (Get-Service fluentdwinsvc).Status
if ($initialStatus -ne "Stopped") {
    Write-Host "The initial status must be 'Stopped', but it was '${initialStatus}'."
    [Environment]::Exit(1)
}

$ENV:PATH="C:\\opt\\fluent\\bin;" + $ENV:PATH
$ENV:PATH="C:\\opt\\fluent;" + $ENV:PATH

td-agent --version

# https://github.com/fluent/fluent-package-builder/issues/618
$thresholdSeconds = 6
Write-Host "Measuring times to start the service..."
$timeSpans = 0..2 | % {
    Measure-Command { Start-Service fluentdwinsvc }
    Start-Sleep 15
    Stop-Service fluentdwinsvc
    Start-Sleep 15
}
Write-Host "Measured seconds to start the service:"
$timeSpans | %{ Write-Host $_.TotalSeconds }
if (($timeSpans | Measure-Object -Property TotalSeconds -Maximum).Maximum -gt $thresholdSeconds) {
    # It should be 0.5s ~ 3s because starting service should be done immediately.
    # (The only things that take time are starting Ruby and loading the libraries.)
    Write-Host "Launching is abnormally slow. (The max value is greater than ${thresholdSeconds}s)"
    [Environment]::Exit(1)
}

Get-ChildItem "C:\\opt\\fluent\\*.log" | %{
    if (Select-String -Path $_ -Pattern "[warn]", "[error]", "[fatal]" -SimpleMatch -Quiet) {
        Write-Host "There are abnormal level logs in ${_}:"
        Select-String -Path $_ -Pattern "[warn]", "[error]", "[fatal]" -SimpleMatch
        [Environment]::Exit(1)
    }
}

# Test: fluentd.bat
Start-Service fluentdwinsvc

$proc = Start-Process "C:\\opt\\fluent\\fluentd.bat" -Wait -NoNewWindow -PassThru
if ($proc.ExitCode -ne 2) {
    Write-Host "Failed to abort when already fluentdwinsvc service is running"
    [Environment]::Exit(1)
}
Write-Host "Succeeded to abort when already fluentdwinsvc service is running"

$proc = Start-Process "C:\\opt\\fluent\\fluentd.bat" -ArgumentList "--version" -Wait -NoNewWindow -PassThru
if ($proc.ExitCode -ne 0) {
    Write-Host "Failed to take the version"
    [Environment]::Exit(1)
}
Write-Host "Succeeded to take the version"

$proc = Start-Process "C:\\opt\\fluent\\fluentd.bat" -ArgumentList "--dry-run" -Wait -NoNewWindow -PassThru
if ($proc.ExitCode -ne 0) {
    Write-Host "Failed to dry-run"
    [Environment]::Exit(1)
}
Write-Host "Succeeded to dry-run"

$fluentdopt = "-c 'C:\opt\fluent\etc\fluent\fluentd.conf' -o 'C:\opt\fluent\fluentd.log' -v"
$proc = Start-Process "C:\\opt\\fluent\\fluentd.bat" -ArgumentList "--reg-winsvc-fluentdopt ""$fluentdopt""" -Wait -NoNewWindow -PassThru
$fluentdoptResult = Get-ItemPropertyValue -Path HKLM:\SYSTEM\CurrentControlSet\Services\fluentdwinsvc -Name fluentdopt
if ($proc.ExitCode -ne 0 -or $fluentdopt -ne $fluentdoptResult) {
    Write-Host "Failed to register fluentdopt"
    [Environment]::Exit(1)
}
Write-Host "Succeeded to register fluentdopt"

# Test: Uninstall
Stop-Service fluentdwinsvc
$msi -Match "fluent-package-([0-9\.]+)-.+\.msi"
$name = "Fluent Package v" + $matches[1]
Write-Host "Uninstalling ...${name}"
Get-CimInstance -Class Win32_Product -Filter "Name='${name}'" | Invoke-CimMethod -MethodName Uninstall
$exitcode = $LASTEXITCODE
if ($exitcode -ne 0) {
    [Environment]::Exit($exitcode)
}
Write-Host "Succeeded to uninstall ${name}"

# fluentd.conf should not be removed
$conf = (Get-ChildItem -Path "c:\\opt" -Filter "fluentd.conf" -Recurse -Name)
if ($conf -ne "fluent\etc\fluent\fluentd.conf") {
  Write-Host "Failed to find fluentd.conf: <${conf}>"
  [Environment]::Exit(1)
}
Write-Host "Succeeded to find fluentd.conf"

# fluentd-0.log should not be removed
$conf = (Get-ChildItem -Path "c:\\opt" -Filter "fluentd-0.log" -Recurse -Name)
if ($conf -ne "fluent\fluentd-0.log") {
  Write-Host "Failed to find fluentd-0.log: <${conf}>"
  [Environment]::Exit(1)
}
Write-Host "Succeeded to find fluentd-0.log"
