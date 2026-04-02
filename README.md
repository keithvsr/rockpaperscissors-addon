# Rock Paper Scissors (RPS)

World of Warcraft addon: challenge guildmates to rock–paper–scissors; results are tracked per character.

## Requirements

- Client version matching the `## Interface` line in [`RPS.toc`](RPS.toc) (currently Classic-era).

## Installing from a release or clone

1. Put the addon folder **`RPS`** under your game’s `Interface/AddOns` directory (path varies by install; the folder name must stay `RPS`).
2. Restart the client or `/reload`, then enable **Rock Paper Scissors** in the AddOns list.

If you use the zip from a build, unzip so you get `AddOns/RPS/...` (not `AddOns/some-other-name/RPS`).

## Building

From the repo root (bash/zsh):

```sh
./build.sh
```

This writes:

- `dist/RPS/` — copy-paste-ready addon tree  
- `dist/RPS.zip` — same contents, archived for sharing  

`dist/` is intended as build output only.

## Usage (in game)

Slash command: **`/rps`**

Examples:

- `/rps challenge <player>` — challenge someone  
- `/rps accept` / `/rps decline` — respond to a challenge  
- `/rps rock` / `/rps paper` / `/rps scissors` — throw after a match is active  

Run `/rps` with no arguments for the full usage line.
