$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$small = [IO.File]::ReadAllText((Join-Path $root 'Source Flash\src\game\view\card\SmallCardsView.as'))
$active = [IO.File]::ReadAllText((Join-Path $root 'Source Flash\src\activeEvents\view\ActiveSubContent.as'))
function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}
Assert-True (-not $small.Contains('isBotRewardSuppressedMatch')) 'obsolete bot-card detector still present'
Assert-True (-not $small.Contains('getDisabledCardMessage')) 'obsolete bot-card message helper still present'
Assert-True ($small.Contains('_loc4_.msg = LanguageMgr.GetTranslation("tank.gameover.DisableGetCard");')) 'canonical disabled-card message path missing'
Assert-True ($active.Contains('private function claimSucceeded(param1:BaseLoader) : Boolean')) 'claimed-reward success parser regressed'
Assert-True ($active.Contains('private function applyClaimedState() : void')) 'claimed-reward UI helper regressed'
Assert-True ($active.Contains('this._info.isAttend = true;')) 'claimed state is not persisted after success'
Assert-True ($active.Contains('this.applyClaimedState();')) 'claimed UI is not restored/applied'
Write-Host 'HUMAN_BOT_CARD_MESSAGE_SMOKE=PASS'
