# 3D Printer Calibration Objects and Scripts

Use at your own risk. Always inspect the resulting GCODE to make sure that sensible values have been inserted by the processing scripts.

## Speed

This generates a tower where the speed will be changed every 10mm.

#. Put Slic3r into advanced mode, and make all the speeds the same value (this is `SLIC3R_SPEED_MM_PER_SEC`). You can leave a first layer modifier in if you need it.

#. Use `speed.scad` to create an STL, decide what your `START_MM_PER_SEC` `STEP` and `END_MM_PER_SEC` will be.

#. Use Slic3r to process the STL and generate a GCODE file.

#. Use `speed/process-file.rb` to transform the GCODE. It will change the flow rate at every  10mm of z-hieght:

```
process-file.rb speed.gcode speed-proc.gcode 24 12 1 24
```


## Temperature and Stringing

This generates two towers where the temperature will be changed every 10mm.

#. Use `temperature-and-stringing.scad` to create an STL, decide what your `Start` `Step` and `End` will be.

#. Use Slic3r to process the STL and generate a GCODE file.

#. Use `temperature-and-stringing/process-file.rb` to transform the GCODE. It will change the temperature rate at every  10mm of z-hieght.