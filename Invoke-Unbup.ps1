Param(
    [Parameter(Mandatory=$True,Position=1)] [string]$Path,
    [Parameter(Position=2)] [string]$pass = "!nf3ct3d!"
    )

$files = Get-ChildItem -Path "$Path\*.bup" -Recurse | Where-Object{-not $_.PSIsContainer}

ForEach($file in $files) { 
    write-host "[!] " -foregroundcolor Cyan -nonewline; Write-Host "Processing $($file.Name)..." -ForegroundColor green
    New-Item -ItemType directory -Path $path -Name $file.BaseName | out-null
    $newPath = $path + "\" + $file.BaseName
    Move-Item -Path $file.FullName -Destination $newPath
    $newFile = (Get-ChildItem -Path $newPath).fullname
    Set-location $newPath
    & "C:\Program Files\7-Zip\7z.exe" "x" $newFile | Out-Null

    $bupFiles = Get-ChildItem -Path $newPath -Recurse -Exclude "*.bup" | Where-Object{-not $_.PSIsContainer}

    ForEach($bupFile in $bupFiles){
        $bupPath = $bupFile.FullName
        Write-Verbose "[!] Processing $bupPath"
        $key = "0x6a"
        $outFile = $bupPath + ".out"
        $bytes = [System.IO.File]::ReadAllBytes("$bupPath")
 
        # Where the magic happens!
        for($i=0; $i -lt $bytes.count ; $i++){
            $bytes[$i] = $bytes[$i] -bxor $key
        }
 

        [System.IO.File]::WriteAllBytes("$outFile", $bytes)
        Write-Verbose "[!] File $bupPath XOR'd with key $key"
        Write-verbose "[!] File saved to $outFile"
        If($outfile -match "Details.out"){
            $fileName = (Get-Content -Path $outfile) | ?{$_ -match "^OriginalName=.+"}
            $renamedFile = $fileName.split('\')[-1]
        }
        ElseIf ($outFile -match "file_0.out"){
            $newRenamed = $newPath + "\" + $renamedFile
            Rename-Item $outFile -NewName $NewRenamed -Force
            
            write-host "[!] " -foregroundcolor Cyan -nonewline; Write-host "Zipping up the package with password: " -NoNewline -ForegroundColor Green; Write-Host "$pass" -ForegroundColor Magenta


            $fileZip = $renamedFile + ".zip"

            & "C:\Program Files\7-Zip\7z.exe" "a" $fileZip "-p$pass" $NewRenamed | Out-Null
            Write-host "[!] " -foregroundcolor Cyan -nonewline; Write-Host "Zip file created successfully:" -NoNewline -ForegroundColor Green; Write-Host " $(Test-Path ($newPath + "\" + $renamedFile))" -ForegroundColor Magenta
            write-host "[!] " -foregroundcolor Cyan -nonewline; Write-Host "File location: $($newPath + "\" + $renamedFile)" -ForegroundColor Green
        }
    }
            write-host "[!] " -foregroundcolor Cyan -nonewline; Write-Host "Removing unneeded files..." -ForegroundColor green
    Get-ChildItem -path $newPath -Exclude "*.zip" | ForEach-Object{Remove-Item $_ -Force | Out-Null}
}