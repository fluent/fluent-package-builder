$ErrorActionPreference = 'Stop'

$PSVersionTable

$base_uri = "http://packages.treasuredata.com.s3.amazonaws.com"
&git fetch --unshallow
$previous_version = (git describe --abbrev=0 --tags) -Replace "v",""
$major_version = ([version] $previous_version).Major
try {
    "Previous version from git: {0}" -F $previous_version | Write-Host
    $previous_msi_name = "fluent-package-${previous_version}-x64.msi"
    $response = Invoke-WebRequest -UseBasicParsing -Uri "${base_uri}/${major_version}/windows/${previous_msi_name}" -OutFile $previous_msi_name -PassThru
}
catch {
    $heroku_uri = 'http://td-agent-package-browser.herokuapp.com'
    Write-Host "An exception was caught: $($_.Exception.Message). Try to find previous version in ${heroku_uri} instead"
    "Checking package major version: {0}" -F $major_version | Write-Host
    "Checking {0}/{1}/windows" -F $heroku_uri, $major_version | Write-Host
    $msi_links = (Invoke-WebRequest -UseBasicParsing -Uri "${heroku_uri}/${major_version}/windows").Links.href | Where-Object {$_ -like "*.msi"}
    $msi_versions = $($msi_links | Select-String '(\d+\.\d+\.\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }) | Sort-Object {[version] $_}
    $previous_version = $msi_versions | Select-Object -Last 1
    "Previous version from {0}: {1}" -F ${heroku_uri}, $previous_version | Write-Host
    $previous_msi_name = "fluent-package-${previous_version}-x64.msi"
    $response = Invoke-WebRequest -UseBasicParsing -Uri "${base_uri}/${major_version}/windows/${previous_msi_name}" -OutFile $previous_msi_name -PassThru
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


