Param
(
    [Parameter(Mandatory=$true)]
    [string]$xmlFile
)

$xml = [xml](Get-Content $xmlFile)

[string]$newRule = @"
<rule name="Redirect to Europe" stopProcessing="true">
  <match url="(.*)" />
  <conditions logicalGrouping="MatchAny">
    <add input="{HTTP_HOST}" pattern="^example\.com$" />
    <add input="{HTTP_HOST}" pattern="^www\.example\.com$" />
  </conditions>
  <action type="Redirect" url="https://europe.example.com/{R:1}" />
</rule>
"@

[xml]$newRuleXml = $newRule

$xml.configuration.'system.webServer'.rewrite.rules.AppendChild($xml.ImportNode($newRuleXml.rule, $true))

$xml.Save($xmlFile)