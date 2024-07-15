param (
    [string]$GpoName,
    [string]$GpoDescription,
    [string]$SharePath,
    [string]$DomainDn
)

Import-Module GroupPolicy

# Create the GPO
$gpo = New-GPO -Name $GpoName -Comment $GpoDescription

# Create the XML for the drive map
$driveMapXML = @"
<DriveMaps clsid="8AD5C1C7-F46C-4DFF-B9E5-A1C349BCEAAF" displayName="Snare-Products Drive" image="7" preference="true">
    <Properties action="U" uid="2E143B8F-6B0D-4E8B-9239-BB1DC4AD8C34" driveLetter="P" path="$SharePath" hide="false" />
</DriveMaps>
"@

# Create a temporary path to store the XML
$gpoBackupPath = "C:\Temp\GPOBackups"
if (-not (Test-Path $gpoBackupPath)) {
    New-Item -ItemType Directory -Path $gpoBackupPath
}

# Backup the GPO
Backup-GPO -Name $GpoName -Path $gpoBackupPath

# Get the path to the GPO XML file
$gpoXMLPath = Join-Path -Path $gpoBackupPath -ChildPath $gpo.ID
$gpoXMLPath = Join-Path -Path $gpoXMLPath -ChildPath "User\Preferences\Drives\Drives.xml"

# Write the drive map XML to the XML file
$driveMapXML | Out-File -FilePath $gpoXMLPath -Encoding ASCII

# Restore the GPO from the modified backup
Restore-GPO -Name $GpoName -Path $gpoBackupPath -Replace

# Clean up temporary backup path
Remove-Item -Recurse -Force -Path $gpoBackupPath

# Link the GPO to the domain
New-GPLink -Name $GpoName -Target $DomainDn
