Class PoShPal_AccessToken {
    [string]$AccessToken
    [string]$Expires

    PoShPal_AccessToken(
        [string]$access_token,
        [datetime]$expires
    ){
        $this.AccessToken = $access_token
        $this.Expires = $expires
    }

    PoShPal_AccessToken(
        [PSObject]$In
    ){
        If(
            $In.PSObject.Properties.Name -contains 'access_token' -and
            $In.PSObject.Properties.Name -contains 'expires_in'
        ){
            $this.Expires = (Get-Date).AddSeconds($In.expires_in)
            $this.AccessToken = $In.access_token
        }Else{
            Throw 'Improperly formatted object'
        }
    }
}
Function Save-PayPalAccessToken {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [PoShPal_AccessToken]$Token,
        [string]$RegistryPath = 'HKCU:\Software\PoShPal'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'Expires' -Value $Token.Expires -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'AccessToken' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Token.AccessToken -AsPlainText -Force)) -Force | Out-Null
    Get-PayPalLocalToken
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Function Get-PayPalAccessToken {
    Param(
        [string]$ClientID,
        [string]$ClientSecret
    )
    $baseUri = 'https://api.paypal.com/v1/oauth2/token.'

    $encodedAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientID`:$ClientSecret"))

    $headers = @{
        'content-type' = 'application/x-www-form-urlencoded'
        'Accept' = 'application/json'
        'Accept-Language' = 'en_US'
        'Authorization' = "Basic $encodedAuthorization"
    }

    $body = @(
        '&grant_type=client_credentials'
    ) -join ''

    $response = Invoke-WebRequest -Uri $baseUri -Body $body -Headers $headers -Method Post
    $AccessToken = [PoShPal_AccessToken]::new($($response.Content | ConvertFrom-Json))
    Save-PayPalAccessToken $AccessToken
}
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
# https://developer.paypal.com/docs/api/orders/v1/#orders_get
Function Get-PayPalOrder {
    Param(
        [string]$OrderID,
        [string]$AccessToken = $PayPalAuthConfig.AccessToken
    )
    $baseUri = 'https://api.paypal.com/v1/checkout/orders'

    $uri = "$baseUri/$orderID"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
}
