<#
.SYNOPSIS
    Checks disk space across lab virtual machines and flags any nearing capacity.

.DESCRIPTION
    Connects to a list of VMs and reports free disk space, flagging any drive
    below a configurable threshold. Useful as a lightweight proactive check
    before disk space becomes a real problem.

.NOTES
    Author: Joel Ephraim
    This is a lab/demo script — review and adapt before use in any real environment.
#>

param(
    [Parameter(Mandatory = $true)]
    [string[]]$ComputerNames,

    [int]$ThresholdPercentFree = 15
)

foreach ($computer in $ComputerNames) {
    try {
        $disks = Get-CimInstance -ComputerName $computer -ClassName Win32_LogicalDisk -Filter "DriveType=3"

        foreach ($disk in $disks) {
            $percentFree = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1)

            $status = if ($percentFree -lt $ThresholdPercentFree) { "LOW SPACE" } else { "OK" }

            [PSCustomObject]@{
                Computer    = $computer
                Drive       = $disk.DeviceID
                PercentFree = "$percentFree%"
                Status      = $status
            }
        }
    }
    catch {
        Write-Warning "Could not connect to $computer : $_"
    }
}
