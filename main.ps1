function Invoke-Interpreter ([string]$code) {
    $code = @($code.ToCharArray() | Where-Object { ("><+-.,[]".ToCharArray()) -contains $_ })
    $memory = New-Object byte[] 30000
    $ptr = 0
    $ip = 0

    while ($ip -lt $code.Count) {
        switch ($code[$ip]) {
            '>' {
                $ptr = ($ptr + 1) % 30000
            }
            '<' {
                if ($ptr -eq 0) {
                    $ptr = 29999
                } else {
                    $ptr = $ptr - 1 
                }
            }
            '+' { 
                $memory[$ptr] = ($memory[$ptr] + 1) % 256
            }
            '-' {
                if ($memory[$ptr] -eq 0) {
                    $memory[$ptr] = 255
                } else { 
                    $memory[$ptr] = $memory[$ptr] - 1
                }
            }
            '.' {
                Write-Host ([char]$memory[$ptr]) -NoNewline
            }
            ',' { 
                $key = [Console]::ReadKey($true)
                $memory[$ptr] = [byte]$key.KeyChar
            }
            '[' {
                if ($memory[$ptr] -eq 0) {
                    $depth = 1

                    while ($depth -gt 0) {
                        $ip++

                        if ($code[$ip] -eq '[') {
                            $depth++
                        } elseif ($code[$ip] -eq ']') {
                            $depth--
                        }
                    }
                }
            }
            ']' {
                if ($memory[$ptr] -ne 0) {
                    $depth = 1

                    while ($depth -gt 0) {
                        $ip--

                        if ($code[$ip] -eq ']') {
                            $depth++
                        } elseif ($code[$ip] -eq '[') {
                            $depth--
                        }
                    }
                }
            }
        }

        $ip++
    }
}

function Convert-TextToBF ([string]$text) {
    $bf = ""
    foreach ($char in $text.ToCharArray()) {
        $val = [int][char]$char
        $bf += ("+" * $val) + "." + (">")
    }
    return $bf
}

Write-Host "╔═══════════════════════════════════════════════════╗"
Write-Host "║             ~ Brainfuck Interpreter ~             ║"
Write-Host "║ Options:                                          ║"
Write-Host "║ 1. Interpret Brainfuck Code                       ║"
Write-Host "║ 2. Convert Text to Brainfuck                      ║"
Write-Host "║ 3. Exit                                           ║"
Write-Host "╚═══════════════════════════════════════════════════╝"

Write-Host ">>> " -NoNewline
$choice = Read-Host

Write-Host "`n"

switch ($choice) {
    "1" {
        $loadFromFile = Read-Host "Load from file? (y/n)"

        if ($loadFromFile -eq 'y') {
            $filePath = Read-Host "Enter the file path"

            if (Test-Path $filePath) {
                $brainfuckCode = Get-Content -Path $filePath -Raw
            } else {
                Write-Error "$filePath not found."
                exit
            }
        } else {
            $brainfuckCode = Read-Host "Paste your Brainfuck code"
        }

        Invoke-Interpreter $brainfuckCode

        Write-Host "`nExecution completed." -ForegroundColor Green
    }
    "2" {
        $textToConvert = Read-Host "Enter the text to convert"
        $generated = Convert-TextToBF $textToConvert

        $writeToFile = Read-Host "Write to file? (y/n)"
        if ($writeToFile -eq 'y') {
            $outputFile = Read-Host "Enter output file path"
            $generated | Out-File -FilePath $outputFile
            Write-Host  -ForegroundColor Green "Brainfuck code written to $outputFile"
        } else {
            Write-Host "Generated Code:`n" -ForegroundColor Green
            Write-Host $generated
        }
    }
    "3" {
        exit
    }
}
