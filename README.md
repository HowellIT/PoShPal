# PoShPal

THIS MODULE IS UNDER DEVELOPMENT. Use at your own risk.

This module is designed to work with the PayPal API. It is under development (PRs welcome!) and currently supports authentication and retrieving order information. Nothing special yet.

Only an experimental build has been done with some minor testing.

## How to set up
Download or clone this repo and:

```PowerShell
Import-Module $ModulePath\src\PoShPal.psm1
```

Before you can use this module, you must first have a PayPall account and create an application here: https://developer.paypal.com/developer/applications

You will need to open that application, switch to the 'Live' version and collect the 'Client ID' and 'Secret' from that screen.

## How to authenticate

With the above mentioned information in hand, get a user token:

```PowerShell
Get-PayPalAccessToken -ClientID $ClientID -ClientSecret $ClientSecret
```

This will store your credentials securely in the registry and in a global variable available to the other cmdlets.

## How to query

To get information on a single sale from PayPal:

```PowerShell
Get-PayPalSale -SaleID 'XXXXXXXXXXXXXXXXX'
```