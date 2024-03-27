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
