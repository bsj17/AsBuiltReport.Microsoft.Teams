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

            #load site contact file if path specified in config file
            if ($SiteContactsPath){
                if(Test-Path -Path $SiteContacts){
                $SiteContacts = Import-Csv -Path $SiteContactsPath
                }
                else {
                    Write-PscriboMessage "Collecting Teams Locations information."
                }
            }

        if (($InfoLevel.LocationInformationService -gt 0) -and $LisLocations) {
            Section -Style Heading2 'LocationInformationService' {

                Write-PscriboMessage "Processing locations"

                $Locations = @()
                foreach ($LisLocation in $LisLocations) {
                    $InObj = [Ordered]@{
                        'Name' = $LisLocation.Description
                        'GPS Coordinates' = "https://www.bing.com/maps?q={0},{1}" -f $LisLocation.Longitude, $LisLocation.Latitude
                        'Address' = "{0} {1}, {2}, {3} {4},{5}" -f $LisLocation.HouseNumber,$LisLocation.StreetName,$LisLocation.City,$LisLocation.StateOrProvince,$LisLocation.PostalCode,$LisLocation.CountryOrRegion
                        'LocationId' = $LisLocation.LocationId

                    }
                    #add SiteContact property if specified in config file
                    if ($SiteContactsPath) {$InObj | Add-Member -NotePropertyName 'SiteContact' -NotePropertyValue ($SiteContacts | Where-Object LocationID -EQ $LisLocation.LocationId).Email -join ";"}
                    $Locations += [PSCustomObject]$InObj

                }

                Paragraph "The following sections detail the configuration of the Locations within the $($CsTenant.DisplayName) tenant."
                BlankLine
                $TableParams = @{
                    Name = 'Locations'
                    List = $false
                    Columns = ($locations | Get-Member | Where-Object MemberType -eq NoteProperty).name | Sort-Object -Descending #'Name', 'GPS Coordinates', 'Optimize Device Dialing', 'Normalization Rules', 'Description'
                    #ColumnWidths = 20, 10, 10, 30, 30
                }
                if ($True #$Report.ShowTableCaptions
                ) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }
                $Locations | Table @TableParams


            }
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
