$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$path = Join-Path $root 'Source Flash\src\ddt\manager\SoundManager.as'
if (-not (Test-Path $path)) { throw "missing SoundManager: $path" }
$source = Get-Content $path -Raw

function Require([bool]$condition, [string]$message) {
  if (-not $condition) { throw $message }
}

Require ($source -match 'setupAudioResource\s*\(\s*param1\s*:\s*Boolean\s*=\s*false\s*\)') 'setupAudioResource must keep optional Boolean callback contract'
Require ($source -match 'if\s*\(\s*!param1\s*\)\s*\{[\s\S]*?this\.initI\(\);[\s\S]*?\}\s*this\.initII\(\);') 'setupAudioResource must preserve audio I/II staged initialization'
Require ($source -match 'private function initI\s*\(\s*\)') 'initI missing'
Require ($source -match 'private function initII\s*\(\s*\)') 'initII missing'

$requiredPrimary = @('166','167','168','169','170','171','200','201','202','203','204','210')
foreach ($id in $requiredPrimary) {
  Require ($source -match ('_dic\["' + $id + '"\]\s*=\s*ModuleLoader\.getDefinition\("Sound' + $id + '"\)')) "primary sound $id missing"
}

Require ($source -match 'new\s+URLRequest\s*\(') 'MP3 URLRequest transport missing'
Require ($source -match 'SoundChannel') 'SoundChannel transport missing'
Require ($source -match '\.mp3') 'MP3 resource suffix missing'
Require ($source -notmatch '\.flv') 'legacy FLV music path returned'
Require ($source -notmatch '\bNetStream\b') 'legacy NetStream returned'
Require ($source -notmatch '\bNetConnection\b') 'legacy NetConnection returned'

Write-Host 'RUFFLE_SOUNDMANAGER_CALLBACK_COMPAT_SMOKE=PASS'
