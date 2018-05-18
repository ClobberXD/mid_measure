# Mid-Measure [mid_measure] (v1.0)

Mid-Measure is a Minetest mod which can be used for quickly calculating the distance (in all three axes) between two nodes, and ascertaining their mid-point, both of which are displayed in the chat (as of now; refer to TODO section below)

The calculations are performed right after pos2 has been marked, and if auto-reset has been enabled, will reset after the configured number of seconds.

Partly inspired by [Minetest-WorldEdit](https://github.com/Uberi/Minetest-WorldEdit)

#### License: MIT

#### Mod Dependencies: default (optional; see below)

#### Custom settings
- `mid_measure.auto_reset` - Auto-reset duration. Accepts a value of `n` seconds, where `0 <= n <= 3600`. If `n==0`, auto-reset is disabled (not recommended for server environments).
- `mid_measure.enable_crafting` - Enables crafting (disabled by default) of marker tool if true. The craft-recipe depends on `default` mod.

#### How does this work?
- Mark the first node by either of the two methods given below:
  - Standing on a node and typing `/mark1`.
  - Left-clicking on a node with the Marker.
- Mark the second node by either of the two methods given below:
  - Standing on a node and typing `/mark2`.
  - Left-clicking on another node with the Marker.
- The distance will automatically be calculated after marking the second node, and the mid-point will be highlighted as well.
- Click on pos1 / pos2 / mid-point or type `/reset_mark` to manually reset at anytime.

#### Craft-recipe for marker tool
The craft-recipe is quite simple actually. It's very similar to the recipe for torches, but the coal lump is replaced by a mese crystal fragment here.
```
[Mese Crystal fragment]
        [Stick]

```

#### TODO
- [ ] Re-implement mod using HUD elements to output distance and mid-point co-ords.