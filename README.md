# OpenSCADSpool
Parametrizable spool primary for 3d filament

## Parameters

### Size
All sizes in mm
![size](Documentation/Images/size.png)

### flange_cutout_keep
This option keeps the cutout segment in the 3d model. You can use the slicer to make a nice wall:
![flange_cutout_keep](Documentation/Images/flange_cutout_keep.png)

The option "lazy-union" in OpenSCAD preferences must be enabled.

1. Set "flange_cutout_keep" to true
2. Export as 3MF or AMF
3. Select cutout in slicer
4. Change slicer parameters by object
   - Wall loops: 0
   - Top shell layers: 0
   - Bottom shell layers: 0
   - Sparse infill density: Your choice
   - Sparse infill pattern: Choose between Rectilinear, Grid, Triangles, Tri-hexagon, Honeycomb or Zig Zag
5. Slice

Use "X-Y contour compensation" if the cutout does not fit into the spool.

### flange_filament_clip
A notch in the flange border to hold the filament
![flange_filament_clip](Documentation/Images/flange_filament_clip.png)

### flange_filament_hole_bambulab
Two holes for filament fixation like on BambuLab spools.
![flange_filament_hole_bambulab](Documentation/Images/flange_filament_hole_bambulab.png)

### flange_filament_hole_inclined
Filament holes 45° inclined for easier filament insertion.
![flange_filament_hole_inclined](Documentation/Images/flange_filament_hole_inclined.png)

### flange_cutout_crossing_window_bore
Extend crossing window to the bore and create a gap (for cable tie)
![flange_cutout_crossing_window_bore](Documentation/Images/flange_cutout_crossing_window_bore.png)

### flange_chamfer_size
Chamfer of flange
![flange_chamfer_size](Documentation/Images/flange_chamfer_size.png)

### barrel_notch_bambulab
A small notch to hold BambuLab filament
![barrel_notch_bambulab](Documentation/Images/barrel_notch_bambulab.png)

### barrel_fixing_hole
A hole to fix the end of filament
![barrel_fixing_hole](Documentation/Images/barrel_fixing_hole.png)

### label_level_meter
Add a level meter label to one segment crossing
![label_level](Documentation/Images/label_level.png)

### bambulab_rfid_pocket
Small pocket (include lid) to reuse BambuLab RFID tags
![bambulab_rfid_pocket](Documentation/Images/bambulab_rfid_pocket.png)

## Print profiles
[MakerWorld](https://makerworld.com/de/models/1357165-parametrizable-openscad-spool)
