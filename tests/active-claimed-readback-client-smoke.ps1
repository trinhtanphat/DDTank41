$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$source = Get-Content (Join-Path $root 'Source Flash\src\activeEvents\view\ActiveSubContent.as') -Raw

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}

Require ($source.Contains('private var _stateLoader:BaseLoader;')) 'state loader field missing'
Require ($source.Contains('this.requestClaimState();')) 'info setter does not request persisted state'
Require ($source.Contains('UserGetActiveState.ashx')) 'state endpoint loader missing'
Require ($source.Contains('_loc1_["activeID"] = this._info.ActiveID;') -or
         $source.Contains('_loc2_["activeID"] = this._info.ActiveID;')) 'activeID is not sent'
Require ($source.Contains('__onStateLoadComplete')) 'state completion handler missing'
Require ($source.Contains('__onStateLoadError')) 'state error handler missing'
Require ($source.Contains('String(_loc3_.@activeID)') -or
         $source.Contains('int(_loc3_.@activeID)')) 'response activeID stale guard missing'
Require ($source.Contains('this._info.isAttend = String(_loc3_.@isAttend).toLowerCase() == "true";')) 'persisted isAttend is not applied'
Require ($source.Contains('this.updateContainer();')) 'UI is not refreshed after readback'
Require ($source.Contains('this._stateLoader.removeEventListener')) 'state loader listeners are not cleaned up'
Require ($source.Contains('this._stateLoader = null;')) 'state loader reference is not released'

Write-Output 'ACTIVE_CLAIMED_READBACK_CLIENT_SMOKE=PASS'
