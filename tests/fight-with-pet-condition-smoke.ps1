$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$conditionPath = Join-Path $root 'Game.Server\Quests\FightWithPetCondition.cs'
$basePath = Join-Path $root 'Game.Server\Quests\BaseCondition.cs'

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw "FIGHT_WITH_PET_CONDITION_SMOKE_FAIL: $message" }
}

Require (Test-Path $conditionPath) 'FightWithPetCondition.cs is missing'
$code = Get-Content $conditionPath -Raw
$base = Get-Content $basePath -Raw

Require ($base -match 'case\s+45:[\s\S]*FightWithPetCondition') 'condition type 45 must map to FightWithPetCondition'
Require ($code -match 'player\.GameOver\s*\+=\s*player_GameOver') 'pet quest must subscribe to battle completion'
Require ($code -match 'm_player\.Pet\s*!=\s*null') 'battle must only count with an equipped pet'
Require ($code -match 'Value--') 'battle completion must decrement remaining progress'
Require ($code -match 'player\.GameOver\s*-=\s*player_GameOver') 'pet quest trigger must be removed'
Require ($code -match 'return\s+Value\s*<=\s*0') 'completion must use server-side remaining progress'

Write-Host 'FIGHT_WITH_PET_CONDITION_SMOKE=PASS'
