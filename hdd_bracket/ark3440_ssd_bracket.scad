// ARK-3440 internal 2.5" SSD bracket - flat plate on 4 shock-mount studs
// Target drive : Goodram CX400 gen.2 512 GB (SSDPR-CX400-512-G2), 100.00 x 69.85 x 7.00 mm
// Drive is screwed to the plate through its 4 bottom holes (countersunk M3 from stud side).
// Studs snap into rubber shock absorbers (grommets) in the chassis.
//
// Frame: X = drive length (0 = drive front face, end opposite SATA connector),
//        Y = drive width (0 = drive centreline),
//        Z = up; Z = 0 is the drive-side face of the plate, studs point +Z.
// Print as modelled: drive face on the bed, studs up, no supports.
// All dimensions in mm.

/* [Drive] */
drive_l   = 100.00;
drive_w   = 69.85;
drive_h   = 7.00;

/* [Drive bottom holes, SFF-8201 - VERIFY ON YOUR DRIVE] */
bot_hole_pitch_x = 76.60;   // along length
bot_hole_pitch_y = 61.71;   // across width (4.07 from each edge)
bot_hole_front   = 14.00;   // first hole from front face (end opposite SATA connector)

/* [Plate] */
plate_t      = 3.00;
plate_r      = 5.00;        // corner radius
plate_margin = 0.00;        // extra beyond drive / stud outline, per side

/* [Cooling window] */
window   = true;
win_web  = 4.0;             // min material between window and countersink / stud base
win_r    = 4.0;             // window corner radius

/* [Studs] */
stud_pitch_x = 85.0;        // along drive length
stud_pitch_y = 70.0;        // across drive width
// Stud pattern shift along X relative to the drive holes. A centred pattern puts the
// dia 10 bases on the drive screw countersinks, so the pattern is shifted:
//   "front": overhangs the front face (connector end left clear)  - default
//   "back" : overhangs the SATA connector end
//   "manual": first stud at stud_x_manual from the drive front face
stud_shift    = "front";
stud_x_manual = -2.05;
stud_gap      = 0.5;        // min clearance stud base to countersink edge
s1_d = 10.0;  s1_h = 6.5;   // base
s2_d =  5.0;  s2_h = 6.5;   // neck (sits in grommet)
s3_d =  7.0;  s3_h = 3.0;   // locking half-sphere (flattened to s3_h)
slot_w     = 1.2;           // vertical split through neck + head
slot_angle = 0;             // 0: slot plane parallel to X

/* [Screws] */
m3_clear = 3.40;
csk_d    = 6.40;            // ISO 10642 / 7046 M3 head dk 6.0 max + 0.4
csk_ang  = 90;

$fn = 64;

// derived
spx = stud_pitch_x;
spy = stud_pitch_y;
hx0 = bot_hole_front;
holes = [for (x = [hx0, hx0 + bot_hole_pitch_x], y = [-1, 1]) [x, y*bot_hole_pitch_y/2]];
// min X offset stud-to-hole so base clears countersink
dy_sh  = abs(spy - bot_hole_pitch_y)/2;
r_need = s1_d/2 + csk_d/2 + stud_gap;
dx_min = r_need > dy_sh ? sqrt(r_need*r_need - dy_sh*dy_sh) : 0;
dpitch = spx - bot_hole_pitch_x;
sx0 = stud_shift == "front" ? hx0 - max(dx_min, dpitch + dx_min)
    : stud_shift == "back"  ? hx0 + dx_min
    : stud_x_manual;
studs = [for (x = [sx0, sx0 + spx], y = [-1, 1]) [x, y*spy/2]];
csk_depth = (csk_d - m3_clear)/2 / tan(csk_ang/2);
// plate = hull of drive outline and stud bases
px0 = min(0, sx0 - s1_d/2) - plate_margin;
px1 = max(drive_l, sx0 + spx + s1_d/2) + plate_margin;
pw  = max(drive_w, spy + s1_d) + 2*plate_margin;
plate_l = px1 - px0;
plate_w = pw;

// window = largest centred rectangle clear of countersinks and stud bases by win_web
feats = concat([for (h = holes) [h[0], h[1], csk_d/2]],
               [for (p = studs) [p[0], p[1], s1_d/2]]);
xc  = drive_l/2;
wx0 = max([for (f = feats) if (f[0] < xc) f[0] + f[2]]) + win_web;
wx1 = min([for (f = feats) if (f[0] > xc) f[0] - f[2]]) - win_web;
wy  = min([for (f = feats) abs(f[1]) - f[2]]) - win_web;

module window_cut() {
    translate([wx0, -wy, -1]) linear_extrude(plate_t + 2)
        translate([win_r, win_r]) offset(r = win_r)
            square([wx1 - wx0 - 2*win_r, 2*wy - 2*win_r]);
}

module plate() {
    translate([px0, -pw/2, 0]) linear_extrude(plate_t)
        translate([plate_r, plate_r]) offset(r = plate_r)
            square([plate_l - 2*plate_r, plate_w - 2*plate_r]);
}

module stud() {
    difference() {
        union() {
            cylinder(d = s1_d, h = s1_h);
            translate([0, 0, s1_h - 0.01]) cylinder(d = s2_d, h = s2_h + 0.01);
            translate([0, 0, s1_h + s2_h]) scale([1, 1, s3_h/(s3_d/2)])
                intersection() {
                    sphere(d = s3_d);
                    translate([-s3_d, -s3_d, 0]) cube(2*s3_d);
                }
        }
        rotate([0, 0, slot_angle])
            translate([-s3_d, -slot_w/2, s1_h]) cube([2*s3_d, slot_w, s2_h + s3_h + 1]);
    }
}

module screw_hole() {
    translate([0, 0, -1]) cylinder(d = m3_clear, h = plate_t + 2);
    translate([0, 0, plate_t - csk_depth])
        cylinder(d1 = m3_clear, d2 = csk_d, h = csk_depth + 0.01);
    translate([0, 0, plate_t]) cylinder(d = csk_d, h = 1);
}

difference() {
    union() {
        plate();
        for (p = studs) translate([p[0], p[1], plate_t - 0.01]) stud();
    }
    for (p = holes) translate([p[0], p[1], 0]) screw_hole();
    if (window) window_cut();
}

// ghost drive (F5 preview only)
%translate([0, -drive_w/2, -drive_h]) cube([drive_l, drive_w, drive_h]);

// clearance check: countersink edge to stud base
min_gap = min([for (h = holes, s = studs) norm(h - s) - csk_d/2 - s1_d/2]);
echo(str("Plate L x W x T        = ", plate_l, " x ", plate_w, " x ", plate_t, " mm"));
echo(str("Stud pattern X x Y     = ", spx, " x ", spy, " mm"));
echo(str("Studs X from drive front = ", sx0, ", ", sx0 + spx, " mm; plate X = ", px0, " .. ", px1, " mm"));
if (window) echo(str("Cooling window         = ", wx1 - wx0, " x ", 2*wy, " mm, X ", wx0, " .. ", wx1));
echo(str("Overall height         = ", plate_t + s1_h + s2_h + s3_h, " mm"));
echo(str("Min csk-to-stud gap    = ", min_gap, " mm"));
assert(min_gap >= stud_gap - 1e-6, "Drive screw countersink collides with stud base");
