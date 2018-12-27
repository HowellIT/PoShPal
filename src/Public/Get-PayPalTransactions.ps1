# https://developer.paypal.com/docs/api/sync/v1/#transactions
Function Get-PayPalTransactions {
    Param(
        [string]$TransactionId,
        [string]$AccessToken = $PayPalAuthConfig.AccessToken.AccessToken
    )
    $baseUri = 'https://api.paypal.com/v1/reporting/transactions'

    $uri = "$baseUri"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    If($PSBoundParameters.ContainsKey('TransactionId')){
        $body = @{
            transaction_id = $TransactionId
        }
    }

    Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Body $body
}