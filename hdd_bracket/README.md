# ARK-3440 internal 2.5" SSD tray

Printable carrier for the internal fixed drive position of the Advantech ARK-3440
(drive screwed to the bottom cover, PCB side towards the cover, thermal pad on cover;
user manual sec. 2.6.1). Sized for Goodram CX400 gen.2 512 GB (SSDPR-CX400-512-G2),
100.00 x 69.85 x 7.00 mm.

Files: `ark3440_ssd_tray.scad` (parametric source), `ark3440_ssd_tray.stl`, `preview.png`
(transparent block = drive).

## Geometry
| Item | Value |
|---|---|
| Tray outline | 102.6 x 74.45 x 7.1 mm |
| Floor | 1.6 mm, window ~60 x 52 mm for thermal pad |
| Side walls | 2.0 mm, 4x M3 side holes, 0.8 mm counterbore |
| Drive top above cover | 8.6 mm (internal limit 12.8 mm per A2 datasheet) |
| Connector end | open, floor edge chamfered for cable bend |

## Assumptions - verify before printing
1. **Hole pattern** uses SFF-8201 values from memory, not from the standard text:
   side holes 14.00 / 90.60 mm from front face, 3.00 mm above bottom; bottom holes
   4.07 mm from side edges (61.71 mm pitch) at 14.00 / 90.60 mm. Measure the CX400 with
   calipers and edit `side_hole_x`, `side_hole_z`, `bot_hole_x`, `bot_hole_y`.
2. **Cover holes coincide with the drive bottom holes** (stock screws go cover -> drive).
   Not confirmed by any drawing. If they do not, set `cover_through = false` and fix the
   tray to the cover otherwise.
3. Free space around the drive on the cover is unknown; tray adds 2.3 mm per side in Y
   and 2.0 mm at the front end. Check for bosses/ribs; reduce `wall_t` or disable
   `end_stop` if needed.

## Assembly
1. Drive into tray, label/PCB side down, SATA connector at the open end.
2. 4x M3 x 4 side screws (max 3 mm thread into drive).
3. Thermal pad on cover; thickness >= 2.0 mm (floor 1.6 + 0.4 compression) so it reaches
   the drive through the window.
4. Cover screws: stock length + 1.6 mm (e.g. M3 x 4 -> M3 x 6 if the stock are M3 x 4);
   do not exceed 3 mm engagement in the drive bottom threads.

## Print
- Material: PETG, ASA or PC. Not PLA: fanless enclosure interior can exceed its ~55 C
  softening point.
- Floor down, no supports. 0.2 mm layers, >= 4 perimeters, 40 % infill.
- Check hole diameters after printing; ream to 3.4 mm if undersized.

## Regenerate
```
openscad -o ark3440_ssd_tray.stl ark3440_ssd_tray.scad
```
