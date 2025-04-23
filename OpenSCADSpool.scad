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

/* [Hidden] */
$fn = 200;

union() {
    flange();
    barrel();
    translate([0, 0, width + flange_wall]) flange();
}

module flange() {
    linear_extrude(flange_wall) difference() {
        circle(flange_diameter / 2);
        circle(bore_diameter / 2);
    }
}

module barrel() {
    linear_extrude(width + 2 * flange_wall) difference() {
        circle(barrel_diameter / 2);
        circle(bore_diameter / 2);
    }
}
