$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw "VIP20_CLIENT_SMOKE_FAIL: $message" }
}

$socket = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\GameSocketOut.as') -Raw
$config = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\ServerConfigManager.as') -Raw
$icon = Get-Content (Join-Path $root 'Source Flash\src\ddt\view\common\VipLevelIcon.as') -Raw
$controller = Get-Content (Join-Path $root 'Source Flash\src\vip\VipController.as') -Raw
$view = Get-Content (Join-Path $root 'Source Flash\src\vip\view\GiveYourselfOpenView.as') -Raw
$head = Get-Content (Join-Path $root 'Source Flash\src\vip\view\VipFrameHead.as') -Raw
$recharge = Get-Content (Join-Path $root 'Source Flash\src\vip\view\RechargeAlertTxt.as') -Raw

Require ($socket -match 'sendOpenVip\(param1:String, param2:int, param3:int = 0\)') 'socket renewal must accept payment mode'
Require ($socket -match 'writeByte\(param3\)') 'socket renewal must send payment mode'
Require ($controller -match 'sendOpenVip\(param1:String, param2:int, param3:int = 0\)') 'controller must propagate payment mode'
Require ($config -match 'VIP_MAX_LEVEL') 'client must read VIPMaxLevel'
Require ($config -match 'VIP_EXP_FOREACHLV') 'client must read cumulative VIP thresholds'
Require ($icon -match 'VIPMaxLevel') 'VIP tooltip must use configured max level'
Require ($icon -match 'Math\.min\(9,this\._level\)') 'legacy icon frame must be clamped safely'
Require ($view -match 'GOLD_PER_XU:int = 1000') 'Gold conversion is missing'
Require ($view -match 'THREE_MONTH_PAY') '3-month configured price is missing'
Require ($view -match 'SIX_MONTH_PAY') '6-month configured price is missing'
Require ($view -match 'ONE_YEAR_PAY:int = SIX_MONTH_PAY \* 2') '1-year price must not reuse the 6-month price'
Require ($view -match '_goldModeBtn') 'Xu/Gold UI toggle is missing'
Require ($view -match 'PlayerManager\.Instance\.Self\.Gold') 'Gold balance display/check is missing'
Require ($view -match 'sendOpenVip\(PlayerManager\.Instance\.Self\.NickName,this\.days,this\._paymentMode\)') 'selected payment mode is not sent'
Require ($view -match 'VIP_LEVEL12') 'VIP10-20 reward fallback table is missing'
Require ($head -match 'VIPExpForEachLv') 'VIP progress must use cumulative threshold config'
Require ($head -match 'Math\.max\(0,safeExp - floorExp\)') 'VIP progress must never render negative'
Require ($head -match '"MAX"') 'VIP max display is missing'
Require ($recharge -match 'Math\.min\(9,param1\)') 'legacy benefit arrays must clamp high VIP levels'

Write-Host 'VIP20_CLIENT_SMOKE=PASS'
