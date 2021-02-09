Function Get-PayPalPayout {
    [cmdletbinding()]
    param (
        [string]$PayoutBatchID
    )
    $baseUri = '/payments/payouts/'

    Invoke-PayPalRestMethod -Method Get -Uri "$baseUri/$payoutBatchID"
}