# Description: Sends a Azure AD Guest Invite with custom message and url.
# Author: Simon Doy
# Last Modified: 2021-04-23
# Change History
#
# v1.0 - Initial Version


param (
        [string]$accessToken,
        [string]$emailAddress,
        [string]$displayName,
        [boolean]$sendEmailInvite,
        [string]$emailMessageText,
        [string]$inviteUrl
)

# Access token can be retrieved via Microsoft Graph Explorer (https://developer.microsoft.com/en-us/graph/graph-explorer)

Write-Host "Attempting to invite $displayName ($emailAddress) to $inviteUrl";

$inviteMessageObject = "" | Select customizedMessageBody,messageLanguage;
$invitationObject = "" | Select invitedUserEmailAddress,inviteRedirectUrl,sendInvitationMessage,invitedUserMessageInfo;

$inviteMessageObject.customizedMessageBody = $emailMessageText;
$inviteMessageObject.messageLanguage = "en-GB";

$invitationObject.invitedUserEmailAddress = $emailAddress;
$invitationObject.inviteRedirectUrl = $inviteUrl;
$invitationObject.sendInvitationMessage = $sendEmailInvite;
$invitationObject.invitedUserMessageInfo = $inviteMessageObject;

$invitation = ConvertTo-Json $invitationObject;
$graphInviteUrl = "https://graph.microsoft.com/beta/invitations";

Write-Host "Calling Graph Invite API $graphInviteUrl with $invitation";
Invoke-RestMethod -Method Post -Uri $graphInviteUrl -Body $invitation -Headers @{"Authorization"="Bearer $accessToken"}


