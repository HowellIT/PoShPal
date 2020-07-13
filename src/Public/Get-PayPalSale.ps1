# https://developer.paypal.com/docs/api/payments/v1/#sale_get
Function Get-PayPalSale {
    [cmdletbinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(
            Mandatory
        )]
        [string]$SaleID
    )
    $baseUri = 'payments/sale'

    $uri = "$baseUri/$SaleID"

    Invoke-PayPalRestMethod -Uri $uri -Method Get
}