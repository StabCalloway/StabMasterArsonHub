<#
.SYNOPSIS
  Enhancement Portal Builder for StabMasterArson.
  Auto-regenerates manifest + pushes changes to GitHub Pages if available.
#>

param(
    [switch]$LocalOnly,
    [string]$RepoName = "StabMasterArson-EnhancementPortal"
)

$root = Join-Path (Get-Location) $RepoName
$docs = "$root/docs"
$manifest = "$docs/manifest.json"
$manifestHistory = "$docs/manifest-history.md"

# --- Self-heal environment ---
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing GitHub CLI..."
    if (Test-Path "./configure.ps1") { & ./configure.ps1 } else { exit 1 }
}

# --- Build manifest ---
$enhancements = Get-ChildItem -Path "$docs/enhancements" -Filter "*.json" -Recurse
$items = @()
foreach ($file in $enhancements) {
    $json = Get-Content $file | ConvertFrom-Json
    $items += $json
}
$manifestObj = [ordered]@{ generated = (Get-Date); count = $items.Count; items = $items }
$manifestObj | ConvertTo-Json -Depth 10 | Out-File $manifest
Write-Host "📜 Manifest updated with $($items.Count) enhancements."

# --- Changelog ---
$entry = "### $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n- Items: $($items.Count)`n"
Add-Content $manifestHistory $entry

# --- Zip + hash ---
$zipPath = "$root/$RepoName.zip"
Compress-Archive -Path "$root/*" -DestinationPath $zipPath -Force
$hash = (Get-FileHash $zipPath -Algorithm SHA256).Hash
"SHA256 ($zipPath) = $hash" | Out-File "$root/$RepoName-sha256.txt"

# --- GitHub Pages deployment ---
if ($LocalOnly) { Write-Host "🌐 Local portal build complete."; exit 0 }

gh auth status 2>$null
if ($LASTEXITCODE -ne 0) { gh auth login }

cd $root
git init
git add .
git commit -m "Portal update $(Get-Date)"
git branch -M main
git remote remove origin 2>$null
git remote add origin "https://github.com/YOUR_USERNAME/$RepoName.git"
git push -u origin main
gh pages deploy --branch main --dist .
Write-Host "✅ Portal deployed to GitHub Pages."
