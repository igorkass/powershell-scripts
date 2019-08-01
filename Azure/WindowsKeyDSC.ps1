Configuration WindowsKey
{
    Import-DscResource -ModuleName DSCR_MSLicense

    Node Win2012Datacenter
    {
        cWindowsLicense Win2012Datacenter
        {
            ProductKey = ""
            Activate   = $true
            Force = $true
        }
    }

    Node Win2016Datacenter
    {
        cWindowsLicense Win2016Datacenter
        {
            ProductKey = ""
            Activate   = $true
            Force = $true
        }
    }
}