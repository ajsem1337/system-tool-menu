# Załaduj moduł logowania i inne moduły
. .\modules\log-module.ps1
. .\modules\package-managers.ps1
. .\modules\windows-update.ps1
. .\modules\diagnostics.ps1

# Funkcja do zapytania użytkownika o logowanie
function Ask-ForLogging {
    $response = Read-Host "Czy chcesz zapisywać logi do pliku? (Tak/Nie)"
    
    if ($response -match "(?i)^tak$") {
        Enable-Logging
    }
    else {
        Write-Host "Logowanie zostało wyłączone."
        Disable-Logging
    }
}

# Wywołanie zapytania o logowanie przed rozpoczęciem operacji
Ask-ForLogging

# Funkcja menu głównego
function Show-Menu {
    Clear-Host
    Write-Host "[MENU GŁÓWNE] Wybierz jedną z opcji:"
    Write-Host "1: Menedżery pakietów"
    Write-Host "2: Aktualizacje Windows"
    Write-Host "3: Backup"
    Write-Host "4: Diagnostyka"
    Write-Host "0: Wyjście"
    $choice = Read-Host "Wybierz opcję (1-0)"

    switch ($choice) {
        1 { Show-PackageManagerMenu }  # Z modułu package-managers.ps1
        2 { Show-WindowsUpdateMenu }    # Z modułu windows-update.ps1
        3 { Show-BackupMenu }          # Z modułu backup.ps1
        4 { Show-DiagnosticsMenu }     # Z modułu diagnostics.ps1
        0 { Write-Host "Zamykanie..." ; exit }
        default { Write-Host "Nieprawidłowy wybór. Spróbuj ponownie." ; Start-Sleep -Seconds 2 ; Show-Menu }
    }
}

# Uruchom menu główne
Show-Menu
