$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$questPath = Join-Path $root 'Source Flash\src\ddt\data\quest\QuestInfo.as'
$quest = Get-Content $questPath -Raw
$methodMatch = [regex]::Match($quest,'(?s)private function getProgressById\(param1:uint\) : uint(?<method>.*?)public function get progress\(\) : Array')
if (-not $methodMatch.Success) { throw 'getProgressById method is missing.' }
$method = $methodMatch.Groups['method'].Value
$serverProgress = '_loc4_ = _loc3_\.target - this\.data\.progress\[param1\];'
if ($method -notmatch $serverProgress) { throw 'Guild quest progress must start from server progress.' }
$caseMatch = [regex]::Match($method,'(?s)case 18:\s*(?<body>.*?)\s*case 20:')
if (-not $caseMatch.Success) { throw 'Guild quest condition type 18 is missing.' }
$body = $caseMatch.Groups['body'].Value
$guard = 'if\(PlayerManager\.Instance\.Self\.ConsortiaID <= 0\)\s*\{\s*_loc4_ = 0;\s*\}\s*break;'
if ($body -notmatch $guard) { throw 'Guild quest progress must stay incomplete when the player has no guild.' }
if ($body -match 'memberList|UseOffer|consortiaInfo') { throw 'Guild quest progress must not override server progress from stale guild caches.' }
Write-Output 'GUILDQUEST_MEMBERSHIP_UI_SMOKE=PASS'
