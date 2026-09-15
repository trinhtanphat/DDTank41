# Projectile Rendering Fix Design

## Problem
Authenticated Ruffle 0.6.0 sessions fail every `playerShoot` with `ReferenceError #1074: Illegal write to read-only property target on game.view.Bomb`. IIS proves projectile and blast SWFs are present and return HTTP 200, so this is not a missing-resource failure.

## Root cause
`game.view.Bomb` extends `flash.events.EventDispatcher` and exposes a public getter named `target`. Ruffle's `EventDispatcher` has an internal private `target` slot initialized by its constructor. The subclass accessor collides with that slot under AVM2/Ruffle and constructor initialization resolves to the read-only accessor.

## Design
Rename the projectile impact accessor from `target` to `impactTarget`. Update every projectile impact consumer from `Bomb.target` to `Bomb.impactTarget`, including `GameView`, `ShockMapAnimation`, and `NewHandFightHelpAction`. Do not alter packet decoding, ballistic physics, server damage, or projectile resource paths.

## Success criteria
- No `#1074 ... game.view.Bomb` on a fresh authenticated shot.
- A shot creates and renders the projectile trajectory.
- Existing impact-point consumers still receive the same `Point` result.
- Client source scan contains no `Bomb(...).target` usage.
- Build/deploy artifact preserves current local resource URLs.