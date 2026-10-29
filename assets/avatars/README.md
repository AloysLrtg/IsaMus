# Avatar artwork contract

Transparent PNGs, **400 × 500 px**, same origin and scale for every layer.
Never crop each body part separately: the stack uses the full canvas.

Paint order (back to front):
1. `background_0.png` to `background_5.png` (optional, may be opaque; palette fallback fills the entire circle)
2. `skin_0.png` to `skin_2.png` (ears, head, neck and bust)
3. `top_0.png` to `top_2.png` (clothes on the lower bust)
4. Independent facial components: `eyes_normal.png`, `mouth_normal.png`, `brows_normal.png` (transparent elsewhere; replaces the former combined `face_0.png`)
5. `hair_0.png` to `hair_2.png` (neutral white/grayscale shapes; tinted independently with hair_color using BlendMode.modulate)
6. `glasses_0.png` to `glasses_2.png` (`0` is fully transparent: no glasses)

PlayerAvatarView loads each image independently with Image.asset; a missing or
unreadable PNG gets a code-drawn placeholder **for that layer only**. Importing
these files requires no widget changes. This folder is registered in pubspec.
`currentSign` swaps only the relevant facial component for two seconds, with no
emoji overlay. Supported replacement PNGs: `mouth_bite.png` (2 Rois),
`mouth_tongue.png` (2 As), `mouth_side.png` (Mediak), `mouth_both_sides.png`
(Dobliak / 29), `eyes_wink.png` (30 / 31), `brows_raised.png` (Jeu).
Each PNG uses the same full 400 × 500 transparent canvas; do not include skin,
hair or glasses in facial files. Missing components animate with code-drawn
mouths, eyelids and eyebrows. Adding each PNG automatically replaces its fallback.
Expressions are transient and do not change the persistent appearance JSON `{skin,hair,glasses,top,background_color,hair_color,border,exclusive_hat}`.

The full view is clipped to a circle matching the speech timer. Portrait layers
retain their 4:5 proportions inside that square, while the background fills it.
Palette IDs background_color and hair_color range from 0 to 5; the four shape IDs
still range from 0 to 2. Existing four-field configurations use background 0 and
the previous cut-dependent hair tint when read.


League rewards add `border` (`none`, `bronze`, `silver`, `gold`, `diamond`)
and `exclusive_hat` (`none`, `txapela`, `crown`). Borders are code-drawn rings;
optional hats load `hat_txapela.png` / `hat_crown.png` above the portrait.
Hat files use a transparent **square** canvas aligned with the final circular
avatar (unlike the 4:5 portrait layers); place artwork in the top third.
Missing hat files use vector fallbacks. Persistent reward selections require
inventory ownership on the server. The editor keeps facial expressions separate.
