Param
(
    [Parameter(Mandatory=$true)]
    [string]$xmlFile,

    [Parameter(Mandatory=$true)]
    [string]$xmlNode,

    [Parameter(Mandatory=$true)]
    [string]$xmlString
)

function Remove-Xml-Node($filePath, $xmlPath) {
    $xml = [xml](cat $filePath)

    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
    $selectedNode = $xml.SelectSingleNode($xmlPath, $ns)

    if ($selectedNode) {
        $selectedNode.ParentNode.RemoveChild($selectedNode)
        $xml.Save($filePath)
    }

    else {
        Write-Output "xml node to delete not found $xmlPath"
        exit(1)
    }
}

Remove-Xml-Node $xmlPath "//ns:$xmlNode[contains(@Name,$xmlString)]"
