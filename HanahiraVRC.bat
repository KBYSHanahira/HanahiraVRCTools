@echo off
title HanahiraVRC - VRChat Fix Toolkit
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$global:Self='%~f0'; $s=[IO.File]::ReadAllText($global:Self,[Text.Encoding]::UTF8); $i=$s.LastIndexOf('#'+'<PS>'); Invoke-Expression $s.Substring($i)" & exit /b
#<PS>
# ============================================================
#  HanahiraVRC - VRChat Fix Toolkit  (PowerShell core, launched from the .bat)
#  Everything below the marker is PowerShell so Unicode box art renders correctly.
#  NOTE: PowerShell variables are case-insensitive ($r and $R are the same).
# ============================================================
$ErrorActionPreference = 'SilentlyContinue'
$Ver = '3.2'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding  = [Text.Encoding]::UTF8

# enable ANSI colours on classic conhost too
try {
    Add-Type -Namespace HV -Name K -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out int m);
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, int m);
'@
    $h = [HV.K]::GetStdHandle(-11); $m = 0
    if ([HV.K]::GetConsoleMode($h, [ref]$m)) { [void][HV.K]::SetConsoleMode($h, $m -bor 4) }
} catch {}

# ---------- paths ----------
$Root      = Split-Path -Parent $global:Self
$VrcData   = Join-Path $env:USERPROFILE 'AppData\LocalLow\VRChat\VRChat'
$VrcCache  = Join-Path $VrcData 'Cache-WindowsPlayer'
$BackupDir = Join-Path $Root 'Backups'
$LogDir    = Join-Path $Root 'Logs'
$LogFile   = Join-Path $LogDir 'HanahiraVRC.log'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ---------- colours: orange on black ----------
$E = [char]27
function Rgb($r, $g, $b)   { "${E}[38;2;${r};${g};${b}m" }
function RgbBg($r, $g, $b) { "${E}[48;2;${r};${g};${b}m" }
$BG     = RgbBg 12 12 14
$R      = "${E}[0m${BG}"
$BOLD   = "${E}[1m"
$BLK    = Rgb 12 12 14
$BGO    = RgbBg 255 122 24
$DIM    = Rgb 128 118 110
$PINK   = Rgb 255 122 24     # accent orange
$VIOLET = Rgb 255 176 64     # amber (headers)
$SKY    = Rgb 214 168 120    # info bullets
$GRN    = Rgb 120 220 140
$YEL    = Rgb 255 200 70
$RED    = Rgb 255 90 80
$WHT    = Rgb 242 236 228
$Grad   = @((Rgb 255 205 110), (Rgb 255 184 80), (Rgb 255 160 55), (Rgb 255 134 35), (Rgb 246 108 22), (Rgb 222 84 16))

$Cols = 120
try { $Cols = $Host.UI.RawUI.WindowSize.Width } catch {}
if ($env:HVRC_COLS) { $Cols = [int]$env:HVRC_COLS }
if (-not $Cols -or $Cols -le 0) { $Cols = 120 }
$TwoCol = $Cols -ge 104
$RuleW  = if ($TwoCol) { 100 } else { 62 }
$Rule   = '  ' + $DIM + ('─' * $RuleW) + $R

function Reset-Screen { Write-Host -NoNewline "${E}[0m${E}[2J${E}[3J${E}[H" }
# ---------- test hook: feed keys from env var instead of the keyboard ----------
$KeyQ = New-Object System.Collections.Queue
if ($env:HVRC_KEYS) { $env:HVRC_KEYS.ToCharArray() | ForEach-Object { $KeyQ.Enqueue($_.ToString().ToUpper()) } }
$TestMode = [bool]$env:HVRC_KEYS

function Get-Key([string[]]$Valid) {
    while ($true) {
        if ($TestMode) {
            if ($KeyQ.Count -eq 0) { Reset-Screen; [Environment]::Exit(0) }
            $k = $KeyQ.Dequeue()
        } else {
            $k = [Console]::ReadKey($true).KeyChar.ToString().ToUpper()
        }
        if ($Valid -contains $k) { return $k }
    }
}
function Wait-Key {
    Write-Host $Rule
    Write-Host -NoNewline "  ${DIM}Press any key to return to the menu...${R}"
    if ($TestMode) { if ($KeyQ.Count -gt 0) { [void]$KeyQ.Dequeue() } } else { [void][Console]::ReadKey($true) }
    Write-Host ''
}

# ---------- output helpers ----------
function Log($msg) { Add-Content -Path $LogFile -Value ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg) -Encoding UTF8 }
function Ok($t)   { Write-Host "  ${GRN}✔${R} $t" }
function Warn($t) { Write-Host "  ${YEL}!${R} $t" }
function Err($t)  { Write-Host "  ${RED}✖${R} $t" }
function Info($t) { Write-Host "  ${SKY}-${R} ${DIM}$t${R}" }

function Show-Banner {
    Write-Host -NoNewline "${BG}${E}[2J${E}[3J${E}[H"
    $art = @(
        '██╗  ██╗ █████╗ ███╗   ██╗ █████╗ ██╗  ██╗██╗██████╗  █████╗ ',
        '██║  ██║██╔══██╗████╗  ██║██╔══██╗██║  ██║██║██╔══██╗██╔══██╗',
        '███████║███████║██╔██╗ ██║███████║███████║██║██████╔╝███████║',
        '██╔══██║██╔══██║██║╚██╗██║██╔══██║██╔══██║██║██╔══██╗██╔══██║',
        '██║  ██║██║  ██║██║ ╚████║██║  ██║██║  ██║██║██║  ██║██║  ██║',
        '╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝'
    )
    Write-Host ''
    for ($i = 0; $i -lt $art.Count; $i++) { Write-Host ("  {0}{1}{2}{3}" -f $BOLD, $Grad[$i], $art[$i], $R) }
    Write-Host ("  {0}{1}{2} VRC FIX TOOLKIT {3}  {4}v{5}  |  squash VRChat bugs in one click{3}" -f $BGO, $BLK, $BOLD, $R, $DIM, $Ver)
    Write-Host $Rule
}

function Show-Title($t) {
    $p = $t -split '  ', 2
    Write-Host ''
    Write-Host ("  {0}{1}{2} {3} {4} {2}{5}{6}{4}" -f $BGO, $BLK, $BOLD, $p[0], $R, $WHT, $p[1])
    Write-Host $Rule
    Write-Host ''
}

function Show-Progress($label) {
    $n = 16
    for ($i = 1; $i -le $n; $i++) {
        $bar = ''
        for ($j = 1; $j -le $n; $j++) {
            if ($j -le $i) { $bar += (Rgb 255 (200 - [int](110 * $j / $n)) (80 - [int](60 * $j / $n))) + '█' }
            else           { $bar += $DIM + '░' }
        }
        $pct = [int]($i * 100 / $n)
        Write-Host -NoNewline ("`r  {0}{1} {2}{3}%{1}  {4}{5}{1}{6}[K" -f $bar, $R, $WHT, $pct, $DIM, $label, $E)
        Start-Sleep -Milliseconds 35
    }
    Write-Host ''
}
function Confirm-Yes($q) {
    Write-Host -NoNewline "  ${YEL}?${R} $q ${DIM}[Y/N]${R} "
    $k = Get-Key @('Y', 'N')
    Write-Host $k
    return ($k -eq 'Y')
}

function Need-Admin {
    if ($IsAdmin) { return $true }
    Err 'This option needs Administrator rights.'
    Info 'Press R in the main menu to relaunch as Administrator.'
    return $false
}

# ---------- logic helpers ----------
function Test-VrcRunning { [bool](Get-Process -Name 'VRChat' -ErrorAction SilentlyContinue) }

function Stop-Vrc {
    Show-Progress 'Stopping processes...'
    $killed = 0
    foreach ($n in 'VRChat', 'start_protected_game', 'EasyAntiCheat', 'EasyAntiCheat_EOS') {
        $p = Get-Process -Name $n -ErrorAction SilentlyContinue
        if ($p) { $p | Stop-Process -Force -ErrorAction SilentlyContinue; $killed += @($p).Count }
    }
    if ($killed -eq 0) { Info 'No VRChat processes were running.' } else { Ok "Stopped $killed process(es)."; Log "killed $killed processes" }
}

function Get-CacheDirs {
    $dirs = @('Cache-WindowsPlayer', 'HTTPCache-WindowsPlayer', 'TextureDiskCache-WindowsPlayer') | ForEach-Object { Join-Path $VrcData $_ }
    $cfg = Join-Path $VrcData 'config.json'
    if (Test-Path $cfg) {
        try {
            $c = Get-Content $cfg -Raw | ConvertFrom-Json
            if ($c.cache_directory) { $dirs += (Join-Path $c.cache_directory 'Cache-WindowsPlayer') }
        } catch {}
    }
    $dirs | Where-Object { Test-Path $_ } | Select-Object -Unique
}

function Get-DirSizeMB($p) {
    $sum = (Get-ChildItem -Recurse -File -LiteralPath $p -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [double]($sum / 1MB)
}

function Clear-VrcCache {
    $dirs = @(Get-CacheDirs)
    if ($dirs.Count -eq 0) { Info 'No cache folders found - already clean.'; return }
    Show-Progress 'Clearing cache...'
    $freed = 0.0; $left = 0
    foreach ($d in $dirs) {
        $freed += Get-DirSizeMB $d
        Remove-Item -Recurse -Force -LiteralPath $d -ErrorAction SilentlyContinue
        if (Test-Path $d) { $left++ }
    }
    if ($left -gt 0) { Err "$left folder(s) could not be fully deleted - some files are in use." }
    Ok ('Cache cleared ({0:N0} MB freed).' -f $freed)
    Log "cache cleared ($([int]$freed) MB)"
}

function Find-VrcDir {
    $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
    $libs = @()
    if ($steam) {
        $steam = $steam -replace '/', '\'
        $libs += $steam
        $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += ($m.Groups[1].Value -replace '\\\\', '\') }
        }
    }
    $libs += 'C:\Program Files (x86)\Steam'
    foreach ($l in $libs) {
        $d = Join-Path $l 'steamapps\common\VRChat'
        if (Test-Path (Join-Path $d 'VRChat.exe')) { return $d }
    }
    return $null
}

function Backup-VrcSettings {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $file = Join-Path $BackupDir "vrc_settings_$stamp.reg"
    & reg.exe export 'HKCU\Software\VRChat\VRChat' $file /y *> $null
    if ($LASTEXITCODE -ne 0) { Warn 'Nothing to back up (registry key not found).'; return $false }
    Ok "Backup saved: Backups\vrc_settings_$stamp.reg"
    Log "backup vrc_settings_$stamp.reg"
    return $true
}

# ============================================================
#  ACTIONS
# ============================================================
function Do-Kill    { Show-Banner; Show-Title 'KILL  Stop stuck processes'; Stop-Vrc }
function Do-Cache   { Show-Banner; Show-Title 'CACHE  Clear avatar / world cache'; Stop-Vrc; Clear-VrcCache }

function Do-Eac {
    Show-Banner; Show-Title 'EAC  Repair Easy Anti-Cheat'
    Stop-Vrc
    $dir = Find-VrcDir
    if (-not $dir) {
        Err 'VRChat install folder not found in your Steam libraries.'
        Info 'Steam > VRChat > Manage > Browse local files'
        Info 'Then run the EasyAntiCheat\\EasyAntiCheat*Setup.exe file and choose Repair Service.'
        return
    }
    Ok "Found game at: $dir"
    $setup = Get-ChildItem -Path (Join-Path $dir 'EasyAntiCheat') -Filter 'EasyAntiCheat*Setup.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $setup) {
        Err 'EAC setup file not found - use Steam > VRChat > Properties > Installed Files > Verify.'
        return
    }
    Info "Launching $($setup.Name) - pick VRChat and click Repair Service."
    if (-not $TestMode) { Start-Process $setup.FullName }
    Log 'EAC setup launched'
}

function Do-Verify {
    Show-Banner; Show-Title 'VERIFY  Verify game files'
    Show-Progress 'Asking Steam...'
    if (-not $TestMode) { Start-Process 'steam://validate/438100' }
    Ok 'Steam is now verifying VRChat - watch its window for progress.'
    Log 'steam validate requested'
}

function Do-Osc {
    Show-Banner; Show-Title 'OSC  Reset OSC data'
    $osc = Join-Path $VrcData 'OSC'
    if (-not (Test-Path $osc)) { Warn 'OSC folder not found.'; return }
    Info 'This deletes all per-avatar OSC configs (the game recreates them on launch).'
    if (-not (Confirm-Yes 'Continue?')) { Warn 'Cancelled.'; return }
    Stop-Vrc
    Show-Progress 'Deleting OSC data...'
    Remove-Item -Recurse -Force -Path $osc -ErrorAction SilentlyContinue
    if (Test-Path $osc) { Err 'Could not delete everything.' } else { Ok 'OSC data reset.'; Log 'OSC reset' }
}

function Get-DiscordHooks([string]$Pattern) {
    foreach ($d in 'Discord', 'DiscordCanary', 'DiscordPTB') {
        $p = Join-Path $env:LOCALAPPDATA $d
        if (Test-Path $p) { Get-ChildItem -Path $p -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $Pattern } }
    }
}

function Do-Discord {
    Show-Banner; Show-Title 'DISCORD  Disable DiscordHook'
    Write-Host "  ${PINK}[1]${R} Disable hook ${WHT}without closing VRChat${R}  ${DIM}(takes effect next game launch)${R}"
    Write-Host "  ${PINK}[2]${R} Disable hook ${WHT}and close VRChat${R}        ${DIM}(recommended - files not locked)${R}"
    Write-Host "  ${PINK}[3]${R} Restore previously disabled hooks"
    Write-Host "  ${PINK}[0]${R} Cancel"
    Write-Host ''
    Write-Host -NoNewline "  ${PINK}❯${R} Choose: "
    $m = Get-Key @('1', '2', '3', '0')
    Write-Host $m; Write-Host ''
    if ($m -eq '0') { return }

    $done = 0; $fail = 0
    if ($m -eq '3') {
        Show-Progress 'Looking for disabled hooks...'
        foreach ($f in @(Get-DiscordHooks 'DiscordHook*.dll.disabled')) {
            try { Rename-Item -LiteralPath $f.FullName -NewName ($f.Name -replace '\.disabled$', '') -ErrorAction Stop; Ok "Restored: $($f.Name -replace '\.disabled$','')"; $done++ }
            catch { Err "Could not restore: $($f.Name)" }
        }
        if ($done -eq 0) { Info 'No disabled hook files found.' } else { Log "discord hook restored: $done files" }
        return
    }

    Show-Progress 'Closing Discord...'
    $wasRunning = @()
    foreach ($n in 'Discord', 'DiscordCanary', 'DiscordPTB') {
        if (Get-Process -Name $n -ErrorAction SilentlyContinue) { $wasRunning += $n }
        Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
    Ok 'Discord closed.'
    if ($m -eq '2') { Stop-Vrc }
    Start-Sleep -Seconds 2

    Show-Progress 'Searching for hook files...'
    foreach ($f in @(Get-DiscordHooks 'DiscordHook*.dll')) {
        try { Rename-Item -LiteralPath $f.FullName -NewName "$($f.Name).disabled" -ErrorAction Stop; Ok "Hook disabled: $($f.Name)"; $done++ }
        catch { Err "Could not rename (file in use): $($f.Name)"; $fail++ }
    }
    Write-Host ''
    if ($done -eq 0 -and $fail -eq 0) { Info 'No active hook files found - already clean.' }
    if ($done -gt 0) { Log "discord hook disabled: $done files" }
    if ($fail -gt 0) { Warn 'Some files are locked - try option 2 to close VRChat as well.' }
    if ($m -eq '1' -and (Test-VrcRunning)) { Info 'VRChat is running - an already-loaded hook goes away on the next game launch.' }
    Info 'Discord updates can bring the hook back - just run this again.'
    foreach ($n in $wasRunning) {
        $upd = Join-Path $env:LOCALAPPDATA "$n\Update.exe"
        if (Test-Path $upd) {
            if (-not $TestMode) { Start-Process -FilePath $upd -ArgumentList '--processStart', "$n.exe" }
            Ok "Reopened $n."
            Log "reopened $n"
        } else { Warn "Could not find $n to reopen - start it from the Start menu." }
    }
    if ($wasRunning.Count -eq 0) { Info 'Discord was not running - open it normally when you are ready.' }
}

function Do-Net {
    Show-Banner; Show-Title 'NET  Network fix'
    if (-not (Need-Admin)) { return }
    Show-Progress 'Flushing DNS...';     & ipconfig.exe /flushdns *> $null;  Ok 'DNS cache flushed.'
    Show-Progress 'Resetting Winsock...'; & netsh.exe winsock reset *> $null; Ok 'Winsock reset.'
    Warn 'Restart your PC for the Winsock reset to fully apply.'
    Log 'net fix done'
}

function Do-Diag {
    Show-Banner; Show-Title 'DIAG  Status check'
    Show-Progress 'Checking...'
    Write-Host ''
    if (Test-VrcRunning) { Warn 'VRChat is running.' } else { Ok 'VRChat is not running.' }
    $nlog = @(Get-ChildItem -Path $VrcData -Filter 'output_log_*.txt' -ErrorAction SilentlyContinue).Count
    Info "Log files: $nlog"
    $cd = @(Get-CacheDirs)
    if ($cd.Count -gt 0) {
        $tot = 0.0; foreach ($d in $cd) { $tot += Get-DirSizeMB $d }
        Info ('Cache size: {0:N0} MB in {1} folder(s)' -f $tot, $cd.Count)
    } else { Info 'No cache folders - already clean.' }
    try {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -Uri 'https://api.vrchat.cloud/api/1/config'
        $sw.Stop()
        Ok ("VRChat API is up (HTTP {0}, {1} ms)" -f $resp.StatusCode, $sw.ElapsedMilliseconds)
    } catch { Err 'VRChat API is down or unreachable.' }
    if (Test-Connection -ComputerName 1.1.1.1 -Count 1 -Quiet -ErrorAction SilentlyContinue) { Ok 'Internet connection is fine.' } else { Err 'No response from the internet.' }
    Log 'diagnose run'
}

function Do-Audio {
    Show-Banner; Show-Title 'AUDIO  Restart Windows audio'
    if (-not (Need-Admin)) { return }
    Show-Progress 'Restarting audio service...'
    Restart-Service -Name 'audiosrv' -Force -ErrorAction SilentlyContinue
    Ok 'Audio service restarted - check your mic in Windows again.'
    Log 'audio services restarted'
}

function Remove-VrcLogs {
    $files = @(Get-ChildItem -Path $VrcData -Filter 'output_log_*.txt' -ErrorAction SilentlyContinue)
    if ($files.Count -eq 0) { Warn 'No logs found.'; return }
    if (Test-VrcRunning) { Info 'Game is running - the current log will be skipped.' }
    Show-Progress 'Deleting logs...'
    $files | Remove-Item -Force -ErrorAction SilentlyContinue
    Ok 'Logs deleted.'; Log 'vrc logs deleted'
}
function Do-Logs { Show-Banner; Show-Title 'LOGS  Delete old VRChat logs'; Remove-VrcLogs }

function Do-Backup { Show-Banner; Show-Title 'BACKUP  Back up VRChat settings'; Show-Progress 'Backing up...'; [void](Backup-VrcSettings) }

function Do-Reset {
    Show-Banner; Show-Title 'RESET  Reset VRChat settings'
    Info 'Deletes graphics / audio / option values in the registry. Your account and avatars are safe.'
    Info 'A backup is always made first.'
    if (-not (Confirm-Yes 'Continue?')) { Warn 'Cancelled.'; return }
    Stop-Vrc
    if (-not (Backup-VrcSettings)) { Err 'Backup failed - reset aborted.'; return }
    & reg.exe delete 'HKCU\Software\VRChat\VRChat' /f *> $null
    Ok 'Settings reset - launch VRChat to regenerate defaults.'
    Log 'settings reset'
}

function Do-Folders {
    Show-Banner; Show-Title 'FOLDERS  Open folders'
    Write-Host "  ${PINK}[1]${R} VRChat data   ${PINK}[2]${R} Cache   ${PINK}[3]${R} Backups   ${PINK}[4]${R} Logs"
    Write-Host ''
    Write-Host -NoNewline "  ${PINK}❯${R} Choose: "
    $k = Get-Key @('1', '2', '3', '4'); Write-Host $k
    $target = switch ($k) { '1' { $VrcData } '2' { $VrcCache } '3' { $BackupDir } '4' { $LogDir } }
    if (-not (Test-Path $target)) { if ($k -eq '3') { New-Item -ItemType Directory -Force -Path $target | Out-Null } else { Warn 'That folder does not exist.'; return } }
    if (-not $TestMode) { Start-Process explorer.exe $target }
    Ok "Opened: $target"
}

function Do-Launch {
    Show-Banner; Show-Title 'LAUNCH  Start VRChat'
    Write-Host "  ${PINK}[1]${R} VR mode     ${PINK}[2]${R} Desktop mode (--no-vr)"
    Write-Host ''
    Write-Host -NoNewline "  ${PINK}❯${R} Choose: "
    $k = Get-Key @('1', '2'); Write-Host $k; Write-Host ''
    if ($k -eq '2') { if (-not $TestMode) { Start-Process 'steam://run/438100//--no-vr/' }; Ok 'Launching VRChat in Desktop mode...' }
    else            { if (-not $TestMode) { Start-Process 'steam://rungameid/438100' };       Ok 'Launching VRChat in VR mode...' }
    Log 'launch vrchat'
}

function Do-AutoFix {
    Show-Banner; Show-Title 'AUTOFIX  One-click cleanup'
    Stop-Vrc
    Clear-VrcCache
    Remove-VrcLogs
    Show-Progress 'Flushing DNS...'; & ipconfig.exe /flushdns *> $null; Ok 'DNS cache flushed.'
    Log 'autofix done'
    Write-Host ''
    if (Confirm-Yes 'Launch VRChat now?') {
        if (-not $TestMode) { Start-Process 'steam://rungameid/438100' }
        Ok 'Launching VRChat...'
    }
}

function Do-Steam {
    Show-Banner; Show-Title 'STEAM  Restart Steam'
    Show-Progress 'Closing Steam...'
    Get-Process -Name 'steam', 'steamwebhelper' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    if (-not $TestMode) { Start-Process 'steam://open/main' }
    Ok 'Steam restarted.'; Log 'steam restarted'
}

function Do-Admin {
    try { Start-Process -FilePath $global:Self -Verb RunAs -ErrorAction Stop; Reset-Screen; [Environment]::Exit(0) }
    catch { Show-Banner; Err 'Could not get Administrator rights.' }
}

function Get-JpImeTip {
    foreach ($l in (Get-WinUserLanguageList)) {
        if ($l.LanguageTag -like 'ja*') { $t = $l.InputMethodTips | Where-Object { $_ -like '0411:*' } | Select-Object -First 1; if ($t) { return $t } }
    }
    return $null
}

function Restart-TextInput {
    Show-Progress 'Restarting text input service...'
    Get-Process -Name 'ctfmon' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    if (-not (Get-Process -Name 'ctfmon' -ErrorAction SilentlyContinue)) { Start-Process (Join-Path $env:windir 'System32\ctfmon.exe') }
    Start-Sleep -Milliseconds 500
    if (Get-Process -Name 'ctfmon' -ErrorAction SilentlyContinue) { Ok 'Text input service (ctfmon) is running.'; Log 'ctfmon restarted' }
    else { Err 'ctfmon did not start.' }
}

function Do-Ime {
    Show-Banner; Show-Title 'IME  Fix Japanese keyboard input in VRChat'
    Write-Host "  ${PINK}[1]${R} Check Japanese IME status"
    Write-Host "  ${PINK}[2]${R} Restart Windows text input service ${DIM}(IME icon missing / frozen)${R}"
    Write-Host "  ${PINK}[3]${R} Relaunch VRChat ${WHT}with Japanese IME ready${R} ${DIM}(recommended)${R}"
    Write-Host "  ${PINK}[4]${R} Open Windows language / IME settings"
    Write-Host "  ${PINK}[0]${R} Cancel"
    Write-Host ''
    Write-Host -NoNewline "  ${PINK}❯${R} Choose: "
    $m = Get-Key @('1', '2', '3', '4', '0')
    Write-Host $m; Write-Host ''
    if ($m -eq '0') { return }

    $tip   = Get-JpImeTip
    $langs = @(Get-WinUserLanguageList)
    $first = if ($langs.Count -gt 0) { $langs[0].LanguageTag } else { '?' }

    if ($m -eq '4') {
        Info 'If your IME still fails in games, look for "Use previous version of Microsoft IME" under Microsoft IME > Compatibility.'
        if (-not $TestMode) { Start-Process 'ms-settings:regionlanguage' }
        Ok 'Opened Windows language settings.'
        return
    }
    if ($m -eq '2') { Restart-TextInput; return }

    if ($m -eq '1') {
        Show-Progress 'Checking IME...'
        Write-Host ''
        if ($tip) { Ok "Japanese IME is installed ($tip)" } else { Err 'No Japanese IME found - add Japanese in Settings > Time & language > Language & region.' }
        if ($first -like 'ja*') { Ok 'Japanese is the first (default) input language.' } else { Warn "Default input language is '$first' - games start in that layout." }
        $ovr = Get-WinDefaultInputMethodOverride
        if ($ovr) { Info "Default input method override: $ovr" }
        if (Get-Process -Name 'ctfmon' -ErrorAction SilentlyContinue) { Ok 'Text input service (ctfmon) is running.' } else { Err 'ctfmon is NOT running - use option 2.' }
        if (Test-VrcRunning) { Warn 'VRChat is running. It reads the IME at launch - switching inside the game does not work.' }
        if (Get-Process -Name 'ATOK*' -ErrorAction SilentlyContinue) { Warn 'ATOK is running. EAC can block ATOK in VRChat - try Microsoft IME.' }
        Info 'Tip: turn the IME on (Japanese layout) BEFORE VRChat starts, and avoid switching layouts in-game.'
        Log 'ime check run'
        return
    }

    # m = 3 : relaunch with IME ready
    if (-not $tip) { Err 'No Japanese IME found - add Japanese in Settings > Time & language first.'; return }
    if ($first -notlike 'ja*') {
        Info "Your default input language is '$first'. VRChat starts in the default layout."
        if (Confirm-Yes 'Set Japanese IME as the default input method? (you can undo this in Windows language settings)') {
            Set-WinDefaultInputMethodOverride -InputTip $tip
            Ok 'Default input method set to Japanese IME.'
            Log "default input override set: $tip"
        }
    }
    Restart-TextInput
    if (Test-VrcRunning) {
        if (-not (Confirm-Yes 'VRChat is running and must restart. Close it now?')) { Warn 'Cancelled.'; return }
    }
    Stop-Vrc
    Write-Host ''
    Info 'Make sure the IME shows "あ" (Japanese) before the game window opens - press Win+Space to change layout.'
    if (-not $TestMode) { Start-Process 'steam://rungameid/438100' }
    Ok 'Launching VRChat...'
    Log 'launch vrchat (ime ready)'
}

function Get-JunkTargets {
    $la = $env:LOCALAPPDATA
    @(
        [pscustomobject]@{ Name = 'User temp files';       Path = $env:TEMP;                                          Admin = $false; AgeHours = 24; Filter = $null }
        [pscustomobject]@{ Name = 'Windows temp files';    Path = (Join-Path $env:windir 'Temp');                     Admin = $true;  AgeHours = 24; Filter = $null }
        [pscustomobject]@{ Name = 'Crash dumps';           Path = (Join-Path $la 'CrashDumps');                       Admin = $false; AgeHours = 0;  Filter = $null }
        [pscustomobject]@{ Name = 'Error reports (WER)';   Path = (Join-Path $la 'Microsoft\Windows\WER');            Admin = $false; AgeHours = 0;  Filter = $null }
        [pscustomobject]@{ Name = 'DirectX shader cache';  Path = (Join-Path $la 'D3DSCache');                        Admin = $false; AgeHours = 0;  Filter = $null }
        [pscustomobject]@{ Name = 'NVIDIA DX cache';       Path = (Join-Path $la 'NVIDIA\DXCache');                   Admin = $false; AgeHours = 0;  Filter = $null }
        [pscustomobject]@{ Name = 'NVIDIA GL cache';       Path = (Join-Path $la 'NVIDIA\GLCache');                   Admin = $false; AgeHours = 0;  Filter = $null }
        [pscustomobject]@{ Name = 'Explorer thumbnails';   Path = (Join-Path $la 'Microsoft\Windows\Explorer');      Admin = $false; AgeHours = 0;  Filter = 'thumbcache_*.db' }
    )
}

function Get-JunkFiles($tg) {
    if (-not $tg.Path -or $tg.Path.Length -lt 10 -or -not (Test-Path -LiteralPath $tg.Path)) { return @() }
    $cut = (Get-Date).AddHours(-$tg.AgeHours)
    @(Get-ChildItem -LiteralPath $tg.Path -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object {
        (($null -eq $tg.Filter) -or ($_.Name -like $tg.Filter)) -and ($_.LastWriteTime -lt $cut)
    })
}

function Get-RecycleBinMB {
    try {
        $sum = 0.0
        foreach ($i in (New-Object -ComObject Shell.Application).NameSpace(0xA).Items()) { $sum += [double]$i.Size }
        return ($sum / 1MB)
    } catch { return 0.0 }
}

function Do-Junk {
    Show-Banner; Show-Title 'JUNK  Clean temporary files'
    Info 'Only temp files, caches and crash dumps are touched - never your documents.'
    Info 'Temp files changed in the last 24 hours are skipped. Close other programs first for best results.'
    Write-Host ''
    Show-Progress 'Scanning...'
    Write-Host ''
    $free0 = (Get-PSDrive -Name ($env:SystemDrive.TrimEnd(':')) -ErrorAction SilentlyContinue).Free
    $plan = @(); $total = 0.0
    foreach ($tg in (Get-JunkTargets)) {
        if ($tg.Admin -and -not $IsAdmin) { Write-Host ("  {0}-{1} {2,-22} {3}needs Administrator{1}" -f $DIM, $R, $tg.Name, $YEL); continue }
        $files = Get-JunkFiles $tg
        $mb = [double](($files | Measure-Object Length -Sum).Sum / 1MB)
        $total += $mb
        Write-Host ("  {0}-{1} {2,-22} {3}{4,9:N1} MB{1}  {5}{6} files{1}" -f $SKY, $R, $tg.Name, $WHT, $mb, $DIM, $files.Count)
        if ($files.Count -gt 0) { $plan += [pscustomobject]@{ Target = $tg; Files = $files } }
    }
    Write-Host ''
    Write-Host ("  {0}Total reclaimable: {1:N1} MB{2}" -f $BOLD, $total, $R)
    Write-Host ''
    if ($plan.Count -gt 0) {
        if (Confirm-Yes 'Delete these files?') {
            Show-Progress 'Cleaning...'
            foreach ($p in $plan) { $p.Files | Remove-Item -Force -ErrorAction SilentlyContinue }
            $free1 = (Get-PSDrive -Name ($env:SystemDrive.TrimEnd(':')) -ErrorAction SilentlyContinue).Free
            $gain = [double](($free1 - $free0) / 1MB)
            if ($gain -lt 0) { $gain = 0 }
            Ok ('Cleanup done - about {0:N0} MB freed on {1}.' -f $gain, $env:SystemDrive)
            Info 'Files that are in use were skipped automatically.'
            Log ("junk cleaned: scanned {0:N0} MB, freed {1:N0} MB" -f $total, $gain)
        } else { Warn 'Cancelled.' }
    } else { Ok 'Nothing to clean - your system is already tidy.' }

    Write-Host ''
    $rb = Get-RecycleBinMB
    if ($rb -gt 0.1) {
        Info ('Recycle Bin holds {0:N1} MB.' -f $rb)
        if (Confirm-Yes 'Empty the Recycle Bin? (permanent - cannot be undone)') {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Ok 'Recycle Bin emptied.'; Log 'recycle bin emptied'
        } else { Info 'Recycle Bin left untouched.' }
    } else { Info 'Recycle Bin is empty.' }
}

# ============================================================
#  MENU
# ============================================================
function VLen($s) { ($s -replace "$([char]27)\[[0-9;]*m", '').Length }
function Pad-V($s, $w) { $n = $w - (VLen $s); if ($n -gt 0) { $s + (' ' * $n) } else { $s } }

function Cell($key, $tag, $desc, $admin = $false) {
    $mark = if ($admin) { "${YEL}*${R} " } else { '  ' }
    "${BGO}${BLK}${BOLD} $key ${R} ${BOLD}${WHT}$($tag.PadRight(8))${R} $mark${DIM}$desc${R}"
}
function Head($t) { "${VIOLET}${BOLD}$t${R} ${DIM}$('─' * [Math]::Max(2, 46 - $t.Length))${R}" }

function Show-StatusBox {
    $run = if (Test-VrcRunning) { "${GRN}RUNNING${R}" } else { "${DIM}not running${R}" }
    $adm = if ($IsAdmin) { "${GRN}Administrator${R}" } else { "${DIM}standard user${R}" }
    $free = ''
    try { $free = '{0:N0} GB free' -f ((Get-PSDrive -Name ($env:SystemDrive.TrimEnd(':'))).Free / 1GB) } catch {}
    $inner = $RuleW - 2
    $line = " ${DIM}VRChat${R} $run     ${DIM}Rights${R} $adm     ${DIM}Disk $($env:SystemDrive)${R} ${WHT}$free${R}"
    if (-not $TwoCol) { $line = " ${DIM}VRChat${R} $run    $adm" }
    Write-Host ("  ${VIOLET}╭" + ('─' * $inner) + "╮${R}")
    Write-Host ("  ${VIOLET}│${R}" + (Pad-V $line $inner) + "${VIOLET}│${R}")
    Write-Host ("  ${VIOLET}╰" + ('─' * $inner) + "╯${R}")
}

function Show-Menu {
    Show-Banner
    Show-StatusBox
    Write-Host ''
    $left = @(
        (Head 'GAME FIXES'),
        (Cell '1' 'KILL'    'Stop stuck VRChat / EAC'),
        (Cell '2' 'CACHE'   'Clear avatar & world cache'),
        (Cell '3' 'EAC'     'Repair Easy Anti-Cheat'),
        (Cell '4' 'VERIFY'  'Verify game files (Steam)'),
        (Cell '5' 'OSC'     'Reset OSC configs'),
        (Cell 'F' 'DISCORD' 'Disable DiscordHook (crashes)'),
        (Cell 'I' 'IME'     'Fix Japanese IME input'),
        '',
        (Head 'NETWORK & AUDIO'),
        (Cell '6' 'NET'     'Flush DNS + reset Winsock' $true),
        (Cell '7' 'DIAG'    'Servers, cache size, logs'),
        (Cell '8' 'AUDIO'   'Restart Windows audio' $true)
    )
    $right = @(
        (Head 'DATA & PC'),
        (Cell '9' 'LOGS'    'Delete old VRChat logs'),
        (Cell 'A' 'BACKUP'  'Back up VRChat settings'),
        (Cell 'B' 'RESET'   'Reset VRChat settings'),
        (Cell 'C' 'FOLDERS' 'Open data / cache / logs'),
        (Cell 'J' 'JUNK'    'Clean temp files & caches'),
        '',
        (Head 'SHORTCUTS'),
        (Cell 'D' 'LAUNCH'  'Start VRChat (VR / Desktop)'),
        (Cell 'E' 'AUTOFIX' 'Close + cache + logs + DNS'),
        (Cell 'S' 'STEAM'   'Restart Steam')
    )
    if (-not $IsAdmin) { $right += (Cell 'R' 'ADMIN' 'Relaunch as Administrator') }
    $right += (Cell 'X' 'EXIT' '')

    if ($TwoCol) {
        $rows = [Math]::Max($left.Count, $right.Count)
        for ($i = 0; $i -lt $rows; $i++) {
            $lc = ''; if ($i -lt $left.Count)  { $lc = $left[$i] }
            $rc = ''; if ($i -lt $right.Count) { $rc = $right[$i] }
            Write-Host ('  ' + (Pad-V $lc 52) + $rc)
        }
    } else {
        foreach ($x in $left)  { Write-Host ('  ' + $x) }
        Write-Host ''
        foreach ($x in $right) { Write-Host ('  ' + $x) }
    }
    Write-Host ''
    Write-Host "  ${YEL}*${R} ${DIM}needs Administrator   -   press a key to choose${R}"
    Write-Host $Rule
    Write-Host -NoNewline "  ${PINK}❯${R} "
}
Log "---- session start v$Ver admin=$IsAdmin ----"
$valid = @('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','I','J','S','R','X')
try {
    while ($true) {
        Show-Menu
        $k = Get-Key $valid
        Write-Host $k
        if ($k -eq 'X') { break }
        switch ($k) {
            '1' { Do-Kill }    '2' { Do-Cache }   '3' { Do-Eac }     '4' { Do-Verify }  '5' { Do-Osc }
            '6' { Do-Net }     '7' { Do-Diag }    '8' { Do-Audio }   '9' { Do-Logs }
            'A' { Do-Backup }  'B' { Do-Reset }   'C' { Do-Folders } 'D' { Do-Launch }  'E' { Do-AutoFix }
            'F' { Do-Discord } 'I' { Do-Ime }     'J' { Do-Junk }    'S' { Do-Steam }   'R' { if (-not $IsAdmin) { Do-Admin } }
        }
        Wait-Key
    }
} finally {
    Reset-Screen
}
Log '---- session end ----'
Write-Host ''
Write-Host "  $($Grad[3])Have fun in VRChat!  ✿  Hanahira${E}[0m"
Write-Host ''