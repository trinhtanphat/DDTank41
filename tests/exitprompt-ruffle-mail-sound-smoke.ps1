$ErrorActionPreference = 'Stop'
$root = 'C:\Gunny\_work\DDTank41-exitprompt-ruffle-mail-sound-20260917'
$managerPath = Join-Path $root 'Source Flash\src\exitPrompt\ExitPromptManager.as'
$buttonsPath = Join-Path $root 'Source Flash\src\exitPrompt\ExitAllButton.as'
$manager = Get-Content $managerPath -Raw
$buttons = Get-Content $buttonsPath -Raw

if ($manager -notmatch 'import flash\.system\.fscommand;') {
    throw 'Exit prompt must import fscommand for standalone Ruffle.'
}
if ($manager -notmatch 'else\s*\{\s*fscommand\("quit"\);\s*\}') {
    throw 'Exit submit must quit standalone Ruffle when ExternalInterface is unavailable.'
}
if ($manager -notmatch 'ExternalInterface\.call\("closeWindow"') {
    throw 'Browser closeWindow fallback must remain intact.'
}
if ($manager -notmatch 'ExternalInterface\.call\("ExitGameToLogin"') {
    throw 'Desktop ExitGameToLogin integration must remain intact.'
}

if ($buttons -notmatch '_emailBt\.mouseEnabled = true;') {
    throw 'Mailbox row must be clickable.'
}
if ($buttons -notmatch '_emailBt\.addEventListener\(MouseEvent\.CLICK,this\._clickEmailBt\);') {
    throw 'Mailbox row must register its click handler.'
}
if ($buttons -notmatch '(?s)private function _clickEmailBt.*?SoundManager\.instance\.play\("008"\);') {
    throw 'Mailbox row must play the same click sound as mission rows.'
}
Write-Output 'EXITPROMPT_RUFFLE_MAIL_SOUND_SMOKE=PASS'
