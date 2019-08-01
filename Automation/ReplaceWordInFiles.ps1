Param(
    [Parameter(Mandatory=$True)]
    [string]$workingDir,

    [Parameter(Mandatory=$True)]
    [string]$sourceWord,

    [Parameter(Mandatory=$True)]
    [string]$targetWord,

    $searchOptions = (Read-Host -Prompt "1: case sensitive/whole word, 2: case sensitive/non-word, 3: case insensitive/whole word, 4: case insensitive/non-word")
)

$files = [System.IO.Directory]::EnumerateFiles("$workingDir","*.*","AllDirectories")

foreach ($file in $files) {

    switch ($searchOptions) {

        1 { (Get-Content -Path $file) -replace "(?-i)\b$sourceWord\b", $targetWord | Set-Content -Path $file }
        2 { (Get-Content -Path $file) -replace "(?-i)$sourceWord", $targetWord | Set-Content -Path $file }
        3 { (Get-Content -Path $file) -replace "\b$sourceWord\b", $targetWord | Set-Content -Path $file }
        4 { (Get-Content -Path $file) -replace $sourceWord, $targetWord | Set-Content -Path $file }
    }
}
