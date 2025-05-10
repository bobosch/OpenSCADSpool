// Render part of spool
show = "bottom"; // [all, bottom, top, cutout]

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
// Thickness of the outer flange border
flange_wall = 6;

/* [Flange] */
// Number of cutouts to safe material and weight (-1: disable)
flange_cutout_segments = 3; // [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
// Export as AMF file, set in your slicer on this object top and bottom shell layers to 0 and choose an infill pattern (see README.md for details)
flange_cutout_keep = false; // [false, true]
// Cutout crossing width
flange_cutout_crossing_width = 20;
// Window width in the crossing (0: disable)
flange_cutout_crossing_window = 0;
// Extend the crossing window to the bore (for cable tie)
flange_cutout_crossing_window_bore = false; // [false, true]
// Round cutout corners
flange_cutout_fillet = 3;
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
// How many percent of the barrel wall is on the bottom side
barrel_wall_split_percent = 20;

/* [Label] */
// Level meter
label_level_meter = false; // [false, true]
// Diameter of the content when full (0: max (flange_radius) )
label_level_full_diameter = 172;
// Show this value on full mark
label_level_full_factor = 1000;
// Font size
label_level_font_size = 5.5;
// Texture depth
label_depth = 0.8;

/* [Hidden] */
flange_radius = flange_diameter / 2;
barrel_radius = barrel_diameter / 2;
bore_radius = bore_diameter / 2;
outer_width = width + 2 * flange_width;
connector_radius = bore_radius + bore_wall + 3.2;
label_level_full_radius = label_level_full_diameter / 2;
rounding_mesh_error = 0.001;

$fn = 200;

if (show == "all" || show == "bottom") {
    union() {
        flange();
        barrel(false);
    }
}

if (show == "all" || show == "top") {
    spool_show() union() {
        flange();
        barrel(true);
    }
}

if (flange_cutout_keep || show == "cutout") {
    spool_show(true) linear_extrude(flange_width) flange_cutout();
}

/*********
* Common *
*********/
module ring(inner_radius, outer_radius) {
    difference() {
        circle(outer_radius);
        circle(inner_radius);
    }
}

module tube(inner_radius, outer_radius, height) {
    linear_extrude(height) ring(inner_radius, outer_radius);
}

/********
* Spool *
*********/

module spool_show(both = false) {
    if (show == "all") translate([0, 0, outer_width]) rotate([180, 0, 0]) children();
    if (show != "all" || both) children();
}

/*********
* Flange *
**********/
module flange() {
    difference() {
        linear_extrude(flange_width) difference() {
            ring(bore_radius, flange_radius);
            if (flange_cutout_segments > -1) flange_cutout();
            if (flange_cutout_crossing_window) flange_cutout_window();
        }
        if (flange_filament_clip) flange_filament_clip();
        if (flange_filament_hole_bambu) flange_filament_hole();
        if (flange_filament_hole_inclined) flange_filament_hole(45);
        if (label_level_meter) linear_extrude(label_depth) flange_level();
    }
}

/* Flange cutout */
module flange_cutout() {
    offset(r = flange_cutout_fillet) offset(r = -flange_cutout_fillet) difference() {
        ring(barrel_radius, flange_radius - flange_wall);
        flange_cutout_crossings(flange_cutout_crossing_width);
        if (label_level_meter && flange_cutout_crossing_window) offset(r = 2) hull() flange_level(false);
    }
}

module flange_cutout_window() {
    offset(r = flange_cutout_fillet) offset(r = -flange_cutout_fillet) difference() {
        flange_cutout_crossings(flange_cutout_crossing_window);
        circle(flange_cutout_crossing_window_bore ?
            (barrel_type == "solid" ?
                    (bore_radius + barrel_wall) : (connector_radius + ((barrel_wall > bore_wall) ? barrel_wall : bore_wall))
            ) : barrel_radius
        );
        ring(flange_radius - flange_wall, flange_radius);
    }
}

module flange_cutout_crossings(width) {
    for (i = [0 : 1 : flange_cutout_segments - 1]) {
        rotate([0, 0, (360 / flange_cutout_segments) * i]) flange_cutout_crossing(width);
    }
}

module flange_cutout_crossing(width) {
    translate([0, -width / 2, 0]) square([flange_radius, width]);
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
module flange_filament_hole(angle = 0) {
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
    difference() {
        tube(bore_radius, barrel_radius, outer_width / 2);
        if(flange_cutout_crossing_window_bore) linear_extrude(outer_width / 2) flange_cutout_window();
    }
}

/* Quick connect barrel */
module barrel_quick(top) {
    height_split = (outer_width / 2) + 2.1;
    if (top) {
        // Bore wall
        tube(connector_radius, connector_radius + bore_wall, height_split);
        // Chamfer
        rotate_extrude() translate([bore_radius, flange_width]) chamfer(bore_wall + 3.2 + rounding_mesh_error);
        // Connector
        translate([0, 0, height_split]) {
            for (i = [0:1:2]) {
                rotate([0, 0, 120 * i]) quick_hold_top(connector_radius);
            }
        }
        // Barrel wall
        barrel_wall(flange_width + width * (1 - (barrel_wall_split_percent / 100)));
    } else {
        // Bore wall
        tube(bore_radius, bore_radius + bore_wall, height_split);
        // Connector
        rotate([0, 0, -25]) translate([0, 0, height_split]) {
            for (i = [0:1:2]) {
                rotate([0, 0, 120 * i]) quick_hold_bottom(bore_radius + bore_wall);
            }
        }
        // Barrel wall
        barrel_wall(flange_width + width * (barrel_wall_split_percent / 100));
    }
}

module barrel_wall(height) {
    if(flange_cutout_crossing_window_bore) {
        linear_extrude(height) difference() {
            barrel_wall_cutout();
            offset(r = -barrel_wall) barrel_wall_cutout();
        }
    } else {
        tube(barrel_radius - barrel_wall, barrel_radius, height);
    }
}

module barrel_wall_cutout() {
    difference() {
        circle(barrel_radius);
        flange_cutout_window();
    }
}

module chamfer(a) {
    p = [[0, 0], [a, 0], [a, a]];
    polygon(points = p, paths= [[0, 1, 2]]);
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
            rotate_extrude() translate([inner_radius, 0]) mirror([1, 0]) quick_lug(3);
            translate([inner_radius - 0.1, 0, 0]) rotate([0, 0, 45]) cube([3, 3, 6], center = true);
        }
    }
}

module quick_lug(height = 0) {
    p = [[0, -2.932], [3, -1.2], [3, height], [0, height]];
    polygon(points = p, paths= [[0, 1, 2, 3]]);
}

/********
* Label *
*********/

/* Level meter */
module flange_level(mark = true) {
    levels = [0.2, 0.4, 0.6, 0.8, 1];

    for (i = [ 0 : len(levels) - 1 ]) {
        r = level_radius(levels[i]);
        if (mark) intersection() {
            ring(r-.3, r+.3);
            flange_cutout_crossing(flange_cutout_crossing_width);
        }
        if (flange_cutout_crossing_window) {
            translate([r - 1 - label_level_font_size, flange_cutout_crossing_width / 2 + 1]) rotate([0, 180, -90]) text(str(levels[i] * label_level_full_factor), size = label_level_font_size, halign = "left");
        } else {
            translate([r - 1 - label_level_font_size, 0]) rotate([0, 180, -90]) text(str(levels[i] * label_level_full_factor), size = label_level_font_size, halign = "center");
        }
    }
}

/* Level meter */
function level_radius(factor) = sqrt(factor * ((label_level_full_radius ? label_level_full_radius : flange_radius)^2 - barrel_radius^2) + barrel_radius^2);
