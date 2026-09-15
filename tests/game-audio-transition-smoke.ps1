$root = Split-Path $PSScriptRoot -Parent
$viewPath = Join-Path $root 'Source Flash\src\game\view\GameViewBase.as'
$view = Get-Content $viewPath -Raw
if ($view -notmatch 'SoundManager\.instance\.stopMusic\(\);\s*SoundManager\.instance\.ensureGameSoundEnabled\(\);\s*SoundManager\.instance\.playGameBackMusic\(this\._map\.info\.BackMusic\);') {
    throw 'Battle entry must stop scene BGM, restore combat SFX, then start the configured map BGM.'
}
$sound = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\SoundManager.as') -Raw
if ($sound -notmatch 'public function ensureGameSoundEnabled\(\)\s*:\s*void[\s\S]*?this\.allowSound = true;[\s\S]*?this\.soundVolumn = 50;') {
    throw 'SoundManager lacks the combat SFX recovery hook.'
}
Write-Output 'GAME_AUDIO_TRANSITION_SMOKE=PASS'
