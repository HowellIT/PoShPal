# https://developer.paypal.com/docs/api/orders/v1/#orders_get
Function Get-PayPalOrder {
    Param(
        [string]$OrderID,
        [string]$AccessToken = $PayPalAuthConfig.AccessToken.AccessToken
    )
    $baseUri = 'https://api.paypal.com/v1/checkout/orders'

    $uri = "$baseUri/$orderID"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
}