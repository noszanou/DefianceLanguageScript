Write-Host "Choose language for Defiance / Choisissez la langue / Sprache wählen:"
Write-Host "1. English"
Write-Host "2. French / Français"
Write-Host "3. German / Deutsch / Allemand"

$choice = Read-Host "Enter your choice (1-3)"

$locale = ""
switch ($choice) {
    "1" { $locale = "english"; Write-Host "English language selected" }
    "2" { $locale = "french"; Write-Host "French language selected" }
    "3" { $locale = "german"; Write-Host "German language selected" }
    default { $locale = "english"; Write-Host "Invalid choice. Default: English" }
}

Write-Host "Monitoring Defiance launch..."

while ($true) {
    try {
        $defianceProcesses = Get-Process -Name "Defiance" -ErrorAction SilentlyContinue
        foreach ($process in $defianceProcesses) {
            $wmiProcess = Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)"
            if ($wmiProcess -ne $null) {
                $commandLine = $wmiProcess.CommandLine
                $execPath = $wmiProcess.ExecutablePath
                if ($commandLine -notmatch "/locale") {
                    $arguments = $commandLine -replace "^.*?Defiance\.exe", ""
                    $newArguments = "/locale $locale" + $arguments
                    Stop-Process -Id $process.Id -Force
                    Start-Sleep -Seconds 1
                    Start-Process -FilePath $execPath -ArgumentList $newArguments -WorkingDirectory (Split-Path -Parent $execPath)
                    Start-Sleep -Seconds 10
                }
            }
        }
    }
    catch {
        Write-Host "Error: $_"
    }

    Start-Sleep -Seconds 2
}