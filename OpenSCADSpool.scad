// Render part of spool
show = "bottom"; // [all, bottom, top]

/* [Size] */
// Spool outer diameter
flange_diameter = 200;
// Spool inner diameter
barrel_diameter = 81;
// Hole diameter
bore_diameter = 57;
// Inner width of the spool. Overal width is width + 2 x flange_wall
width = 59;
// Strength of the flange
flange_wall = 3.5;

/* Barrel */
// Type of the barrel
barrel_type = "quick"; // [solid, quick]
// Barrel wall thickness (when not solid)
barrel_wall = 1.8;

/* [Hidden] */
flange_radius = flange_diameter / 2;
barrel_radius = barrel_diameter / 2;
bore_radius = bore_diameter / 2;
outer_width = width + 2 * flange_wall;

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
        tube(bore_radius, flange_radius, flange_wall);
}

/*********
* Barrel *
**********/
module barrel(top) {
    if (barrel_type == "solid") {
        barrel_solid();
    }
    else if (barrel_type == "quick") {
        barrel_quick(top);
    }
}

/* Solid barrel */
module barrel_solid() {
    tube(bore_radius, barrel_radius, outer_width / 2);
}

/* Quick connect barrel */
module barrel_quick(top) {
    height_split = (outer_width / 2) + 2.1;
    if (top) {
        connector_radius = bore_radius + barrel_wall + 3.2;
        tube(connector_radius, connector_radius + barrel_wall, height_split);
        translate([0, 0, height_split]) {
            for (i = [0:1:2]) {
                rotate([0, 0, 120 * i]) quick_hold_top(connector_radius);
            }
        }
        tube(barrel_radius - 1, barrel_radius, outer_width * 0.8);
    } else {
        tube(bore_radius, bore_radius + barrel_wall, height_split);
        rotate([0, 0, -25]) translate([0, 0, height_split]) {
            for (i = [0:1:2]) {
                rotate([0, 0, 120 * i]) quick_hold_bottom(bore_radius + barrel_wall);
            }
        }
        tube(barrel_radius - 1, barrel_radius, outer_width * 0.2);
    }
}

module quick_hold_bottom(inner_radius) {
    a = (3.3 * 180) / (PI * inner_radius);
    rotate_extrude(angle = 25) translate([inner_radius, 0]) quick_lug();
    rotate([0, 0, 25 + a]) {
        intersection() {
            rotate_extrude() translate([inner_radius, 0]) quick_lug();
            translate([inner_radius - 0.1, 0, -1.5]) rotate([0, 0, 45]) cube(3, center = true);
        }
    }
}

module quick_hold_top(inner_radius) {
    a = (3.3 * 180) / (PI * inner_radius);
    rotate_extrude(angle = 25) translate([inner_radius, 0]) mirror([1, 0, 0]) quick_lug();
    rotate([0, 0, a / -2]) {
        translate([0, 0, -3]) intersection() {
            rotate_extrude() translate([inner_radius, 0]) mirror([1, 0, 0]) quick_lug();
            translate([inner_radius - 0.1, 0, -1.5]) rotate([0, 0, 45]) cube(3, center = true);
        }
        translate([inner_radius - 0.1, 0, -1.5]) rotate([0, 0, 45]) cube(3, center = true);
    }
}

module quick_lug() {
    p = [[0, -2.932], [3, -1.2], [3, 0], [0, 0]];
    polygon(points = p, paths= [[0, 1, 2, 3]]);
}
