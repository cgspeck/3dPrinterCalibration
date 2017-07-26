Start=200;
Step=2;
End=210;

Tower_Distance=50;

Base_Thickness=2;


CUBE_SIZE=10;
NOTCH_Y=2;
NOTCH_Z=2;

FONT_SIZE=4;

FONT_X=CUBE_SIZE / 2;
FONT_Z=(CUBE_SIZE - NOTCH_Z) / 2;

module TempCube(temp) {
    difference() {
        cube(CUBE_SIZE);
        
        translate([0, 0, CUBE_SIZE - NOTCH_Z]) {
            cube([CUBE_SIZE, NOTCH_Y, NOTCH_Z]);
        }
        
        translate([FONT_X, 0.5, FONT_Z]) rotate([90, 0, 0]) linear_extrude(1) text(temp, FONT_SIZE, halign="center", valign="center");
    }
} 

module TempStack() {
    for(i = [Start : Step : End]) {
        o = (i - Start) / Step;
        translate([
            0,
            0,
            o * CUBE_SIZE
        ]) {
            TempCube(str(i));
        }
    }
}

module Base() {
    cube([
        CUBE_SIZE * 3 + Tower_Distance,
        CUBE_SIZE * 3,
        Base_Thickness
    ]);
}

module CalibrationTowers() {
    translate([CUBE_SIZE, CUBE_SIZE, Base_Thickness]) TempStack();

    translate([CUBE_SIZE + Tower_Distance, CUBE_SIZE, Base_Thickness]) TempStack();

    Base();
}

CalibrationTowers();