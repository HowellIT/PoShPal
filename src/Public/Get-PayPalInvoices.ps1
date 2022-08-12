Function Get-PayPalInvoices {
    [cmdletbinding()]
    param (
        [string]$Id
    )
    $baseUri = 'invoicing/invoices'

    if ($PSBoundParameters.Keys -contains 'Id') {
        $uri = "$baseUri/$Id"
    } else {
        $uri = "$baseUri"
    }

    $response = Invoke-PayPalRestMethod -Uri $uri -Method Get
    if ($PSBoundParameters.Keys -contains 'Id') {
        $response
    } else {
        $response.items
    }
}