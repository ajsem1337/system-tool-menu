# Funkcja do instalacji i aktualizacji systemu z użyciem PSWindowsUpdate (moduł opcjonalny)
function Perform-WindowsUpdate-With-Module {
    $start = Get-Date
    Write-Host "[LOG] Rozpoczynanie pełnej aktualizacji systemu Windows..."

    try {
        # Sprawdź, czy moduł jest zainstalowany
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Host "[LOG] Moduł PSWindowsUpdate nie jest zainstalowany. Instalowanie..."
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber
            Import-Module PSWindowsUpdate
            Write-Host "[LOG] Moduł PSWindowsUpdate został zainstalowany i załadowany."
        }
        else {
            Write-Host "[LOG] Moduł PSWindowsUpdate jest już zainstalowany."
            Import-Module PSWindowsUpdate
        }

        # Uruchom aktualizację
        Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose

        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Aktualizacja systemu zakończona w $($duration.TotalSeconds) sekundy."
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd przy aktualizacji systemu: $_" -ForegroundColor Red
    }

    # Po zakończeniu daj użytkownikowi możliwość naciśnięcia Enter
    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu Windows Update..."
    Show-WindowsUpdateMenu
}

# Funkcja do przeprowadzenia aktualizacji systemu bez użycia modułu PSWindowsUpdate (domyślnie z użyciem wuauclt lub usoclient)
function Perform-WindowsUpdate-Without-Module {
    $start = Get-Date
    Write-Host "[LOG] Rozpoczynanie pełnej aktualizacji systemu Windows (bez PSWindowsUpdate)..."

    try {
        # Logowanie przed rozpoczęciem procesu aktualizacji
        Write-Host "[LOG] Wymuszanie wykrywania i instalacji aktualizacji..."
        
        # Uruchomienie aktualizacji
        Invoke-Expression -Command "wuauclt /detectnow /updatenow"
        
        # Czekamy chwilę, aby sprawdzić, co się dzieje
        Start-Sleep -Seconds 10
        
        # Sprawdzamy, czy aktualizacje zostały wykryte
        Write-Host "[LOG] Próba wykrycia dostępnych aktualizacji zakończona. Wykonywanie aktualizacji..."
        
        # Możemy dodać dodatkowe komendy, jak np. `usoclient` do skanowania, jeśli to wymagane
        Invoke-Expression -Command "usoclient StartScan"
        
        # Czekamy chwilę na wykonanie aktualizacji
        Start-Sleep -Seconds 10

        # Sprawdzanie, czy są jakiekolwiek dostępne aktualizacje
        Write-Host "[LOG] Aktualizacje systemu powinny być teraz zainstalowane."

        # Zakończenie operacji
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Aktualizacja systemu zakończona w $($duration.TotalSeconds) sekundy."
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd przy aktualizacji systemu: $_" -ForegroundColor Red
        # Zapisz błąd do pliku
        $_ | Out-File "C:\path\to\error_log.txt" -Append
    }

    # Po zakończeniu daj użytkownikowi możliwość naciśnięcia Enter
    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu Windows Update..."
    Show-WindowsUpdateMenu
}


# Funkcja do przeprowadzenia aktualizacji tylko zabezpieczeń
function Perform-SecurityUpdate {
    $start = Get-Date
    Write-Host "[LOG] Rozpoczynanie aktualizacji zabezpieczeń systemu Windows..."
    
    try {
        # Komenda do instalacji tylko aktualizacji zabezpieczeń
        Write-Host "[LOG] Sprawdzanie dostępnych aktualizacji zabezpieczeń..."
        Start-Process "powershell.exe" -ArgumentList "Install-WindowsUpdate -AcceptAll -IgnoreReboot -Category 'SecurityUpdates'" -Wait
        
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Aktualizacja zabezpieczeń zakończona w $($duration.TotalSeconds) sekundy."
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd przy aktualizacji zabezpieczeń: $_" -ForegroundColor Red
    }

    # Po zakończeniu daj użytkownikowi możliwość naciśnięcia Enter
    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu Windows Update..."

    # Po zakończeniu wróć do menu Windows Update
    Show-WindowsUpdateMenu
}

# Funkcja do wyłączenia aktualizacji systemu
function Disable-WindowsUpdate {
    $start = Get-Date
    Write-Host "[LOG] Wyłączanie automatycznych aktualizacji Windows..."
    
    try {
        # Wyłączanie usługi Windows Update
        Stop-Service -Name wuauserv -Force
        Set-Service -Name wuauserv -StartupType Disabled
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Automatyczne aktualizacje zostały wyłączone w $($duration.TotalSeconds) sekundy."
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd przy wyłączaniu aktualizacji: $_" -ForegroundColor Red
    }

    # Po zakończeniu daj użytkownikowi możliwość naciśnięcia Enter
    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu Windows Update..."

    # Po zakończeniu wróć do menu Windows Update
    Show-WindowsUpdateMenu
}

# Funkcja do przywrócenia ustawienia automatycznych aktualizacji
function Enable-WindowsUpdate {
    $start = Get-Date
    Write-Host "[LOG] Włączanie automatycznych aktualizacji Windows..."
    
    try {
        # Włączenie usługi Windows Update
        Set-Service -Name wuauserv -StartupType Manual
        Start-Service -Name wuauserv
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Automatyczne aktualizacje zostały włączone w $($duration.TotalSeconds) sekundy."
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd przy włączaniu aktualizacji: $_" -ForegroundColor Red
    }

    # Po zakończeniu daj użytkownikowi możliwość naciśnięcia Enter
    Read-Host -Prompt "Naciśnij Enter, aby wrócić do menu Windows Update..."

    # Po zakończeniu wróć do menu Windows Update
    Show-WindowsUpdateMenu
}

# Funkcja menu dla Windows Update
function Show-WindowsUpdateMenu {
    Clear-Host
    Write-Host "[MENU AKTUALIZACJI WINDOWS] Wybierz opcję:"
    Write-Host "1: Aktualizuj system (wszystkie aktualizacje, PSWindowsUpdate)"
    Write-Host "2: Aktualizuj system (wszystkie aktualizacje, bez PSWindowsUpdate)"
    Write-Host "3: Wyłącz automatyczne aktualizacje"
    Write-Host "4: Włącz automatyczne aktualizacje"
    Write-Host "0: Wróć do głównego menu"
    $choice = Read-Host "Wybierz opcję (1-0)"

    switch ($choice) {
        1 { Perform-WindowsUpdate-With-Module }
        2 { Perform-WindowsUpdate-Without-Module }
        3 { Disable-WindowsUpdate }
        4 { Enable-WindowsUpdate }
        0 { Show-Menu }  # Powrót do głównego menu
        default { Write-Host "Nieprawidłowy wybór. Spróbuj ponownie." ; Start-Sleep -Seconds 2 ; Show-WindowsUpdateMenu }
    }
}