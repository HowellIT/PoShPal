Function Get-PayPalLocalToken {
    Param(
        [string]$Path = (Get-PayPalAuthConfigSavePath)
    )
    Function ConvertTo-PlainText{
        Param(
            [string]$string
        )
        $ss = ConvertTo-SecureString $string
        $creds = New-Object pscredential('PoShPal',$ss)
        $creds.GetNetworkCredential().Password
    }
    $combinedProperties = @()
    $properties = 'Expires'
    $propertiesToConvert = 'AccessToken','ClientID','ClientSecret'
    $combinedProperties += $properties
    $combinedProperties += $propertiesToConvert
    $obj = Get-Content "$Path\config.json" | ConvertFrom-Json | Select $combinedProperties
    ForEach($property in $propertiesToConvert){
        $obj."$property" = ConvertTo-PlainText $obj."$property"
    }
    $global:PayPalAuthConfig = [PSCustomObject]@{
        AccessToken = [PoShPal_AccessToken]::new($obj.AccessToken,$obj.Expires)
        ClientCredentials = [PoShPal_ClientCredentials]::new($obj.ClientID,$obj.ClientSecret)
    }#>
    #$global:PayPalAuthConfig = [PoShPal_AccessToken]::new($obj.AccessToken,$obj.Expires)
    $PayPalAuthConfig
}