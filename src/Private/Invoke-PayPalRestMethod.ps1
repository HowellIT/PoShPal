Function Invoke-PayPalRestMethod {
    [cmdletbinding()]
    param (
        [string]$Method,
        [string]$Uri,
        [object]$Body,
        [string]$AccessToken = $PayPalAuthConfig.AccessToken.AccessToken
    )
    $baseUri = 'https://api.paypal.com/v2/'

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type'  = 'application/json'
    }

    $splat = @{
        Uri     = "$baseUri$Uri"
        Method  = $Method
        Headers = $headers
    }

    if ($PSBoundParameters.Keys -contains 'Body') {
        $splat['Body'] = $Body
    }

    Write-Verbose "Splat: $($splat | ConvertTo-Json)"

    Invoke-RestMethod @splat
}