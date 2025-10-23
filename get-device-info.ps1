# Get user name
$username = Read-Host "Enter the name of the user"
$location = Read-Host "Enter the location of this system"

# Get Hostname
$hostname = $env:COMPUTERNAME

# Get System Info
$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$bios = Get-CimInstance -ClassName Win32_BIOS
$processor = Get-CimInstance -ClassName Win32_Processor
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$memoryModules = Get-CimInstance -ClassName Win32_PhysicalMemory
$physicalDisks = Get-CimInstance Win32_DiskDrive
$diskCapacity = Get-CimInstance Win32_DiskDrive | ForEach-Object { "{0} GB" -f [math]::Round($_.Size / 1GB, 2) }
$networkDetails = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" | Select-Object Description, MACAddress
$timestamp = Get-Date -Format "dd-MM-yyyy_HHmmss"


# Caculate Total RAM (in GB)
$totalRAMGB = [math]::Round(($computerSystem.TotalPhysicalMemory / 1GB), 2)

# Get RAM Speeds (there may be more than one module with different speeds)
$ramSpeeds = ($memoryModules | Select-Object -ExpandProperty Speed | Sort-Object -Unique)

# Counting Disks
$diskCount = $physicalDisks.count + 1

# Joining strings
$ramSpeedString = ($ramSpeeds -join ", ")
$allAdapters = ($networkDetails | ForEach-Object {"$($_.Description)-$($_.MACAddress)"})-join ", "
$diskCapacity = ($diskCapacity -join ", ")

# Output collected information
$systemInfo = [PSCustomObject]@{
    "User"            = $username
    "Location"        = $location  
    "Hostname"        = $hostname
    "Model"           = $computerSystem.Model
    "Processor"       = $processor.Name
    "ProcessorSpeed"  = "$($processor.MaxClockSpeed) MHz"
    "TotalRAM"        = "$totalRAMGB GB"
    "RAMspeed"        = "$ramSpeedString MHz"
    "No of Disks"     = $diskCount
    "Disk Sizes"      = $diskCapacity
    "OperatingSystem" = $os.Caption
    "SerialNumber"    = $bios.SerialNumber
    "Networking Info" = $allAdapters
    "Date and time"   = $timestamp
}

$outputFile = ".\SystemInfoLog.csv"

# If file doesnt exist, create it; otherwise append new entry
if (Test-Path $outputFile) {
    $systemInfo | Export-Csv -Path $outputFile -NoTypeInformation -Append
}
else {
    $systemInfo | Export-Csv -Path $outputFile -NoTypeInformation
}

Write-Host "`nSystem information added to: $outputFile" -ForegroundColor Green


# I have no idea how to script in powershell, this was (mostly) written by chatgpt -shayaan