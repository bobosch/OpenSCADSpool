// Render part of spool
show = "bottom"; // [all, bottom, top]

/* [Size] */
// Spool outer diameter
flange_diameter = 200;
// Spool inner diameter
barrel_diameter = 81;
// Hole diameter
bore_diameter = 57;
// Inner width of the spool. Overal width is width + 2 x flange_width
width = 59;
// Strength of the flange
flange_width = 3.5;

/* [Flange] */
// Number of cutouts to safe material and weight (-1: disable)
flange_cutout_segments = 3; // [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
// Export as AMF file, set in your slicer on this object top and bottom shell layers to 0 and choose an infill pattern (see README.md for details)
flange_cutout_keep = false; // [false, true]
// Cutout crossing width
flange_cutout_crossing_width = 20;
// Window width in the crossing (0: disable)
flange_cutout_crossing_window = 0;
// Filament clip on the flange border
flange_filament_clip = false; // [false, true]
// Number of hole pairs
flange_filament_hole_count = 4; // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
// Filament holes BambuLab spool compatible
flange_filament_hole_bambu = false; // [false, true]
// Inclined filament holes
flange_filament_hole_inclined = false; // [false, true]

/* [Barrel] */
// Type of the barrel
barrel_type = "quick"; // [solid, quick]
// Bore wall thickness (when barrel not solid)
bore_wall = 1.8;
// Barrel wall thickness (when barrel not solid)
barrel_wall = 1.2;

/* [Hidden] */
flange_radius = flange_diameter / 2;
barrel_radius = barrel_diameter / 2;
bore_radius = bore_diameter / 2;
outer_width = width + 2 * flange_width;
rounding_mesh_error = 0.001;

$fn = 200;

if (show == "all") {
    translate([0, 0, outer_width]) rotate([180, 0, 0]) union() {
        flange();
        barrel(true);
    }
}

if (show == "all" || show == "bottom") {
    union() {
        flange();
        barrel(false);
    }
}

if (show == "top") {
    union() {
        flange();
        barrel(true);
    }
}

if (flange_cutout_keep) {
    flange_cutout();
    if (show == "all") translate([0, 0, width + flange_width]) flange_cutout();
}

/*********
* Common *
*********/
module tube(inner_radius, outer_radius, height) {
    linear_extrude(height) difference() {
        circle(outer_radius);
        circle(inner_radius);
    }
}

/*********
* Flange *
**********/
module flange() {
    difference() {
        tube(bore_radius, flange_radius, flange_width);
        if (flange_cutout_segments > -1) flange_cutout();
        if (flange_cutout_crossing_window) flange_cutout_window();
        if (flange_filament_clip) flange_filament_clip();
        if (flange_filament_hole_bambu) flange_filament_hole(0);
        if (flange_filament_hole_inclined) flange_filament_hole(45);
    }
}

/* Flange cutout */
module flange_cutout() {
    difference() {
        tube(barrel_radius, flange_radius - 6, flange_width);
        for (i = [0 : 1 : flange_cutout_segments - 1]) {
            rotate([0, 0, (360 / flange_cutout_segments) * i]) translate([0, -flange_cutout_crossing_width / 2, 0]) cube([flange_radius, flange_cutout_crossing_width, flange_width]);
        }
    }
}

module flange_cutout_window() {
    difference() {
        union() for (i = [0 : 1 : flange_cutout_segments - 1]) {
            rotate([0, 0, (360 / flange_cutout_segments) * i]) translate([0, -flange_cutout_crossing_window / 2, 0]) cube([flange_radius, flange_cutout_crossing_window, flange_width]);
        }
        cylinder(flange_width, barrel_radius, barrel_radius);
        tube(flange_radius - 6, flange_radius, flange_width);
    }
}

/* Filament clip */
module flange_filament_clip() {
    rotate_extrude() translate([flange_radius - 3, flange_width - 1.2]) filament_clip();
}

module filament_clip() {
    r = 1.741 / 2;
    p = [[-r, 0], [-0.808, 1.2], [0.808, 1.2], [r, 0]];
    circle(r);
    polygon(points = p, paths = [[0, 1, 2, 3]]);
}

/* Filament hole */
module flange_filament_hole(angle) {
    r = flange_radius - 3;
    s = 30;
    a = asin(s / (2 * r));
    for (i = [0 : 1 : flange_filament_hole_count - 1]) {
        rotate([-angle, 0, (360 / flange_filament_hole_count) * i + a]) translate([r, 0, -2]) cylinder(h = flange_width * 2 + 4, r = 1.75);
        rotate([+angle, 0, (360 / flange_filament_hole_count) * i - a]) translate([r, 0, -2]) cylinder(h = flange_width * 2 + 4, r = 1.75);
    }
}

/*********
* Barrel *
**********/
module barrel(top) {
    if (barrel_type == "solid") barrel_solid();
    else if (barrel_type == "quick") barrel_quick(top);
}

/* Solid barrel */
module barrel_solid() {
    tube(bore_radius, barrel_radius, outer_width / 2);
}

/* Quick connect barrel */
module barrel_quick(top) {
    height_split = (outer_width / 2) + 2.1;
    if (top) {
        connector_radius = bore_radius + bore_wall + 3.2;
        tube(connector_radius, connector_radius + bore_wall, height_split);
        translate([0, 0, height_split]) {
            for (i = [0:1:2]) {
                rotate([0, 0, 120 * i]) quick_hold_top(connector_radius);
            }
        }
        tube(barrel_radius - barrel_wall, barrel_radius, outer_width * 0.8);
    } else {
        tube(bore_radius, bore_radius + bore_wall, height_split);
        rotate([0, 0, -25]) translate([0, 0, height_split]) {
            for (i = [0:1:2]) {
                rotate([0, 0, 120 * i]) quick_hold_bottom(bore_radius + bore_wall);
            }
        }
        tube(barrel_radius - barrel_wall, barrel_radius, outer_width * 0.2);
    }
}

module quick_hold_bottom(inner_radius) {
    a = (3.3 * 180) / (PI * inner_radius);
    rotate_extrude(angle = 25) translate([inner_radius - rounding_mesh_error, 0]) quick_lug();
    rotate([0, 0, 25 + a]) {
        intersection() {
            rotate_extrude() translate([inner_radius, 0]) quick_lug();
            translate([inner_radius - 0.1, 0, -1.5]) rotate([0, 0, 45]) cube(3, center = true);
        }
    }
}

module quick_hold_top(inner_radius) {
    a = (3.3 * 180) / (PI * inner_radius);
    rotate_extrude(angle = 25) translate([inner_radius + rounding_mesh_error, 0]) mirror([1, 0]) quick_lug();
    rotate([0, 0, a / -2]) {
        translate([0, 0, -3]) intersection() {
            rotate_extrude() translate([inner_radius, 0]) mirror([1, 0]) quick_lug();
            translate([inner_radius - 0.1, 0, -1.5]) rotate([0, 0, 45]) cube(3, center = true);
        }
        translate([inner_radius - 0.1, 0, -1.5]) rotate([0, 0, 45]) cube(3, center = true);
    }
}

module quick_lug() {
    p = [[0, -2.932], [3, -1.2], [3, 0], [0, 0]];
    polygon(points = p, paths= [[0, 1, 2, 3]]);
}
