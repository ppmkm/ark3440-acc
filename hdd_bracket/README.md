# ARK-3440 internal 2.5" SSD bracket

Flat plate carrying a 2.5" SSD on 4 snap-in studs for rubber shock absorbers (grommets).
Sized for Goodram CX400 gen.2 512 GB (SSDPR-CX400-512-G2), 100.00 x 69.85 x 7.00 mm.

Files: `ark3440_ssd_bracket.scad` (parametric source), `ark3440_ssd_bracket.stl`,
`preview.png` (stud side; grey block = drive).

## Geometry
| Item | Value |
|---|---|
| Plate | 100 x 95 x 3 mm, R5 corners |
| Drive holes | 4x M3 clearance 3.4 mm, 90 deg countersink 6.4 mm, from stud side |
| Studs | 4x, rectangular pattern 85 x 70 mm, centred on drive |
| Stud section 1 (base) | dia 10.0, h 6.5 |
| Stud section 2 (neck) | dia 5.0, h 6.5, split |
| Stud section 3 (lock) | half-sphere dia 7.0 flattened to h 3.0, split |
| Split | 1.2 mm vertical slot through sections 2+3 (`slot_w`, `slot_angle`) |
| Overall height | 19.0 mm (plate + stud) |

## Stud pattern orientation
The 85 mm pitch runs across the drive width (Y), 70 mm along the length (X)
(`long_across_width = true`). With the opposite orientation each stud base (dia 10) overlaps a
drive screw countersink by 3.6 mm; the model aborts with an assertion in that case.

## Assumptions - verify before printing
1. Drive bottom holes: 61.71 mm across, 76.60 mm along, first hole 14.00 mm from the front face
   (end opposite the SATA connector). These are recalled SFF-8201 values, not taken from the
   standard. Measure the drive and edit `bot_hole_*`.
2. The stud pattern is centred on the drive.
3. Studs point away from the drive; the drive face of the plate is flat.

## Assembly
1. Drive against flat face of plate, 4x M3 x 6 countersunk (ISO 10642 / 7046) from the stud
   side: 3 mm thread engagement into drive.
2. Press studs into grommets; split halves close while the dia 7 head passes through, then spring back.

## Print
- Material: PETG, ASA or PC (not PLA: enclosure interior can exceed ~55 C).
- Orientation as modelled: drive face on bed, studs up, no supports
  (head underside overhang 1 mm radial).
- 0.2 mm layers or finer on studs, >= 3 perimeters, 100 % infill on studs
  (neck halves are 1.9 mm wide). Neck strength across layer lines is the weak point; if studs
  break, increase `s2_d` / reduce `slot_w`, or print the plate on edge.

## Regenerate
```
openscad -o ark3440_ssd_bracket.stl ark3440_ssd_bracket.scad
```
