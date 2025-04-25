# OpenSCADSpool
Parametrizable spool primary for 3d filament

## Slicer flange cutouts
1. Set "flange_cutout_keep" to true
2. Export as AMF
3. Select cutout in slicer
![Selection in Slicer](Documentation/Images/cutout_slicer_select.png)
4. Change slicer parameters by object
   - Top shell layers: 0
   - Bottom shell layers: 0
   - Sparse infill density: Your choice
   - Sparse infill pattern: Choose between Rectilinear, Grid, Triangles, Tri-hexagon, Honeycomb or Zig Zag
5. Slice
![Result in Slicer](Documentation/Images/cutout_slicer_sliced.png)
