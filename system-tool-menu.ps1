# Menu aplikacji terminalowej
# Plik: system-tool-menu.ps1

# Sprawdzenie, czy skrypt uruchomiono jako administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Ten skrypt wymaga uruchomienia jako administrator. Zakończenie..." -ForegroundColor Red
    exit
}

# Funkcja dynamicznego wyświetlania menu
function Show-Menu {
    param (
        [string]$Title,
        [hashtable]$Options
    )

    Clear-Host
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan

    foreach ($key in ($Options.Keys | Sort-Object {[int]$_})) {
        Write-Host "$key. $($Options[$key])" -ForegroundColor Yellow
    }

    Write-Host "========================" -ForegroundColor Cyan
}

# -----------------------------
#         GŁÓWNE FUNKCJE
# -----------------------------

function WindowsUpdate {
    Write-Host "[LOG] Uruchamiam WindowsUpdate..." -ForegroundColor Cyan
    $start = Get-Date

    Write-Host "Sprawdzanie aktualizacji Windows..." -ForegroundColor Green
    Start-Process -Wait -FilePath "powershell.exe" -ArgumentList "-Command Install-Module PSWindowsUpdate -Force"
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -Install -AcceptAll -AutoReboot

    $end = Get-Date
    $duration = $end - $start
    Write-Host "[LOG] WindowsUpdate zakończone! Czas trwania: $($duration.TotalSeconds) sek." -ForegroundColor Green

    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu głównego"
}

function PackageManagers {
    $packageOptions = @{
        "1" = "Chocolatey";
        "2" = "Winget";
        "3" = "Scoop";
        "4" = "Powrót do menu głównego"
    }

    while ($true) {
        Show-Menu -Title "Menedżery pakietów" -Options $packageOptions
        $choice = Read-Host "Wybierz opcję"

        switch ($choice) {
            "1" {
                Write-Host "[LOG] Wybrano: Aktualizowanie Chocolatey..."
                $start = Get-Date
                if (Get-Command choco -ErrorAction SilentlyContinue) {
                    choco upgrade all -y
                } else {
                    Write-Host "Chocolatey nie jest zainstalowany. Czy chcesz go zainstalować? (Tak/Nie)" -ForegroundColor Red
                    $installChoco = Read-Host
                    if ($installChoco -match "(?i)^tak$") {
                        Set-ExecutionPolicy Bypass -Scope Process -Force
                        [System.Net.WebClient]::new().DownloadString('https://chocolatey.org/install.ps1') | Invoke-Expression
                    }
                }
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] Operacja (Chocolatey) zakończona w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "2" {
                Write-Host "[LOG] Wybrano: Aktualizowanie Winget..."
                $start = Get-Date
                if (Get-Command winget -ErrorAction SilentlyContinue) {
                    winget upgrade --all --accept-source-agreements --accept-package-agreements
                } else {
                    Write-Host "Winget nie jest zainstalowany. Czy chcesz go zainstalować? (Tak/Nie)" -ForegroundColor Red
                    $installWinget = Read-Host
                    if ($installWinget -match "(?i)^tak$") {
                        Invoke-WebRequest -Uri "https://aka.ms/get-winget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller.cab"
                        Add-AppxPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller.cab"
                    }
                }
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] Operacja (Winget) zakończona w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "3" {
                Write-Host "[LOG] Wybrano: Aktualizowanie Scoop..."
                $start = Get-Date
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop update *
                } else {
                    Write-Host "Scoop nie jest zainstalowany. Czy chcesz go zainstalować? (Tak/Nie)" -ForegroundColor Red
                    $installScoop = Read-Host
                    if ($installScoop -match "(?i)^tak$") {
                        Invoke-Expression "iwr -useb get.scoop.sh | iex"
                    }
                }
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] Operacja (Scoop) zakończona w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "4" {
                return
            }
            default {
                Write-Host "Nieprawidłowa opcja, spróbuj ponownie." -ForegroundColor Red
            }
        }
    }
}

function Diagnostics {
    $diagnosticOptions = @{
        "1" = "DISM";
        "2" = "SFC Scannow";
        "3" = "CheckDisk";
        "4" = "Powrót do menu głównego"
    }

    while ($true) {
        Show-Menu -Title "Diagnostyka systemu" -Options $diagnosticOptions
        $choice = Read-Host "Wybierz opcję"

        switch ($choice) {
            "1" {
                Write-Host "[LOG] Uruchamianie DISM..."
                $start = Get-Date
                DISM /Online /Cleanup-Image /ScanHealth
                DISM /Online /Cleanup-Image /CheckHealth
                DISM /Online /Cleanup-Image /RestoreHealth
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] DISM zakończone w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "2" {
                Write-Host "[LOG] Uruchamianie SFC Scannow..."
                $start = Get-Date
                sfc /scannow
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] SFC zakończone w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "3" {
                Write-Host "[LOG] Uruchamianie CheckDisk..."
                $start = Get-Date
                Get-Volume | ForEach-Object {
                    if ($_.FileSystem -eq "NTFS") {
                        chkdsk $($_.DriveLetter): /f /r
                    }
                }
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] CheckDisk zakończone w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "4" {
                return
            }
            default {
                Write-Host "Nieprawidłowa opcja, spróbuj ponownie." -ForegroundColor Red
            }
        }
    }
}

function ReinstallMicrosoftStore {
    Write-Host "[LOG] Próba ponownego zarejestrowania Sklepu Microsoft..." -ForegroundColor Green
    $start = Get-Date
    try {
        Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach-Object {
            Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
        }
        Write-Host "Sklep Microsoft został pomyślnie zarejestrowany." -ForegroundColor Green
    } catch {
        Write-Host "Nie udało się ponownie zarejestrować Sklepu Microsoft. Plik AppXManifest.xml może być niedostępny." -ForegroundColor Red
        Write-Host "Spróbuj przywrócić Sklep Microsoft z Microsoft Update lub za pomocą narzędzia Media Creation Tool." -ForegroundColor Yellow
    }
    $end = Get-Date
    $duration = $end - $start
    Write-Host "[LOG] Rejestracja (Microsoft Store) zakończona w $($duration.TotalSeconds) sek."

    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu głównego"
}

# -----------------------------
#       MENU BACKUP
# -----------------------------
function BackupMenu {
    $backupOptions = @{
        "1" = "Backup rejestru";
        "2" = "Tworzenie punktu przywracania";
        "3" = "Oczyszczanie dysku";
        "4" = "Powrót do menu głównego"
    }

    while ($true) {
        Show-Menu -Title "Menu Backup i Przywracania" -Options $backupOptions
        $choice = Read-Host "Wybierz opcję"

        switch ($choice) {
            "1" {
                Write-Host "[LOG] Tworzenie backupu rejestru..."
                $start = Get-Date
                reg export HKLM "C:\Backup\registry.reg" /y
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] Backup rejestru zakończony w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "2" {
                Write-Host "[LOG] Tworzenie punktu przywracania..."
                $start = Get-Date
                Checkpoint-Computer -Description "Punkt przywracania" -RestorePointType "MODIFY_SETTINGS"
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] Tworzenie punktu przywracania zakończone w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "3" {
                Write-Host "[LOG] Uruchamianie oczyszczania dysku..."
                $start = Get-Date
                Start-Process -FilePath "cleanmgr.exe" -Wait
                $end = Get-Date
                $duration = $end - $start
                Write-Host "[LOG] Oczyszczanie dysku zakończone w $($duration.TotalSeconds) sek."
                Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
            }
            "4" {
                return
            }
            default {
                Write-Host "Nieprawidłowa opcja, spróbuj ponownie." -ForegroundColor Red
            }
        }
    }
}

# -----------------------------
#    INSTALACJE DODATKOWE
# -----------------------------
function InstallDirectX {
    Write-Host "[LOG] Instalowanie DirectX Runtime..." -ForegroundColor Green
    $start = Get-Date
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/1C/1C38D42D-6A2A-4D8E-9792-B5E759D8DE0A/directx_Jun2010_redist.exe" -OutFile "$env:TEMP\directx_redist.exe"
    Start-Process -FilePath "$env:TEMP\directx_redist.exe" -ArgumentList "/Q /T:$env:TEMP\DirectX" -Wait
    Start-Process -FilePath "$env:TEMP\DirectX\DXSETUP.exe" -ArgumentList "/silent" -Wait
    $end = Get-Date
    $duration = $end - $start
    Write-Host "[LOG] DirectX Runtime został zainstalowany w $($duration.TotalSeconds) sek."
    Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
}

function InstallDotNet6 {
    Write-Host "[LOG] Instalowanie .NET Runtime 6..." -ForegroundColor Green
    $start = Get-Date
    winget install --id Microsoft.DotNet.Runtime.6 -e --accept-source-agreements --accept-package-agreements
    $end = Get-Date
    $duration = $end - $start
    Write-Host "[LOG] .NET Runtime 6 został zainstalowany w $($duration.TotalSeconds) sek."
    Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
}

function InstallDotNet8 {
    Write-Host "[LOG] Instalowanie .NET Runtime 8..." -ForegroundColor Green
    $start = Get-Date
    winget install --id Microsoft.DotNet.Runtime.8 -e --accept-source-agreements --accept-package-agreements
    $end = Get-Date
    $duration = $end - $start
    Write-Host "[LOG] .NET Runtime 8 został zainstalowany w $($duration.TotalSeconds) sek."
    Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
}

function InstallDotNet9 {
    Write-Host "[LOG] Instalowanie .NET Runtime 9..." -ForegroundColor Green
    $start = Get-Date
    winget install --id Microsoft.DotNet.Runtime.9 -e --accept-source-agreements --accept-package-agreements
    $end = Get-Date
    $duration = $end - $start
    Write-Host "[LOG] .NET Runtime 9 został zainstalowany w $($duration.TotalSeconds) sek."
    Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
}

function InstallAdditional {
    $additionalOptions = @{
        "1" = "Instalacja DirectX";
        "2" = "Instalacja .NET Runtime 6";
        "3" = "Instalacja .NET Runtime 8";
        "4" = "Instalacja .NET Runtime 9";
        "5" = "Powrót do menu głównego"
    }

    while ($true) {
        Show-Menu -Title "Instalacje dodatkowe" -Options $additionalOptions
        $choice = Read-Host "Wybierz opcję"

        switch ($choice) {
            "1" {
                InstallDirectX
            }
            "2" {
                InstallDotNet6
            }
            "3" {
                InstallDotNet8
            }
            "4" {
                InstallDotNet9
            }
            "5" {
                return
            }
            default {
                Write-Host "Nieprawidłowa opcja, spróbuj ponownie." -ForegroundColor Red
            }
        }
    }
}

# -----------------------------
#        MENU GŁÓWNE
# -----------------------------
function MainMenu {
    $mainOptions = @{
        "1" = "Windows Update";
        "2" = "Menedżery pakietów";
        "3" = "Diagnostyka systemu";
        "4" = "Backup i Przywracanie";
        "5" = "Reinstalacja Sklepu Microsoft";
        "6" = "Instalacje dodatkowe";
        "7" = "Wyjście"
    }

    while ($true) {
        Show-Menu -Title "Menu Główne" -Options $mainOptions
        $choice = Read-Host "Wybierz opcję"

        switch ($choice) {
            "1" {
                WindowsUpdate
            }
            "2" {
                PackageManagers
            }
            "3" {
                Diagnostics
            }
            "4" {
                BackupMenu
            }
            "5" {
                ReinstallMicrosoftStore
            }
            "6" {
                InstallAdditional
            }
            "7" {
                Write-Host "Zakończono program." -ForegroundColor Green
                exit
            }
            default {
                Write-Host "Nieprawidłowa opcja, spróbuj ponownie." -ForegroundColor Red
            }
        }
    }
}

# Start programu
MainMenu
