//Creating the shadowbox cutouts
elem = 26.419;
spac = 4.5;
h=25.4*1.4;

module boxrow(j) {
    row = j*elem+(j-1)*spac;
    difference(){
        square([row+3*spac,h]);
        union(){
            for(i=[0:1:j]){
                translate([spac+i*(elem+spac)-0.5,-0.001])
                square([1,h/2]);
            }
        }
    }
}


for(i=[0:2]){translate([0,i*(h+3)])boxrow(6);}
*translate([140,0])
for(i=[0:5]){translate([0,i*(h+3)])boxrow(2);}
*for(j=[0:5]){
    translate([150,j*(h+3)])
    for(i=[0:2]){
        translate([i*74,h*3.3])boxrow(2);}
    }
echo( 2*elem+spac+3*spac);