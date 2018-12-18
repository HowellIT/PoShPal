# https://developer.paypal.com/docs/api/payments/v1/#sale_get
Function Get-PayPalSale {
    Param(
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