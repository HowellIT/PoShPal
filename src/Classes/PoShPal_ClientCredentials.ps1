Class PoShPal_ClientCredentials {
    [string]$ClientID
    [string]$ClientSecret

    PoShPal_ClientCredentials(
        [string]$ClientID,
        [string]$ClientSecret
    ){
        $this.ClientID = $ClientID
        $this.ClientSecret = $ClientSecret
    }
}