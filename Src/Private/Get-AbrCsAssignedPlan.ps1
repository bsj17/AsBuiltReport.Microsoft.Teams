function Get-AbrCsAssignedPlan {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Teams Assigned Plan information
    .DESCRIPTION

    .NOTES
        Version:        0.1.0
        Author:         James "UcMadScientist" Arber
        Twitter:        @UCMadScientist
        Github:         Atreidae
    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
    param (
    )

    begin {
        Write-PscriboMessage "Collecting Teams Subscription information."
    }

    process {
            if ($Options.ShowSectionBlurb) {
                if (!$options.ShowSectionFullDescription){ #We dont want the blurb and the full description if the user selects both
                Paragraph "Teams assigned plans are the licences that enable different levels of Teams Calling functionality."
                BlankLine
                }
            }
            if ($Options.ShowSectionFullDescription) {
                Paragraph "Teams assigned plans are the licences that enable different levels of Teams functionality. These include things such as Microsoft E3, E5, Business Voice, Calling Plans, Audio Conferencing and more."
                Paragraph "At least one of these licences must be assigned to a user in your tenant to enable Teams functionality."
                BlankLine
            }
            Paragraph "The following table summarises the assigned plan information within the $($CsTenant.Name) tenant."
            BlankLine
            $CsAssignedPlanInfo = @()
            foreach ($CsAssignedPlan in $CsAssignedPlans) {
                $InObj = [Ordered]@{
                    'Capability' = $CsAssignedPlan.Capability
                    'ServicePlanId' = $CsAssignedPlan.ServicePlanId
                    'CapabilityStatus' = $CsAssignedPlan.CapabilityStatus
                    'ServiceInstance' = $CsAssignedPlan.ServiceInstance
                }
                $CsAssignedPlanInfo += [pscustomobject]$InObj
            }

            $TableParams = @{
                Name = "Assigned Plans - $($AzTenant.Name)"
                List = $false
                ColumnWidths = 35, 50, 15
            }
            if ($Report.ShowTableCaptions) {
                $TableParams['Caption'] = "- $($TableParams.Name)"
            }
            $CsAssignedPlanInfo | Table @TableParams

    }

    end {}
}