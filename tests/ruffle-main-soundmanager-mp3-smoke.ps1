$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'Source Flash\src\ddt\manager\SoundManager.as'
$text = Get-Content $path -Raw

if ($text -match 'sound/[^\r\n]*\.flv') { throw 'ddt.manager.SoundManager still targets FLV music' }
if ($text -match 'import\s+flash\.net\.(NetStream|NetConnection)') { throw 'SoundManager still imports NetStream/NetConnection' }
if ($text -match '\b_ns\b|\b_nc\b') { throw 'SoundManager still references NetStream/NetConnection fields' }
if ($text -notmatch 'import\s+flash\.net\.URLRequest') { throw 'URLRequest import missing for MP3 music' }
if ($text -notmatch 'new\s+Sound\s*\(') { throw 'Remote MP3 Sound object missing' }
if ($text -notmatch 'sound/[^\r\n]*\.mp3') { throw 'SoundManager does not target MP3 assets' }
if ($text -notmatch '_musicChannel\.position') { throw 'Pause/resume position preservation missing' }
if ($text -notmatch 'Event\.SOUND_COMPLETE') { throw 'Music completion/loop handling missing' }
Write-Host 'RUFFLE_MAIN_SOUNDMANAGER_MP3_SMOKE=PASS'