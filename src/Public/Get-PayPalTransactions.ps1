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
    $baseUri = 'reporting/transactions'

    $uri = "$baseUri"

    $body = @{
        start_date = (Get-Date $StartDate -Format o) -replace '(\.\d+)',''
        end_date = (Get-Date $EndDate -Format o) -replace '(\.\d+)',''
        fields = 'all'
    }

    If($PSBoundParameters.ContainsKey('TransactionId')){
        $body['transaction_id'] = $TransactionId
    }

    Write-Verbose "Body: $($body | ConvertTo-Json)"

    $response = Invoke-PayPalRestMethod -Uri $uri -Method Get -Body $body
    $response.transaction_details
}