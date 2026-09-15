# Projectile Rendering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the `game.view.Bomb.target` / `EventDispatcher.target` collision so projectile flight and downstream damage rendering execute under Ruffle 0.6.0.

**Architecture:** Keep packet decoding and ballistic physics unchanged. Rename only the Bomb impact-point accessor and its call sites, then rebuild/deploy the Flash artifact and verify with a fresh authenticated Ruffle shot.

**Tech Stack:** ActionScript 3, Ruffle 0.6.0, IIS runtime assets.

**Spec:** `docs/superpowers/specs/2026-09-14-projectile-rendering-design.md`

## Global Constraints
- Do not change projectile packet layout or server damage logic.
- Keep resource URLs local to `103.9.156.182/Gunny/`.
- Runtime proof requires no fresh `#1074 ... game.view.Bomb` after a shot.

### Task 1: Rename the colliding accessor
**Files:** Modify `Bomb.as`, `SimpleBomb.as`, `GameView.as`, `ShockMapAnimation.as`, and `NewHandFightHelpAction.as`; maintain `tests/projectile-target-smoke.ps1`.
- [ ] Write a failing source-contract test that rejects `function get target()` in `Bomb.as` and requires `impactTarget` call sites.
- [ ] Run it and confirm RED on the current source.
- [ ] Rename getter `target` to `impactTarget`; update `Bomb(...).target` references to `.impactTarget`.
- [ ] Re-run the contract test and `git diff --check`; both must PASS.
- [ ] Commit `fix(flash): avoid Bomb target collision on Ruffle`.

### Task 2: Runtime verification
- [ ] Build the existing Flash client using the available project compiler/toolchain; if the repo cannot compile on 182, patch the deploy artifact only through a reproducible SWF tool and record the command.
- [ ] Deploy the rebuilt artifact to the live Gunny web root with a timestamped backup.
- [ ] Launch a fresh authenticated game, fire at least one shot, and verify projectile travel plus absence of `#1074` in the new Ruffle log segment.
- [ ] Verify IIS returns projectile/blast assets HTTP 200 and the client shows impact/damage again.