Function Get-PayPalNextInvoiceNumber {
    [cmdletbinding()]
    param (
        [string]$InvoiceNumber
    )
    $uri = 'invoicing/generate-next-invoice-number'

    if ($PSBoundParameters.Keys -contains 'InvoiceNumber') {
        $body = @{invoice_number = $InvoiceNumber }
        $response = Invoke-PayPalRestMethod -Uri $uri -Method POST -Body ($body | ConvertTo-Json -Compress)
    } else {
        $response = Invoke-PayPalRestMethod -Uri $uri -Method POST
    }

    $response.invoice_number
}