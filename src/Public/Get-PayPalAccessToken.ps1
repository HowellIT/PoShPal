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