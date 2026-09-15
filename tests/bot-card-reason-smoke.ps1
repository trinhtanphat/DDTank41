$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'Source Flash\src\game\view\card\SmallCardsView.as'
if (-not (Test-Path $path)) { throw 'SmallCardsView.as missing' }
$src = [IO.File]::ReadAllText($path)
function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}
Assert-True ($src.Contains('private function isBotRewardSuppressedMatch() : Boolean')) 'bot-match detector missing'
Assert-True ($src.Contains('NickName.indexOf("NPC ") == 0')) 'bot nickname contract missing'
Assert-True ($src.Contains('private function getDisabledCardMessage() : String')) 'disabled-card reason helper missing'
Assert-True ($src.Contains('NPC/bot')) 'bot reward reason text missing'
Assert-True ($src.Contains('LanguageMgr.GetTranslation("tank.gameover.DisableGetCard")')) 'human no-damage fallback removed'
Assert-True ($src.Contains('_loc4_.msg = this.getDisabledCardMessage();')) 'card tooltip does not use reason helper'
Write-Host 'BOT_CARD_REASON_SMOKE=PASS'
