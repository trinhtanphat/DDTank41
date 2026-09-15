$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'Source Flash\src\CharacterSoundManager.as'
$text = Get-Content $path -Raw

if ($text -match 'sound/[^\r\n]*\.flv') { throw 'Music playback still targets FLV, which triggers Ruffle unsupported-video open-website flow' }
if ($text -match 'import\s+flash\.net\.(NetStream|NetConnection)') { throw 'CharacterSoundManager still imports NetStream/NetConnection' }
if ($text -match '\b_ns\b|\b_nc\b') { throw 'CharacterSoundManager still references legacy NetStream/NetConnection fields' }
if ($text -notmatch 'import\s+flash\.net\.URLRequest') { throw 'URLRequest import missing for MP3 Sound loading' }
if ($text -notmatch 'new\s+Sound\s*\(') { throw 'Remote music Sound object is missing' }
if ($text -notmatch 'sound/[^\r\n]*\.mp3') { throw 'Music playback does not target MP3 assets' }
if ($text -notmatch '_musicChannel\.position') { throw 'Pause/resume position preservation missing' }
if ($text -notmatch 'Event\.SOUND_COMPLETE') { throw 'Music completion/loop handling missing' }
Write-Host 'RUFFLE_MUSIC_PLAYBACK_SMOKE=PASS'
