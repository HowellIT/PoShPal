Function Set-PayPalAuthConfig {
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]$ClientID,
        [Parameter(
            Mandatory = $true
        )]
        [string]$ClientSecret,
        [Parameter(
            Mandatory = $true
        )]
        [string]$AccessToken,
        [Parameter(
            Mandatory = $true
        )]
        [datetime]$AccessTokenExpirationDate
    )
    $Script:PayPalAuthConfig = [PSCustomObject]@{
        AccessToken = [PoShPal_AccessToken]::new($AccessToken,$AccessTokenExpirationDate)
        ClientCredentials = [PoShPal_ClientCredentials]::new($ClientID,$ClientSecret)
    }

}