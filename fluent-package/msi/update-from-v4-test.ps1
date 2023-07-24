$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-PSDebug -Trace 1

# Install v4
Invoke-WebRequest "https://s3.amazonaws.com/packages.treasuredata.com/4/windows/td-agent-4.5.0-x64.msi" -OutFile "td-agent-4.5.0-x64.msi"
Start-Process msiexec -ArgumentList "/i", "td-agent-4.5.0-x64.msi", "/quiet" -Wait -NoNewWindow
Start-Sleep 30 # Must wait until all processes are surely started.
$test_setting = @'
<source>
  @type sample
  tag test
</source>
<match test>
  @type file
  path "#{ENV['TD_AGENT_TOPDIR']}/output/test"
  <buffer []>
    @type memory
    flush_mode immediate
  </buffer>
</match>
'@
Add-Content -Path "C:\\opt\\td-agent\\etc\\td-agent\\td-agent.conf" -Encoding UTF8 -Value $test_setting
Restart-Service fluentdwinsvc
Start-Sleep 30 # Must wait until all processes are surely started.

# Update to v5
$new_package = ((Get-Item "C:\\fluentd\\fluent-package\\msi\\repositories\\fluent-package-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName
Start-Process msiexec -ArgumentList "/i", $new_package, "/quiet" -Wait -NoNewWindow
Start-Service fluentdwinsvc
Start-Sleep 30 # Must wait until all processes are surely started.

# Test: Access to the configs with the old path
If (-Not (Test-Path "C:\\opt\\td-agent\\etc\\td-agent\\fluentd.conf")) {
    [Environment]::Exit(1)
}
If (-Not (Test-Path "C:\\opt\\td-agent\\etc\\td-agent\\td-agent.conf")) {
    [Environment]::Exit(1)
}

# Test: Keep the old log files
If ((Get-ChildItem "C:\\opt\\td-agent\\*.log").Count -eq 0) {
    [Environment]::Exit(1)
}

# Test: The previous config works as before
$output_files = Get-ChildItem "C:\\opt\\td-agent\\output"
Start-Sleep 5
$output_files_after_sleep = Get-ChildItem "C:\\opt\\td-agent\\output"
If ($output_files_after_sleep.Count -le $output_files.Count) {
    [Environment]::Exit(1)
}
