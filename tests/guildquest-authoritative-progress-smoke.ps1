$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$path = Join-Path $root 'Source Flash\src\ddt\data\quest\QuestInfo.as'
$code = Get-Content $path -Raw
if ($code -notmatch 'case 18:[\s\S]*ConsortiaID <= 0[\s\S]*_loc4_ = 0;[\s\S]*break;') { throw 'no-guild guard missing' }
if ($code -match 'case 18:[\s\S]*?case 20:[\s\S]*memberList\.length') { throw 'guild quest must not use stale memberList cache' }
if ($code -match 'case 18:[\s\S]*?case 20:[\s\S]*Self\.UseOffer') { throw 'guild quest must not override server progress from client guild cache' }
Write-Output 'GUILDQUEST_AUTHORITATIVE_PROGRESS_SMOKE=PASS'
