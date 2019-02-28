PARAM
(
  $Username,
  $Password,
  $Credentials,
  $OperationType,
  $UsePagedImport,
  $PageSize,
  $Schema
)

BEGIN
{

}
PROCESS
{
   
    Get-ADGroup -Filter { GroupCategory -eq "Distribution"} -Properties * | ForEach-Object {

            $obj = @{}
            $obj.Add("objectGuid", ([GUID]$_.objectGUID).ToString())
            $obj.Add("[ObjectClass]", [string]"group")
            $obj.Add("[DN]", [string]$_.DistinguishedName)
            $obj.Add("member", ([array]$_.Members))
            $obj.Add("objectSidString", [string]$_.objectSid.Value)

            $obj
    }

}
END
{
}