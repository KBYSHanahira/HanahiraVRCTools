@echo off
title HanahiraVRC - OSC Chatbox Stats
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$global:Self='%~f0'; $s=[IO.File]::ReadAllText($global:Self,[Text.Encoding]::UTF8); $i=$s.LastIndexOf('#'+'<PS>'); Invoke-Expression $s.Substring($i)" & exit /b
#<PS>
# ============================================================
#  OscStats - sends CPU / RAM / GPU usage to the VRChat Chatbox via OSC
#  VRChat: Action Menu > Options > OSC > Enabled.  Ctrl+C to stop.
#  NOTE: PowerShell variables are case-insensitive.
# ============================================================
$ErrorActionPreference = 'SilentlyContinue'
$OscHost  = '127.0.0.1'
$OscPort  = if ($env:OSC_PORT) { [int]$env:OSC_PORT } else { 9000 }
$Interval = 2        # seconds between updates (VRChat rate-limits the chatbox)
$KeepAlive = 10      # resend unchanged text after this many seconds
$Once     = [bool]$env:OSC_ONCE   # test mode: send one packet and exit
$BarOn    = [string][char]0x25C6   # filled segment (diamond, renders in VRChat)
$BarOff   = [string][char]0x25C7   # empty segment
$Mark     = [string][char]0x25C6   # header diamond
$BarLen   = 5
$Debug    = [bool]$env:OSC_DEBUG   # writes raw PresentMon samples to Logs\osc_debug.txt
$DebugLog = Join-Path (Split-Path -Parent $global:Self) 'Logs\osc_debug.txt'
$dbgLines = 0
$PmExe    = Join-Path (Split-Path -Parent $global:Self) 'PresentMon.exe'

function Pad4([byte[]]$b) {
    $n = 4 - ($b.Length % 4)          # always adds 1-4 NULs (string terminator + pad)
    $out = New-Object byte[] ($b.Length + $n)
    [Array]::Copy($b, $out, $b.Length)
    $out
}
function New-OscChatbox([string]$text) {
    $u = [Text.Encoding]::UTF8
    $ms = New-Object IO.MemoryStream
    foreach ($part in @((Pad4 $u.GetBytes('/chatbox/input')), (Pad4 $u.GetBytes(',sTF')), (Pad4 $u.GetBytes($text)))) {
        $ms.Write($part, 0, $part.Length)
    }
    $ms.ToArray()
}

# ---------- static info ----------
$cpuName = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$cpuName = ($cpuName -replace '\(R\)|\(TM\)|\bCPU\b|\bProcessor\b|@.*$|\d+-Core', '' -replace '\s+', ' ').Trim()

function Get-Bar([double]$pct) {
    $n = [int][Math]::Round([Math]::Max(0, [Math]::Min(100, $pct)) / 100 * $BarLen)
    ($BarOn * $n) + ($BarOff * ($BarLen - $n))
}
$cpuShort = $cpuName -replace '^(AMD|Intel)\s+', '' -replace '^Core\s+', '' -replace '^Ryzen\s+\d+\s+', ''
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# ---------- counters ----------
$cpuCtr = $null
foreach ($c in @('% Processor Utility', '% Processor Time')) {
    try {
        $cat = if ($c -like '*Utility') { 'Processor Information' } else { 'Processor' }
        $p = New-Object Diagnostics.PerformanceCounter($cat, $c, '_Total')
        [void]$p.NextValue(); $cpuCtr = $p; break
    } catch {}
}

function Get-Gpu {
    $o = & nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>$null
    if ($LASTEXITCODE -eq 0 -and $o) {
        $f = ($o | Select-Object -First 1) -split ',\s*'
        $name = $f[0] -replace 'NVIDIA|GeForce', '' -replace '\s+', ' '
        return [pscustomobject]@{ Name = $name.Trim(); Load = [int]$f[1]; Used = [double]$f[2] / 1024; Total = [double]$f[3] / 1024 }
    }
    # fallback (AMD / Intel): sum of 3D engine utilisation, no VRAM
    $name = ((Get-CimInstance Win32_VideoController | Select-Object -First 1).Name -replace '\s+', ' ').Trim()
    $s = (Get-Counter '\GPU Engine(*engtype_3D)\Utilization Percentage').CounterSamples | Measure-Object CookedValue -Sum
    [pscustomobject]@{ Name = $name; Load = [int][Math]::Min(100, $s.Sum); Used = $null; Total = $null }
}

# ---------- FPS via PresentMon (needs Administrator) with watchdog ----------
$StallSec = 15       # VRChat running but no frame data for this long -> restart PresentMon
$pm = $null; $pmTask = $null; $colMs = -1; $colSc = -1
$pmStarted = [DateTime]::MinValue; $pmLastData = [DateTime]::MinValue
$pmNextTry = [DateTime]::MinValue; $pmFails = 0

function Stop-Pm {
    if ($script:pm -and -not $script:pm.HasExited) { try { $script:pm.Kill() } catch {} }
    # also clear leftovers started from this same exe (e.g. from a crashed earlier run)
    Get-Process PresentMon | Where-Object { $_.Path -eq $PmExe } | ForEach-Object { try { $_.Kill() } catch {} }
    $script:pm = $null; $script:pmTask = $null
}
function Start-Pm {
    Stop-Pm
    $script:colMs = -1; $script:colSc = -1
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $PmExe
    $psi.Arguments = '--process_name VRChat.exe --output_stdout --no_console_stats --stop_existing_session'
    $psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.CreateNoWindow = $true
    $script:pm = [Diagnostics.Process]::Start($psi)
    $script:pmTask = $script:pm.StandardOutput.ReadLineAsync()
    $script:pmStarted = [DateTime]::Now; $script:pmLastData = [DateTime]::Now
}
function Fail-Pm([string]$why) {
    $err = ''
    if ($script:pm -and $script:pm.HasExited) { $err = ($script:pm.StandardError.ReadToEnd().Trim() -replace '\s+', ' ') }
    Stop-Pm
    $script:pmFails++
    $wait = [Math]::Min(60, 5 * [Math]::Pow(2, [Math]::Min($script:pmFails - 1, 4)))
    $script:pmNextTry = [DateTime]::Now.AddSeconds($wait)
    Write-Host ("PresentMon: {0}; restart in {1:N0}s (fail #{2}) {3}" -f $why, $wait, $script:pmFails, $err)
}

# drain PresentMon output; returns FPS of the busiest swap chain since last call, or $null
function Get-Fps {
    if (-not (Test-Path $PmExe)) { return $null }
    if (-not $pm) {
        if ([DateTime]::Now -lt $pmNextTry) { return $null }
        try { Start-Pm } catch { Fail-Pm "start error: $($_.Exception.Message)"; return $null }
    }
    $win = @{}
    while ($pmTask -and $pmTask.IsCompleted) {
        $line = $pmTask.Result
        if ($null -eq $line) { Fail-Pm 'exited'; return $null }
        $script:pmTask = $pm.StandardOutput.ReadLineAsync()
        if ($Debug -and $script:dbgLines -lt 40) { Add-Content -Path $DebugLog -Value $line; $script:dbgLines++ }
        $f = $line.Split(',')
        if ($script:colMs -lt 0) {                                   # header row
            $script:colMs = [Array]::FindIndex($f, [Predicate[string]]{ param($x) $x -ieq 'MsBetweenPresents' })
            $script:colSc = [Array]::FindIndex($f, [Predicate[string]]{ param($x) $x -ieq 'SwapChainAddress' })
            continue
        }
        $ms = 0.0
        if ($f.Length -gt $script:colMs -and [double]::TryParse($f[$script:colMs], [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$ms) -and $ms -gt 0) {
            $k = if ($script:colSc -ge 0) { $f[$script:colSc] } else { '-' }
            if (-not $win.ContainsKey($k)) { $win[$k] = @(0, 0.0) }
            $win[$k][0]++; $win[$k][1] += $ms
        }
    }
    if ($Debug -and $win.Count -gt 0) {
        foreach ($k in $win.Keys) { Add-Content -Path $DebugLog -Value ("WINDOW swapchain={0} frames={1} sumMs={2:N1} fps={3:N1}" -f $k, $win[$k][0], $win[$k][1], (1000 * $win[$k][0] / $win[$k][1])) }
    }
    if ($win.Count -gt 0) { $script:pmLastData = [DateTime]::Now; $script:pmFails = 0 }
    elseif ($pm.HasExited) { Fail-Pm 'exited'; return $null }
    elseif (([DateTime]::Now - $pmLastData).TotalSeconds -gt $StallSec -and ([DateTime]::Now - $pmStarted).TotalSeconds -gt $StallSec -and (Get-Process VRChat)) {
        Fail-Pm "no frame data for ${StallSec}s while VRChat is running"; return $null
    }
    if ($win.Count -eq 0) { return $null }
    $best = $win.Values | Sort-Object { $_[0] } -Descending | Select-Object -First 1
    [int][Math]::Round(1000 * $best[0] / $best[1])
}

$udp = New-Object Net.Sockets.UdpClient
$udp.Connect($OscHost, $OscPort)
Write-Host "OscStats -> ${OscHost}:$OscPort every ${Interval}s  (Ctrl+C to stop)"
$last = ''; $lastSent = [DateTime]::MinValue
try {
    while ($true) {
        $cpu = if ($cpuCtr) { [int][Math]::Min(100, $cpuCtr.NextValue()) } else { 0 }
        $os  = Get-CimInstance Win32_OperatingSystem
        $tot = $os.TotalVisibleMemorySize / 1MB; $use = $tot - $os.FreePhysicalMemory / 1MB
        $g   = Get-Gpu
        $vram = if ($null -ne $g.Total) { ' {0:N1}/{1:N0}GB' -f $g.Used, $g.Total } else { '' }
        $fps = Get-Fps
        $head = if ($null -ne $fps) { "$Mark FPS $fps`n" } else { '' }
        $ramPct = $use / $tot * 100
        $text = $head +
            ("CPU {0} {1}% {2}`n" -f $cpuShort, $cpu, (Get-Bar $cpu)) +
            ("RAM {0:N1}/{1:N0}G {2}`n" -f $use, $tot, (Get-Bar $ramPct)) +
            ("GPU {0} {1}% {2}" -f $g.Name, $g.Load, (Get-Bar $g.Load))
        if ($null -ne $g.Total) {
            $text += ("`nVRAM {0:N1}/{1:N0}G {2}" -f $g.Used, $g.Total, (Get-Bar ($g.Used / $g.Total * 100)))
        }
        if ($text.Length -gt 144) { $text = $text.Substring(0, 144) }
        if ($text -ne $last -or ([DateTime]::Now - $lastSent).TotalSeconds -ge $KeepAlive) {
            $pkt = New-OscChatbox $text
            [void]$udp.Send($pkt, $pkt.Length)
            $last = $text; $lastSent = [DateTime]::Now
            Write-Host ($text -replace "`n", ' | ')
        }
        if ($Once) { break }
        Start-Sleep -Seconds $Interval
    }
} finally { $udp.Close(); Stop-Pm }
