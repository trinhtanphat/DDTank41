$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$file = Join-Path $root 'Source Flash\src\phy\maps\Tile.as'
$text = Get-Content $file -Raw
$firstErase = $text.IndexOf('bitmapData.draw(param2,_loc4_,null,BlendMode.ERASE);')
$brinkDraw = $text.IndexOf('bitmapData.draw(_loc5_,_loc4_,null,param3.blendMode);')
$lastErase = $text.LastIndexOf('bitmapData.draw(param2,_loc4_,null,BlendMode.ERASE);')
if ($firstErase -lt 0 -or $brinkDraw -lt 0) { throw 'Expected crater erase/brink draw sequence missing.' }
if ($lastErase -le $brinkDraw) {
    throw 'Crater mask is not re-erased after brink draw; opaque crater centers can refill the hole.'
}
Write-Output 'CRATER_DIG_ORDER_SMOKE=PASS'
