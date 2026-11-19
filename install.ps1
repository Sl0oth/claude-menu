param([switch]$Uninstall)

& {
    $ErrorActionPreference = "Continue"
    $SourceUrl = "https://raw.githubusercontent.com/Sl0oth/claude-menu/main/clm"
    $Dir = if ($env:CLM_INSTALL_DIR) { $env:CLM_INSTALL_DIR.TrimEnd("\") } else { Join-Path $env:LOCALAPPDATA "clm" }
    $Shim = Join-Path $Dir "clm.cmd"
    $Script = Join-Path $Dir "clm.py"
    $Cache = Join-Path $env:LOCALAPPDATA "clm\update.json"

    function Get-UserPath {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment")
        $value = $key.GetValue("Path", "", [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        $key.Close()
        return $value
    }

    function Set-UserPath([string]$Value) {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment", $true)
        $key.SetValue("Path", $Value, [Microsoft.Win32.RegistryValueKind]::ExpandString)
        $key.Close()
        [Environment]::SetEnvironmentVariable("CLM_PATH_REFRESH", "1", "User")
        [Environment]::SetEnvironmentVariable("CLM_PATH_REFRESH", $null, "User")
    }

    function Get-ShimPath([string]$Path) {
        foreach ($name in "LOCALAPPDATA", "USERPROFILE") {
            $prefix = [Environment]::GetEnvironmentVariable($name)
            if ($prefix) {
                $prefix = $prefix.TrimEnd("\")
                if ($Path.StartsWith("$prefix\", [StringComparison]::OrdinalIgnoreCase)) {
                    return "%$name%" + $Path.Substring($prefix.Length)
                }
            }
        }
        return $Path
    }

    $entries = (Get-UserPath) -split ";" | Where-Object { $_ }
    $others = $entries | Where-Object { $_.TrimEnd("\") -ne $Dir }

    if ($Uninstall) {
        Remove-Item -LiteralPath $Shim, $Script, $Cache -Force -ErrorAction SilentlyContinue
        foreach ($folder in $Dir, (Split-Path -Parent $Cache)) {
            if ((Test-Path -LiteralPath $folder) -and -not (Get-ChildItem -LiteralPath $folder -Force)) {
                Remove-Item -LiteralPath $folder -Force
            }
        }
        if (@($others).Count -ne @($entries).Count) { Set-UserPath (@($others) -join ";") }
        Write-Host "Removed clm from $Dir"
        return
    }

    $Python = $null
    foreach ($name in "py", "python", "python3") {
        $command = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $command) { continue }
        $found = & $command.Source -c "import sys; print(sys.executable.encode('unicode_escape').decode('ascii')) if sys.version_info >= (3, 9) else sys.exit(1)" 2>$null |
            Select-Object -Last 1
        if ($LASTEXITCODE -ne 0 -or -not $found) { continue }
        $found = [regex]::Unescape($found.Trim())
        if (Test-Path -LiteralPath $found -PathType Leaf) {
            $Python = $found
            break
        }
    }
    if (-not $Python) { throw "clm needs Python 3.9 or newer. Install it from https://www.python.org/downloads/ and run this again." }

    & $Python -c "import curses" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing windows-curses..."
        & $Python -m pip install --user --quiet --disable-pip-version-check windows-curses
        & $Python -c "import curses" 2>$null
        if ($LASTEXITCODE -ne 0) { throw "Could not install windows-curses. Try: `"$Python`" -m pip install windows-curses" }
    }

    try {
        New-Item -ItemType Directory -Force -Path $Dir -ErrorAction Stop | Out-Null
        $Local = if ($PSCommandPath) { Join-Path (Split-Path -Parent $PSCommandPath) "clm" } else { $null }
        if ($Local -and (Test-Path -LiteralPath $Local -PathType Leaf)) {
            $Target = $Local
            Remove-Item -LiteralPath $Script -Force -ErrorAction SilentlyContinue
            Write-Host "Using clm from $Local"
        } else {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            $Download = "$Script.download"
            Invoke-WebRequest -UseBasicParsing -Uri $SourceUrl -OutFile $Download -ErrorAction Stop
            if ((Get-Content -LiteralPath $Download -TotalCount 1) -notmatch "python3") {
                Remove-Item -LiteralPath $Download -Force
                throw "the download did not look like clm."
            }
            Move-Item -LiteralPath $Download -Destination $Script -Force -ErrorAction Stop
            $Target = $Script
            Write-Host "Installed $Script"
        }
        $page = [Globalization.CultureInfo]::CurrentCulture.TextInfo.OEMCodePage
        $encoding = if ($page -eq 65001) { New-Object Text.UTF8Encoding $false } else { [Text.Encoding]::GetEncoding($page) }
        [IO.File]::WriteAllText($Shim, "@`"$(Get-ShimPath $Python)`" `"$(Get-ShimPath $Target)`" %*`r`n", $encoding)
    } catch {
        throw "Could not install clm: $($_.Exception.Message)"
    }

    if (@($others).Count -eq @($entries).Count) {
        Set-UserPath ((@($entries) + $Dir) -join ";")
        Write-Host "Added $Dir to your PATH. Open a new terminal to use it."
    }
    if (-not (($env:Path -split ";") -contains $Dir)) { $env:Path = "$env:Path;$Dir" }

    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "Note: Claude Code (claude) is not on your PATH yet. clm needs it to open chats."
    }
    Write-Host "Done. Run: clm"
}
