Function Confirm-PayPalAccessToken {
    Param(
        [ValidateNotNullOrEmpty()]
        [PoShPal_AccessToken]$AccessToken,
        [ValidateNotNullOrEmpty()]
        [PoShPal_ClientCredentials]$ClientCredentials = $PayPalAuthConfig.ClientCredentials
    )
    # this will need more than just checking expiration date
    If(($AccessToken.Expires -lt (Get-Date)) -and ($ClientCredentials)){
        Try{
            Get-PayPalAccessToken -ClientID $ClientCredentials.ClientID -ClientSecret $ClientCredentials.ClientSecret
            $true
        }Catch{
            $false
        }
    }Else{
        $true
    }
}