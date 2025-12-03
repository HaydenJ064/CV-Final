<#
setup_env.ps1
Creates a Python virtual environment in `./.venv`, installs packages from `installed.txt`,
and optionally installs CHAIR/AMBER extras (spacy, nltk, numpy<2) and downloads the spacy model.

Usage (from repo root):
  powershell -ExecutionPolicy Bypass -File .\setup_env.ps1          # default
  powershell -ExecutionPolicy Bypass -File .\setup_env.ps1 -InstallAmberExtras

Notes:
- This script uses the venv's python executable directly (no need to `Activate` the venv).
- If you want GPU PyTorch, install the appropriate CUDA wheel manually before running other installs.
- The README lists model-specific `transformers` versions; create separate envs if you need different versions.
#>
param(
    [switch]$InstallAmberExtras
)

$ErrorActionPreference = 'Stop'

Write-Host "Repo root: $PSScriptRoot"

# Check python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Error "Python not found on PATH. Please install Python >= 3.9 and re-run this script."
    exit 1
}

$venvDir = Join-Path $PSScriptRoot '.venv'
$venvPython = Join-Path $venvDir 'Scripts\python.exe'

if (-not (Test-Path $venvDir)) {
    Write-Host "Creating virtual environment at $venvDir..."
    & python -m venv $venvDir
} else {
    Write-Host "Virtual environment already exists at $venvDir"
}

if (-not (Test-Path $venvPython)) {
    Write-Error "Expected venv python at $venvPython not found. The venv may not have been created correctly."
    exit 1
}

Write-Host "Upgrading pip in the venv..."
& $venvPython -m pip install --upgrade pip

$reqFile = Join-Path $PSScriptRoot 'installed.txt'
if (-not (Test-Path $reqFile)) {
    Write-Error "Requirements file not found at $reqFile. Make sure you're running this from the repo root."
    exit 1
}

Write-Host "Installing packages from installed.txt (this may take a while)..."
& $venvPython -m pip install -r $reqFile

if ($InstallAmberExtras) {
    Write-Host "Installing CHAIR/AMBER extras: spacy, nltk, numpy<2..."
    & $venvPython -m pip install spacy nltk "numpy<2"
    Write-Host "Downloading spacy model en_core_web_lg (may be large)..."
    & $venvPython -m spacy download en_core_web_lg
}

Write-Host 'Done. To use the venv in PowerShell run:'
Write-Host '  .\\.venv\\Scripts\\Activate.ps1'
Write-Host 'Alternatively, call the venv Python directly: .\\.venv\\Scripts\\python.exe -m module_name'

Write-Host 'Important notes:' -ForegroundColor Yellow
Write-Host "- The README lists model-specific 'transformers' versions (e.g., 4.37.2 for LLaVA)." -ForegroundColor Yellow
Write-Host '  If you plan to evaluate multiple models that require different "transformers" versions, create separate venvs.' -ForegroundColor Yellow
Write-Host '- If you want GPU PyTorch, install the correct CUDA wheel from pytorch.org before running other installs.' -ForegroundColor Yellow

exit 0
