$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$bossPath = Join-Path $root 'Source Flash\src\ddt\manager\BossBoxManager.as'
$timerPath = Join-Path $root 'Source Flash\src\ddt\view\bossbox\TimeCountDown.as'
$boss = [IO.File]::ReadAllText($bossPath)
$timer = [IO.File]::ReadAllText($timerPath)
function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}
Assert-True ($boss.Contains('private function promoteReadyTimeBox() : Boolean')) 'ready time-box promotion helper missing'
Assert-True ($boss.Contains('this.delaySumTime = 0;')) 'ready time-box countdown is not clamped to zero'
$showStart = $boss.IndexOf('public function showTimeBox() : void')
$showEnd = $boss.IndexOf('public function showGradeBox() : void',$showStart)
$showBody = $boss.Substring($showStart,$showEnd-$showStart)
Assert-True ($showBody.Contains('this.promoteReadyTimeBox();')) 'showTimeBox can render disabled preview at zero'
$oneStart = $boss.IndexOf('private function _timeOne(param1:Event) : void')
$oneEnd = $boss.IndexOf('private function _getShowBoxID',$oneStart)
$oneBody = $boss.Substring($oneStart,$oneEnd-$oneStart)
Assert-True ($oneBody.Contains('this.promoteReadyTimeBox();')) 'zero countdown is not promoted immediately'
Assert-True ($timer.Contains('removeEventListener(TimerEvent.TIMER,this._timer);')) 'timer listener cleanup missing before restart'
Assert-True ($timer.Contains('removeEventListener(TimerEvent.TIMER_COMPLETE,this._timerComplete);')) 'timer-complete listener cleanup missing before restart'
Write-Output 'TIMEBOX_CLAIM_RACE_SMOKE=PASS'