$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$bomb = Get-Content (Join-Path $root 'Source Flash\src\game\view\Bomb.as') -Raw
$simple = Get-Content (Join-Path $root 'Source Flash\src\game\objects\SimpleBomb.as') -Raw
$view = Get-Content (Join-Path $root 'Source Flash\src\game\view\GameView.as') -Raw
$shock = Get-Content (Join-Path $root 'Source Flash\src\game\animations\ShockMapAnimation.as') -Raw
if ($bomb -match 'function\s+get\s+target\s*\(') { throw 'Bomb still exposes EventDispatcher-conflicting target getter' }
if ($bomb -notmatch 'function\s+get\s+impactTarget\s*\(') { throw 'Bomb.impactTarget getter missing' }
if ($simple -match 'function\s+get\s+target\s*\(') { throw 'SimpleBomb still exposes EventDispatcher-conflicting target getter' }
if ($simple -notmatch 'function\s+get\s+impactTarget\s*\(') { throw 'SimpleBomb.impactTarget getter missing' }
if ($simple -match '_info\.target\b') { throw 'SimpleBomb still calls Bomb.target' }
if ($simple -notmatch '_info\.impactTarget\b') { throw 'SimpleBomb does not call Bomb.impactTarget' }
if ($view -match 'Bomb\([^\r\n]+\)\.target\b') { throw 'GameView still calls Bomb.target' }
if (([regex]::Matches($view, 'Bomb\([^\r\n]+\)\.impactTarget\b')).Count -lt 2) { throw 'GameView impactTarget calls missing' }
if ($shock -match '_loc4_\.target\b') { throw 'ShockMapAnimation still calls SimpleBomb.target' }
if (([regex]::Matches($shock, '_loc4_\.impactTarget\b')).Count -lt 2) { throw 'ShockMapAnimation impactTarget calls missing' }
Write-Host 'PROJECTILE_TARGET_SMOKE=PASS'
