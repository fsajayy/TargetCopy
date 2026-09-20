# TargetCopy Engineering Baseline

**Document:** `docs/ENGINEERING_BASELINE.md`\
**Status:** Authoritative post-publish engineering baseline\
**Published baseline:** `v1.0.0-beta.3`\
**Frozen commit:** `267f858b43d99b46bd868c686a1926796d3c936a`\
**Tag object:** `35f3954c1639eb6e73c74ac97327bc8407cd2434`\
**Runtime target:** WoW Forever 1.60.1 --- Build 69913 --- Interface
16001\
**Next release theme:** `v1.0.0-beta.4` Compatibility Stabilization

------------------------------------------------------------------------

## 1. Purpose and Authority

This document is the single authoritative engineering handoff produced
from the Post-Publish Baseline (PPB) audit of TargetCopy
`v1.0.0-beta.3`.

It consolidates:

-   published baseline identity;
-   package and load architecture;
-   module ownership and dependency observations;
-   public compatibility contract;
-   persistence contract;
-   static and runtime evidence;
-   PPB findings and risk disposition;
-   next-beta scope;
-   release gates;
-   deferred work and handoff rules.

Separate Phase 1/2/3/4 PPB documents are intentionally not required. Git
history should be used to track revisions to this baseline.

### 1.1 Evidence semantics

All engineering claims should use one of these verification states:

-   **STATIC VERIFIED** --- supported by inspection of the frozen
    source/package.
-   **RUNTIME VERIFIED** --- observed directly on the target WoW Forever
    runtime.
-   **RUNTIME NOT TESTED** --- relevant runtime behavior has not been
    directly demonstrated.
-   **NOT APPLICABLE** --- runtime verification is not meaningful for
    the claim.

Additional workflow classifications such as `OBSERVED`, `DEFERRED`,
`ACCEPT`, `EXPERIMENT`, and `FIX` may describe disposition, but they do
not replace the verification state.

### 1.2 Authority rule

> Existence in source does not imply production authority.

The authoritative behavior path is the path actually used by the
published feature. Legacy, stale, experimental, or unreferenced
alternatives must not be treated as production behavior merely because
they exist in the repository.

------------------------------------------------------------------------

## 2. Published Baseline Identity

Published Baseline #1 is immutable for audit purposes.

  Item             Baseline
  ---------------- --------------------------------------------
  Repository       `fsajayy/TargetCopy`
  Published tag    `v1.0.0-beta.3`
  Frozen commit    `267f858b43d99b46bd868c686a1926796d3c936a`
  Tag object SHA   `35f3954c1639eb6e73c74ac97327bc8407cd2434`
  Tag date         `2026-09-18T19:05:26Z`
  Client runtime   WoW Forever 1.60.1
  Build            69913
  Interface        16001

The annotated tag is unsigned. This is recorded as repository metadata
and is not classified as a product defect.

The baseline tag/commit must not be moved or rewritten. Fixes belong in
later versions, beginning with beta.4.

------------------------------------------------------------------------

## 3. Product Scope and Engineering Boundary

TargetCopy's current product path is:

``` text
Target
  ↓
Capture
  ↓
Reuse / Action
```

Current published functionality centers on:

-   acquiring the current target and target name;
-   Quick Copy of target-related text;
-   macro preview and macro creation/update;
-   target and raid-marker macro commands;
-   direct raid-marker UI;
-   settings and persistent UI state;
-   floating access button;
-   diagnostics.

A proposed change should first pass the product gate:

> Does this materially improve Target → Capture → Reuse/Action?

Changes that do not pass this gate should be postponed unless they
address a demonstrated compatibility, reliability, security, packaging,
or maintainability requirement.

------------------------------------------------------------------------

## 4. Package and Load Architecture

### 4.1 Frozen package inventory

``` text
.github/
.gitignore
.pkgmeta
Bindings.lua
Bindings.xml
CHANGELOG.md
Compat.lua
Core.lua
LICENSE
Modules/
  Macro.lua
  Marker.lua
  QuickCopy.lua
  Unit.lua
README.md
RELEASE.md
TargetCopy.toc
UI/
  DebugPanel.lua
  FloatingButton.lua
  MainWindow.lua
  QuickCopyPopup.lua
  Settings.lua
tests/
  validate.py
```

### 4.2 TOC load order

`TargetCopy.toc` declares:

``` text
Core.lua
Compat.lua
Modules\Unit.lua
Modules\Marker.lua
Modules\Macro.lua
Modules\QuickCopy.lua
UI\MainWindow.lua
UI\QuickCopyPopup.lua
UI\FloatingButton.lua
UI\Settings.lua
UI\DebugPanel.lua
Bindings.lua
```

It also declares:

``` text
## Interface: 16001
## SavedVariables: TargetCopyDB
```

### 4.3 Lifecycle orchestration

`Core.lua` owns the main addon lifecycle.

Registered events:

-   `ADDON_LOADED`
-   `PLAYER_LOGIN`
-   `PLAYER_TARGET_CHANGED`
-   `PLAYER_REGEN_DISABLED`
-   `PLAYER_REGEN_ENABLED`

At `ADDON_LOADED`, TargetCopy initializes the DB, restores the
main-window position, and applies floating-button settings.

At `PLAYER_LOGIN`, it refreshes the UI, reapplies floating-button
settings, and prints the loaded message.

Target and combat-state changes refresh the main UI.

The architecture is event-driven. No `OnUpdate` polling loop was
identified in the audited baseline.

**Verification:** STATIC VERIFIED.

------------------------------------------------------------------------

## 5. Module Ownership and Dependency Map

### 5.1 Ownership summary

  -------------------------------------------------------------------------
  Module                    Primary responsibility  Assessment
  ------------------------- ----------------------- -----------------------
  `Core.lua`                lifecycle, DB           ACCEPTABLE
                            initialization, slash
                            routing

  `Compat.lua`              capability/runtime      HEALTHY
                            compatibility helpers
                            and diagnostics

  `Modules/Unit.lua`        safe unit/name/meta     HEALTHY
                            access

  `Modules/Marker.lua`      marker names plus       STALE SURFACE
                            legacy/direct marker
                            helpers

  `Modules/Macro.lua`       macro body generation   HEALTHY
                            and create/update

  `Modules/QuickCopy.lua`   Quick Copy text         HEALTHY
                            generation and trigger

  `UI/MainWindow.lua`       main UI and feature     P2 COUPLING RISK
                            integration

  `UI/QuickCopyPopup.lua`   Quick Copy popup        HEALTHY
                            lifecycle

  `UI/FloatingButton.lua`   reusable floating       HEALTHY
                            launcher and position

  `UI/Settings.lua`         user configuration UI   ACCEPTABLE

  `UI/DebugPanel.lua`       runtime diagnostics     HEALTHY
                            presentation

  `Bindings.lua`            Quick Copy binding      HEALTHY
                            entry point
  -------------------------------------------------------------------------

### 5.2 Dependency observations

``` text
Core
 ├─ UI
 ├─ QuickCopy
 ├─ Settings
 ├─ DebugPanel
 └─ FloatingButton

Compat
 ├─ Unit
 └─ DB

Macro
 ├─ Compat
 └─ DB

QuickCopy
 ├─ Unit
 ├─ QuickCopyPopup
 └─ DB

MainWindow
 ├─ Unit
 ├─ Macro
 ├─ Compat
 ├─ Marker.names
 ├─ Settings
 └─ DB

Settings
 ├─ DB
 ├─ Compat
 ├─ FloatingButton
 └─ UI

Bindings
 └─ QuickCopy
```

No major dependency cycle requiring immediate architectural intervention
was identified.

`MainWindow.lua` is an integration/orchestration hub and carries
elevated responsibility, but no evidence currently justifies a beta.4
decomposition/refactor.

**Verification:** STATIC VERIFIED.

------------------------------------------------------------------------

## 6. Public Compatibility Contract

The following published behavior is compatibility-sensitive and must not
be broken silently.

### 6.1 Commands and UI

-   `/tc`
-   `/targetcopy`
-   `/tc debug`
-   `/tc help`
-   main TargetCopy UI
-   settings access
-   floating button

### 6.2 Target and Quick Copy

-   current-target acquisition;
-   target-name capture;
-   Quick Copy enable/disable behavior;
-   Quick Copy mode behavior;
-   Quick Copy keybind;
-   `target` mode output such as `/target Silvaria`.

### 6.3 Macro behavior

-   macro preview;
-   generated `TC_<Target>` naming behavior;
-   macro creation;
-   existing macro update instead of duplicate creation;
-   body replacement on update;
-   target macro body;
-   `/tm n` marker macro body;
-   target + marker body;
-   macro creation disabled during combat.

### 6.4 Persistent UX

`TargetCopyDB` is an internal implementation object but contains user
state. Therefore it carries a persistence compatibility obligation.

Compatibility-sensitive persisted state includes:

-   Quick Copy settings;
-   main-window position;
-   floating-button enabled/locked/position state;
-   macro icon configuration where used.

Internal functions are not automatically public contracts. In
particular, `Marker:Get()` and `Marker:Set()` are not public
compatibility promises merely because they exist in source.

------------------------------------------------------------------------

## 7. Persistence Contract

### 7.1 beta.3 default shape

``` lua
TargetCopyDB = {
    window = {
        point = "CENTER",
        relativePoint = "CENTER",
        x = 0,
        y = 0,
    },

    floatingButton = {
        enabled = true,
        locked = false,
        point = "CENTER",
        relativePoint = "CENTER",
        x = 250,
        y = 0,
    },

    quickCopy = {
        enabled = true,
        mode = "target",
    },

    macroName = "TC_Target",
    macroIcon = 134400,
}
```

### 7.2 Field status

  Field                                      Status
  ------------------------------------------ -------------------------
  `window.point/relativePoint/x/y`           ACTIVE
  `floatingButton.enabled`                   ACTIVE
  `floatingButton.locked`                    ACTIVE
  `floatingButton.point/relativePoint/x/y`   ACTIVE
  `quickCopy.enabled`                        ACTIVE
  `quickCopy.mode`                           ACTIVE
  `macroIcon`                                ACTIVE READ-ONLY CONFIG
  `macroName`                                STALE PERSISTED FIELD

### 7.3 Initialization semantics

Initialization is:

``` text
ADDON_LOADED
  ↓
InitDB()
  ↓
TargetCopyDB = TargetCopyDB or {}
  ↓
MergeDefaults(defaults, TargetCopyDB)
  ↓
NS.db = TargetCopyDB
```

`NS.db` references the persistent table; it is not intended as a
separate copy.

`MergeDefaults()` is **default hydration**, not a general migration
engine.

Static semantics:

-   correctly-shaped existing scalar values are preserved;
-   missing scalar values are added;
-   nested tables are recursively hydrated;
-   if a default expects a table but the persisted value is not a table,
    the persisted value can be replaced with a table and defaults;
-   unknown persisted keys are preserved.

Therefore:

``` text
MergeDefaults = DEFAULT HYDRATION
Migration     = SCHEMA TRANSFORMATION
Cleanup       = DATA REMOVAL
```

### 7.4 Future schema policy

Pure additive fields can normally use default hydration.

Explicit migration should be introduced when future changes require
operations such as:

-   field rename;
-   field move;
-   type change;
-   persisted-field removal;
-   enum/format transformation;
-   other non-additive schema transformations.

The absence of `schemaVersion` is not classified as a beta.3 defect.
Schema versioning should be introduced when a real non-additive
migration requirement exists.

------------------------------------------------------------------------

## 8. Runtime Compatibility Evidence

Runtime evidence was collected on:

``` text
Addon Version: v1.0.0-beta.3
Client Version: 1.60.1
Build: 69913
Interface: 16001
```

### 8.1 Runtime identity and capabilities

`/tc debug` successfully reported:

-   addon version;
-   client/build/interface;
-   `SetRaidTarget: true`;
-   `CreateMacro: true`;
-   `EditMacro: true`;
-   Quick Copy state;
-   binding;
-   combat state;
-   current target;
-   SavedVariables presence.

API availability is not treated as proof that a particular feature path
works.

### 8.2 Runtime contract matrix

  -----------------------------------------------------------------------
  Contract                Verification            Result
  ----------------------- ----------------------- -----------------------
  Addon load on Forever   RUNTIME VERIFIED        PASS
  1.60.1

  `/tc debug`             RUNTIME VERIFIED        PASS

  Target/name acquisition RUNTIME VERIFIED        PASS

  Quick Copy keybind      RUNTIME VERIFIED        PASS

  Quick Copy `target`     RUNTIME VERIFIED        PASS
  output

  Macro preview           RUNTIME VERIFIED        PASS
  generation

  Create macro            RUNTIME VERIFIED        PASS

  Update existing macro   RUNTIME VERIFIED        PASS

  Duplicate avoided       RUNTIME VERIFIED        PASS
  during update

  Updated macro body      RUNTIME VERIFIED        PASS
  correct

  `/tm n` through chat    RUNTIME VERIFIED        PASS

  Generated `/tm n` macro RUNTIME VERIFIED        PASS
  execution

  Generated target +      RUNTIME VERIFIED        PASS
  marker macro

  Create Macro disabled   RUNTIME VERIFIED        PASS
  in combat

  Direct raid-marker      RUNTIME VERIFIED        **FAIL**
  button

  Marker button changes   RUNTIME VERIFIED        PASS
  macro selection/preview

  Settings write to       RUNTIME VERIFIED        PASS
  runtime DB

  Runtime DB serialized   RUNTIME VERIFIED        PASS
  on normal Exit Game

  Main-window custom      RUNTIME VERIFIED        PASS
  position serialized to
  disk

  Persisted Quick Copy    RUNTIME VERIFIED        **FAIL**
  values restored at
  fresh startup

  Quick Copy persistence  RUNTIME VERIFIED        **FAIL**
  across `/reload`

  Quick Copy persistence  RUNTIME VERIFIED        **FAIL**
  across logout/login

  `Marker:Set()` direct   RUNTIME NOT TESTED      UNREFERENCED
  helper

  `Marker:Get()` helper   RUNTIME NOT TESTED      UNREFERENCED
  -----------------------------------------------------------------------

### 8.3 Direct marker failure boundary

Observed:

``` text
Click marker button
 ├─ direct target marking        FAIL
 └─ selectedMark / preview       PASS
```

Separately:

``` text
/tm n via chat                   PASS
/tm n via generated macro       PASS
/target <name> + /tm n macro    PASS
```

Therefore raid marking is not generally unavailable on the client. The
observed failure is specific to the beta.3 direct secure-marker-button
production path.

Root cause has not yet been established.

### 8.4 SavedVariables divergence

A controlled persistence sequence established:

``` text
Settings changed:
enabled = false
mode    = name
        ↓
/tc debug confirms runtime DB
false / name                     PASS
        ↓
Normal Exit Game
        ↓
TargetCopy.lua on disk
false / name                     PASS
        ↓
Fresh client startup
        ↓
/tc debug runtime DB
true / target                    FAIL
```

While the fresh session was running, the SavedVariables file on disk
still contained `false / name`, while runtime diagnostics reported
`true / target`.

Only one `TargetCopy.lua` was found under the audited
`_classic_beta_\WTF` tree.

Consequently:

-   runtime mutation works;
-   normal-exit serialization works;
-   persisted custom data exists on disk;
-   fresh runtime nevertheless receives/produces default Quick Copy
    state;
-   the divergence occurs on the startup/read side of the lifecycle;
-   exact root cause is **NOT ESTABLISHED**.

Do not classify this as a general "SavedVariables do not save" defect.

------------------------------------------------------------------------

## 9. PPB Findings Register

  -----------------------------------------------------------------------------------
  ID                Finding                       Evidence          Disposition
  ----------------- ----------------------------- ----------------- -----------------
  PPB-01            No schema version/migration   STATIC VERIFIED   ACCEPT for
                                                                    current additive
                                                                    schema; future
                                                                    requirement when
                                                                    needed

  PPB-02 / PPB-15   `macroName` persisted but no  STATIC VERIFIED   DEFER
                    active consumer

  PPB-03 / PPB-14   `Marker:Set()` exists but is  STATIC VERIFIED;  DEFER; may be
                    unreferenced                  runtime not       used only as
                                                  tested            isolated
                                                                    experiment

  PPB-04 / PPB-13   `Marker:Get()` exists but is  STATIC VERIFIED;  DEFER
                    unreferenced                  runtime not
                                                  tested

  PPB-05            Validator primarily           STATIC VERIFIED   DEFER
                    structural/package-oriented

  PPB-06 / PPB-12   `MainWindow.lua` has elevated STATIC VERIFIED   ACCEPT for beta.4
                    integration responsibility

  PPB-07            Modular separation exists     STATIC VERIFIED   ACCEPT

  PPB-08            Event-driven architecture     STATIC VERIFIED   ACCEPT

  PPB-09            No `OnUpdate` polling         STATIC VERIFIED   ACCEPT
                    identified

  PPB-10            Published marker UI uses      STATIC VERIFIED   Implementation
                    secure-action implementation                    exists; runtime
                                                                    path fails

  PPB-11 / PPB-17   Correctly-shaped existing DB  STATIC VERIFIED   ACCEPT
                    values are preserved by
                    `MergeDefaults()`

  PPB-16            `UI.mark` display surface     STATIC VERIFIED   DEFER
                    exists but is cleared during
                    refresh

  PPB-18            Missing DB fields are         STATIC VERIFIED   ACCEPT
                    recursively hydrated

  PPB-19            Wrong-type nested persisted   STATIC VERIFIED   ACCEPT for
                    values can be replaced by                       current schema;
                    defaults structure                              compatibility
                                                                    consideration

  PPB-20            Non-additive future schema    STATIC ANALYSIS   ACCEPT AS POLICY
                    changes require explicit
                    migration/version strategy

  PPB-21            Destructive/transformative    STATIC ANALYSIS   ACCEPT AS POLICY
                    migration requires
                    rollback/downgrade policy

  PPB-22            Unknown persisted keys        STATIC VERIFIED   ACCEPT
                    survive default hydration

  PPB-23            Direct raid-marker button     RUNTIME VERIFIED  **P1 ---
                    does not mark target                            EXPERIMENT →
                                                                    FIX**

  PPB-24            Persisted DB state diverges   RUNTIME VERIFIED  **P1 ---
                    from runtime state on                           EXPERIMENT; fix
                    startup/reload/login                            only after root
                                                                    cause**

  PPB-25            Settings window observed as   RUNTIME VERIFIED  DEFER
                    non-draggable/stuck
  -----------------------------------------------------------------------------------

------------------------------------------------------------------------

## 10. Risk Disposition

### 10.1 PPB-23 --- Direct Raid Marker

**Priority:** P1\
**Disposition:** `EXPERIMENT → FIX`\
**Target:** next beta

The experiment must isolate relevant paths rather than immediately
replacing production code:

``` text
A. SecureActionButtonTemplate + raidtarget
B. direct SetRaidTarget("target", n)
C. /tm n command mechanism
```

`Marker:Set()` being present does not authorize it as the replacement.
It remains runtime-untested until explicitly demonstrated.

Acceptance contract:

``` text
Click Star
→ target receives Star
→ selectedMark = 1
→ preview uses /tm 1

Click Skull
→ target receives Skull
→ selectedMark = 8
→ preview uses /tm 8

Clear
→ target marker removed
```

Existing macro-builder behavior must remain regression-PASS.

### 10.2 PPB-24 --- SavedVariables startup/load divergence

**Priority:** P1\
**Disposition:** `EXPERIMENT`\
**Fix authorization:** only after root cause is established.

Minimum instrumentation should observe:

``` text
SavedVariables file
       ↓
addon loading
       ↓
ADDON_LOADED
       ↓
TargetCopyDB BEFORE InitDB()
       ↓
MergeDefaults()
       ↓
TargetCopyDB AFTER InitDB()
       ↓
PLAYER_LOGIN
```

At each relevant checkpoint, record whether the table exists and the
values of:

``` text
quickCopy.enabled
quickCopy.mode
```

Do not use the following as speculative fixes:

-   adding `schemaVersion`;
-   deleting/resetting `TargetCopyDB`;
-   force-writing SavedVariables;
-   replacing `MergeDefaults()` without evidence;
-   cleaning stale `macroName`;
-   unrelated persistence/schema redesign.

### 10.3 Lower-priority findings

The following do not belong in the beta.4 compatibility-fix scope unless
new evidence changes their risk:

-   `MainWindow.lua` decomposition;
-   `Marker:Get()` cleanup;
-   `Marker:Set()` cleanup;
-   `macroName` removal;
-   `UI.mark` cleanup;
-   general validator expansion;
-   Settings-window drag UX fix;
-   broad DB/schema cleanup.

------------------------------------------------------------------------

## 11. beta.4 Compatibility-Stabilization Scope

`v1.0.0-beta.4` should be a compatibility-stabilization release, not an
architecture rewrite.

### In scope

``` text
P1 — Raid Marker compatibility
 ├─ isolate failing mechanism
 ├─ test viable compatible path
 ├─ establish root cause/mechanism
 └─ fix after evidence

P1 — SavedVariables startup/load
 ├─ lifecycle instrumentation
 ├─ identify divergence point
 └─ fix only after root cause

Regression
 ├─ Quick Copy
 ├─ Create Macro
 ├─ Update Macro
 ├─ /tm macro
 ├─ Target + Mark macro
 └─ combat restriction
```

### Explicitly out of scope

``` text
MainWindow refactor
DB cleanup
macroName removal
Marker module cleanup
schema redesign without demonstrated need
UI.mark cleanup
unrelated Settings redesign
unrelated new features
```

If one of these becomes necessary to resolve a P1 root cause, that
dependency must be demonstrated explicitly before scope is expanded.

------------------------------------------------------------------------

## 12. beta.4 Release Gate

beta.4 must not be published solely because a patch appears correct by
inspection.

### Gate A --- Direct marker

Required runtime evidence:

-   Star direct click marks target;
-   Skull direct click changes marker;
-   Clear removes marker;
-   marker selection still updates preview;
-   Mark macro still works;
-   Target + Mark macro still works.

### Gate B --- Persistence

First establish the PPB-24 divergence point.

If the fix belongs in TargetCopy, verify at minimum:

``` text
Set:
enabled = false
mode    = name

/reload
→ persisted as expected

Logout → Login
→ persisted as expected

Exit Game → fresh startup
→ persisted as expected
```

Disk inspection may be used as supporting evidence when needed.

### Gate C --- Regression

The following published beta.3 behaviors must remain functional:

-   `/tc`;
-   `/tc debug`;
-   target/name capture;
-   Quick Copy keybind;
-   `/target <name>` Quick Copy output;
-   macro preview;
-   Create Macro;
-   update existing macro;
-   no duplicate macro on update;
-   correct replacement body;
-   generated `/tm n` macro;
-   generated target + marker macro;
-   Create Macro disabled in combat.

### Gate D --- Scope control

Review the beta.3 → beta.4 diff. Every material change must be
explainable by compatibility stabilization or a demonstrated dependency.

Unrelated refactors, cleanup, redesign, and features should not be
bundled into the release.

### Gate E --- Evidence quality

Final release claims must use:

-   `STATIC VERIFIED`;
-   `RUNTIME VERIFIED`;
-   `RUNTIME NOT TESTED`;
-   `NOT APPLICABLE`.

API/function availability alone is insufficient evidence of feature
correctness.

------------------------------------------------------------------------

## 13. Deferred and Out-of-Scope Work

The following remain intentionally deferred:

### Architecture

`MainWindow.lua` is a coupling risk, not a demonstrated beta.4 blocker.
Refactor only when there is a concrete maintainability or
feature-delivery reason.

### Marker legacy/internal surface

`Marker:Get()` and `Marker:Set()` are unreferenced in the published
runtime source path. Do not delete or promote them without a separate
decision.

### Persistence cleanup

`macroName` is stale persisted state. Do not remove it as incidental
cleanup during PPB-24 investigation.

### Schema evolution

No schema migration framework is required merely for completeness.
Introduce one when a real non-additive persisted-schema change requires
it.

### UI cleanup

`UI.mark` and the non-draggable Settings window are lower-priority
findings. They should not expand beta.4 unless evidence establishes a
stronger product or compatibility impact.

### Test infrastructure

`tests/validate.py` currently provides structural/package validation.
Behavioral test expansion is desirable but deferred from the P1
compatibility investigation unless a small regression test directly
protects a beta.4 fix.

------------------------------------------------------------------------

## 14. Engineering and Handoff Rules

### 14.1 Branch discipline

Preferred development flow:

``` text
main
  └─ publish-quality

dev
  └─ integration/testing

feature/*
  └─ isolated experiments or implementation work
```

### 14.2 Change discipline

For compatibility-sensitive work:

1.  identify the affected public/persistent contract;
2.  establish current evidence;
3.  reproduce the failure;
4.  isolate the mechanism;
5.  prototype the smallest viable change;
6.  runtime-test on WoW Forever 1.60.1;
7.  regression-test already verified behavior;
8.  merge only after evidence supports the change.

### 14.3 Runtime discipline

Runtime authority is actual WoW Forever 1.60.1 behavior.

Static inspection can establish implementation facts but cannot
substitute for runtime evidence where client behavior, protected
actions, API compatibility, persistence lifecycle, or combat
restrictions are involved.

### 14.4 Performance discipline

Maintain:

-   event-driven behavior over polling;
-   no `OnUpdate` loop without demonstrated need;
-   no repeated unnecessary frame creation;
-   reusable frames;
-   bounded diagnostics/logging;
-   minimal work on target-change events;
-   modules inactive until needed where practical.

### 14.5 Baseline discipline

The beta.3 tag/commit is the immutable published reference for this PPB.

Do not rewrite historical evidence to match later fixes. beta.4 evidence
should be recorded as new evidence against the new release candidate.

------------------------------------------------------------------------

## 15. Current Engineering Checkpoint

PPB Phase 1 - Read-Only Baseline Audit             PASS
PPB Phase 2 - Dependency / Call-Graph Audit        PASS / CLOSED
PPB Phase 3 - Compatibility & Persistence          CLOSED
PPB Phase 4 - Risk Disposition & Next-Beta Plan    CLOSED

Published baseline
v1.0.0-beta.3 / 267f858b43d99b46bd868c686a1926796d3c936a

PPB-23 - Raid Marker Compatibility
- RUNTIME VERIFIED compatibility failure in published direct-marker path
- direct SetRaidTarget path blocked by client protection
- secure experiments did not establish a safe direct action
- normal player-created /tm macros work
- beta.4 uses marker selection for generated macros

PPB-24 - SavedVariables Persistence
- RUNTIME VERIFIED load/persistence divergence
- runtime settings mutation and disk serialization work
- persisted TargetCopyDB is unavailable before initialization
- MergeDefaults eliminated as reset cause
- deferred PLAYER_LOGIN initialization also failed
- no TargetCopy persistence hack adopted
- treated as a WoW Forever client compatibility limitation

Beta.4 implementation
- SavedVariables lifecycle diagnostics integrated into /tc debug
- PPB PowerShell harness added
- direct marker controls replaced by macro marker selection
- macro workflow simplified to target + optional marker
- compact native marker selector added
- Quick Actions clarified
- main window layout polished
- optional Custom Macro mode added
- final beta.4 regression gate: 9/9 PASS

Implementation checkpoints
0f9f9de - compatibility diagnostics and PPB harness
d5acd7f - macro-based marker selection
d2d3556 - simplified macro workflow and marker selector
f62a2dc - Quick Actions refinement
e7f71a2 - compact main window
4164393 - optional Custom Macro preview

Release disposition
- v1.0.0-beta.3 remains the immutable published baseline
- beta.4 feature implementation is CLOSED
- beta.4 release preparation is ACTIVE
- beta.4 has not yet been tagged or published

The Post-Publish Baseline audit is closed. The beta.4 implementation and
final regression gate are complete. PPB-23 and PPB-24 remain documented
compatibility constraints unless new runtime evidence changes them.
