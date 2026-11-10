param(
    [string]$GodotPath = $env:GODOT_BIN,
    [int]$TimeoutSeconds = 600
)
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
if (-not $GodotPath) {
    $found = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $GodotPath = $found.Source }
}
if (-not $GodotPath -or -not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Supply the standalone Godot executable: .\Run-Local-Tests.ps1 -GodotPath "D:\Tools\Godot\Godot_console.exe". Project baseline: Godot 4.5.1 Standard.'
}
$GodotPath = (Get-Item -LiteralPath $GodotPath).FullName
$runRoot = Join-Path $projectRoot ('builds\local-tests\' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
$sandbox = Join-Path $runRoot 'project'
[IO.Directory]::CreateDirectory($sandbox) | Out-Null
# Test scripts can write reports and saves. Run a copy, preserving source evidence.
foreach ($item in Get-ChildItem -LiteralPath $projectRoot -Force) {
    if ($item.Name -in @('.git', '.godot', 'builds')) { continue }
    Copy-Item -LiteralPath $item.FullName -Destination $sandbox -Recurse
}
$previousReportDir = $env:ALIEN_TEST_REPORT_DIR
$env:ALIEN_TEST_REPORT_DIR = 'res://reports/local-reconstruction'
$results = @()
function Invoke-Check([string]$Name, [string[]]$EngineArgs) {
    $stdout = Join-Path $runRoot ($Name + '.stdout.log')
    $stderr = Join-Path $runRoot ($Name + '.stderr.log')
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $argumentLine = ($EngineArgs | ForEach-Object { '"' + $_ + '"' }) -join ' '
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = $GodotPath
    $info.Arguments = $argumentLine
    $info.WorkingDirectory = $sandbox
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $info
    [void]$process.Start()
    $outputTask = $process.StandardOutput.ReadToEndAsync()
    $errorTask = $process.StandardError.ReadToEndAsync()
    $timedOut = -not $process.WaitForExit($TimeoutSeconds * 1000)
    if ($timedOut) { $process.Kill(); $process.WaitForExit() }
    $process.WaitForExit()
    [IO.File]::WriteAllText($stdout, $outputTask.Result)
    [IO.File]::WriteAllText($stderr, $errorTask.Result)
    $log = [IO.File]::ReadAllText($stdout) + [IO.File]::ReadAllText($stderr)
    $passed = -not $timedOut -and $process.ExitCode -eq 0 -and $log -notmatch '(?m)(SCRIPT ERROR:|^ERROR:|^FAIL\b)'
    Write-Host (('{0}: {1}' -f $Name, $(if ($passed) { 'PASS' } else { 'FAIL' })))
    [pscustomobject]@{ suite=$Name; passed=$passed; exit=$process.ExitCode; timeout=$timedOut; seconds=[math]::Round($timer.Elapsed.TotalSeconds,2) }
}
try {
    & $GodotPath --version | Set-Content -LiteralPath (Join-Path $runRoot 'engine-version.txt')
    $results += Invoke-Check 'import' @('--headless','--path',$sandbox,'--editor','--import')
    if ($results[-1].passed) {
        foreach ($suite in @('test_b01','test_b02','test_b03','test_0901','test_world','test_reconstruction')) {
            $results += Invoke-Check $suite @('--headless','--path',$sandbox,'--script',('tests/' + $suite + '.gd'))
        }
    }
} finally {
    $env:ALIEN_TEST_REPORT_DIR = $previousReportDir
    ConvertTo-Json -InputObject $results -Depth 5 | Set-Content -LiteralPath (Join-Path $runRoot 'results.json')
    Write-Host "Logs and isolated test project: $runRoot"
}
if ($results.Count -ne 7 -or @($results | Where-Object { -not $_.passed }).Count) { exit 1 }
exit 0
