$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

$handler = Get-Content (Join-Path $root 'Game.Server\Packets\Client\TreasureHandler.cs') -Raw
$player = Get-Content (Join-Path $root 'Game.Server\GamePlayer.cs') -Raw
$gameServer = Get-Content (Join-Path $root 'Game.Server\GameServer.cs') -Raw
$business = Get-Content (Join-Path $root 'Bussiness\PlayerBussiness.cs') -Raw
$manager = Get-Content (Join-Path $root 'Bussiness\Managers\TreasureAwardMgr.cs') -Raw

if ($handler -notmatch '\[PacketHandler\(135,') { throw 'Treasure opcode 135 handler is missing.' }
if ($handler -notmatch 'case TreasurePackageType\.DIG:') { throw 'Treasure DIG command is missing.' }
if ($handler -notmatch 'TryDig\(position, out reward\)') { throw 'Treasure DIG must validate and mutate through PlayerTreasure.TryDig.' }
if ($player -notmatch 'Treasure = new PlayerTreasure\(this, saveTodb: true\)') { throw 'GamePlayer treasure initialization is missing.' }
if ($player -notmatch 'Treasure\.LoadFromDatabase\(\)') { throw 'GamePlayer treasure load is missing.' }
if ($player -notmatch 'Treasure\.SaveToDatabase\(\)') { throw 'GamePlayer treasure save is missing.' }
if ($gameServer -notmatch 'TreasureAwardMgr\.Init\(\)') { throw 'Treasure reward manager startup initialization is missing.' }

$requiredProcedures = @(
  'SP_Treasure_All',
  'SP_GetSingleTreasure',
  'SP_GetSingleTreasureData',
  'SP_Users_Treasure_Add',
  'SP_UpdateUserTreasure',
  'SP_TreasureData_Add',
  'SP_UpdateTreasureData'
)
foreach ($procedure in $requiredProcedures) {
  if ($business -notmatch [regex]::Escape($procedure)) {
    throw "Treasure persistence call missing: $procedure"
  }
}
if ($manager -notmatch 'Math\.Min\(16,') { throw 'Treasure reward generation must be bounded to the board size.' }

Write-Output 'TREASURE_SERVER_REGRESSION=PASS'
