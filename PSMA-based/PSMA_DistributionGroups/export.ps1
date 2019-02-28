param
(
	$Username,
	$Password,
    $Credentials,
    $ExportType 
)
BEGIN
{
}
PROCESS
{
    $lError = $null

    $DN = $_.'[DN]'
    $member = $_.member
            
    if($DN){
        $group = Get-ADGroup -Identity $DN 
        if(!$group){
            $obj = @{}
            $obj.Add("[Identifier]", ($_.'[Identifier]'))
            $obj.Add("[ErrorName]", "PSException")
            $obj.Add("[ErrorDetail]", "Couldn't find group with Identity $DN")
            $obj
            $lError = $true
        }else{
            try{
                #Check if member was specified and got value, or if member was specified but is empty
                if($member -or (!$member -and (($_.'[ChangedAttributeNames]').Contains("member")) )){
                    #Member was specified but is emtpy, so build an empty array
                    if(!$member){
                        $member = @()
                    }

                    #Get the current members of the group
                    $currentMembers = Get-ADGroupMember -Identity $DN | Select-Object -ExpandProperty 'distinguishedName'

                    #Get the supposed members of the group
                    $supposedMembers = $member
                    
                    #Remove any members which aren't supposed to be there
                    $currentMembers | ForEach-Object {
                        if(!($supposedMembers.Contains($_))){
                            Remove-ADGroupMember -Identity $DN -Members $_ -Confirm:$false
                        }
                    }

                    #Add any new members
                    $supposedMembers | ForEach-Object {
                        if(!($currentMembers.Contains($_))){
                            Add-ADGroupMember -Identity $DN -Members $_ -Confirm:$false
                        }
                    }
                }
            }catch{
                $obj = @{}
                $obj.Add("[Identifier]", ($_.'[Identifier]'))
                $obj.Add("[ErrorName]", "PSException")
                $obj.Add("[ErrorDetail]", ($_.Exception.Message))
                $obj
                $lError = $true
            }
        }
    }else{
        $obj = @{}
        $obj.Add("[Identifier]", ($_.'[Identifier]'))
        $obj.Add("[ErrorName]", "PSException")
        $obj.Add("[ErrorDetail]", "No DN specified")
        $obj
        $lError = $true
    }
    

    if(!$lError){
        $obj = @{}
        $obj.Add("[Identifier]", ($_.'[Identifier]'))
        $obj.Add("[ErrorName]", "success")
        $obj
    }
}
END
{
}


