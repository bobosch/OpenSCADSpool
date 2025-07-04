// Render part of spool
show = "bottom"; // [all, bottom, top, cutout, label]

/* [Size] */
// Spool outer diameter
flange_diameter = 200;
// Spool inner diameter
barrel_diameter = 81.0; // 0.1
// Hole diameter
bore_diameter = 57.0; // 0.1
// Inner width of the spool. Overal width is width + 2 x flange_width
width = 60.0; // 0.1
// Strength of the flange
flange_width = 3.5; // 0.1
// Thickness of the outer flange border
flange_wall = 6.0; // 0.1

/* [Flange] */
// Number of cutouts to safe material and weight (-1: disable)
flange_cutout_segments = 3; // [-1:1:12]
// Export as 3MF or AMF file, set in your slicer on this object top and bottom shell layers to 0 and choose an infill pattern (see README.md for details)
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
flange_filament_hole_count = 4; // [1:1:12]
// Filament holes BambuLab spool compatible
flange_filament_hole_bambulab = false; // [false, true]
// Inclined filament holes
flange_filament_hole_inclined = false; // [false, true]
// Chamfer of flange
flange_chamfer_size = 1.0; // 0.1

/* [Barrel] */
// Type of the barrel
barrel_type = "quick"; // [solid, quick]
// Bore wall thickness (when barrel not solid)
bore_wall = 1.8; // 0.1
// Barrel wall thickness (when barrel not solid)
barrel_wall = 1.2; // 0.1
// How many percent of the barrel wall is on the bottom side
barrel_wall_split_percent = 20;
// Notch for BambuLab filament, only on the top part of the spool (position; 0: disable)
barrel_notch_bambulab = 0; // [0:1:12]
// Hole to fix end of filament, only on the top part of the spool (position; 0: disable)
barrel_fixing_hole = 0; // [0:1:12]

/* [Label] */
// Level meter
label_level_meter = false; // [false, true]
// Diameter of the content when full (0: max (flange_radius) )
label_level_full_diameter = 174;
// Show this value on full mark
label_level_full_factor = 1000;
// Font size
label_level_font_size = 5.5; // 0.1
// Texture depth
label_depth = 0.8; // 0.1
// Use color instead of relief
label_color = false; // [false, true]
// Area for BambuLab label (position; 0: disable)
label_area_bambulab = 0; // [0:1:12]
// Separate color for BambuLab label area
label_area_bambulab_color = false; // [false, true]
// Custom label area (position; 0: disable)
label_area_position = 0; // [0:1:12]
// Custom label area width and height (0: disable)
label_area_size = [90, 40];

/* [Other] */
// Small pocket (include lid) to reuse BambuLab RFID tags (position; 0: disable)
bambulab_rfid_pocket = 0; // [0:1:12]

/* [Hidden] */
flange_radius = flange_diameter / 2;
barrel_radius = barrel_diameter / 2;
bore_radius = bore_diameter / 2;
outer_width = width + 2 * flange_width;
connector_radius = bore_radius + bore_wall + 3.2;
barrel_height_top = width * (1 - (barrel_wall_split_percent / 100));
label_level_full_radius = label_level_full_diameter / 2;
rounding_mesh_error = 0.001;

$fn = 200;

if (show == "all" || show == "bottom") {
    color([0.5, 0.5, 0.5]) union() {
        flange();
        barrel(false);
    }
}

if (show == "all" || show == "top") {
    spool_show() color([0.5, 0.5, 0.5]) union() {
        flange();
        barrel(true);
    }
}

if (flange_cutout_keep || show == "cutout") {
    spool_show(true) color([1, 1, 0]) linear_extrude(flange_width) flange_cutout();
}

if (label_color || show == "label") {
    spool_show(true) color([0, 0, 0]) linear_extrude(label_depth) flange_level();
}

if (label_area_bambulab_color) {
    spool_show(true) color([1, 1, 1]) linear_extrude(0.2) label_area_bambulab();
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

module crossings_rotate(segments) {
    for (i = [0 : 1 : segments - 1]) {
        rotate([0, 0, (360 / segments) * i]) children();
    }
}

/**
* Rotate to the cutout center
*
* @param number Segment number
*/
module cutout_rotate(number = 1) {
    rotate([0, 0, (flange_cutout_segments ? (360 / flange_cutout_segments) * (number - 0.5) : 0)]) children();
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
        intersection() {
            linear_extrude(flange_width) difference() {
                ring(bore_radius, flange_radius);
                if (flange_cutout_segments > -1) flange_cutout();
                if (flange_cutout_crossing_window) flange_cutout_window();
            }
            flange_chamfer();
        }
        if (flange_filament_clip) flange_filament_clip();
        if (flange_filament_hole_bambulab) flange_filament_hole();
        if (flange_filament_hole_inclined) flange_filament_hole(45);
        if (label_level_meter) linear_extrude(label_depth) flange_level();
        if (bambulab_rfid_pocket) bambulab_rfid_pocket_hole();
        if (label_area_bambulab_color) linear_extrude(0.2) label_area_bambulab();
    }

    if (bambulab_rfid_pocket) linear_extrude(1) bambulab_rfid_shape();
}

module flange_chamfer() {
    p = [[bore_radius + flange_chamfer_size, 0], [flange_radius - flange_chamfer_size, 0], [flange_radius, flange_chamfer_size], [flange_radius, flange_width], [bore_radius, flange_width], [bore_radius, flange_chamfer_size]];
    rotate_extrude() polygon(points = p, paths = [[0, 1, 2, 3, 4, 5]]);
}

/* Flange cutout */
module flange_cutout() {
    offset(r = flange_cutout_fillet) offset(r = -flange_cutout_fillet) difference() {
        ring(barrel_radius, flange_radius - flange_wall);
        flange_cutout_crossings(flange_cutout_crossing_width);
        if (label_level_meter && flange_cutout_crossing_window) offset(r = 2) hull() flange_level(false);
        if (label_area_bambulab) label_area_bambulab();
        if (label_area_position) label_area_custom();
        if (bambulab_rfid_pocket) offset(r = 1) bambulab_rfid_pocket();
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
    crossings_rotate(flange_cutout_segments) flange_cutout_crossing(width);
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
    crossings_rotate(flange_filament_hole_count) {
        rotate([-angle, 0, + a]) translate([r, 0, -2]) cylinder(h = flange_width * 2 + 4, r = 1.75);
        rotate([+angle, 0, - a]) translate([r, 0, -2]) cylinder(h = flange_width * 2 + 4, r = 1.75);
    }
}

/*********
* Barrel *
**********/
module barrel(top) {
    translate([0, 0, flange_width]) difference() {
        union() {
            if (barrel_type == "solid") barrel_solid();
            else if (barrel_type == "quick") barrel_quick(top);
            if(top && barrel_notch_bambulab) barrel_notch_bambulab();
        }
        if(top && barrel_fixing_hole) barrel_fixing_hole();
    }
}

/* Solid barrel */
module barrel_solid() {
    difference() {
        tube(bore_radius, barrel_radius, width / 2);
        if(flange_cutout_crossing_window_bore) linear_extrude(width / 2) flange_cutout_window();
    }
}

/* Quick connect barrel */
module barrel_quick(top) {
    height_split = (width / 2) + 2.1;
    if (top) {
        // Bore wall
        tube(connector_radius, connector_radius + bore_wall, height_split);
        // Chamfer
        rotate_extrude() translate([bore_radius, 0]) bore_chamfer(bore_wall + 3.2 + rounding_mesh_error);
        // Connector
        translate([0, 0, height_split]) {
            crossings_rotate(3) quick_hold_top(connector_radius);
        }
        // Barrel wall
        barrel_wall(barrel_height_top);
    } else {
        // Bore wall
        tube(bore_radius, bore_radius + bore_wall, height_split);
        // Connector
        rotate([0, 0, -25]) translate([0, 0, height_split]) {
            crossings_rotate(3) quick_hold_bottom(bore_radius + bore_wall);
        }
        // Barrel wall
        barrel_wall(width * (barrel_wall_split_percent / 100));
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

module bore_chamfer(a) {
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

/* Barrel notch for BambuLab filament */
module barrel_notch_bambulab() {
    cutout_rotate(barrel_notch_bambulab) translate([barrel_radius - barrel_wall, 0, 0]) rotate([90, 0, 90]) linear_extrude(3 + barrel_wall) hull() {
        translate([0, 3]) circle(1.5);
        square([4, 0.0001], center = true);
    }
}

module barrel_fixing_hole() {
    cutout_rotate(barrel_fixing_hole) translate([barrel_radius - barrel_wall - 0.5, 0, barrel_height_top - 1.5]) rotate([0, 90, 0]) cylinder(barrel_wall + 1, 1, 1);
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
            difference() {
                flange_cutout_crossing(flange_cutout_crossing_width);
                if(flange_cutout_crossing_window) flange_cutout_crossing(flange_cutout_crossing_window);
            }
        }
        if (flange_cutout_crossing_window) {
            translate([r - 1 - label_level_font_size, flange_cutout_crossing_width / 2 + 1]) rotate([0, 180, -90]) text(str(levels[i] * label_level_full_factor), size = label_level_font_size, halign = "left");
        } else {
            translate([r - 1 - label_level_font_size, 0]) rotate([0, 180, -90]) text(str(levels[i] * label_level_full_factor), size = label_level_font_size, halign = "center");
        }
    }
}

function level_radius(factor) = sqrt(factor * ((label_level_full_radius ? label_level_full_radius : flange_radius)^2 - barrel_radius^2) + barrel_radius^2);

/* Label area */
module label_area_bambulab() {
    cutout_rotate(label_area_bambulab) hull() {
        translate([flange_radius - 15, 0]) circle(10);
        translate([flange_radius - 41, 0]) circle(10);
    }
}

module label_area_custom() {
    cutout_rotate(label_area_position) translate([bore_radius + (flange_radius - bore_radius - label_area_size[1]) / 2, -label_area_size[0] / 2]) square([label_area_size[1], label_area_size[0]]);
}

/********
* Other *
*********/

module bambulab_rfid_shape() {
    translate([7, 0]) circle(10);
    square([14, 20], center = true);
}

module bambulab_rfid_pocket(notch = false) {
    cutout_rotate(bambulab_rfid_pocket) translate([47.5, 0]) {
        bambulab_rfid_shape();
        if(notch) translate([0, 7]) square(5);
    }
}

module bambulab_rfid_pocket_hole() {
    translate([0, 0, flange_width - 1.2]) linear_extrude(1.2) bambulab_rfid_pocket(true);
}
