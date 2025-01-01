# log-module.ps1

# Zmienna, która określa, czy logowanie jest włączone
$LoggingEnabled = $false
$LogFilePath = ""

# Funkcja do włączenia logowania
function Enable-Logging {
    # Tworzymy folder logs, jeśli nie istnieje
    $logFolder = ".\logs"
    if (-not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory
    }

    # Tworzymy nazwę pliku logu z datą
    $dateString = Get-Date -Format "yyyy-MM-dd"
    $LogFilePath = "$logFolder\log-$dateString.txt"
    
    # Włączamy logowanie
    $LoggingEnabled = $true
    Write-Host "[LOG] Logowanie włączone. Zapis logów do pliku: $LogFilePath"
}

# Funkcja do wyłączenia logowania
function Disable-Logging {
    $LoggingEnabled = $false
    Write-Host "[LOG] Logowanie wyłączone."
}

# Funkcja do zapisania logu do pliku
function Write-Log {
    param (
        [string]$message
    )
    
    if ($LoggingEnabled) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] $message"
        
        # Używamy pełnej ścieżki do pliku logu
        $logMessage | Out-File -FilePath $LogFilePath -Append
    }
}
