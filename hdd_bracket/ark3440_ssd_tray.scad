// ARK-3440 internal 2.5" SSD carrier tray
// Target drive : Goodram CX400 gen.2 512 GB (SSDPR-CX400-512-G2), 100.00 x 69.85 x 7.00 mm
// Mount        : ARK-3440 bottom cover, internal fixed bay (manual sec. 2.6.1),
//                PCB/bottom side of drive towards cover, thermal pad on cover.
//
// Frame: X = drive length (0 = front face, i.e. end opposite the SATA connector),
//        Y = drive width, Z = up (Z = 0 is the face lying on the bottom cover).
// All dimensions in mm.

/* [Drive] */
drive_l   = 100.00;   // SFF-8201 A6 max 100.45
drive_w   = 69.85;    // SFF-8201 A5
drive_h   = 7.00;     // CX400 gen.2
clr       = 0.30;     // per-side fit clearance

/* [Drive mounting holes, SFF-8201 - VERIFY ON YOUR DRIVE] */
side_hole_x   = [14.00, 90.60];   // from front face
side_hole_z   = 3.00;             // from drive bottom face
bot_hole_x    = [14.00, 90.60];   // from front face
bot_hole_y    = 4.07;             // from each side edge (61.71 pitch)

/* [Tray] */
floor_t     = 1.60;   // under drive; thermal pad must be >= floor_t + 0.4
wall_t      = 2.00;
wall_h      = 5.50;   // above drive bottom face; must exceed side_hole_z + 2
end_stop    = true;   // lip at front face (non-connector end)
end_stop_h  = 3.00;

/* [Thermal window in floor] */
win_margin_x = 8.0;   // keep-out from bottom hole centres, along X
win_margin_y = 9.0;   // keep-out from side edges, along Y
win_r        = 3.0;

/* [Screws, M3] */
m3_clear    = 3.40;
m3_head_d   = 6.20;   // counterbore for side screws (pan / wafer head)
side_cb_d   = 0.80;   // counterbore depth into wall

/* [Cover fixing] */
// true : cover screws pass through floor into drive bottom threads (stock pattern)
// false: floor holes omitted, drive held by side screws only; tray bonded/taped
cover_through = true;

$fn = 48;

// derived
pocket_l = drive_l + 2*clr;
pocket_w = drive_w + 2*clr;
out_l    = pocket_l + (end_stop ? wall_t : 0);
out_w    = pocket_w + 2*wall_t;
x0       = end_stop ? wall_t : 0;   // pocket origin in X
y0       = wall_t;                  // pocket origin in Y

module rrect(l, w, r, h) {
    translate([r, r, 0]) linear_extrude(h)
        offset(r = r) square([l - 2*r, w - 2*r]);
}

module body() {
    // floor
    cube([out_l, out_w, floor_t]);
    // side walls
    for (y = [0, out_w - wall_t])
        translate([0, y, 0]) cube([out_l, wall_t, floor_t + wall_h]);
    // front end stop
    if (end_stop)
        cube([wall_t, out_w, floor_t + end_stop_h]);
}

module cuts() {
    // side screw holes + counterbores
    for (x = side_hole_x) {
        translate([x0 + clr + x, -1, floor_t + side_hole_z]) rotate([-90, 0, 0])
            cylinder(d = m3_clear, h = out_w + 2);
        // counterbores from both outer faces
        translate([x0 + clr + x, -1, floor_t + side_hole_z]) rotate([-90, 0, 0])
            cylinder(d = m3_head_d, h = side_cb_d + 1);
        translate([x0 + clr + x, out_w - side_cb_d, floor_t + side_hole_z]) rotate([-90, 0, 0])
            cylinder(d = m3_head_d, h = side_cb_d + 1);
    }
    // bottom holes (cover screws into drive)
    if (cover_through)
        for (x = bot_hole_x, y = [bot_hole_y, drive_w - bot_hole_y])
            translate([x0 + clr + x, y0 + clr + y, -1])
                cylinder(d = m3_clear, h = floor_t + 2);
    // thermal window
    wx0 = x0 + clr + min(bot_hole_x) + win_margin_x;
    wx1 = x0 + clr + max(bot_hole_x) - win_margin_x;
    wy0 = y0 + clr + win_margin_y;
    wy1 = y0 + clr + drive_w - win_margin_y;
    translate([wx0, wy0, -1]) rrect(wx1 - wx0, wy1 - wy0, win_r, floor_t + 2);
    // cable relief: connector end is open; chamfer floor edge for cable bend
    translate([out_l, y0, floor_t]) rotate([-90, 0, 0])
        cylinder(r = floor_t, h = pocket_w, $fn = 4);
}

difference() { body(); cuts(); }

// ghost drive for checking (F5 preview only)
%translate([x0 + clr, y0 + clr, floor_t]) cube([drive_l, drive_w, drive_h]);

echo(str("Tray outline L x W x H = ", out_l, " x ", out_w, " x ", floor_t + wall_h, " mm"));
echo(str("Drive top above cover = ", floor_t + drive_h, " mm (internal limit 12.8 mm)"));
echo(str("Cover screw length    = stock + ", floor_t, " mm (keep thread engagement <= 3 mm into drive)"));
