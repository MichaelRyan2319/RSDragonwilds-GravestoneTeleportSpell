# Gravestone Teleport for RuneScape: Dragonwilds

A spell mod for RuneScape: Dragonwilds: teleport to your gravestone, the spot
where you last died. It runs on the
[Spell Framework](https://github.com/MichaelRyan2319/RSDragonwilds-SpellFramework).

It adds one spell to the Spellbook, under **Custom Spells**:

| Spell | What it does | Runes | Cooldown |
| --- | --- | --- | --- |
| **Gravestone Teleport** | Teleports you to your newest gravestone in this world. You arrive 1.5 m from it, facing it. | none | 10 s |

- It costs no runes on purpose. When you die your runes are in the gravestone,
  so a rune cost would stop you casting it exactly when you need it.
- Nothing is cast, and no cooldown starts, when you have no gravestone or are
  already standing at it.
- The teleport is the game's own (the one Home Teleport and the lodestones
  use), with its loading screen, so the world around the gravestone is loaded
  before you arrive.
- Once you empty a gravestone the game removes it, and the spell has nowhere to
  take you until you die again.
- Works in your own world (single player, or as the host).
- Your saves stay valid with or without the mod. See the Spell Framework's
  README for how.
- Doesn't change any world settings, so achievements keep working.

## Requirements

- [UE4SS for RuneScape: Dragonwilds](https://github.com/MichaelRyan2319/RSDragonwilds-UE4SS)
- [Spell Framework](https://github.com/MichaelRyan2319/RSDragonwilds-SpellFramework).
  With 2.0.0 or later the spell checks for a gravestone before anything
  happens. With an older version the cast animation plays first, and you are
  told afterwards if there is no gravestone.

## Install with Mod Loader

[Mod Loader](https://github.com/MichaelRyan2319/ModLoader) installs the mod and
keeps it up to date.

1. **Add game** and pick RuneScape: Dragonwilds. Mod Loader 1.0.1 or later sets
   the mods folder to the game's inner `RSDragonwilds` folder (the one with
   `Binaries` and `Content` in it).
2. **Add mod** `MichaelRyan2319/RSDragonwilds-GravestoneTeleportSpell`. Mod
   Loader 1.1.0 or later offers to add UE4SS and the Spell Framework as well;
   click **Yes**. With an older Mod Loader, add
   `MichaelRyan2319/RSDragonwilds-UE4SS` and
   `MichaelRyan2319/RSDragonwilds-SpellFramework` yourself first.
3. Start the game and load your world.

## Install by hand

1. Install UE4SS and the Spell Framework (see Requirements).
2. Download `GravestoneTeleportSpell.zip` from the [Releases](../../releases)
   page and extract it into the game's `RSDragonwilds` folder (the one with
   `Binaries` and `Content` in it). In Steam, right-click RuneScape:
   Dragonwilds > Manage > Browse local files to find it. The spell ends up in
   `Binaries\Win64\ue4ss\Mods\SpellFramework\Spells\` as
   `GravestoneTeleport.lua`.
3. Start the game and load your world.

## Using it

1. Press **P** to open the Spellbook, open **Custom Spells** and drag
   Gravestone Teleport into a slot of the spell radial.
2. Press **Q** to open the spell radial and cast it. The Home Teleport
   animation plays, and partway through it you are taken to your gravestone.
   With several gravestones you go to the newest; take what's in it and cast
   again for the one before.

The numbers are at the top of the spell file: how far from the gravestone you
arrive (`LAND_BESIDE`), and the moment in the animation at which you leave
(`CAST_POINT`). The cooldown is the `cooldown` line further down. An update
replaces the file, so change them again after an update.

## Uninstall

Remove it in Mod Loader, or delete `GravestoneTeleport.lua` from
`Win64\ue4ss\Mods\SpellFramework\Spells\`. A radial slot that held it shows
Siphon Runes.
