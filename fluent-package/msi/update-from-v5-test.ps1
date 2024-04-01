$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Set-PSDebug -Trace 1

$v4MsiFilename = "td-agent-4.5.3-x64.msi"
$v5MsiFilename = "fluent-package-5.0.2-x64.msi"

Invoke-WebRequest "https://s3.amazonaws.com/packages.treasuredata.com/4/windows/$v4MsiFilename" -OutFile $v4MsiFilename
Invoke-WebRequest "https://s3.amazonaws.com/packages.treasuredata.com/5/windows/$v5MsiFilename" -OutFile $v5MsiFilename
$newPackage = ((Get-Item "C:\\fluentd\\fluent-package\\msi\\repositories\\fluent-package-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1).FullName

# Prepare v5 environment that is migrated from v4.
Start-Process msiexec -ArgumentList "/i", $v4MsiFilename, "/quiet" -Wait
Start-Sleep 30 # Must wait until all processes are surely started.

Stop-Service fluentdwinsvc
Start-Process msiexec -ArgumentList "/i", $v5MsiFilename, "/quiet" -Wait

if ((Get-Service fluentdwinsvc).Status -ne "Stopped") {
    Write-Error "V5 must not start automatically."
}

# Add new config
$newConfig = @'
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
Add-Content -Path "C:\\opt\\td-agent\\etc\\td-agent\\fluentd.conf" -Encoding UTF8 -Value $newConfig

# Update to the new package
Start-Process msiexec -ArgumentList "/i", $newPackage, "/quiet" -Wait
Start-Service fluentdwinsvc
Start-Sleep 30 # Must wait until all processes are surely started.

# Test: The previous config works as before
$outputFiles = Get-ChildItem "C:\\opt\\td-agent\\output"
Start-Sleep 5
$outputFilesAfterSleep = Get-ChildItem "C:\\opt\\td-agent\\output"
if ($outputFilesAfterSleep.Count -le $outputFiles.Count) {
    Write-Error ("The previous config does not work. Output file num: {0} to {1}." -f $outputFiles.Count, $outputFilesAfterSleep.Count)
}

# TODO: Add tests here when it becomes able to take over the fluentdopt and autostart configuration.
