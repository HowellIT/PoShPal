Class PoShPal_AccessToken {
    [string]$AccessToken
    [string]$Expires

    PoShPal_AccessToken(
        [string]$access_token,
        [datetime]$expires
    ){
        $this.AccessToken = $access_token
        $this.Expires = $expires
    }

    PoShPal_AccessToken(
        [PSObject]$In
    ){
        If(
            $In.PSObject.Properties.Name -contains 'access_token' -and
            $In.PSObject.Properties.Name -contains 'expires_in'
        ){
            $this.Expires = (Get-Date).AddSeconds($In.expires_in)
            $this.AccessToken = $In.access_token
        }Else{
            Throw 'Improperly formatted object'
        }
    }
}