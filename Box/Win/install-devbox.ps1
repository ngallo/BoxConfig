$step = 1

$programfiles=${env:ProgramFiles(x86)}
if($programfiles -eq "") {
    $programfiles=${env:ProgramFiles}
}

function Print([string]$output) {
    $text = '[' + $(get-date -f HH:mm:ss) + '] ' + $output
    Write-Host $text
}

function Call([string]$title, $block) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $text = 'Started task ' + $step + ': ' + $title
    Print $text
    &$block
    $sw.Stop()
    $text = 'Completed task ' + $step + ': ' + $title + ' - Elapsed: ' + $sw.Elapsed
    Print $text
    $step = $step + 1
}

function CreateDir([string]$targetdir) {
    if(!(Test-Path -Path $targetdir )){
        New-Item -ItemType directory -Path $targetdir
        Print 'Creted directory ' + $targetdir
    }
}

function CreateLinkWithHotKey {
    $dest = $args[0];
    $link = $args[1];
    $hotkey = $args[2];
    $objShell = New-Object -ComObject WScript.Shell
    $lnk = $objShell.CreateShortcut($dest)
    $lnk.TargetPath = $link
    $lnk.HotKey = $hotkey
    $lnk.Save() 
}

#.\install-choc.ps1

# Chocolatey settings
Call 'Chocolatey settings' { 
        chocolatey feature enable -n allowGlobalConfirmation
    }

$programfiles=${env:ProgramFiles(x86)}
if ($programfiles -eq "") {
    $programfiles=${env:ProgramFiles}
}

# toolsroot
Call 'toolsroot' { 
        Print "toolsroot"
        cinst -y toolsroot
    }

# sysinternals
Call 'sysinternals' { 
        Print "sysinternals"
        cinst -y sysinternals
    }

# webpicmd
Call 'webpicmd' { 
        Print "webpicmd"
        cinst -y webpicmd
    }

# vim
Call 'vim' { 
        Print "vim"
        cinst -y vim
        $gvimbin = "$programfiles\vim\vim74\gvim.exe"
        $gvimlink = "c:\Users\Public\Desktop\GVim.lnk"
        $gvimhotkey = "Ctrl+Shift+Alt+V"
        CreateLinkWithHotKey "$gvimlink" "$gvimbin" "$gvimhotkey"
    }

# git
Call 'git' { 
        Print "git"
        cinst -y git
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$programfiles\Git\bin", "Machine")
    }

# cmder mini
Call 'cmder mini' { 
        Print "cmder mini"
        cinst -y cmdermini.portable
        $gvimbin = "c:\tools\cmdermini\Cmder.exe"
        $gvimlink = "c:\Users\Public\Desktop\Cmder.lnk"
        $gvimhotkey = "Ctrl+Shift+Alt+C"
        CreateLinkWithHotKey "$gvimlink" "$gvimbin" "$gvimhotkey"
    }
