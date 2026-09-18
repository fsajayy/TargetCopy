# Changelog

## 1.0.0-beta.3

### Added
- Dedicated TargetCopy Debug panel opened with `/tc debug`.
- Structured diagnostic report for addon/client version, build, interface, API capabilities, Quick Copy state, combat state, current target, and SavedVariables state.
- Debug report Refresh and Select All controls.
- Draggable and closable diagnostics window.

### Changed
- `/tc debug` now opens the dedicated diagnostics panel instead of printing the full diagnostic report to chat.

## 1.0.0-beta.2

### Fixed
- Addon source layout is now aligned with the release packager so tagged builds can be packaged correctly from the repository root.


## 1.0.0-beta.1

### Added
- Public-beta repository structure.
- Copy Name and `/target` generation.
- Raid marker controls and marker clearing.
- Macro builder with automatic per-target macro creation/update (`TC_<TargetName>`).
- Optional draggable floating button.
- Settings for floating-button visibility, lock, and position reset.
- Quick Copy popup independent of the main panel.
- Quick Copy modes: Name only, `/target` command, and Name + `/target`.
- Native WoW key-binding entry for Quick Copy.
- `/tc debug` diagnostics.

### Fixed
- Raid marker controls now use secure action buttons for protected raid-marker actions.
- Raid-marker UI no longer reads protected secret marker values.
- Macro creation now uses target-specific names instead of overwriting a single `TC_Target` macro.
- Quick Copy key binding is registered under its dedicated `Target Copy` category.
- Main-panel macro preview/status spacing.
- Settings now closes when the main TargetCopy panel closes.
- No-target and unavailable-API states are guarded instead of raising UI errors.
