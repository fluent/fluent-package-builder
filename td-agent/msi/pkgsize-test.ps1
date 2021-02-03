$ErrorActionPreference = 'Stop'

&git fetch --unshallow
$previous_version = (git describe --abbrev=0 --tags) -Replace "v",""
$previous_msi_name = "td-agent-${previous_version}-x64.msi"

"Previous version: {0}" -F $previous_version | Write-Host
$base_uri = "http://packages.treasuredata.com.s3.amazonaws.com"
$response = Invoke-WebRequest -Uri "${base_uri}/4/windows/${previous_msi_name}" -OutFile $previous_msi_name -PassThru
$msi = (Get-Item "td-agent\\msi\\repositories\\td-agent-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1
"Checking package size: {0}" -F $msi.FullName | Write-Host
$package_size_threshold = $response.RawContentLength * 1.2
$previous_msi = (Get-Item $previous_msi_name)
"{0:0.0} MiB ({1}) {2}" -F ($previous_msi.Length / 1024 / 1024), $previous_msi.Length, $previous_msi.Name | Write-Host
"{0:0.0} MiB ({1}) {2}" -F ($msi.Length / 1024 / 1024), $msi.Length, $msi.Name | Write-Host
if ($msi.Length -gt $package_size_threshold) {
    "{0:0.0} MiB ({1}) exceeds {2}. Check whether needless file are bundled or not." -F ($msi.Length / 1024 / 1024), $msi.Length, $package_size_threshold | Write-Error
    [Environment]::Exit(1)
}
Write-Host "Succeeded to check package size"


