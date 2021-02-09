Import-Module 'C:\Users\Anthony\GIT\PoShPal\build\PoShPal'
Get-PayPalLocalToken
Get-PaypalAccessToken

$payments = $report | ?{$_.PaymentType -ne 'Partner Payments'}# -and $_.PaymentType -notlike 'client*'}
$groups = $payments | Group-Object 'PayPal Email Address'
$payoutItems = foreach ($user in $groups) {
    $note = "TechSnips $($user.Group[0].MonthYear): "
    foreach ($group in $user.Group) {
        $note += "`n$($group.PaymentType) - `$$($group.PaymentOwed)"
    }
    $splat = @{
        Currency = 'USD'
        Note = $note
        Receiver = $user.group[0].'PayPal Email Address'
        RecipientType = 'Email'
        Value = ($user.group.PaymentOwed | Measure-Object -Sum).Sum
        SenderItemID = "$($user.group[0].MonthYear.Replace(' ',''))-$($user.group[0].'PayPal Email Address')"
    }
    New-PayPalPayoutItem @splat
}

$2pay = $report | ?{$_.Name -ne 'Adam Listek' -and $_.Name -ne 'Anthony Howell'}# -and $_.name -notlike '*black*'}
$test = $report | ?{$_.Name -like '*black*'}

$payoutItems = foreach ($pay in $2pay) {
    $splat = @{
        Currency = 'USD'
        Note = "TechSnips $($pay.MonthYear) - `$$($pay.PaymentOwed)"
        Receiver = $pay.'PayPal Email Address'
        RecipientType = 'Email'
        Value = $pay.PaymentOwed
        SenderItemID = "$($pay.MonthYear.Replace(' ',''))-$($pay.'PayPal Email Address')"
    }
    New-PayPalPayoutItem @splat
}

$date = (Get-Date).AddMonths(-1)
$splat = @{
    BatchID = "$((Get-Culture).DateTimeFormat.MonthNames[$date.Month-1])$($date.Year)-01"
    EmailMessage = "Thank you for your contribution to TechSnips!"
    EmailSubject = "TechSnips Payout - $((Get-Culture).DateTimeFormat.MonthNames[$date.Month-1]) $($date.Year)"
    Note = "This is your earnings for $((Get-Culture).DateTimeFormat.MonthNames[$date.Month-1]) $($date.Year)"
    PayoutItems = $payoutItems
}
New-PayPalPayout @splat -Whatif