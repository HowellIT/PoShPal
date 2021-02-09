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
            Mandatory = $false
        )]
        [string]$AccessToken,
        [Parameter(
            Mandatory = $false
        )]
        [datetime]$AccessTokenExpirationDate
    )
    $Global:PayPalAuthConfig = [PSCustomObject]@{
        AccessToken = [PoShPal_AccessToken]::new()
        ClientCredentials = [PoShPal_ClientCredentials]::new($ClientID,$ClientSecret)
    }
    if ($null -ne $AccessToken -and $null -ne $AccessTokenExpirationDate) {
        $Global:PayPalAuthConfig.AccessToken = [PoShPal_AccessToken]::new($AccessToken,$AccessTokenExpirationDate)
    }
}