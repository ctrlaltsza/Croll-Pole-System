## Join Croll Studios !! - discord.gg/DBqCZjZ8VN

# Qbox Stripper Pole Resource

A professional FiveM/Qbox resource built for immersive nightclub and adult entertainment roleplay. This script adds interactive stripper pole dancing, animated cash throwing, and a progression-based money cleaning system designed to feel polished, server-friendly, and easy to integrate into existing Qbox servers.

## Features

- Interactive stripper pole dancing with restricted job access support.
- Pole-based checks that require an active dancer before players can throw or clean money.
- Cash roll and cash band interactions through the pole menu.
- Money-throwing animation when players toss bands or rolls.
- Progression-based roll cleaning system tied to each character.
- Server-side item validation for cleaner and more secure handling.
- Configurable pole locations, jobs, item names, and payout values.
- Built for Qbox with ox_lib, ox_target, and ox_inventory support.

## Cleaning Progression

Cash roll cleaning progresses per character and increases as more rolls are cleaned:

- 1st roll: $60
- 2nd roll: $65
- 3rd roll: $75
- 4th+ roll: $80

This creates a more rewarding system over time instead of using a flat payout for every interaction.

## Dependencies

- qbx_core
- ox_lib
- ox_target
- ox_inventory

## Installation

1. Add the resource to your server.
2. Make sure all dependencies are installed and started.
3. Update your `fxmanifest.lua`, `config.lua`, `client.lua`, and `server.lua` files.
4. Confirm your inventory includes the required items such as `cashroll`, `cashband`, and your clean money item.
5. Ensure the resource starts after its dependencies in your server config.

## Configuration

The resource is configurable for:

- Allowed jobs
- Pole locations
- Prop spawning or zone-based targeting
- Item names
- Clean money payout values
- Roll progression values

## Notes

This resource is intended for roleplay servers that want a more immersive and interactive nightclub system. The included progression and server-side validation help create a better gameplay loop while keeping interactions controlled and consistent.
