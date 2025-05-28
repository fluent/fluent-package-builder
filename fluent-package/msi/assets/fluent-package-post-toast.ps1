$binDir = $(Split-Path $MyInvocation.MyCommand.Path -Parent)
$topDir = $(Split-Path $binDir -Parent)
$xml = @"
<toast scenario="reminder">
  <visual>
    <binding template="ToastGeneric">
      <image id="1" placement="appLogoOverride" src="$(Join-Path $topDir -ChildPath "share/fluent-package-toast-icon.png")" alt="Fluentd logo"/>
      <text>Fluent Package has been installed!</text>
      <text>If you want enterprise technical support, access the following URL</text>
      <text>https://www.fluentd.org/enterprise=services</text>
    </binding>
  </visual>
  <actions>
    <action content="Check enterprise services for Fluentd" activationType="protocol" arguments="https://www.fluentd.org/enterprise_services" />
  </actions>
</toast>
"@
$XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
$XmlDocument.loadXml($xml)
# Fluent Package Command Prompt
$App = $(Get-StartApps -Name "Fluent Package Command Prompt")
$AppId = $App.AppID
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($XmlDocument)
