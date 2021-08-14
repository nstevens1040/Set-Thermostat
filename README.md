# Set-Thermostat
PowerShell function to change temperature settings on a Honeywell T5-T6 Lyric thermostat.  
  
## Requirements  
This script is for Windows PowerShell and will not work on PowerShell Core.  
|                 |               |
|-----------------|---------------|
|PSVersion        |5.1.19041.1151 |
|PSEdition        |Desktop        |
|BuildVersion     |10.0.19041.1151|
|CLRVersion       |4.0.30319.42000|
|WSManStackVersion|3.0            |  
  
## Environment Variables  
In order to use this script, you must have these environment variables set. These values are availabe once you register on [Honeywell Home Developer](https://developer.honeywellhome.com/user/register)  
   - HWAPIKEY = Consumer Key that you are given once you register an app.
   - HWCALLBACK = The **URLEncoded** callback url that you set when you register an app.
   - HWDEVICE = Your thermostat's device id. Nomenclature is LCC-{Non colon separated thermostat MAC address}.
   - HWLOCID = Your location id. This is retrievable via the [https://api.honeywell.com/v2/locations](https://developer.honeywellhome.com/lyric/apis/get/locations) endpoint
   - HWPASS = Your **URLEncoded** password to login to [https://developer.honeywellhome.com/](https://developer.honeywellhome.com/)
   - HWUSER = Your **URLEncoded** username (email address) to login to [https://developer.honeywellhome.com/](https://developer.honeywellhome.com/)  


