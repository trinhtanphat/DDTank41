$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$smallPath = Join-Path $root 'Source Flash\src\game\view\card\SmallCardsView.as'
$small = [IO.File]::ReadAllText($smallPath)
function Assert-True([bool]$condition, [string]$message) { if (-not $condition) { throw $message } }
Assert-True ($small.Contains('public static const SMALL_CARD_VIEW_TIME:uint = 4;')) 'small-card reveal hold is not 4 seconds'
Assert-True ($small.Contains('CrazyTankSocketEvent.SHOW_CARDS,this.__showAllSmallCards')) 'small cards do not listen for SHOW_CARDS'
Assert-True ($small.Contains('removeEventListener(CrazyTankSocketEvent.SHOW_CARDS,this.__showAllSmallCards)')) 'SHOW_CARDS listener is not removed'
Assert-True ($small.Contains('protected function __showAllSmallCards(param1:CrazyTankSocketEvent) : void')) 'small-card SHOW_CARDS parser missing'
Assert-True ($small.Contains('this._cards[uint(this._smallShowCardInfos[_loc1_].index)].play(null,int(this._smallShowCardInfos[_loc1_].templateID),this._smallShowCardInfos[_loc1_].count,false);')) 'full reward cards are not revealed'
Assert-True ($small.Contains('this._onAllComplete = ON_ALL_COMPLETE_CNT;')) 'reveal completion state is not sealed'
Assert-True ($small.Contains('this._timerForView.reset();')) 'reveal timer is not reset after SHOW_CARDS'
Assert-True ($small.Contains('this._timerForView.start();')) 'reveal timer is not started after SHOW_CARDS'
Write-Host 'POSTGAME_REWARD_REVEAL_CLIENT_SMOKE=PASS'