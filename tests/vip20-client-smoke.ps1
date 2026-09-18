$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw "VIP20_CLIENT_SMOKE_FAIL: $message" }
}

$serverConfig = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\ServerConfigManager.as') -Raw
$head = Get-Content (Join-Path $root 'Source Flash\src\vip\view\VipFrameHead.as') -Raw
$icon = Get-Content (Join-Path $root 'Source Flash\src\ddt\view\common\VipLevelIcon.as') -Raw
$socket = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\GameSocketOut.as') -Raw
$controller = Get-Content (Join-Path $root 'Source Flash\src\vip\VipController.as') -Raw
$openView = Get-Content (Join-Path $root 'Source Flash\src\vip\view\GiveYourselfOpenView.as') -Raw
$alert = Get-Content (Join-Path $root 'Source Flash\src\vip\view\RechargeAlertTxt.as') -Raw

Require ($serverConfig -match 'VIP_MAX_LEVEL') 'VIPMaxLevel config key is missing'
Require ($serverConfig -match 'function get VIPExpForEachLv') 'cumulative VIP EXP config getter is missing'
Require ($head -match 'VIPMaxLevel') 'VIP head must use server max level'
Require ($head -match 'Math\.max\(0,safeExp - floorExp\)') 'VIP progress must clamp negative progress'
Require ($head -match 'level >= maxLevel \? "MAX"') 'VIP20 max label is missing'
Require ($icon -match 'VIPMaxLevel') 'VIP icon tooltip still assumes VIP9 max'
Require ($icon -match 'Math\.min\(9,this\._level\)') 'legacy icon frames must be clamped'
Require ($socket -match 'writeByte\(param3\)') 'payment mode is not written to renewal packet'
Require ($controller -match 'sendOpenVip\(param1,param2,param3\)') 'payment mode is not forwarded by controller'
Require ($openView -match 'GOLD_PER_XU:int = 1000') 'Gold conversion constant is missing'
Require ($openView -match 'THREE_MONTH_PAY') '3-month package price must use its shop price'
Require ($openView -match 'SIX_MONTH_PAY') '6-month package price must use its shop price'
Require ($openView -match 'PAY_WITH_GOLD') 'Gold payment mode is missing'
Require ($openView -match '_paymentMode') 'payment mode state is missing'
Require ($openView -match 'VipController\.instance\.sendOpenVip\(PlayerManager\.Instance\.Self\.NickName,this\.days,this\._paymentMode\)') 'renewal packet must include payment mode'
Require ($openView -notmatch 'VIPLevel == 9 \?') 'reward UI must not hardcode VIP9 as max'
Require ($openView -match 'Math\.min\(this\._vipChestsArr\.length - 1') 'reward lookup must be bounded for VIP20'
Require ($alert -match 'displayLevel:int = Math\.max\(1,Math\.min\(9,param1\)\)') 'legacy benefit art must clamp high VIP levels'

Write-Host 'VIP20_CLIENT_SMOKE=PASS'
