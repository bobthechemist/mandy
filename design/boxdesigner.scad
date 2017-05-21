mat_thickness = 3.14; // inches to mm
notch_depth = mat_thickness;
notch_width = 01.38 * notch_depth;
male = 1;
female = 0;
kerf = -0.1;

module notched_side(length, gender, nd = notch_depth, nw = notch_width, k = kerf){
    difference(){
        square([length,nd]);
        for(i=[(gender?nw:0):nw*2:length]){
            translate([i-k/2,0])
            square([nw+k,nd]);
        }
    }
}

x = 100;
y = 100;
//notch sequence is 1-1-1-1 for top/bottom box and
// 0-0-0-1 for sides

//Create four-sided notched pieces for box
*difference(){
    square([x,y]);
    union(){
        translate([0,0])notched_side(x, 0);
        mirror([1,0,0])rotate(90,[0,0,1])
        notched_side(y,0);
        translate([0,y])mirror([0,1,0])
        notched_side(x,0);
        translate([x-1*notch_depth,0])
        rotate(180,[0,1,0])
        rotate(90,[0,0,1])
        notched_side(y,1);
        
    }
}

// notch_depth, notch_width, kerf need to be defined
// i# is -1 for no notches, 0 for female, 1 for male
module piece(x, y, x0, y0, x1, y1) {
    difference(){
        square([x,y]);
        union(){
           if(x0>-1){
                translate([0,0])notched_side(x, x0);
           }
           if(y0>-1){
               mirror([1,0,0])rotate(90,[0,0,1])
               notched_side(y,y0);
           }
           if(x1>-1){
               translate([0,y])mirror([0,1,0])
               notched_side(x,x1);
           }
           if(y1>-1){
               translate([x-0.999*notch_depth,0])
               rotate(180,[0,1,0])
               rotate(90,[0,0,1])
               notched_side(y,y1);
           }
        }
    }
}

// Test frame
*union(){
    piece(50,38.1,-1,1,-1,0);
    translate([0,45])piece(40,38.1,-1,1,-1,0);
    translate([45,45])piece(50,38.1,-1,1,-1,0);
    translate([55,0])piece(40,38.1,-1,1,-1,0);
}
// Mandy is 17 3/4" x 23 3/4 " x 1 1/2 ".  Allow for 1/4 " 
// on each edge, making the frame (outer dimensions) 
// 17 1/4" x 23 1/4 " x 1 1/2 ".  In metric:
// 438.15 x 590.55 x 38.1.  1/8 " stock is 3.175 mm.
*union(){
    piece(438.15,38.1,-1,1,-1,0);
    translate([0,45])difference(){
        piece(590.55,38.1,-1,1,-1,0);
        translate([355.6,0])square([50.8,19.0]);
    }
    translate([0,90])difference(){
        piece(438.15,38.1,-1,1,-1,0);
        translate([393.7,0])square([25.4,19.0]);
    }
    translate([0,135])piece(590.55,38.1,-1,1,-1,0);
}

// edge length / (fudge * notch_depth) should be an integer
// for clean-looking notches.

echo (65/(1.38*notch_depth));

translate([67 ,0])piece(65,45,1,1,1,1);
piece(65,45,1,1,1,1);

translate([0,47])
piece(65,34.5,0,0,0,1);
translate([67,47])
piece(65,34.5,0,0,0,1);
translate([0,85])
piece(45,34.5,0,0,0,1);
translate([47,85])
piece(45,34.5,0,0,0,1);

