# MUST RUN AS ADMINISTRATOR

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$false, ValueFromPipeline=$True)] $InputObject,
	[Parameter(Mandatory=$false)] [Switch] $Help
)

Begin {
	$usage = @'

VHD-Compact — Compact .vhd and .vhdx files in bulk

Usage:
    VHD-Compact -Help
    VHD-Compact file1.vhdx file2.vhdx
    'file1.vhdx', 'file1.vhdx' | VHD-Compact
    DIR *.vhd, *.vhdx -File -Recursive | VHD-Compact
'@

	if ($Help) { $usage; exit }
	if (-not $InputObject) { $usage; exit }
}

Process {

	###################

	# Check if the script is running with elevated privileges
	if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		# If not, restart the script with elevated privileges
		$scriptPath = $PSCommandPath
		Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"  `"$($InputObject | gi)`" " -Verb RunAs
		exit
	}

	#Write-Host "The script is running with elevated privileges."
	
	###################


	foreach ($vhd in $InputObject) {
		$vhd_fullpath = gi $vhd | % FullName
@"
select vdisk File="$vhd_fullpath"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@ | diskpart

	}
	
	
	###################
	
	# PAUSE
	Write-Host "Press any key to continue..."
	$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	
}


End {}



	
	
<#

#>
