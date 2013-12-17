# Vim Stuff
$SCRIPTPATH = "C:\Scripts"
$VIMPATH = "C:\Program Files\Vim\vim72\vim.exe"

Set-Alias vi   $VIMPATH
Set-Alias vim  $VIMPATH

# Customize the command prompt
function prompt {
  $path = ""
        $pathbits = ([string]$pwd).split("\", [System.StringSplitOptions]::RemoveEmptyEntries)
        if($pathbits.length -eq 1) {
                $path = $pathbits[0] + "\"
        } else {
                $path = $pathbits[$pathbits.length - 1]
        }
        $userLocation = $env:username + '@' + [System.Environment]::MachineName + ' ' + $path
        $host.UI.RawUi.WindowTitle = $userLocation
    Write-Host($userLocation) -nonewline -foregroundcolor Green 

        Write-Host('>') -nonewline -foregroundcolor Green    
        return " "
}

# for editing your PowerShell profile
Function Edit-Profile
{
    vim $profile
}

# for editing your Vim settings
Function Edit-Vimrc
{
    vim $home\_vimrc
}
