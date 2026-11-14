$ErrorActionPreference = "Stop"
function Run-Step([string]$label, [string]$command) {
  Write-Host "`n== $label ==" -ForegroundColor Cyan
  Invoke-Expression $command
  if ($LASTEXITCODE -ne 0) { throw "Failed: $label (exit $LASTEXITCODE)" }
}
if (-not (Test-Path "pubspec.yaml")) { throw "Run this script from the Flutter project root." }
Run-Step "Flutter toolchain" "flutter doctor -v"
Run-Step "Install dependencies" "flutter pub get"
Run-Step "Format" "dart format --output=none --set-exit-if-changed lib test"
Run-Step "Analyze" "flutter analyze"
Run-Step "Tests" "flutter test"
Run-Step "Android release APK smoke build (unsigned)" "flutter build apk --release -PunsignedSmokeBuild=true"
Run-Step "Android release bundle smoke build (unsigned)" "flutter build appbundle --release -PunsignedSmokeBuild=true"
Write-Host "`nAutomated checks passed. This does NOT validate signing, targetSdk, Play Console policy, or real-device behavior." -ForegroundColor Green
