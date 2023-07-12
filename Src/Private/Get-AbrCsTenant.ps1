function Get-AbrCsTenant {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Teams Tenant information
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
        Write-PscriboMessage "Collecting Teams Tenant information."
    }

    process {
        $CsTenant = Get-CsTenant
        $CSTenantInfo = [PSCustomObject]@{
            'Tenant Name' = $CsTenant.DisplayName
            'Tenant ID' = $CsTenant.TenantId
            'Sip Domains' = $CsTenant.SipDomain
            'Service Instance' = $CsTenant.ServiceInstance
            'Location' = "$($CsTenant.Street) ($($CsTenant.StateorProvince) $($CsTenant.PostalCode) $($CsTenant.CountryorRegion))"
        }

        $TableParams = @{
            Name = "Tenant - $($CsTenant.DisplayName)"
            List = $true
            ColumnWidths = 50, 50
        }
        if ($Report.ShowTableCaptions) {
            $TableParams['Caption'] = "- $($TableParams.Name)"
        }
        $CsTenantInfo | Table @TableParams
    }

    end {}
}
