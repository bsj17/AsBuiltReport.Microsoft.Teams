function Get-AbrCsOnlineLisLocation {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Teams LIS information
    .DESCRIPTION

    .NOTES
        Version:        0.1.0
        Author:         Branko Sabadi
        Twitter:        @branqic
        Github:         @bsj17
    .EXAMPLE

    .LINK

    #>

    [CmdletBinding()]
    param (

    )

    begin {
        Write-PscriboMessage "Collecting Teams Locations information."
    }

    process {
            $LisLocations = Get-CsOnlineLisLocation

        if ($True) { #($InfoLevel.LocationInformationService -eq 0) -and ($LisLocations)
            Section -Style Heading2 'Telephone Numbers' {
                Write-Host "Calculating phone number properties, This may take some time" -ForegroundColor Green}

                $Locations = @()
                foreach ($LisLocation in $LisLocations) {
                    $InObj = [Ordered]@{
                        'Name' = $LisLocation.Description
                        'GPS Coordinates' = "{0},{1}" -f $LisLocation.Longitude, $LisLocation.Longitude
                        'Address' = 'adresa'
                        'LocationId' = $LisLocation.LocationId
                    }
                    $Locations += [PSCustomObject]$InObj

                }

                Paragraph "The following sections detail the configuration of the Locations within the $($CsTenant.DisplayName) tenant."
                BlankLine
                $TableParams = @{
                    Name = 'Locations'
                    List = $false
                    Columns = ($locations | Get-Member | where MemberType -eq NoteProperty).name #'Name', 'GPS Coordinates', 'Optimize Device Dialing', 'Normalization Rules', 'Description'
                    #ColumnWidths = 20, 10, 10, 30, 30
                }
                if ($True #$Report.ShowTableCaptions
                ) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }
                $Locations | Table @TableParams


            }

        else {
            Section -Style Heading2 'LocationInformationService' {
                Paragraph 'No Telephone Locations found'
                Paragraph 'Direct routing doesnt require location. However its more nicer to have associated.'
            }
        }
    }

    end {

    }
}
