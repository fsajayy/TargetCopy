# TargetCopy

TargetCopy is a compact utility addon for **World of Warcraft: Forever**.

## Features

- Copy the current target's name.
- Generate `/target <name>`.
- Assign or clear raid target markers.
- Build Target / Mark / Target + Mark macros.
- Create or update the `TC_Target` macro automatically.
- Optional draggable floating `TC` button.
- Optional **Quick Copy** popup with a WoW key binding.
- Quick Copy modes:
  - Name only
  - `/target` command
  - Name + `/target`
- Runtime diagnostics with `/tc debug`.

## Quick Copy

Quick Copy intentionally does not open the main panel. It shows a small edit box,
selects the generated text, and waits for `Ctrl+C`.

The addon does **not** claim direct OS clipboard access. After detecting Ctrl+C it
shows brief feedback and closes. Enter/Escape close immediately; idle popup closes
after 10 seconds.

### Key binding

Go to WoW's Key Bindings UI and find **TargetCopy > Quick Copy current target**.

A default `Ctrl+Alt+C` binding is intentionally **not forced programmatically** in
this public beta, because overriding a player's existing key binding is undesirable.
Set `Ctrl+Alt+C` there if it is free.

## Commands

- `/tc` — toggle main window
- `/tc settings` — open settings
- `/tc quick` — invoke Quick Copy
- `/tc reset` — reset window/floating-button positions
- `/tc debug` — diagnostics
- `/tc help`

## Bug reports

Please include:

1. TargetCopy version
2. WoW Forever client/interface version
3. `/tc debug` output
4. Lua error text, if any
5. Steps to reproduce

## Development

`main` is intended for tested/stable code. Use a development branch for active work.
Tagged versions are packaged by GitHub Actions using the BigWigsMods packager.

See `RELEASE.md`.
