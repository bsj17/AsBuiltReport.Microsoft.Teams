function Get-AbrRestPSTNGWStatus {
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
        $sectionName = "PSTN Gateways health status"
    )

    begin {
        Write-PscriboMessage "Collecting status for $sectionName."


    }

    process {

        $PSTNGateways = Get-CsOnlinePSTNGateway

        #load site contact file if path specified in config file
        Write-PscriboMessage "Testing TAC token path."
        if ($TACtokenPath){
            if(Test-Path -Path $TACtokenPath ){
            Write-PscriboMessage "Testing TAC token path specified: $TACtokenPath"
            $token = Get-Content -Path $TACtokenPath
            }
            if([string]::IsNullOrEmpty($token)){
            Write-PscriboMessage "TAC token path specified, but file is empty."

            Section -Style Heading2 "$sectionName" { Paragraph 'TAC token path specified, but file is empty.'}

            }
        }
        else {
            Write-PscriboMessage "TAC token path emtpy. No results will be presented"
            Section -Style Heading2 "$sectionName" { Paragraph 'TAC token path emtpy. No results will be presented'}

        }



        if ($PSTNGateways -and $token) {
            Section -Style Heading2 "$sectionName" {

                Write-PscriboMessage "Processing locations"

                $GwStatus = @()
                try {

                    foreach ($PSTNGateway in $PSTNGateways) {
                    $GwStatus += Get-RestPSTNGWStatus -TACAccesstoken $token -PSTNGw $PSTNGateway.identity -ErrorAction Stop

                    }
                }
                catch {
                    $_.Exception.Message
                    Paragraph "Creation of following $sectionName failed due to error $($_.Exception.Message) "
                }
                if ($GwStatus) {
                    try {
                        Paragraph "The following sections detail the configuration of $sectionName"
                        BlankLine
                        $TableParams = @{
                            Name = 'PSTN gateways'
                            List = $false
                            Columns = ($GwStatus | Get-Member | Where-Object MemberType -eq NoteProperty).name | Sort-Object -Descending
                            #ColumnWidths = 20, 10, 10, 30, 30
                        }
                        if ($True #$Report.ShowTableCaptions
                        ) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $GwStatus | Table @TableParams
                    }
                    catch {
                        Paragraph "Failed aquiring data for section $sectionName"
                    }
                }



            }
        }

        else {}
    }

    end {

    }
}
