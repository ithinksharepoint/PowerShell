param
(
	[Parameter(Mandatory=$true, HelpMessage='Url for Site Collection hosting content type')]
	[string]$Url = "https://sharepoint.ithinksharepoint.com",
	[Parameter(Mandatory=$true, HelpMessage='Name of the Content Type to apply document template to')]
	[string]$ContentTypeName = "Policy Document",
	[Parameter(Mandatory=$true, HelpMessage='File path of the document template to upload')]
	[string]$DocumentTemplatePath = "",
	[Parameter(Mandatory=$false, HelpMessage='Filename to store the file in SharePoint as')]
	[string]$DocumentTemplateFileName = "",
	[Parameter(Mandatory=$false, HelpMessage='Should derived child content types and list content types be updated?')]
	[boolean]$UpdateChildren = $true
)

$site=Get-SPSite $Url;


if($site -ne $null)
{
	$rootWeb = Get-SPWeb $Url;
	$contentType = $rootWeb.ContentTypes | ?{$_.Name -eq $ContentTypeName};
	
	if($contentType -ne $null -and [System.IO.File]::Exists($DocumentTemplatePath))
	{
		
		$templateFile = [System.IO.File]::OpenRead($DocumentTemplatePath);
		$memoryStream = new-object System.IO.MemoryStream;
		$templateFile.CopyTo($memoryStream);
		
		if([String]::IsNullOrEmpty($DocumentTemplateFileName))
		{
			$DocumentTemplateFileName = [System.IO.Path]::GetFileName($DocumentTemplatePath);
		}
		
		$destinationUrl=[String]::Format("{0}/{1}/{2}", $rootWeb.ServerRelativeUrl, $contentType.ResourceFolder.Url, $DocumentTemplateFileName);
		if(-not [String]::IsNullOrEmpty($contentType.DocumentTemplateUrl))
		{
			Write-Host "Checking Content Type Document Template Url: $contentType.DocumentTemplateUrl for file" -ForegroundColor White;
			$checkFile = $rootWeb.GetFile($contentType.DocumentTemplateUrl);
			if($checkFile.Exists)
			{
				Write-Host "File found at $contentType.DocumentTemplateUrl, removing" -ForegroundColor White;
				$checkFile.Delete();
			}
		}
		
		
		Write-Host "Checking for file @ $destinationUrl" -ForegroundColor White;
		$checkFile=$rootWeb.GetFile($destinationUrl);
		if($checkFile.Exists)
		{
			Write-Host "file found @ $destinationUrl, removing" -ForegroundColor White;
			$checkFile.Delete();
		}
		
		Write-Host "Content Type Document Template not set or found " $contentType.Name -ForegroundColor White;
			
		$checkFile = $contentType.ResourceFolder.Files.Add($destinationUrl, $memoryStream.ToArray());
		$checkFile.Update();
		
		Write-Host "Uploaded file $DocumentTemplatePath -> $destinationUrl for" $contentType.Name -ForegroundColor White;
		
		$contentType.DocumentTemplate = $DocumentTemplateFileName;
		$contentType.UpdateIncludingSealedAndReadOnly($UpdateChildren);
		
		Write-Host "Applied Document Template $destinationUrl to " $contentType.Name " and updated content type (All Children Update Flag set? $UpdateChildren)" -ForegroundColor Green;
	

		
	
	}
	else{
		Write-Error "Cannot find $ContentTypeName in $Url or cannot find document template file $DocumentTemplatePath, please check.";
	}
}
else
{
	Write-Host "Cannot find Site $Url" -ForegroundColor Yellow;
}


Write-Host "Finished";