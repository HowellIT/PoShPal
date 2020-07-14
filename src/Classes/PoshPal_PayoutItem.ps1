# https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#definition-payout_item

Class PoshPal_PayoutItem {
    [ValidateSet('Email','Phone','PayPal_ID')]
    [string]$RecipientType
    [string]$Receiver
    [string]$Value
    [ValidateLength(3,3)]
    [string]$Currency
    [string]$Note
    [string]$SenderItemID

    PoshPal_PayoutItem (
        [string]$RecipientType,
        [string]$Receiver,
        [string]$Value,
        [string]$Currency,
        [string]$Note,
        [string]$SenderItemID
    ) {
        $this.RecipientType = $RecipientType
        $this.Receiver = $Receiver
        $this.Value = $Value
        $this.Currency = $Currency
        $this.Note = $Note
        $this.SenderItemID = $SenderItemID
    }

    PoshPal_PayoutItem (
        [string]$RecipientType,
        [string]$Receiver,
        [string]$Value,
        [string]$Currency
    ) {
        $this.RecipientType = $RecipientType
        $this.Receiver = $Receiver
        $this.Value = $Value
        $this.Currency = $Currency
    }

    [string] ToString(){
        return "$($this.Receiver) - $($this.Value)"
    }

    [string] ToJson(){
        return @{
            recipient_Type = $this.RecipientType
            receiver = $this.Receiver
            amount = @{
                value = $this.Value
                currency = $this.Currency
            }
            note = $this.Note
            sender_item_id = $this.SenderItemID
        } | ConvertTo-Json -Depth 2
    }

    [hashtable] ToHashtable(){
        $return = @{
            recipient_type = $this.RecipientType
            receiver = $this.Receiver
            amount = @{
                value = $this.Value
                currency = $this.Currency
            }
        }
        if ($this.Note.Length -gt 0) {
            $return['note'] = $this.Note
        }
        if ($this.SenderItemID.Length -gt 0) {
            $return['sender_item_id'] = $this.SenderItemID
        }
        return $return
    }
}