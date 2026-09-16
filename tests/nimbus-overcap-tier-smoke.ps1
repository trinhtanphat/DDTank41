$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'Game.Server\GameUtils\PlayerEquipInventory.cs'
$source = [IO.File]::ReadAllText($path)
function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}
Assert-True ($source.Contains('if (strengthenLevel >= 15)')) 'strengthen levels above +15 still lose Nimbus aura'
Assert-True (-not $source.Contains('if (strengthenLevel == 15)')) 'legacy exact +15 Nimbus gate remains'
Assert-True ($source.Contains('num = Math.Max(num, 4);')) 'armor/head overcap aura must preserve repo tier 4 semantics'
Assert-True ($source.Contains('num2 = Math.Max(num2, 4);')) 'weapon overcap aura must preserve repo tier 4 semantics'
Write-Host 'NIMBUS_OVERCAP_TIER_SMOKE=PASS'