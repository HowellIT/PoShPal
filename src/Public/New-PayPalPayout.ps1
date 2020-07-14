Function New-PayPalPayout {
    [cmdletbinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [string]$BatchID,
        [Parameter(
            Mandatory
        )]
        [string]$EmailSubject,
        [Parameter(
            Mandatory
        )]
        [string]$EmailMessage,
        [string]$Note,
        [PoshPal_PayoutItem[]]$PayoutItems
    )
    $uri = 'payments/payouts'

    $batchHeader = @{
        sender_batch_id = $BatchID
        email_subject = $EmailSubject
        email_message = $EmailMessage
    }

    if ($PSBoundParameters.Keys -contains 'Note') {
        $batchHeader['note'] = $Note
    }

    $body = @{
        sender_batch_header = $batchHeader
        items = @(($PayoutItems | %{$_.ToHashtable()}))
    }

    $Body | ConvertTo-Json -Depth 5

    Invoke-PayPalRestMethod -Method Post -Uri $uri -Body ($body | ConvertTo-Json -Depth 5)
}