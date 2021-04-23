# Description: Uses a CSV file formatted with Headers of Employee, Email
# Author: Simon Doy
# Last Modified: 2021-04-23
# Change History
#
# v1.0 - Initial Version

param (
        [string]$csvFilePath,
        [string]$accessToken
)

# Access token can be retrieved via Microsoft Graph Explorer (https://developer.microsoft.com/en-us/graph/graph-explorer)
# "Hi, You have been invited to access the [Company Intranet]. This will give you access to the tools and resources at [Company] from one central location. Click on the accept invitation button below to access."

Write-Host "Reading users from Csv file $csvFilePath";

$employeeName = "";
$employeeEmail = "";
$emailMessageText = "Hi, You have been invited to access the [Company Intranet]. This will give you access to the tools and resources at [Company] from one central location. Click on the accept invitation button below to access. A video guide explaining what to do can be found here: [insert link to video]"
$inviteUrl = "https://[tenanturl].sharepoint.com"

$employees = Import-Csv -Path $csvFilePath;

foreach($employee in $employees){
    $employeeName = $employee.Employee;
    $employeeEmail = $employee.Email;

    .\Send-AzureAdGuestInvitation.ps1 -accessToken $accessToken -emailAddress $employeeEmail -displayName $employeeName -emailMessageText $emailMessageText -sendEmailInvite $true -inviteUrl $inviteUrl
}