Function Save-PayPalAccessToken {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [PoShPal_AccessToken]$Token,
        [string]$RegistryPath = 'HKCU:\Software\PoShPal'
    )
    If(-not(Test-Path $RegistryPath)){
        New-Item $RegistryPath
    }
    New-ItemProperty -Path $RegistryPath -Name 'Expires' -Value $Token.Expires -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name 'AccessToken' -Value (ConvertFrom-SecureString (ConvertTo-SecureString $Token.AccessToken -AsPlainText -Force)) -Force | Out-Null
    Get-PayPalLocalToken
}