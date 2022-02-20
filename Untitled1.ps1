
Write-Host ""
Write-Host "what would you like to do, please Select option A or B?"
Write-Host "A) collect new baseline?"
Write-Host "B) Begin monitoring files with saved baseline?"

$responds = Read-Host -Prompt "please enter 'A' OR 'B'"

Function calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exist() {

    $baselineExist = Test-Path -Path "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\baseline.txt"
    

    if($baselineExist){
    #delete it
    Remove-Item -Path "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\baseline.txt"
    
    }
}


#$hash = calculate-File-Hash "C:\Users\CYBERGHANA 003\Dropbox\PC\Desktop\new projects\FIM\files"
$hash = calculate-File-Hash "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\files"

#Write-Host "User entered $($responds)"

if ($responds -eq "A".ToUpper()){
#DELETE IF ALREADY THERE
Erase-Baseline-If-Already-Exist

#CALCULATE HASH FROM THE TARGET FILES AND STORE IN BASELINE.TXT
#Write-Host "Calculate Hashes, make new Baseline.txt" -ForegroundColor Cyan

#collect all files in the target folder
$files = Get-ChildItem -Path "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\files"


#for file, calculate the hash and write to baseline.txt
foreach ($f in $files) {
    $hash = calculate-File-Hash $f.FullName
    "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\baseline.txt" -Append
    }
}

elseif ($responds -eq "B".ToUpper()){
    $fileHashDictionary = @{}

    #load files hashes from baseline.txt and store them in a dictionary
    $filePathsandHashes = Get-Content -Path "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\baseline.txt"
    
    foreach ($f in $filePathsandHashes){
        $fileHashDictionary.Add($f.split("|")[0],$f.split("|")[1])
    
    }

    #$fileHashDictionary.Values
    #$fileHashDictionary["dfg"] -eq $null

    #BEGIN MONITOIRNG FILES WITH SAVED BASELINE
    #Write-Host "Read Existing Baseline.txt, Start Monitoring Files." -ForegroundColor Yellow
    while($true){
        Start-Sleep -Seconds 1

        $files = Get-ChildItem -Path "C:\Users\CYBERGHANA-003\Desktop\new projects\FIM\files"

        #Write-Host "checking if files match....." -ForegroundColor Red
        foreach ($f in $files) {
            $hash = calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "C:\Users\CYBERGHANA 003\Dropbox\PC\Desktop\new projects\FIM\baseline.txt" -Append
            
            #Notify user if new files have been created
            if ($fileHashDictionary[$hash.Path] -eq $null){
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            
            }
            else {

            #Notify if a file has been changed
            if ($fileHashDictionary[$hash.Path] -eq $hash.Hash){
            #THE FILE HAS NOT CHANGED
            
            }

            else {
                #file has been compromised!.., Notify the user
                Write-Host "$($hash.Path) has changed!!!!.." -ForegroundColor Yellow
            }
        }

        foreach ($key in $fileHashDictionary.Keys){
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists){
                #one of the baseline files haave been deleted, notify the user!!!....
                Write-Host "$($key) has been deleted!.." -ForegroundColor Red
            
            }
        
        }

        }
    }



}


