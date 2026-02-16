$ErrorActionPreference = 'Stop'

$base_uri = "https://fluentd.cdn.cncf.io"
&git fetch --unshallow
try {
    $previous_version = (git describe --abbrev=0 --tags) -Replace "v",""
    "Previous version from git: {0}" -F $previous_version | Write-Host
    $previous_msi_name = "fluent-package-${previous_version}-x64.msi"
    $previous_major_version = ([version]$previous_version).Major
    $response = Invoke-WebRequest -Uri "${base_uri}/lts/${previous_major_version}/windows/${previous_msi_name}" -OutFile $previous_msi_name -PassThru
}
catch {
    $heroku_uri = 'https://td-agent-package-browser.herokuapp.com'
    Write-Host "An exception was caught: $($_.Exception.Message). Try to find previous version in ${heroku_uri} instead"
    $msi_links = (Invoke-WebRequest -Uri "${heroku_uri}/lts/6/windows/index.html").Links.href | Where-Object {$_ -like "*.msi"}
    $msi_versions = $($msi_links | Select-String '(\d+\.\d+\.\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }) | Sort-Object {[version] $_}
    $previous_version = $msi_versions | Select-Object -Last 1
    "Previous version from {0}: {1}" -F ${heroku_uri}, $previous_version | Write-Host
    $previous_msi_name = "fluent-package-${previous_version}-x64.msi"
    $response = Invoke-WebRequest -Uri "${base_uri}/lts/6/windows/${previous_msi_name}" -OutFile $previous_msi_name -PassThru
}

$msi = (Get-Item "fluent-package\\msi\\repositories\\fluent-package-*.msi") | Sort-Object -Descending { $_.LastWriteTime } | Select-Object -First 1
"Checking package size: {0}" -F $msi.FullName | Write-Host
$package_size_threshold = $response.RawContentLength * 1.3
$previous_msi = (Get-Item $previous_msi_name)
"{0:0.0} MiB ({1}) {2}" -F ($previous_msi.Length / 1024 / 1024), $previous_msi.Length, $previous_msi.Name | Write-Host
"{0:0.0} MiB ({1}) {2}" -F ($msi.Length / 1024 / 1024), $msi.Length, $msi.Name | Write-Host
if ($msi.Length -gt $package_size_threshold) {
    "{0:0.0} MiB ({1}) exceeds {2}. Check whether needless file are bundled or not." -F ($msi.Length / 1024 / 1024), $msi.Length, $package_size_threshold | Write-Error
    [Environment]::Exit(1)
}
Write-Host "Succeeded to check package size"


