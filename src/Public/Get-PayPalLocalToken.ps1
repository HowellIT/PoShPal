Function Get-PayPalLocalToken {
    Param(
        [string]$RegistryPath = 'HKCU:\Software\PoShPal'
    )
    Function ConvertTo-PlainText{
        Param(
            [string]$string
        )
        $ss = ConvertTo-SecureString $string
        $creds = New-Object pscredential('PoShPal',$ss)
        $creds.GetNetworkCredential().Password
    }
    $properties = 'Expires'
    $propertiesToConvert = 'AccessToken' #,'ClientID','ClientSecret'
    [string[]]$combinedProperties = $properties,$propertiesToConvert
    $obj = Get-ItemProperty $RegistryPath | Select $combinedProperties
    ForEach($property in $propertiesToConvert){
        $obj."$property" = ConvertTo-PlainText $obj."$property"
    }
    <#$global:PayPalAuthConfig = [PSCustomObject]@{
        UserToken = [PoShPal_AccessToken]::new($obj.Token,$obj.Expires)
        #ClientCredentials = [eBayAPI_ClientCredentials]::new($obj.ClientID,$obj.ClientSecret,$obj.RUName)
    }#>
    $global:PayPalAuthConfig = [PoShPal_AccessToken]::new($obj.AccessToken,$obj.Expires)
    $PayPalAuthConfig
}