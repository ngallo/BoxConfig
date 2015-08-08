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

function make-link
{
    $link = $args[0];
    $dest = $args[1];
    if(test-path "$link") {
        rm "$link"
    }
    cmd /c mklink  "$link" "$dest"
}

.\install-choc.ps1

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
        $gvimlink = "c:\Users\Public\Desktop\GVim"
        make-link "$gvimlink" "$gvimbin"
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
        make-link "c:\Users\Public\Desktop\Cmder" "c:\tools\cmdermini\Cmder.exe"
    }
