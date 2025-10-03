Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MMC Calendar - GitHub Pages Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "Error: Not in a git repository. Please run this script from your project root." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Switch to main branch if not already there
Write-Host "Checking current branch..."
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne "main") {
    Write-Host "Switching to main branch..." -ForegroundColor Yellow
    git checkout main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to switch to main branch." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Commit any uncommitted changes
Write-Host "Checking for uncommitted changes..."
$hasChanges = git diff --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Found uncommitted changes. Committing them..." -ForegroundColor Yellow
    git add .
    git commit -m "Auto-commit before deployment - $(Get-Date)"
    Write-Host "Changes committed." -ForegroundColor Green
} else {
    Write-Host "No uncommitted changes." -ForegroundColor Green
}

# Build the project for GitHub Pages
Write-Host ""
Write-Host "Building project for GitHub Pages..." -ForegroundColor Yellow
npm run build:gh-pages
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Build failed." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Build completed." -ForegroundColor Green

# Switch to gh-pages branch
Write-Host ""
Write-Host "Switching to gh-pages branch..." -ForegroundColor Yellow
git checkout gh-pages
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to switch to gh-pages branch." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Copy built files to root
Write-Host "Copying built files..." -ForegroundColor Yellow
Copy-Item -Path "dist\*" -Destination "." -Recurse -Force
Write-Host "Files copied." -ForegroundColor Green

# Add all files
Write-Host "Adding files to git..." -ForegroundColor Yellow
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to add files to git." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Commit changes
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "Deploy to GitHub Pages - $(Get-Date)"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Nothing to commit or commit failed." -ForegroundColor Yellow
}

# Push to gh-pages branch
Write-Host "Pushing to gh-pages branch..." -ForegroundColor Yellow
git push origin gh-pages
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to push to gh-pages branch." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Switch back to main
Write-Host "Switching back to main branch..." -ForegroundColor Yellow
git checkout main
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to switch back to main branch." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app should be live at:" -ForegroundColor Green
Write-Host "https://ghislaingirard.github.io/mmc-calendar/" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
Read-Host "Press Enter to exit"
