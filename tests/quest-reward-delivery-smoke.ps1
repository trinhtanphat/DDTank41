$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'Game.Server\Quests\QuestInventory.cs'

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw "QUEST_REWARD_DELIVERY_SMOKE_FAIL: $message" }
}

Require (Test-Path $path) 'QuestInventory.cs is missing'
$code = Get-Content $path -Raw
$start = $code.IndexOf('public bool Finish(BaseQuest baseQuest, int selectedItem)')
$end = $code.IndexOf('private byte[] method_4()', $start)
Require ($start -ge 0 -and $end -gt $start) 'could not isolate QuestInventory.Finish'
$finish = $code.Substring($start, $end - $start)

Require ($finish -notmatch 'bool\s+checkbag') 'quest finish must not require every unrelated bag to have an empty slot'
Require ($finish -notmatch 'FindFirstEmptySlot\(\)\s*<\s*0') 'quest finish must not silently gate on any globally full bag'
Require ($finish -notmatch 'GetEmptyCount\(\)\s*<') 'quest reward preflight must not reject stackable rewards solely because a bag has no empty slot'
Require ($finish -match 'StackItemToAnother\(item\)') 'stackable quest rewards must try existing stacks first'
Require ($finish -match 'SendItemsToMail\(overdueItems') 'undeliverable rewards must fall back to mail'
Require ($finish -match 'FarmBag\.AddItem\(item\)') 'farm rewards must be added to FarmBag'
Require ($finish -notmatch 'foreach \(ItemInfo item in farmBg\)[\s\S]{0,180}EquipBag\.AddItem') 'farm rewards must never be routed into EquipBag'
Require ($finish -match 'len \+ temp\.MaxCount > tempCount') 'multi-stack reward chunking must use the randomized final count'

Write-Host 'QUEST_REWARD_DELIVERY_SMOKE=PASS'
