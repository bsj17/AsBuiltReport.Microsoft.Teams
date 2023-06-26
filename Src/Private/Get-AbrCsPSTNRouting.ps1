function Get-AbrCsPSTNCallRouting {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Microsoft Teams PSTN Calling Information
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
        Write-PScriboMessage "CallRouting InfoLevel set at $($InfoLevel.CallRouting)."
    }

    process {
        #region Dial Plans
        Write-PScriboMessage 'Collecting Tenant Dial Plans.'
        $CsTenantDialPlans = Get-CsTenantDialPlan | Sort-Object DisplayName
        if (($InfoLevel.CallRouting -gt 0) -and ($CsTenantDialPlans)) {
            Section -Style Heading2 'Tenant Dial Plans' {
                if ($Options.ShowSectionBlurb) {
                    if (!$options.ShowSectionFullDescription) {
                        #We dont want the blurb and the full description if the user selects both
                        Paragraph 'Teams Tenant Dial Plans are used to control the dialing behaviour of users within your tenant.'
                        BlankLine
                    }
                }
                if ($Options.ShowSectionFullDescription) {
                    Paragraph 'Telephone numbers in Teams are typically in E.164 format. This means that they should be in the format +[Country Code][Area Code][Subscriber Number].'
                    Paragraph {
                        Text "Thus, an Australian E.164 would be represented as '+61370100555'. However, users would typically dial '03 7010 0555' as they have on other PSTN devices."
                        Text 'To allow users to keep dialing numbers the way they are used to,' ; Text 'Tenant Dial Plans' -Bold ; Text 'provide the required information translate from one format to the other'
                        Text 'They do this by containing one ore more' ; Text 'Normalisation Rules' -Bold ; Text 'that are processed one at a time' ; Text 'in order' -Bold; Text 'to cover the many different ways users may dial a number.'
                        Text 'Multiple dial plans can be created to support different dialing patterns, such as internal extensions, international dialing, or even to support different carriers.'
                        Text 'For more information see https://learn.microsoft.com/en-us/microsoftteams/create-and-manage-dial-plans?WT.mc_id=M365-MVP-5003444' }
                    BlankLine
                }
                $CsTenantDialPlanInfo = @()
                foreach ($CsTenantDialPlan in $CsTenantDialPlans) {
                    $InObj = [Ordered]@{
                        'Name' = $CsTenantDialPlan.SimpleName
                        'External Access Prefix' = $CsTenantDialPlan.ExternalAccessPrefix
                        'Optimize Device Dialing' = $CsTenantDialPlan.OptimizeDeviceDialing
                        'Normalization Rules' = $CsTenantDialPlan.NormalizationRules.Name
                        'Description' = $CsTenantDialPlan.Description
                    }
                    $CsTenantDialPlanInfo += [PSCustomObject]$InObj
                }

                if ($InfoLevel.CallRouting -le 2) {
                    Paragraph "The following sections detail the configuration of the Dial Plans within the $($CsTenant.DisplayName) tenant."
                    $TableParams = @{
                        Name = 'Dial Plans'
                        List = $false
                        Columns = 'Name', 'Normalization Rules', 'Description'
                        ColumnWidths = 25, 25, 50
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $CsTenantDialPlanInfo | Table @TableParams
                } else {
                    Paragraph "The following sections detail the configuration of the Dial Plans within the $($CsTenant.DisplayName) tenant."
                    BlankLine
                    $TableParams = @{
                        Name = 'Dial Plans'
                        List = $false
                        Columns = 'Name', 'External Access Prefix', 'Optimize Device Dialing', 'Normalization Rules', 'Description'
                        ColumnWidths = 20, 10, 10, 30, 30
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $CsTenantDialPlanInfo | Table @TableParams
                }
            }
        } else {
            Section -Style Heading2 'Tenant Dial Plans' {
                Paragraph 'No Tenant Dial Plans found, Your Tenant will default to the Service Country Diaplan.'
                Paragraph 'See https://learn.microsoft.com/en-us/microsoftteams/what-are-dial-plans#tenant-dial-plan-scope?WT.mc_id=M365-MVP-5003444 for more information.'
            }
        }
        #endregion Dial Plans

        #region Norm Rules
        Write-PScriboMessage 'Collecting Normalization Rules.'
        $CsTenantNormRules = (Get-CsTenantDialPlan).NormalizationRules | Sort-Object Name -Unique
        if (($InfoLevel.CallRouting -gt 0) -and ($CsTenantNormRules)) {

            Section -Style Heading2 'Teams Normalization Rules' {
                if ($Options.ShowSectionBlurb) {
                    if (!$options.ShowSectionFullDescription) {
                        #We dont want the blurb and the full description if the user selects both
                        Paragraph 'Teams Normalization Rules are used to allow and translate dialing patterns within your tenant.'
                        BlankLine
                    }
                }
                if ($Options.ShowSectionFullDescription) {
                    Paragraph {
                        Text 'Normalization rules are used as part of your' ; Text 'Tenant Dial Plans' -Bold ; Text 'to translate one string of numbers into another using' ; Text 'Regular Expressions (RegEx)' -Bold
                        Text 'These rules are typically created to support an individual extension range, or to translate a local number into an E.164 number and can be re-used in multiple Dial Plans.'
                        Text 'They do this by containing multiple' ; Text 'Normalisation Rules' -Bold ; Text 'that are processed in order to cover the many different ways users may dial a number.'
                        Text 'For more information see https://learn.microsoft.com/en-us/microsoftteams/create-and-manage-dial-plans?WT.mc_id=M365-MVP-5003444' }
                    BlankLine
                }
                $CsTenantNormRulesInfo = @()
                foreach ($CsTenantNormRule in $CsTenantNormRules) {
                    $InObj = [Ordered]@{
                        'Name' = $CsTenantNormRule.Name
                        'Pattern' = $CsTenantNormRule.Pattern
                        'Translation' = $CsTenantNormRule.Translation
                        'Description' = $CsTenantNormRule.Description
                        'Is Internal Extension' = $CsTenantNormRule.IsInternalExtension
                    }
                    $CsTenantNormRulesInfo += [PSCustomObject]$InObj
                }

                if ($InfoLevel.CallRouting -le 2) {
                    Paragraph "The following sections detail the Normalization Rules within the $($CsTenant.DisplayName) tenant."
                    $TableParams = @{
                        Name = 'Normalization Rules'
                        List = $false
                        Columns = 'Name', 'Description'
                        ColumnWidths = 50, 50
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $CsTenantNormRulesInfo | Table @TableParams
                } else {
                    Paragraph "The following sections detail the Normalization Rules within the $($CsTenant.DisplayName) tenant."
                    BlankLine
                    $TableParams = @{
                        Name = 'Normalization Rules'
                        List = $false
                        Columns = 'Name', 'Pattern', 'Translation', 'Description', 'Is Internal Extension'
                        ColumnWidths = 20, 20, 20, 30, 10
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $CsTenantNormRulesInfo | Table @TableParams
                }
            }
        } else {
            Section -Style Heading2 'Teams Normalization Rules' {
                Paragraph 'No custom Normalization Rules found, this is normal if you do not have any custom Dial Plans.'
                Paragraph 'Your Tenant will default to the Service Country Diaplan.'
                Paragraph 'See https://learn.microsoft.com/en-us/microsoftteams/what-are-dial-plans#tenant-dial-plan-scope?WT.mc_id=M365-MVP-5003444 for more information.'
            }
        }
        #endregion Norm Rules


        #Region Direct Routing
        Write-PScriboMessage 'Collecting Direct Routing Configuration.'
        $CsOnlinePSTNGateways = (Get-CsOnlinePSTNGateway)
        if (($InfoLevel.CallRouting -le 3) -and (($CsOnlinePSTNGateways | Measure-Object).count -eq 0)) {
            Section -Style Heading2 'Direct Routing' {
                Paragraph 'Direct Routing does not appear to be configured for this tenant as no PSTN Gateways exist.'
                Paragraph 'This is normal if you use Operator Connect or Microsoft PSTN Calling.'
                Paragraph 'See https://docs.microsoft.com/en-us/microsoftteams/direct-routing-plan?WT.mc_id=M365-MVP-5003444 for more information.'
            }
            Write-PScriboMessage 'No Direct Routing PSTN Gateways Configured, Skipping Direct Route Sections. Set CallRouting InfoLevel to >4 to force these sections' -IsWarning

        } else {
            Section -Style Heading2 'Direct Routing' {
                Paragraph 'Direct Routing lets you connect a supported, customer-provided Session Border Controller (SBC) to Microsoft Teams. With this capability, you can configure on-premises Public Switched Telephone Network (PSTN) connectivity with Microsoft Teams client'
                Paragraph 'Additionally these SBCs can be used to connect to on premises legacy letelephone systems such as PBXs and Analog Devices.'
                Paragraph 'See https://docs.microsoft.com/en-us/microsoftteams/direct-routing-plan?WT.mc_id=M365-MVP-5003444 for more information.'
            }

            #region PSTN Gateways
            Write-PScriboMessage 'Collecting PSTN Gateways.'
            if (($InfoLevel.CallRouting -gt 0) -and ($CsOnlinePSTNGateways)) {

                Write-PScriboMessage 'Define PSTN Gateway section'
                Section -Style Heading3 'PSTN Gateways' {
                    if ($Options.ShowSectionBlurb) {
                        if (!$options.ShowSectionFullDescription) {
                            #We dont want the blurb and the full description if the user selects both
                            Paragraph {
                                'PSTN Gateways are used to connect your Teams environment to the Public Switched Telephone Network (PSTN).'
                            }
                            Paragraph 'For more information see https://learn.microsoft.com/en-us/microsoftteams/direct-routing-border-controllers?WT.mc_id=M365-MVP-5003444'
                            BlankLine
                        }
                    }
                    if ($Options.ShowSectionFullDescription) {

                        Paragraph "Put some text about SBC's here" #todo
                        Paragraph 'For more information see https://learn.microsoft.com/en-us/microsoftteams/direct-routing-border-controllers?WT.mc_id=M365-MVP-5003444'
                        BlankLine
                    }
                    $CsOnlinePSTNGatewayInfo = @()
                    foreach ($CsOnlinePSTNGateway in $CsOnlinePSTNGateways) {
                        $InObj = [Ordered]@{
                            'Name' = $CsOnlinePSTNGateway.Identity
                            'Inbound Teams Number Translation Rules' = $CsOnlinePSTNGateway.InboundTeamsNumberTranslationRules
                            'Inbound Pstn Number Translation Rules' = $CsOnlinePSTNGateway.InboundPstnNumberTranslationRules
                            'Outbound Teams Number Translation Rules' = $CsOnlinePSTNGateway.OutboundTeamsNumberTranslationRules
                            'Outbound Pstn Number Translation Rules' = $CsOnlinePSTNGateway.OutboundPstnNumberTranslationRules
                            'FQDN' = $CsOnlinePSTNGateway.FQDN
                            'SIP Signalling Port' = $CsOnlinePSTNGateway.SIPSignallingPort
                            'Failover Time' = $CsOnlinePSTNGateway.FailoverTimeSeconds
                            'Forward Call History' = $CsOnlinePSTNGateway.ForwardCallHistory
                            'Forward P-Asserted Identity' = $CsOnlinePSTNGateway.ForwardPAI
                            'Send Sip Options' = $CsOnlinePSTNGateway.SendSipOptions
                            'Max Concurrent Sessions' = $CsOnlinePSTNGateway.MaxConcurrentSessions
                            'Enabled' = $CsOnlinePSTNGateway.Enabled
                            'Media Bypass' = $CsOnlinePSTNGateway.MediaBypass
                            'Gateway Site' = $CsOnlinePSTNGateway.GatewaySiteId
                            'Gateway Site Lbr Enabled' = $CsOnlinePSTNGateway.GatewaySiteLbrEnabled
                            'Gateway Lbr Enabled User Override' = $CsOnlinePSTNGateway.GatewayLbrEnabledUserOverride
                            'Failover Response Codes' = $CsOnlinePSTNGateway.FailOverResponseCodes
                            'Pidf Lo Supported' = $CsOnlinePSTNGateway.PidfLoSupported
                            'Media Relay Routing Location Override' = $CsOnlinePSTNGateway.MediaRelayRoutingLocationOverride
                            'Proxy SBC' = $CsOnlinePSTNGateway.ProxySBC
                            'Bypass Mode' = $CsOnlinePSTNGateway.BypassMode
                            'Description' = $CsOnlinePSTNGateway.Description
                        }
                        $CsOnlinePSTNGatewayInfo += [PSCustomObject]$InObj
                    }

                    Write-PScriboMessage 'Status Healthcheck'
                    Write-PScriboMessage "Gateway Disabled $($Healthcheck.PSTNGateways.GatewayDisabled)"
                    Write-PScriboMessage "Options Disabled $($Healthcheck.PSTNGateways.OptionsDisabled)"

                    if ($Healthcheck.PSTNGateways.GatewayDisabled) {
                        Write-PScriboMessage 'Gateway Disabled Healthcheck'
                        $CsOnlinePSTNGatewayInfo | Where-Object { $_.'Enabled' -ne $True } | Set-Style -Style Critical -Property 'Enabled'
                        $Healthcheck.PSTNGateways | Add-Member -NotePropertyName 'Fault' -NotePropertyValue $true -Force
                        $Healthcheck.PSTNGateways.GatewayDisabled | Add-Member -NotePropertyName 'Message' -force -NotePropertyValue "One or more of your PSTN Gateways are disabled. This is normal if you are performing maintenance on the SBC. Otherwise may indicate a problem with your gateway configuration"
                    }

                    if ($Healthcheck.PSTNGateways.OptionsDisabled) {
                        Write-PScriboMessage 'Gateway Options Healthcheck'
                        $CsOnlinePSTNGatewayInfo | Where-Object { $_.'SendSipOptions' -ne $True } | Set-Style -Style Critical -Property 'SendSipOptions'
                        $Healthcheck.PSTNGateways | Add-Member -NotePropertyName 'Fault' -NotePropertyValue $true -Force
                        $Healthcheck.PSTNGateways.OptionsDisabled | Add-Member -NotePropertyName 'Message' -force -NotePropertyValue "One or more of your PSTN Gateways are not using SIP Options requests to monitor the health of the SBC. This is normal if you are performing maintenance on the SBC. Otherwise may indicate a problem with your gateway configuration"
                    }

                    ##Todo add more Health Checks

                    if ($InfoLevel.CallRouting -ge 4) {
                        Paragraph "The following sections detail the configuration of the PSTN Gateways (SBC's) $($CsTenant.DisplayName) tenant."
                        foreach ($CsOnlinePSTNGatewayObj in $CsOnlinePSTNGatewayInfo) {
                            Section -Style Heading4 "$($CsOnlinePSTNGatewayObj.Name)" {
                                $TableParams = @{
                                    Name = "PSTN Gateway- $($CsOnlinePSTNGatewayObj.Name)"
                                    List = $true
                                    ColumnWidths = 50, 50
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $CsOnlinePSTNGatewayObj | Table @TableParams
                            }
                        }


                    } else {
                        Paragraph "The following sections summarize the PSTN Gateways (SBC's) $($CsTenant.DisplayName) tenant."
                        BlankLine

                        if ($InfoLevel.CallRouting -eq 1) {
                            $TableParams = @{
                                Name = 'PSTN Gateways'
                                List = $false
                                Columns = 'Name', 'Send Sip Options', 'Description', 'Enabled'
                                ColumnWidths = 20, 10, 10, 60
                            }
                        } else {
                            $TableParams = @{
                                Name = 'PSTN Gateways'
                                List = $false
                                Columns = 'Name', 'Media Bypass', 'Proxy SBC', 'Send Sip Options', 'Description', 'Enabled'
                                ColumnWidths = 10, 10, 10, 10, 10, 50
                            }
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $CsOnlinePSTNGatewayInfo | Table @TableParams

                    }
                }
            } else {
                Section -Style Heading3 'PSTN Gateways' {
                    Paragraph 'No custom PSTN Gateways found, this is normal if you do not use Direct Routing.' #Todo check this
                    Paragraph 'Your Tenant will default to routing calls to Operator Connect or Microsoft PSTN Calling.'
                    Paragraph 'See https://learn.microsoft.com/en-US/microsoftteams/manage-voice-routing-policies?WT.mc_id=M365-MVP-5003444 for more information.'
                }
            }


            #region Voice Routing Policies

            ##TODO, run a health check to see if the Voice Routing Policies are assigned to users
            Write-PScriboMessage 'Collecting Voice Routing Policies.'
            $CsVoiceRoutingPolicies = (Get-CsOnlineVoiceRoutingPolicy)
            if (($InfoLevel.CallRouting -gt 0) -and ($CsVoiceRoutingPolicies.count -gt 1)) {
                Section -Style Heading3 'Voice Routing Policies' {
                    if ($Options.ShowSectionBlurb) {
                        if (!$options.ShowSectionFullDescription) {
                            #We dont want the blurb and the full description if the user selects both
                            Paragraph {
                                'Voice Routing Policies are used to assign' ; Text 'Voice Routes'-Bold ; Text 'to users within your tenant.'
                            }
                            Paragraph 'For more information see https://learn.microsoft.com/en-us/microsoftteams/create-and-manage-dial-plans'
                            BlankLine
                        }
                    }
                    if ($Options.ShowSectionFullDescription) {

                        Paragraph "If you've deployed Direct Routing in your organization, you use call routing policies to allow Teams users to receive and make phone calls to the Public Switched Telephone Network (PSTN) using your on-premises telephony infrastructure."
                        Paragraph 'A call routing policy (also called a voice routing policy) is a container for PSTN usage records. You create and manage voice routing policies by going to Voice > Voice routing policies in the Microsoft Teams admin center or by using Windows PowerShell.'
                        Paragraph "You can use the global (Org-wide default) policy or create and assign custom policies. Users will automatically get the global policy unless you create and assign a custom policy. Keep in mind that you can edit the settings in the global policy but you can't rename or delete it."
                        Paragraph "It's important to know that assigning a voice routing policy to a user doesn't enable them to make PSTN calls in Teams. You'll also need to enable the user for Direct Routing and complete other configuration steps."
                        Paragraph 'For more information see https://learn.microsoft.com/en-us/microsoftteams/create-and-manage-dial-plans'

                        BlankLine
                    }
                    $CsVoiceRoutingPoliciesInfo = @()
                    foreach ($CsVoiceRoutingPolicy in $CsVoiceRoutingPolicies) {
                        $InObj = [Ordered]@{
                            'Name' = $CsVoiceRoutingPolicy.Identity
                            'Route Type' = $CsVoiceRoutingPolicy.RouteType
                            'PSTN Usages' = $CsVoiceRoutingPolicy.OnlinePSTNUsages
                            'Description' = $CsVoiceRoutingPolicy.Description
                        }
                        $CsVoiceRoutingPoliciesInfo += [PSCustomObject]$InObj
                    }

                    if ($InfoLevel.CallRouting -le 2) {
                        Paragraph "The following sections detail the Voice Routing Policies within the $($CsTenant.DisplayName) tenant."
                        $TableParams = @{
                            Name = 'Voice Routing Policies'
                            List = $false
                            Columns = 'Name', 'Description'
                            ColumnWidths = 50, 50
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $CsVoiceRoutingPoliciesInfo | Table @TableParams
                    } else {
                        Paragraph "The following sections detail the Voice Routing Policies within the $($CsTenant.DisplayName) tenant."
                        BlankLine
                        $TableParams = @{
                            Name = 'Voice Routing Policies'
                            List = $false
                            Columns = 'Name', 'Route Type', 'PSTN Usages', 'Description'
                            ColumnWidths = 20, 10, 20, 50
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $CsVoiceRoutingPoliciesInfo | Table @TableParams
                    }
                }
            } else {
                Section -Style Heading3 'Voice Routing Policies' {
                    Paragraph 'No custom Voice Routing Policies found, this is normal if you do not use Direct Routing.' #Todo check this
                    Paragraph 'Your Tenant will default to routing calls to Operator Connect or Microsoft PSTN Calling.'
                    Paragraph 'See https://learn.microsoft.com/en-US/microsoftteams/manage-voice-routing-policies?WT.mc_id=TeamsAdminCenterCSH for more information.'
                }
            }
            #endregion Voice Routing Policies

            ## Todo Health Check to see if Voice Routes are assigned to SBC's and that they are enabled!
            #region Voice Routes
            Write-PScriboMessage 'Collecting Voice Routes.'
            $CsVoiceRoutes = (Get-CsOnlineVoiceRoute)
            if (($InfoLevel.CallRouting -gt 0) -and ($CsVoiceRoutes)) {
                Section -Style Heading3 'Voice Routes' {
                    if ($Options.ShowSectionBlurb) {
                        if (!$options.ShowSectionFullDescription) {
                            #We dont want the blurb and the full description if the user selects both
                            Paragraph {
                                'Voice Routes are used as part of Voice Routing Policies are used to link' ; Text 'PSTN Usage Records'-Bold ; Text 'and' ; Text 'PSTN Gateways' -Bold ; Text 'to users within your tenant.'
                            }
                            BlankLine
                        }
                    }
                    if ($Options.ShowSectionFullDescription) {

                        Paragraph "If you've deployed Direct Routing in your organization, you use call routing policies to allow Teams users to receive and make phone calls to the Public Switched Telephone Network (PSTN) using your on-premises telephony infrastructure."
                        Paragraph 'more text here' #todo
                        Paragraph 'For more information see https://learn.microsoft.com/en-US/microsoftteams/manage-voice-routing-policies?WT.mc_id=TeamsAdminCenterCSH'

                        BlankLine
                    }
                    $CsVoiceRoutesInfo = @()
                    foreach ($CsVoiceRoute in $CsVoiceRoutes) {
                        $InObj = [Ordered]@{
                            'Priority' = $CsVoiceRoute.Priority
                            'Name' = $CsVoiceRoute.Identity
                            'Number Pattern' = $CsVoiceRoute.NumberPattern
                            'PSTN Usages' = $CsVoiceRoute.OnlinePSTNUsages
                            'PSTN Gateway' = $CsVoiceRoute.OnlinePSTNGatewayList
                            'Bridge Source Phone Number' = $CsVoiceRoute.BridgeSourcePhoneNumber
                            'Description' = $CsVoiceRoutingPolicy.Description
                        }
                        $CsVoiceRoutesInfo += [PSCustomObject]$InObj
                    }

                    if ($InfoLevel.CallRouting -le 2) {
                        Paragraph "The following sections summarize the Voice Routes within the $($CsTenant.DisplayName) tenant."
                        $TableParams = @{
                            Name = 'Voice Routes'
                            List = $false
                            Columns = 'Name', 'Description'
                            ColumnWidths = 50, 50
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $CsVoiceRoutesInfo | Table @TableParams
                    } else {
                        Paragraph "The following sections detail the Voice Routes within the $($CsTenant.DisplayName) tenant."
                        BlankLine
                        $TableParams = @{
                            Name = 'Voice Routes'
                            List = $false
                            Columns = 'Priority', 'Name', 'Number Pattern', 'PSTN Usages', 'PSTN Gateway', 'Bridge Number', 'Description'
                            ColumnWidths = 5, 10, 10, 10, 10, 15, 40
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $CsVoiceRoutesInfo | Table @TableParams
                    }
                }
            } else {
                Section -Style Heading3 'Voice Routing Policies' {
                    Paragraph 'No custom Voice Routing Policies found, this is normal if you do not use Direct Routing.'
                    Paragraph 'Your Tenant will default to routing calls to Operator Connect or Microsoft PSTN Calling.'
                    Paragraph 'See https://learn.microsoft.com/en-US/microsoftteams/manage-voice-routing-policies?WT.mc_id=TeamsAdminCenterCSH for more information.'
                }
            }
            #endregion Voice Routes

        }
        #endregion Direct Routing
        Write-PScriboMessage 'End Region Direct Routing.'

        #region Blocked Number Patterns
        Write-PScriboMessage 'Collecting Number Blocking Patterns'

        Section -Style Heading2 'Number Blocking' {
            Paragraph 'Number Blocking is used to block calls to specific numbers or number patterns.'
            Paragraph 'For more information see https://docs.microsoft.com/en-us/microsoftteams/call-blocking-policies-in-teams?WT.mc_id=M365-MVP-5003444'
        }
        $CsInboundBlockedNumberPatterns = Get-CsInboundBlockedNumberPattern | Sort-Object Name
        if (($InfoLevel.CallRouting -gt 0) -and ($CsInboundBlockedNumberPatterns)) {
            Section -Style Heading3 'Inbound Blocked Number Patterns' {
                if ($Options.ShowSectionBlurb) {
                    if (!$options.ShowSectionFullDescription) {
                        #We dont want the blurb and the full description if the user selects both
                        Paragraph 'An inbound PSTN call from a number that matches the blocked number pattern will be blocked.'
                        BlankLine
                    }
                }
                if ($Options.ShowSectionFullDescription) {
                    Paragraph 'An inbound PSTN call from a number that matches the blocked number pattern will be blocked.'
                    Paragraph {
                        Text 'This can be used to block calls from particular numbers, such as telemarketers, or to block calls from a particular area code, such as 1900 numbers.'
                        Text 'Microsoft Calling Plans, Direct Routing, and Operator Connect all support blocking inbound calls from the Public Switched Telephone Network (PSTN). This feature allows an administrator to define a list of number patterns and exceptions at the tenant global level so that the caller ID of every incoming PSTN call to the tenant can be checked against the list for a match. If a match is made, an incoming call is rejected.'
                        Text 'Similar to other number patterns in Microsoft Teams, these are based around RegEx patterns.'
                        Text 'For more information see https://learn.microsoft.com/en-us/microsoftteams/block-inbound-calls?WT.mc_id=M365-MVP-5003444' }
                    BlankLine
                }
                $CsInboundBlockedNumberPatternInfo = @()
                foreach ($CsInboundBlockedNumberPattern in $CsInboundBlockedNumberPatterns) {
                    $InObj = [Ordered]@{
                        'Name' = $CsInboundBlockedNumberPattern.Name
                        'Pattern' = $CsInboundBlockedNumberPattern.Pattern
                        'Enabled' = $CsInboundBlockedNumberPattern.Enabled
                        'Description' = $CsInboundBlockedNumberPattern.Description
                    }
                    $CsInboundBlockedNumberPatternInfo += [PSCustomObject]$InObj
                }

                if ($InfoLevel.CallRouting -gt 0) {
                    Paragraph "The following sections detail the configuration of the Blocked Number Patterns within the $($CsTenant.DisplayName) tenant."
                    $TableParams = @{
                        Name = 'Blocked Number Patterns'
                        List = $false
                        Columns = 'Name', 'Pattern', 'Enabled', 'Description'
                        ColumnWidths = 20, 20, 10, 50
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $CsInboundBlockedNumberPatternInfo | Table @TableParams
                }
            }
        } else {
            Section -Style Heading3 'Inbound Blocked Number Patterns' {
                Paragraph 'No Blocked Number Patterns found, Your Tenant will not block any inbound PSTN calls'
                Paragraph 'For more information see https://learn.microsoft.com/en-us/microsoftteams/block-inbound-calls?WT.mc_id=M365-MVP-5003444'
            }
        }
        #endregion Blocked Number Patterns

        #region Exempt Number Patterns
        Write-PScriboMessage 'Collecting Number Blocking Expemptions'

        $CsInboundExemptNumberPatterns = Get-CsInboundExemptNumberPattern | Sort-Object Name
        if (($InfoLevel.CallRouting -gt 0) -and ($CsInboundExemptNumberPatterns)) {
            Section -Style Heading3 'Inbound Number Blocking Exempt Number Patterns' {
                if ($Options.ShowSectionBlurb) {
                    if (!$options.ShowSectionFullDescription) {
                        #We dont want the blurb and the full description if the user selects both
                        Paragraph 'An inbound PSTN call from a number that matches the Exempt number pattern will be ignored if it exists in a Blocked Number Pattern.'
                        BlankLine
                    }
                }
                if ($Options.ShowSectionFullDescription) {
                    Paragraph 'An inbound PSTN call from a number that matches the Exempt number pattern will be ignored if it exists in a Blocked Number Pattern.'
                    Paragraph {
                        Text 'This is handy if for example, you have blocked an entire area code, but need to allow a specific number from a vendor through'
                        Text 'Similar to other number patterns in Microsoft Teams, these are based around RegEx patterns.'
                        Text 'For more information see https://learn.microsoft.com/en-us/microsoftteams/block-inbound-calls?WT.mc_id=M365-MVP-5003444' }
                    BlankLine
                }
                $CsInboundExemptNumberPatternInfo = @()
                foreach ($CsInboundExemptNumberPattern in $CsInboundExemptNumberPatterns) {
                    $InObj = [Ordered]@{
                        'Name' = $CsInboundExemptNumberPattern.Name
                        'Pattern' = $CsInboundExemptNumberPattern.Pattern
                        'Enabled' = $CsInboundExemptNumberPattern.Enabled
                        'Description' = $CsInboundExemptNumberPattern.Description
                    }
                    $CsInboundExemptNumberPatternInfo += [PSCustomObject]$InObj
                }

                if ($InfoLevel.CallRouting -gt 0) {
                    Paragraph "The following sections detail the configuration of the Exempt Number Patterns within the $($CsTenant.DisplayName) tenant."
                    $TableParams = @{
                        Name = 'Exempt Number Patterns'
                        List = $false
                        Columns = 'Name', 'Pattern', 'Enabled', 'Description'
                        ColumnWidths = 20, 20, 10, 50
                    }
                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }
                    $CsInboundExemptNumberPatternInfo | Table @TableParams
                }
            }
        } else {
            Section -Style Heading3 'Inbound Number Blocking Exempt Number Patterns' {
                Paragraph 'No Exempt Number Patterns found, No numbers will be specifically allowed through Number Block Patterns'
                Paragraph 'For more information see https://learn.microsoft.com/en-us/microsoftteams/block-inbound-calls?WT.mc_id=M365-MVP-5003444'
            }
        }
        #endregion Exempt Number Patterns

    }


    end {}
}
