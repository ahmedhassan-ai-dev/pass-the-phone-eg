$ErrorActionPreference = 'Stop'
$brandingProjectRoot = Split-Path -Parent $PSScriptRoot
$brandingSource = Join-Path $brandingProjectRoot 'assets/branding/splash_logo.png'
$brandingResourceDirectory = Join-Path $brandingProjectRoot 'android/app/src/main/res/drawable-nodpi'
foreach ($brandingRequired in @('adaptive_foreground.png', 'adaptive_background.png', 'adaptive_background2.png', 'splash_logo.png')) {
    if (-not (Test-Path -LiteralPath (Join-Path $brandingProjectRoot "assets/branding/$brandingRequired") -PathType Leaf)) {
        throw "Missing branding source: $brandingRequired"
    }
}
New-Item -ItemType Directory -Force -Path $brandingResourceDirectory | Out-Null
Copy-Item -LiteralPath $brandingSource -Destination (Join-Path $brandingResourceDirectory 'splash_logo.png')
Push-Location $brandingProjectRoot
try {
    dart run flutter_launcher_icons
    if ($LASTEXITCODE -ne 0) { throw 'Launcher resource generation failed.' }
} finally {
    Pop-Location
}
