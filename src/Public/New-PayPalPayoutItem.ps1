Function New-PayPalPayoutItem {
    [cmdletbinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateSet('Email','Phone','PayPal_ID')]
        [string]$RecipientType,
        [Parameter(
            Mandatory
        )]
        [string]$Receiver,
        [Parameter(
            Mandatory
        )]
        [string]$Value,
        [ValidateLength(3,3)]
        [string]$Currency = 'USD',
        [string]$Note,
        [string]$SenderItemID
    )
    $pItem = [PoshPal_PayoutItem]::new($RecipientType,$Receiver,$Value,$Currency)
    if ($PSBoundParameters.Keys -contains 'Note') {
        $pItem.Note = $Note
    }
    if ($PSBoundParameters.Keys -contains 'SenderItemID') {
        $pItem.SenderItemID = $SenderItemID
    }
    $pItem
}