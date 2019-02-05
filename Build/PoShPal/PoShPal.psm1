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
Class PoShPal_ClientCredentials {
    [string]$ClientID
    [string]$ClientSecret

    PoShPal_ClientCredentials(
        [string]$ClientID,
        [string]$ClientSecret
    ){
        $this.ClientID = $ClientID
        $this.ClientSecret = $ClientSecret
    }
}
Function Confirm-PayPalAccessToken {
    Param(
        [ValidateNotNullOrEmpty()]
        [PoShPal_AccessToken]$AccessToken,
        [ValidateNotNullOrEmpty()]
        [PoShPal_ClientCredentials]$ClientCredentials = $PayPalAuthConfig.ClientCredentials
    )
    # this will need more than just checking expiration date
    If(($AccessToken.Expires -lt (Get-Date)) -and ($ClientCredentials)){
        Try{
            Get-PayPalAccessToken -ClientID $ClientCredentials.ClientID -ClientSecret $ClientCredentials.ClientSecret
            $true
        }Catch{
            $false
        }
    }Else{
        $true
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
}
Function Save-PayPalClientCredentials {
    Param(
        [PoShPal_ClientCredentials]$Creds,
        [string]$RegistryPath = 'HKCU:\Software\PoShPal'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'ClientID' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientID -AsPlainText -Force)) -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'ClientSecret' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientSecret -AsPlainText -Force)) -Force | Out-Null
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Function Get-PayPalAccessToken {
    Param(
        [ValidateNotNullOrEmpty()]
        [string]$ClientID = $PayPalAuthConfig.ClientCredentials.ClientID,
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret = $PayPalAuthConfig.ClientCredentials.ClientSecret
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
    $creds = [PoShPal_ClientCredentials]::new($ClientID,$ClientSecret)
    Save-PayPalAccessToken $AccessToken
    Save-PayPalClientCredentials $creds
    Get-PayPalLocalToken
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
    $combinedProperties = @()
    $properties = 'Expires'
    $propertiesToConvert = 'AccessToken','ClientID','ClientSecret'
    $combinedProperties += $properties
    $combinedProperties += $propertiesToConvert
    $obj = Get-ItemProperty $RegistryPath | Select $combinedProperties
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
# https://developer.paypal.com/docs/api/payments/v1/#sale_get
Function Get-PayPalSale {
    Param(
        [ValidateNotNullOrEmpty()]
        [string]$SaleID,
        [string]$AccessToken = $PayPalAuthConfig.AccessToken.AccessToken
    )
    $baseUri = 'https://api.paypal.com/v1/payments/sale'

    $uri = "$baseUri/$SaleID"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
}
# https://developer.paypal.com/docs/api/sync/v1/#transactions
Function Get-PayPalTransactions {
    [cmdletbinding()]
    Param(
        [string]$TransactionId,
        [ValidateNotNullOrEmpty()]
        [datetime]$StartDate,
        [datetime]$EndDate = (Get-Date),
        [string]$AccessToken = $PayPalAuthConfig.AccessToken.AccessToken
    )
    $baseUri = 'https://api.paypal.com/v1/reporting/transactions'

    $uri = "$baseUri"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    $body = @{
        start_date = (Get-Date $StartDate -Format o) -replace '(\.\d+)',''
        end_date = (Get-Date $EndDate -Format o) -replace '(\.\d+)',''
        fields = 'all'
    }

    If($PSBoundParameters.ContainsKey('TransactionId')){
        $body['transaction_id'] = $TransactionId
    }

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Body $body
    $response.transaction_details
}
