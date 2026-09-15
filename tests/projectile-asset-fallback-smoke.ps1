$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$ball = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\BallManager.as') -Raw

if ($ball -notmatch 'import\s+flash\.system\.ApplicationDomain;') {
    throw 'BallManager must inspect ApplicationDomain before instantiating projectile linkage'
}
if ($ball -notmatch 'hasDefinition\s*\(\s*solveBulletMovieName\(param1\)\s*\)') {
    throw 'createBulletMovie must guard missing bullet linkage'
}
if ($ball -match 'return\s+ClassUtils\.CreatInstance\(solveBulletMovieName\(param1\)\)\s+as\s+MovieClip;') {
    throw 'createBulletMovie still blindly instantiates missing bullet linkage'
}
if ($ball -notmatch 'new\s+MovieClip\s*\(\s*\)') {
    throw 'Visible projectile fallback MovieClip missing'
}
if ($ball -notmatch '\.graphics\.drawCircle\s*\(') {
    throw 'Visible projectile fallback geometry missing'
}
Write-Host 'PROJECTILE_ASSET_FALLBACK_SMOKE=PASS'