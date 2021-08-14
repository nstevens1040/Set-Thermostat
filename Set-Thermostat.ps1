function Set-Thermostat
{
    [cmdletbinding()]
    Param(
        [ValidateSet("Heat","Cool","Off")]
        [string]$Mode,
        [Int32]$HeatSetpoint,
        [Int32]$CoolSetpoint,
        [ValidateSet("NoHold","TemporaryHold","PermanentHold")]
        [string]$ThermostatSetpointStatus,
        [string]$NextPeriodTime,
        [Int32]$EndHeatSetpoint,
        [Int32]$EndCoolSetpoint
    )
    if(!("Json.Deserialize" -as [type]))
    {
        if(Test-Path -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.nupkg")
        {
            Remove-Item -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.nupkg"
        }
        if(Test-Path -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0")
        {
            Remove-Item -Recurse -Force "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0"
        }
        if(Test-Path -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.zip")
        {
            Remove-Item -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.zip"
        }
        [System.Net.WebClient]::new().DownloadFile(
            "https://globalcdn.nuget.org/packages/microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.nupkg",
            "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.nupkg"
        )
        Move-Item "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.nupkg" "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.zip"
        Expand-Archive -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0.zip" -DestinationPath "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0"
        Add-Type -Path "$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0\lib\net45\Microsoft.CodeDom.Providers.DotNetCompilerPlatform.dll"
        Invoke-Expression -Command "class RoslynCompilerSettings : Microsoft.CodeDom.Providers.DotNetCompilerPlatform.ICompilerSettings`n{`n    [string] get_CompilerFullPath()`n    {`n        return `"$($ENV:TEMP)\microsoft.codedom.providers.dotnetcompilerplatform.3.6.0\tools\Roslyn472\csc.exe`"`n    }`n    [int] get_CompilerServerTimeToLive()`n    {`n        return 10`n    }`n}"
        $DotNetCodeDomProvider = [Microsoft.CodeDom.Providers.DotNetCompilerPlatform.CSharpCodeProvider]::new([RoslynCompilerSettings]::new())
        Add-Type -CodeDomProvider $DotNetCodeDomProvider -TypeDefinition (irm "https://raw.githubusercontent.com/nstevens1040/Json.Deserializer/master/Json.Deserializer/Deserialize.cs") `
        -ReferencedAssemblies @(
            [Microsoft.CSharp.RuntimeBinder.Binder].Assembly.Location,
            [System.Management.Automation.Internal.AutomationNull].Assembly.Location,
            [System.Web.Script.Serialization.JavaScriptSerializer].Assembly.Location
        )
    }
    if(!("Execute.HttpRequest" -as [type]))
    {
        Add-Type -TypeDefinition (irm "https://raw.githubusercontent.com/nstevens1040/Execute.HttpRequest/master/Execute.HttpRequest/Execute.HttpRequest.cs") `
        -ReferencedAssemblies @(
            "C:\WINDOWS\Microsoft.Net\assembly\GAC_MSIL\System.Net.Http\v4.0_4.0.0.0__b03f5f7f11d50a3a\System.Net.Http.dll",
            "C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies\Microsoft.mshtml.dll",
            [Microsoft.CSharp.RuntimeBinder.Binder].Assembly.Location,
            "C:\WINDOWS\Microsoft.Net\assembly\GAC_64\System.Web\v4.0_4.0.0.0__b03f5f7f11d50a3a\System.Web.dll"
        )
    }
    $HWAPIKEY = [System.Environment]::GetEnvironmentVariable("HWAPIKEY")
    $HWCALLBACK = [System.Environment]::GetEnvironmentVariable("HWCALLBACK")
    $HWDEVICE = [System.Environment]::GetEnvironmentVariable("HWDEVICE")
    $HWLOCID = [System.Environment]::GetEnvironmentVariable("HWLOCID")
    $HWPASS = [System.Environment]::GetEnvironmentVariable("HWPASS")
    $HWUSER = [System.Environment]::GetEnvironmentVariable("HWUSER")
    function get-honeywell_auth_token
    {
        [cmdletbinding()]
        Param()
        $r1 = [Execute.HttpRequest]::Send(
            ([Execute.Httprequest]::Send(
                [execute.httprequest]::Send("https://api.honeywell.com/oauth2/authorize?response_type=code&redirect_uri=$($HWCALLBACK)&client_id=$($HWAPIKEY)").HttpResponseMessage.RequestMessage.RequestUri.AbsoluteUri
            )).HttpResponseMessage.RequestMessage.RequestUri.AbsoluteUri,
            [System.Net.Http.HttpMethod]::Post,
            $null,
            $null,
            "application/x-www-form-urlencoded",
            "username=$($HWUSER)&password=$($HWPASS)&subSystemId=1&reset=false"
        )
        $CookieCollection = $r1.CookieCollection
        $ra = [Execute.HttpRequest]::Send(
            $r1.HttpResponseMessage.RequestMessage.RequestUri.AbsoluteUri,
            [System.Net.Http.HttpMethod]::Get,
            $null,
            $CookieCollection
        )
        $rb = [Execute.HttpRequest]::Send(
            $ra.HttpResponseMessage.RequestMessage.RequestUri.AbsoluteUri,
            [System.Net.Http.HttpMethod]::Post,
            $null,
            $CookieCollection,
            "application/x-www-form-urlencoded",
            "decision=yes"
        )
        $uri = "https://api.honeywell.com" + $rb.HtmlDocument.body.getElementsByTagName("form")[0].action
        $r2 = [Execute.HttpRequest]::Send(
            $uri,
            [System.Net.Http.HttpMethod]::Post,
            $null,
            $CookieCollection,
            "application/x-www-form-urlencoded",
            "selDevices=$($HWDEVICE)&areFutureDevicesEnabled=false"
        )
        $r2.ResponseText
    }
    Add-Type -TypeDefinition "namespace Thermostat`n{`n    using System;`n    public class Settings`n    {`n        public string mode`n        {`n            get;`n            set;`n        }`n        public Int32 heatSetpoint`n        {`n            get;`n            set;`n        }`n        public Int32 coolSetpoint`n        {`n            get;`n            set;`n        }`n        public string thermostatSetpointStatus`n        {`n            get;`n            set;`n        }`n        public string nextPeriodTime`n        {`n            get;`n            set;`n        }`n        public Int32 endHeatSetpoint`n        {`n            get;`n            set;`n        }`n        public Int32 endCoolSetpoint`n        {`n            get;`n            set;`n        }`n        public string heatCoolMode`n        {`n            get;`n            set;`n        }`n    }`n}"
    $settings = [Thermostat.Settings]::new()
    $auth_token = get-honeywell_auth_token
    $uri = "https://api.honeywell.com/v2/devices/thermostats/$($HWDEVICE)?apikey=$($HWAPIKEY)&locationId=$($HWLOCID)"
    $Headers = [ordered]@{"Authorization"="Bearer $($auth_token)"}
    $o = [Json.Deserialize]::Convert([Execute.HttpRequest]::Send($uri,[System.Net.Http.HttpMethod]::Get,$Headers).ResponseText)
    $settings | gm -memberType Property |% Name |% { $settings."$($_)" = $o.changeableValues."$($_)"}
    if($Mode)
    {
        $settings.mode = $Mode
        $settings.heatCoolMode = $Mode
    }
    if($HeatSetpoint)
    {
        $settings.heatSetpoint = $HeatSetpoint
    }
    if($CoolSetpoint)
    {
        $settings.coolSetpoint = $CoolSetpoint
    }
    if($ThermostatSetpointStatus)
    {
        $settings.thermostatSetpointStatus = $ThermostatSetpointStatus
    }
    if($NextPeriodTime)
    {
        Try {
            $d = [datetime]::Parse($NextPeriodTime)
            $settings.nextPeriodTime = $NextPeriodTime
        }
        catch {
            write-error "nextPeriodTime should be formatted like '18:00:00' for 6pm"
        }
    }
    if($EndHeatSetpoint)
    {
        $settings.endHeatSetpoint = $EndHeatSetpoint
    }
    if($EndCoolSetpoint)
    {
        $settings.endCoolSetpoint = $EndCoolSetpoint
    }
    $body = $settings |ConvertTo-Json
    write-host "New Settings"
    $settings | gm -memberType Property |% Name |% {
        write-host "$($_):" -ForeGroundColor Green -NoNewLine
        @(1..(32 - ("$($_):".Length))).ForEach({ write-host " " -NoNewLine})
        write-host "$($settings |% "$($_)")" -ForeGroundColor Yellow
    }
    $r = iwr -Method "POST" -Uri $uri -Headers $Headers -ContentType "application/json" -Body $Body
    return $r.StatusDescription
}
