$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$file = Join-Path $root 'Source Flash\src\activeEvents\view\ActiveSubContent.as'
$text = [IO.File]::ReadAllText($file,[Text.Encoding]::UTF8)
function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}
$claimed = ([char]0x0110).ToString() + ([char]0x00E3) + ' nh' + ([char]0x1EAD) + 'n'
$claimedLine = 'this._activeGetBtn.text = "' + $claimed + '";'
Assert-True ($text.Contains('private function applyClaimedState() : void')) 'claimed-state renderer missing'
Assert-True ($text.Contains($claimedLine)) 'claimed button label missing'
Assert-True ($text.Contains('this._activeGetBtn.enable = false;')) 'claimed button must be disabled'
Assert-True ($text.Contains('private function claimSucceeded(param1:BaseLoader) : Boolean')) 'claim response validator missing'
Assert-True ($text.Contains('if(this.claimSucceeded(_loc2_))')) 'claim success is not validated'
Assert-True ($text.Contains('this._info.isAttend = true;')) 'successful claim does not persist in model'
Assert-True ($text.Contains('if(this._info.isAttend)')) 'render path does not restore claimed state'
$clickStart = $text.IndexOf('private function _activeGetBtnClick')
$completeStart = $text.IndexOf('private function __onLoadComplete')
$clickBody = $text.Substring($clickStart,$completeStart-$clickStart)
Assert-True (-not $clickBody.Contains('this._info.isAttend = true;')) 'claim is marked before server success'
Write-Output 'ACTIVE_REWARD_CLAIMED_UI_SMOKE=PASS'