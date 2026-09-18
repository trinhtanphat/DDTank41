$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$playerPath = Join-Path $root 'Game.Server\GamePlayer.cs'
$handlerPath = Join-Path $root 'Game.Server\Packets\Client\OpenVipHandler.cs'
$propertiesPath = Join-Path $root 'Bussiness\GameProperties.cs'
$sqlPath = Join-Path $root 'Database\20260918_v389_vip20.sql'

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw "VIP20_SERVER_SMOKE_FAIL: $message" }
}

$player = Get-Content $playerPath -Raw
$handler = Get-Content $handlerPath -Raw
$properties = Get-Content $propertiesPath -Raw
$sql = Get-Content $sqlPath -Raw

Require ($properties -match 'VIPExpForEachLv.*7800000') 'default VIP EXP thresholds must reach VIP20'
Require ($player -match 'GetVipMaxLevel\(\)') 'dynamic VIP max helper is missing'
Require ($player -match 'thresholds\.Count') 'VIP progression must derive max from thresholds'
Require ($player -match 'currentLevel >= thresholds\.Count') 'VIP level-up bound must be dynamic'
Require ($player -match 'currentLevel > thresholds\.Count') 'VIP level-down bound must be dynamic'
Require ($player -notmatch 'level\s*==\s*9') 'VIP9 hard stop remains in AddExpVip'
Require ($player -notmatch 'level\s*<\s*9') 'VIP9 level-up ceiling remains'
Require ($player -notmatch 'VIPLevel\s*>=\s*9') 'VIP9 daily EXP ceiling remains'
Require ($handler -match 'GoldPerXu\s*=\s*1000') 'Gold/Xu conversion is missing on the server'
Require ($handler -match 'paymentMode\s*=\s*packet\.ReadByte\(\)') 'server must read client payment mode'
Require ($handler -match 'RemoveGold\(charged\)') 'Gold payment must be charged server-side'
Require ($handler -match 'MoneyDirect\(charged') 'Xu payment must be charged server-side'
Require ($handler -match 'renewalResult\s*!=\s*1') 'failed renewal must be detected'
Require ($handler -match 'Refund\(client\.Player') 'failed renewal must refund payment'
Require ($handler -notmatch 'VIPLevel\s*==\s*9') 'renewal must not reject players at legacy VIP9'
Require ($sql -match "WHEN 'VIPMaxLevel' THEN '20'") 'v389 config migration must advertise VIP20'
Require ($sql -match '7800000') 'v389 config migration must include VIP20 EXP floor'
Require ($sql -match '112206\|112206\|112206') 'high-level weekly reward fallback must be configured'
Require ($sql -match 'THROW 51020') 'migration must fail if required config rows are missing'

Write-Host 'VIP20_SERVER_SMOKE=PASS'
