Function Save-PayPalAuthConfig {
    Param(
        [PoShPal_AccessToken]$Token = $PayPalAuthConfig.AccessToken,
        [PoShPal_ClientCredentials]$Creds = $PayPalAuthConfig.ClientCredentials
    )
    $dir = Get-PayPalAuthConfigSavePath
    If(-not(Test-Path $dir -PathType Container)){
        New-Item $dir -ItemType Directory | Out-Null
    }
    If(-not(Test-Path $dir\config.json -PathType Leaf)){
        New-Item $dir\config.json -ItemType File | Out-Null
    }
    @{
        Expires = $Token.Expires
        AccessToken = (ConvertFrom-SecureString (ConvertTo-SecureString $Token.AccessToken -AsPlainText -Force))
        ClientID = (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientID -AsPlainText -Force))
        ClientSecret = (ConvertFrom-SecureString (ConvertTo-SecureString $Creds.ClientSecret -AsPlainText -Force))
    } | ConvertTo-Json | Out-File $dir\config.json
}