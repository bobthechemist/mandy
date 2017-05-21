th = 3.175;
x = 590.55;
y = 438.15;
h = 34.925;
k = 0.1; //kerf
f = 0.1; //fudge

//cube([x,th,h]);
//cube([th,y,h]);
//translate([x,0,0])cube([th,y,h]);
//translate([0,y,0])cube([x,th,h]);

module male(x,h) {
    
    union(){
        translate([th,0,0])
        cube([x-2*th,th,h]);
        intersection(){
            cube([x,th,h]);
            union(){
                for(i=[0.20:0.20:0.8]){
                    for(j=[0, x-th]){
                        translate([j,0,i*h-th/2+k])
                        cube([th,th,th-2*k]);
                    }
                }
            }
        }
    }
}

module female(x,h) {
    difference(){
        cube([x,th,h]);
        union(){
            for(i=[0.20:0.20:0.8]){
                for(j=[0, x-th]){
                    translate([j,0,i*h-th/2])
                    cube([th,th,th]);
                }
            }
        }
    }
}

//male(f*x,h);
//translate([0,f*y-th,0])male(f*x, h);
//translate([-th,0,0])rotate(90,[0,0,1])female(f*y, h);
//translate([f*x+2*th,0,0])rotate(90,[0,0,1])female(f*y, h);

// Provide x, y and z.  Knobs should be same as z.
//  Also need a true/false for each side.  Go with 4 fixed
//  knobs at present.
// x and y are the absolute distances

module side(x, y, z, gender,b,l,t,r, kerf) {
    module teeth(tw,tz,k=0){
        for(i=[0.20:0.20:0.8]){
            translate([i*tw-tz/2+k,-.01,-.01])
            cube([tz-2*k,tz+.02,tz+.02]);
        }
    }
    module female(k=0){
        difference(){
            cube([x,y,z]);
            union(){
                if(b>0)teeth(x,z,k);
                if(t>0)translate([0,y-z,0])teeth(x,z,k);
                if(l>0)rotate(90,[0,0,1])translate([0,-z,0])teeth(y,z,k);
                if(r>0)translate([x-z,0,0])
                    rotate(90,[0,0,1])translate([0,-z,0])teeth(y,z,k);
                
            }
        }
    }

    
// Female piece
    if(gender==0) {
        female();
    }
    else {
// Male piece with kerf
        if(b==0)translate([z,0,0])cube([x-2*z,z,z]);
        if(l==0)translate([0,z,0])cube([z,y-2*z,z]);
        if(t==0)translate([z,y-z,0])cube([x-2*z,z,z]);
        if(r==0)translate([x-z,z,0])cube([z,y-2*z,z]);
        translate([z,z,0])cube([x-2*z,y-2*z,z]);
        difference(){
            translate([0.001,0.001,+0.001])
            cube([x-0.002,y-0.002,z-.002]);
            female(kerf);
        }
    
    }
}

module temp() {
    translate([-0.1,-th-0.1,25-th+0.1])
    side(30,30,th,1,1,1,0,0,0);
}


difference(){
    rotate(90,[1,0,0])color("red")
    side(75,25,th,1,0,1,0,1,0.1);
    temp();
}

difference(){
    translate([0,-th,0])
    rotate(90,[0,1,0])rotate(90,[0,0,1])color("green")
    side(75,25,th,0,0,1,0,1,0.1);
    temp();
}

color("blue")
translate([-0.1,-th-0.1,25-th])
side(30,30,th,1,1,1,0,0,0.0);
