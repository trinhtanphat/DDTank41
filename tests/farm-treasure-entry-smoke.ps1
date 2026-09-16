$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$viewPath = Join-Path $root 'Source Flash\src\farm\viewx\FarmMainView.as'
$view = Get-Content $viewPath -Raw

if ($view -notmatch 'import treasure\.controller\.TreasureManager;') {
    throw 'Farm treasure entry must import TreasureManager.'
}

if ($view -notmatch '(?s)private function __goTreasureBtn\(param1:MouseEvent\)\s*:\s*void\s*\{\s*TreasureManager\.instance\.show\(\);\s*\}') {
    throw 'Farm treasure button must open the treasure controller.'
}

Write-Output 'FARM_TREASURE_ENTRY_SMOKE=PASS'
