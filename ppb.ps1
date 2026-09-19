param(
    [ValidateSet("status","hashes","sv","sync","verify-clean","evidence")]
    [string]$Command = "status"
)

$ErrorActionPreference = "Stop"

$Repo = $PSScriptRoot
$Runtime = "E:\WOW\World of Warcraft\_classic_beta_\Interface\AddOns\TargetCopy"
$SV = "E:\WOW\World of Warcraft\_classic_beta_\WTF\Account\1515937599#1\SavedVariables\TargetCopy.lua"

$TrackedRuntimeFiles = @(
    "Core.lua",
    "Compat.lua",
    "Bindings.lua",
    "TargetCopy.toc",
    "Modules\Unit.lua",
    "Modules\Marker.lua",
    "Modules\Macro.lua",
    "Modules\QuickCopy.lua",
    "UI\MainWindow.lua",
    "UI\QuickCopyPopup.lua",
    "UI\FloatingButton.lua",
    "UI\Settings.lua",
    "UI\DebugPanel.lua"
)

function Hash($Path) {
    if (-not (Test-Path $Path)) { return $null }
    (Get-FileHash $Path -Algorithm SHA256).Hash
}

function Show-Hashes {
    Write-Host "=== REPO / RUNTIME HASHES ==="

    foreach ($file in $TrackedRuntimeFiles) {
        $a = Join-Path $Repo $file
        $b = Join-Path $Runtime $file

        if (-not (Test-Path $a)) {
            Write-Host "[REPO MISSING]    $file"
            continue
        }

        if (-not (Test-Path $b)) {
            Write-Host "[RUNTIME MISSING] $file"
            continue
        }

        if ((Hash $a) -eq (Hash $b)) {
            Write-Host "[MATCH]    $file"
        } else {
            Write-Host "[MISMATCH] $file"
        }
    }
}

function Show-SV {
    Write-Host "=== SAVEDVARIABLES ==="

    if (-not (Test-Path $SV)) {
        Write-Host "File : MISSING"
        return
    }

    $item = Get-Item $SV
    Write-Host "File     : FOUND"
    Write-Host "Size     : $($item.Length) bytes"
    Write-Host "Modified : $($item.LastWriteTime)"

    $content = Get-Content $SV -Raw

    $enabled = [regex]::Match(
        $content,
        '\["enabled"\]\s*=\s*(true|false)'
    )

    $mode = [regex]::Match(
        $content,
        '\["mode"\]\s*=\s*"([^"]+)"'
    )

    if ($enabled.Success) {
        Write-Host "enabled  : $($enabled.Groups[1].Value)"
    } else {
        Write-Host "enabled  : NOT PARSED"
    }

    if ($mode.Success) {
        Write-Host "mode     : $($mode.Groups[1].Value)"
    } else {
        Write-Host "mode     : NOT PARSED"
    }
}

function Show-Instrumentation {
    Write-Host "=== INSTRUMENTATION ==="

    $core = Join-Path $Repo "Core.lua"

    if (Select-String $core -Pattern 'SVTEST' -Quiet) {
        Write-Host "SVTEST            : INSTALLED"
    } else {
        Write-Host "SVTEST            : ABSENT"
    }

    if (Test-Path (Join-Path $Repo "MarkerExperiment.lua")) {
        Write-Host "MarkerExperiment  : PRESENT"
    } else {
        Write-Host "MarkerExperiment  : ABSENT"
    }

    $atm = "E:\WOW\World of Warcraft\_classic_beta_\Interface\AddOns\ActiveTargetManual\Combat.lua"

    if ((Test-Path $atm) -and (Select-String $atm -Pattern 'ATMTEST' -Quiet)) {
        Write-Host "ATMTEST           : INSTALLED"
    } else {
        Write-Host "ATMTEST           : ABSENT"
    }
}

function Show-Git {
    Write-Host "=== GIT ==="

    Push-Location $Repo
    try {
        $branch = git branch --show-current
        Write-Host "Branch : $branch"

        $changes = @(git status --porcelain)

        if ($changes.Count -eq 0) {
            Write-Host "State  : CLEAN"
        } else {
            Write-Host "State  : DIRTY"
            $changes | ForEach-Object { Write-Host "  $_" }
        }
    }
    finally {
        Pop-Location
    }
}

function Sync-Runtime {
    Write-Host "=== SYNC REPO -> RUNTIME ==="

    foreach ($file in $TrackedRuntimeFiles) {
        $src = Join-Path $Repo $file
        $dst = Join-Path $Runtime $file

        if (-not (Test-Path $src)) {
            throw "Repo file missing: $src"
        }

        $parent = Split-Path $dst -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        Copy-Item $src $dst -Force

        if ((Hash $src) -ne (Hash $dst)) {
            throw "Hash verification failed: $file"
        }

        Write-Host "[SYNCED+VERIFIED] $file"
    }
}

function Verify-Clean {
    Write-Host "=== EXPERIMENT CLEANLINESS ==="

    $problems = @()

    $core = Join-Path $Repo "Core.lua"
    if (Select-String $core -Pattern 'SVTEST' -Quiet) {
        $problems += "SVTEST remains in Core.lua"
    }

    if (Test-Path (Join-Path $Repo "MarkerExperiment.lua")) {
        $problems += "MarkerExperiment.lua remains"
    }

    $toc = Join-Path $Repo "TargetCopy.toc"
    if (Select-String $toc -Pattern 'MarkerExperiment|PPBDiagnostics' -Quiet) {
        $problems += "Experimental TOC entry remains"
    }

    $atm = "E:\WOW\World of Warcraft\_classic_beta_\Interface\AddOns\ActiveTargetManual\Combat.lua"
    if ((Test-Path $atm) -and (Select-String $atm -Pattern 'ATMTEST' -Quiet)) {
        $problems += "ATMTEST remains"
    }

    if ($problems.Count -eq 0) {
        Write-Host "PASS: no known experiment instrumentation"
    } else {
        Write-Host "FAIL:"
        $problems | ForEach-Object { Write-Host " - $_" }
    }
}

function Write-Evidence {
    $EvidenceDir = Join-Path $Repo ".ppb-evidence"

    if (-not (Test-Path $EvidenceDir)) {
        New-Item -ItemType Directory -Path $EvidenceDir -Force | Out-Null
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $out = Join-Path $EvidenceDir "ppb-$stamp.txt"

    $report = @()

    $report += "TARGETCOPY PPB EVIDENCE"
    $report += "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += ""

    Push-Location $Repo
    try {
        $report += "=== GIT ==="
        $report += "Branch: $(git branch --show-current)"
        $report += git status --porcelain
    }
    finally {
        Pop-Location
    }

    $report += ""
    $report += "=== REPO / RUNTIME HASHES ==="

    foreach ($file in $TrackedRuntimeFiles) {
        $a = Join-Path $Repo $file
        $b = Join-Path $Runtime $file

        if (-not (Test-Path $a)) {
            $report += "[REPO MISSING] $file"
        }
        elseif (-not (Test-Path $b)) {
            $report += "[RUNTIME MISSING] $file"
        }
        elseif ((Hash $a) -eq (Hash $b)) {
            $report += "[MATCH] $file"
        }
        else {
            $report += "[MISMATCH] $file"
        }
    }

    $report += ""
    $report += "=== SAVEDVARIABLES ==="

    if (Test-Path $SV) {
        $item = Get-Item $SV
        $report += "File: FOUND"
        $report += "Size: $($item.Length)"
        $report += "Modified: $($item.LastWriteTime)"

        $svContent = Get-Content $SV -Raw

        $enabled = [regex]::Match(
            $svContent,
            '\["enabled"\]\s*=\s*(true|false)'
        )

        $mode = [regex]::Match(
            $svContent,
            '\["mode"\]\s*=\s*"([^"]+)"'
        )

        if ($enabled.Success) {
            $report += "enabled: $($enabled.Groups[1].Value)"
        }

        if ($mode.Success) {
            $report += "mode: $($mode.Groups[1].Value)"
        }
    }
    else {
        $report += "File: MISSING"
    }

    $report += ""
    $report += "=== INSTRUMENTATION ==="

    $core = Join-Path $Repo "Core.lua"

    $report += "SVTEST: " + $(if (Select-String $core -Pattern 'SVTEST' -Quiet) {
        "INSTALLED"
    } else {
        "ABSENT"
    })

    $report += "MarkerExperiment: " + $(if (Test-Path (Join-Path $Repo "MarkerExperiment.lua")) {
        "PRESENT"
    } else {
        "ABSENT"
    })

    $atm = "E:\WOW\World of Warcraft\_classic_beta_\Interface\AddOns\ActiveTargetManual\Combat.lua"

    $report += "ATMTEST: " + $(if (
        (Test-Path $atm) -and
        (Select-String $atm -Pattern 'ATMTEST' -Quiet)
    ) {
        "INSTALLED"
    } else {
        "ABSENT"
    })

    [System.IO.File]::WriteAllLines(
        $out,
        $report,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "Evidence written:"
    Write-Host $out
}
switch ($Command) {
    "status" {
        Show-Git
        Write-Host ""
        Show-Hashes
        Write-Host ""
        Show-SV
        Write-Host ""
        Show-Instrumentation
    }

    "hashes" {
        Show-Hashes
    }

    "sv" {
        Show-SV
    }

    "sync" {
        Sync-Runtime
    }

    "verify-clean" {
        Verify-Clean
    }

    "evidence" {
        Write-Evidence
    }
}