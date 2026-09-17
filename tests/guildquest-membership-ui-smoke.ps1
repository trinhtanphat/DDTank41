$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$questPath = Join-Path $root 'Source Flash\src\ddt\data\quest\QuestInfo.as'
$quest = Get-Content $questPath -Raw

$guard = '(?s)case 18:\s*if\(PlayerManager\.Instance\.Self\.ConsortiaID <= 0\)\s*\{\s*_loc4_ = 0;\s*break;\s*\}\s*switch\(_loc3_\.param\)'
if ($quest -notmatch $guard) {
    throw 'Guild quest progress must stay incomplete when the player has no guild.'
}

if ($quest -notmatch 'ConsortionModelControl\.Instance\.model\.memberList\.length') {
    throw 'Expected guild-member progress source is missing.'
}

Write-Output 'GUILDQUEST_MEMBERSHIP_UI_SMOKE=PASS'