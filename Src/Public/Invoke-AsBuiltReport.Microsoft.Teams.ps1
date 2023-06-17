function Invoke-AsBuiltReport.Microsoft.Teams {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Scope = 'Function')] #The product name is "Teams", this is incorrectly being flagged as plural
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of Microsoft Teams in Word/HTML/Text formats
    .DESCRIPTION
        Documents the configuration of Microsoft Teams in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         James Arber
        Twitter:
        Github:
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Microsoft.Teams
    #>

    # Do not remove or add to these parameters
    param (
        [String[]] $Target,
        [PSCredential] $Credential,
        [Switch] $MFA
    )
    #Get-RequiredModule -Name 'MicrosoftTeams' -Version '5.0.0'

    Write-PScriboMessage -Plugin 'Module' -Message 'Please refer to the AsBuiltReport.Microsoft.Teams GitHub website for more detailed information about this project.'
    Write-PScriboMessage -Plugin 'Module' -Message 'Do not forget to update your report configuration file after each new version release: https://www.asbuiltreport.com/user-guide/new-asbuiltreportconfig/'
    Write-PScriboMessage -Plugin 'Module' -Message 'Documentation: https://github.com/AsBuiltReport/AsBuiltReport.Microsoft.Teams'
    Write-PScriboMessage -Plugin 'Module' -Message 'Issues or bug reporting: https://github.com/AsBuiltReport/AsBuiltReport.Microsoft.Teams/issues'

    # Check the current AsBuiltReport.Microsoft.Teams module
    $InstalledVersion = Get-Module -ListAvailable -Name AsBuiltReport.Microsoft.Teams -ErrorAction SilentlyContinue | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty Version

    if ($InstalledVersion) {
        Write-PScriboMessage -Plugin 'Module' -Message "AsBuiltReport.Microsoft.Teams $($InstalledVersion.ToString()) is currently installed."
        $LatestVersion = Find-Module -Name AsBuiltReport.Microsoft.Teams -Repository PSGallery -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
        if ($LatestVersion -gt $InstalledVersion) {
            Write-PScriboMessage -Plugin 'Module' -Message "AsBuiltReport.Microsoft.Teams $($LatestVersion.ToString()) is available."
            Write-PScriboMessage -Plugin 'Module' -Message "Run 'Update-Module -Name AsBuiltReport.Microsoft.Teams -Force' to install the latest version."
        }
    }

    #Check for Teams module
    Get-RequiredModule -Name 'MicrosoftTeams' -Version '5.0.0'

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options
    $Healthcheck = $ReportConfig.Healthcheck

    # Used to set values to TitleCase where required
    $TextInfo = (Get-Culture).TextInfo

    # Whilst AsBuiltReport supports multiple targets, due to the interactive nature of Microsoft logins, this module only supports a single target. If you wish to support multiple targets, you will need to use token authentication and update the code below to support this.
    # I may look to add support for multiple targets in the future using tokens, but for now, this is not a priority. -UcMadScientist

    #region foreach loop
    foreach ($TenantId in $Target) {
        #First, check to see if we are already connected to the tenant
        Try {
            Write-PScriboMessage "Checking for connection to $TenantId'."
            if ((get-cstenant).tenantid -ne $TenantId) {
                Write-PScriboMessage "Wrong Tenant'." -IsWarning
                Throw "Connected to Wrong Tenant, Reconnecting"
            }
            else {
                Write-PScriboMessage "Already connected to $TenantId'."
                $CsAccount = $true
            }
        }
        Catch {
            Try {
                Write-PScriboMessage "Connecting to Teams Tenant ID '$TenantId'."
                if ($MFA) {
                    $CsAccount = Connect-MicrosoftTeams -TenantId $TenantId -ErrorAction Stop
                } else {
                    $CsAccount = Connect-MicrosoftTeams -Credential $Credential -TenantId $TenantId -ErrorAction Stop
                }
            }
            Catch {
                Write-Error $_
            }


        }

        if ($CsAccount) {
            #Collect Teams Tenant information
            $CsTenant = Get-CsTenant

            Section -Style Heading1 "$($CsTenant.DisplayName) Basic Tenant Information" {
                Get-AbrCsTenant
            }

            Section -Style Heading1 'PSTN Call Routing' {
                Get-AbrCsPSTNCallingInfo
            }
        }


    }
    #endregion foreach loop
}
