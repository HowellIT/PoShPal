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
    }

    If($PSBoundParameters.ContainsKey('TransactionId')){
        $body['transaction_id'] = $TransactionId
    }

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Body $body
    $response.transaction_details
}