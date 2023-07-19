function Get-RestPSTNGWStatus {
    <#
     .SYNOPSIS
     Used to get information about GW helth status from TAC portal API.
     Using this is not documeted and it's currently experimental.
     Access
     .DESCRIPTION
     Using https://trunkstatsapi-prod.trafficmanager.net/v1/Status/trunk is not documeted and it's currently experimental.
     Access token needs to be obtained from TAC until I figure out right set of claims to be
     .NOTES
         Version:        0.1.0
         Author:         Branko Sabadi
         Twitter:        @branqic
         Github:         @bsj17
     .EXAMPLE
     $Thetoken ="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsI..."
     Get-PSTNGWStatus -Thetoken $Thetoken -PSTNGw "sbc01.test.com"
     .LINK
     #>
    [CmdletBinding()]
    param (
       [Parameter(Position = 0, Mandatory = $true,
          HelpMessage="Copy Access token from TAC console using developer mode in browser")]
       [string]$TACAccesstoken,
       [Parameter(Position = 1, Mandatory = $true)]
       $PSTNGw
    )
    try {

       $content = (Invoke-WebRequest -UseBasicParsing -Uri "https://trunkstatsapi-prod.trafficmanager.net/v1/Status/trunk/$PSTNGw" `
       -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/114.0" `
          -Headers @{
          "Accept" = "application/json"
          "Accept-Language" = "en-US,en;q=0.5"
          "Accept-Encoding" = "gzip, deflate, br"
          "Authorization" = "Bearer {0}" -f $TACAccesstoken
          "X-Requested-With" = "XMLHttpRequest"
          "Origin" = "https://admin.teams.microsoft.com"
          "Referer" = "https://admin.teams.microsoft.com/"
          "Sec-Fetch-Dest" = "empty"
          "Sec-Fetch-Mode" = "cors"
          "Sec-Fetch-Site" = "cross-site"
          } `
          -ContentType "application/json" ).content | ConvertFrom-Json
    }
    catch {
       $_.Exception.Message
    }
       if($content){
       return [pscustomobject] @{
            "trunkFqdn" = $content.trunkFqdn;
            "SBC Model" = $content.info.userAgent
            "tlsStatus" = $content.optionsAndTlsStatus.tlsStatus
            "certificateExpirationDate" = $content.optionsAndTlsStatus.certificateExpirationDate
            "trunkOverallStatus" = $content.InactiveNoRecentPingsAndCalls

          }
          Remove-Variable content
       }
}
