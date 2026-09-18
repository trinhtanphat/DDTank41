$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

$controller = Get-Content (Join-Path $root 'Source Flash\src\farm\FarmModelController.as') -Raw
$selector = Get-Content (Join-Path $root 'Source Flash\src\farm\viewx\ManureOrSeedSelectedView.as') -Raw
$mainView = Get-Content (Join-Path $root 'Source Flash\src\farm\viewx\FarmMainView.as') -Raw
$socket = Get-Content (Join-Path $root 'Source Flash\src\ddt\manager\GameSocketOut.as') -Raw

if ($controller -notmatch 'public var pendingSeedTemplateId:int = 0') {
    throw 'Missing pending seed state used by the Ruffle click-to-plant flow.'
}
if ($selector -notmatch 'pendingSeedTemplateId = this\._currentCell\.itemInfo\.TemplateID') {
    throw 'Seed selection still does not publish the selected seed.'
}
if ($selector -match 'this\._currentCell\.dragStart\(\);\s*if\(this\._type == SEED\)') {
    throw 'Seed selection still depends on Flash dragStart, which regresses Ruffle planting.'
}
if ($mainView -notmatch 'pendingSeedTemplateId > 0') {
    throw 'Farm field click does not consume the selected seed.'
}
if ($mainView -notmatch 'sowSeed\(_loc7_\.info\.fieldID,FarmModelController\.instance\.pendingSeedTemplateId\)') {
    throw 'Farm field click does not send the seed packet.'
}
if ($socket -notmatch 'writeByte\(FarmPackageType\.GROW_FIELD\)') {
    throw 'Farm seed packet opcode is missing.'
}
if ($socket -notmatch '(?s)writeByte\(13\).*?writeInt\(param2\).*?writeInt\(param1\)') {
    throw 'Farm seed packet payload order no longer matches the server handler.'
}

Write-Output 'FARM_RUFFLE_CLICK_PLANT=PASS'
