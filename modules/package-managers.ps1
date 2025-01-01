# Załaduj moduł logowania
. .\modules\log-module.ps1

function Install-Chocolatey {
    Write-Host "[LOG] Wybrano: Instalowanie/aktualizowanie Chocolatey..."
    Write-Log "[LOG] Wybrano: Instalowanie/aktualizowanie Chocolatey..."

    $start = Get-Date
    try {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "[LOG] Chocolatey jest zainstalowany. Aktualizowanie..."
            Write-Log "[LOG] Chocolatey jest zainstalowany. Aktualizowanie..."
            choco upgrade all -y
        }
        else {
            $installChoco = Read-Host "Chocolatey nie jest zainstalowany. Czy chcesz go zainstalować? (Tak/Nie)" -ForegroundColor Red
            if ($installChoco -match "(?i)^tak$") {
                Write-Host "[LOG] Instalowanie Chocolatey..."
                Write-Log "[LOG] Instalowanie Chocolatey..."
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.WebClient]::new().DownloadString('https://chocolatey.org/install.ps1') | Invoke-Expression
                Write-Host "[LOG] Aktualizowanie pakietów za pomocą Chocolatey..."
                Write-Log "[LOG] Aktualizowanie pakietów za pomocą Chocolatey..."
                choco upgrade all -y
            }
            else {
                Write-Host "[LOG] Instalacja Chocolatey została anulowana."
                Write-Log "[LOG] Instalacja Chocolatey została anulowana."
            }
        }
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd: $_" -ForegroundColor Red
        Write-Log "[ERROR] Wystąpił błąd przy aktualizacji Chocolatey: $_"
    }
    finally {
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Operacja (Chocolatey) zakończona w $($duration.TotalSeconds) sek."
        Write-Log "[LOG] Aktualizacja Chocolatey zakończona w $($duration.TotalSeconds) sek."
        Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
    }

    # Po zakończeniu wróć do menu menedżerów pakietów
    Show-PackageManagerMenu
}

function Install-Scoop {
    Write-Host "[LOG] Wybrano: Instalowanie/aktualizowanie Scoop..."
    $start = Get-Date
    try {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Host "[LOG] Scoop jest zainstalowany. Aktualizowanie..."
            scoop update *
        }
        else {
            $installScoop = Read-Host "Scoop nie jest zainstalowany. Czy chcesz go zainstalować? (Tak/Nie)" -ForegroundColor Red
            if ($installScoop -match "(?i)^tak$") {
                Write-Host "[LOG] Instalowanie Scoop..."
                iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
                Write-Host "[LOG] Aktualizowanie pakietów za pomocą Scoop..."
                scoop update *
            }
            else {
                Write-Host "[LOG] Instalacja Scoop została anulowana."
            }
        }
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd: $_" -ForegroundColor Red
    }
    finally {
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Operacja (Scoop) zakończona w $($duration.TotalSeconds) sek."
        Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
    }

    # Po zakończeniu wróć do menu menedżerów pakietów
    Show-PackageManagerMenu
}

function Install-Winget {
    Write-Host "[LOG] Wybrano: Instalowanie/aktualizowanie Winget..."
    $start = Get-Date
    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "[LOG] Winget jest zainstalowany. Aktualizowanie..."
            winget upgrade --all
        }
        else {
            $installWinget = Read-Host "Winget nie jest zainstalowany. Czy chcesz go zainstalować? (Tak/Nie)" -ForegroundColor Red
            if ($installWinget -match "(?i)^tak$") {
                Write-Host "[LOG] Instalowanie Winget..."
                # Winget jest częścią Windows 10 1809+ i 11, więc instalujemy go z Microsoft Store, jeśli nie jest zainstalowany
                Start-Process "ms-windows-store://pdp/?productid=9NBLGGH42THS" -Wait
                Write-Host "[LOG] Aktualizowanie pakietów za pomocą Winget..."
                winget upgrade --all
            }
            else {
                Write-Host "[LOG] Instalacja Winget została anulowana."
            }
        }
    }
    catch {
        Write-Host "[ERROR] Wystąpił błąd: $_" -ForegroundColor Red
    }
    finally {
        $end = Get-Date
        $duration = $end - $start
        Write-Host "[LOG] Operacja (Winget) zakończona w $($duration.TotalSeconds) sek."
        Read-Host -Prompt "Naciśnij Enter, aby kontynuować..."
    }

    # Po zakończeniu wróć do menu menedżerów pakietów
    Show-PackageManagerMenu
}

# Funkcja menu podmenu dla menedżerów pakietów
function Show-PackageManagerMenu {
    Clear-Host
    Write-Host "[MENU MENEDŻERÓW PAKIETÓW] Wybierz menedżera pakietów do aktualizacji:"
    Write-Host "1: Aktualizuj Chocolatey"
    Write-Host "2: Aktualizuj Scoop"
    Write-Host "3: Aktualizuj Winget"
    Write-Host "0: Wróć do menu głównego"
    $choice = Read-Host "Wybierz opcję (1-0)"

    switch ($choice) {
        1 { Install-Chocolatey }
        2 { Install-Scoop }
        3 { Install-Winget }
        0 { Show-Menu }  # Powrót do głównego men
        default { Write-Host "Nieprawidłowy wybór. Spróbuj ponownie." ; Start-Sleep -Seconds 2 ; Show-PackageManagerMenu }
    }
}