$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

$inventoryPath = Join-Path $root 'Game.Server\GameUtils\PlayerFarmInventory.cs'
$inventory = Get-Content $inventoryPath -Raw
$growPath = Join-Path $root 'Game.Server\Farm\Handle\GrowFields.cs'
$grow = Get-Content $growPath -Raw
$playerFarmPath = Join-Path $root 'Game.Server\GameUtils\PlayerFarm.cs'
$playerFarm = Get-Content $playerFarmPath -Raw

if ($inventory -match 'm_fields\[place\]\s*=\s*item;\s*if\s*\(m_fields\[place\]\s*!=\s*null\)') {
    throw 'Farm field insertion regression: slot is assigned before the occupied-slot check.'
}
if ($inventory -notmatch 'fieldId\s*<\s*0\s*\|\|\s*fieldId\s*>=\s*m_fields\.Length') {
    throw 'Farm planting must validate the field index.'
}
if ($inventory -notmatch 'field\s*==\s*null\s*\|\|\s*field\.SeedID\s*!=\s*0') {
    throw 'Farm planting must reject missing or already occupied fields.'
}
if ($grow -notmatch 'FarmBag\.GetItemCount\(templateId\)\s*<=\s*0') {
    throw 'Farm planting must verify seed ownership before mutating the field.'
}
if ($grow -notmatch 'FarmBag\.RemoveTemplate\(templateId,\s*1\)') {
    throw 'Farm planting must consume exactly one seed after a successful plant.'
}
if ($playerFarm -notmatch 'fieldId\s*>=\s*base\.CurrentFields\.Length') {
    throw 'Farm harvest must use array bounds rather than filtered field count.'
}

Write-Output 'FARM_PLANTING_REGRESSION=PASS'
