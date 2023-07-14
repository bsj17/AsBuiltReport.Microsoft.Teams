function Get-AbrCsHealthCheck {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve notes from the Health Check
    .DESCRIPTION

    .NOTES
        Version:        0.1.0
        Author:         James Arber
        Twitter:        @UcMadScientist
        Github:         atreidae
    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "Begining Health Check."
    }

    process {
        #Region Gateways
        Write-PScriboMessage 'Gateways Healthcheck'
        if (($Healthcheck.PSTNGateways.Fault)) {
            Section -Style Heading2 'Gateway Health Checks' {
                if ($Options.ShowSectionBlurb) {
                    if (!$options.ShowSectionFullDescription) {
                        #We dont want the blurb and the full description if the user selects both
                        Paragraph "Below are some potential issues with PSTN gateways and Direct Routing within $($CsTenant.DisplayName) tenant."
                        BlankLine
                    }
                }
                if ($Options.ShowSectionFullDescription) {
                    Paragraph "Below are some potential issues with PSTN gateways and Direct Routing within $($CsTenant.DisplayName) tenant."
                    Paragraph {
                        Text 'Configuration issues with your gateway configuration can cause problems in making and reciving calls.'
                     }
                    BlankLine
                }
                #Replace these with my pretty table things
                if ($Healthcheck.PSTNGateways.GatewayDisabled.Message){
                    Paragraph "$($Healthcheck.PSTNGateways.GatewayDisabled.Message)"
                    BlankLine
                }

                if ($Healthcheck.PSTNGateways.GatewayOptions.Message){
                    Paragraph "$($Healthcheck.PSTNGateways.GatewayDisabled.Message)"
                    BlankLine
                }
            }

        } else {
            Section -Style Heading2 'Gateway Health Checks' {
                Paragraph 'No faults were found whilst checking the PSTN gateways.'
            }
        }
        #endregion Phone Numbers

        #Migration checks
        #check for meeting migrations
        #check for on-prem records, without an on-prem instance.

    }


    end {}
}
