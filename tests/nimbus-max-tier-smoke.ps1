$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'Game.Server\GameUtils\PlayerEquipInventory.cs'
$source = [IO.File]::ReadAllText($path)
function Assert-True([bool]$condition, [string]$message) { if (-not $condition) { throw $message } }
Assert-True ($source.Contains('num = Math.Max(num, 1);')) 'armor light tier 1 is not monotonic'
Assert-True ($source.Contains('num = Math.Max(num, 2);')) 'armor light tier 2 is not monotonic'
Assert-True ($source.Contains('num = Math.Max(num, 3);')) 'armor light tier 3 is not monotonic'
Assert-True ($source.Contains('num = Math.Max(num, 4);')) 'armor light tier 4 is not monotonic'
Assert-True ($source.Contains('num2 = Math.Max(num2, 1);')) 'weapon circle tier 1 is not monotonic'
Assert-True ($source.Contains('num2 = Math.Max(num2, 2);')) 'weapon circle tier 2 is not monotonic'
Assert-True ($source.Contains('num2 = Math.Max(num2, 3);')) 'weapon circle tier 3 is not monotonic'
Assert-True ($source.Contains('num2 = Math.Max(num2, 4);')) 'weapon circle tier 4 is not monotonic'
Assert-True (-not $source.Contains('num = ((num > 1) ? num : 3);')) 'legacy armor tier-3 downgrade guard remains'
Assert-True (-not $source.Contains('num = ((num > 1) ? num : 4);')) 'legacy armor tier-4 downgrade guard remains'
Assert-True (-not $source.Contains('num2 = ((num2 > 1) ? num2 : 3);')) 'legacy weapon tier-3 downgrade guard remains'
Assert-True (-not $source.Contains('num2 = ((num2 > 1) ? num2 : 4);')) 'legacy weapon tier-4 downgrade guard remains'
Write-Host 'NIMBUS_MAX_TIER_SMOKE=PASS'
