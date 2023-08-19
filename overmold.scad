$fn = 20;
wall_t = 5;
wire_seal_l = 2.5;
gate_r = 0.75;
gate_l = 0.5;
runner_r = 3;
runner_l = 5;
inlet_l = 2;
min_overmold = 1;

module runner_gate(part_r = 5, gate_r = 0.75, gate_l = 0.5, runner_r = 3, runner_l = 5, inlet_l = 2){
  color("darkred") translate([0, -part_r, 0]) rotate([90, 0, 0]){
    translate([0, 0, -0.5])cylinder(r = gate_r, h = gate_l + 0.5);
    translate([0, 0, gate_l]) cylinder(r1 = gate_r, r2 = runner_r, h = runner_r - gate_r);
    translate([0, 0, gate_l + runner_r - gate_r]) cylinder(r = runner_r, h = runner_l);
    translate([0, 0, gate_l + runner_r - gate_r + runner_l]) cylinder(r1 = runner_r, r2 = runner_r + inlet_l + 0.5, h = inlet_l + 0.5);
  }
}
gate_runner_l = gate_l + (runner_r - gate_r) + runner_l + inlet_l;


module align_feature(type, pos, fr = 1.5, fl = 3){
  if(type == 1){
    if(pos < 0){
      rotate([180, 0, 0]) {
        cylinder(r = fr, h = fl + 0.5);
        cylinder(r1 = fr + 0.25, r2 = fr, h = 0.25);
      }
    }
    else{
      cylinder(r1 = fr, r2 = fr * 0.9, h = fl - 0.5);
    }
  }
}


module mold_down(xm, xp, ym, yp, zm, zp, align, pos_invert){
  color("white") translate([-xm, -ym, -zm]) union(){
    difference(){
      cube([xm + xp, ym + yp, zm]);
      if(pos_invert < 0){
        translate([xm + xp - wall_t / 2, ym + yp - wall_t / 2, zm]) align_feature(type = align[0], pos = -1);
        translate([+ wall_t / 2, + wall_t / 2, zm]) align_feature(type = align[2], pos = -1);
      }
      else{
        translate([+ wall_t / 2, ym + yp - wall_t / 2, zm]) align_feature(type = align[1], pos = -1);
        translate([xm + xp - wall_t / 2, + wall_t / 2, zm]) align_feature(type = align[3], pos = -1);
      }
    }
    if(pos_invert > 0){
      translate([xm + xp - wall_t / 2, ym + yp - wall_t / 2, zm]) align_feature(type = align[0], pos = 1);
      translate([+ wall_t / 2, + wall_t / 2, zm]) align_feature(type = align[2], pos = 1);
    }
    else{
      translate([+ wall_t / 2, ym + yp - wall_t / 2, zm]) align_feature(type = align[1], pos = 1);
      translate([xm + xp - wall_t / 2, + wall_t / 2, zm]) align_feature(type = align[3], pos = 1);
    }
  }
}

module mold_up(xm, xp, ym, yp, zm, zp, align, pos_invert){
  mirror([0, 0, 1]) translate([0, 0, 0]) mold_down(xm, xp, ym, yp, zp, 0, align, pos_invert);
}

module make_mold(xm, xp, ym, yp, zm, zp, align = [0, 0, 0, 0]){
  difference(){
    mold_down(xm, xp, ym, yp, zm, zp, align, 1);
    children();
  }
  
  translate([0, -(ym * 2 + 2.5)]) rotate([180, 0, 0]) difference(){
    mold_up(xm, xp, ym, yp, zm, zp, align, -1);
    children();
  }
}

function vlen(vec) = is_list(vec) ? len(vec) : 1;
function vec_sum(vec, c = 0) = c < vlen(vec) - 1 ? vec[c] + vec_sum(vec, c + 1) : vec[c];
function sub_vec(vec, start, end) = [for(i = [start : vlen(vec) - 1 - end]) vec[i]];
function vec_r_sum(vec) = vlen(vec) == 1 ? 0 : vec[0] + vec[1] + vec_r_sum(sub_vec(vec, 1, 0));
function calc_wire_size(wire_r, dist) = [vec_r_sum(wire_r) + (vlen(wire_r) - 1) * dist, max(wire_r), min(wire_r)];
function calc_wire_dist(wire_r, dist) = [for(i = [0 : vlen(wire_r) - 1]) calc_wire_size([for(j = [0 : i]) wire_r[j]], dist)[0]];


module wire(wire_r, dist, l){
  wire_size = calc_wire_size(wire_r, dist);
  wire_dist = calc_wire_dist(wire_r, dist);
  
  for(i = [0 : vlen(wire_r) - 1]) rotate([0, -90, 0]) translate([0, -wire_size[0] / 2 + wire_dist[i], 0]){
    color("grey") cylinder(r = wire_r[i], h = l);
  }
}

module glue(wire_r, dist, mold_r, mold_l, cone = 0){
  wire_size = calc_wire_size(wire_r, dist);
  wire_dist = calc_wire_dist(wire_r, dist);
  
  translate([0, -wire_size[0] / 2, 0]) color("red") sphere(r = mold_r);
  translate([0, wire_size[0] / 2, 0]) color("red") sphere(r = mold_r);
  
  if(cone == 0){
    color("red") translate([-mold_l, -wire_size[0] / 2, 0]) sphere(r = mold_r);
    color("red") translate([-mold_l, wire_size[0] / 2, 0]) sphere(r = mold_r);
  }
  
  for(i = [0 : vlen(wire_r) - 1]) rotate([0, -90, 0]) translate([0, -wire_size[0] / 2 + wire_dist[i], 0]){
    if(cone == 1){
      color("red") translate([0, 0, mold_l]) cylinder(r1 = mold_r, r2 = wire_size[2], h = mold_r - wire_size[2]);
    }
    color("red") cylinder(r = mold_r, h = mold_l);
  }
}


module straight_junction(wire_left, wire_right, mold_r, mold_l, dist){
  wire_size_left = calc_wire_size(wire_left, dist[0]);
  wire_len_left = mold_l[0] / 2 + mold_r - wire_size_left[1]  + wire_seal_l + 10;
  wire(wire_left, dist[0], wire_len_left);
    
  wire_size_right = calc_wire_size(wire_right, dist[1]);
  wire_len_right = mold_l[1] / 2 + mold_r - wire_size_right[1]  + wire_seal_l + 10;
  rotate([0, 180, 0]) wire(wire_right, dist[1], wire_len_right);
    
  color("red") hull(){
    glue(wire_left, dist[0], mold_r, mold_l[0]);
    rotate([0, 0, 180]) glue(wire_right, dist[1], mold_r, mold_l[1]);
  };
}
//straight_junction([0.5, 0.5, 2, 2], [3, 1, 1, 3], 5, [5, 5], [1, 1]);


module T_junction(wire_left, wire_right, wire_up, mold_r, mold_l, dist){
  wire_size_left = calc_wire_size(wire_left, dist[0]);
  wire_len_left = mold_l[0] + mold_r - wire_size_left[1]  + wire_seal_l + 10;
  wire(wire_left, dist[0], wire_len_left);
    
  wire_size_right = calc_wire_size(wire_right, dist[1]);
  wire_len_right = mold_l[1] + mold_r - wire_size_right[1]  + wire_seal_l + 10;
  rotate([0, 180, 0]) wire(wire_right, dist[1], wire_len_right);
  
  wire_size_up = calc_wire_size(wire_up, dist[2]);
  wire_len_up = mold_l[2] + mold_r - wire_size_up[1]  + wire_seal_l + 10;
  rotate([0, 0, -90]) wire(wire_up, dist[2], wire_len_up);
    
  color("red") hull(){
    glue(wire_left, dist[0], mold_r, mold_l[0]);
    rotate([0, 0, 180]) glue(wire_right, dist[1], mold_r, mold_l[1]);
  };
  color("red") hull() rotate([0, 0, -90]) glue(wire_up, dist[2], mold_r, mold_l[2]);

}

module dice(val, size, t){
  if(val == 1){
    cylinder(r = size, h = t);
  }
  if(val == 2){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
  }
  if(val == 3){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
  }
  if(val == 4){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
  }
   if(val == 5){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    cylinder(r = size, h = t);
    translate([size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
  }
  if(val == 6){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
  }
  if(val == 7){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    cylinder(r = size, h = t);
    translate([size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
  }
  if(val == 8){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([0, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([0, -size * 3.5, 0]) cylinder(r = size, h = t);
  }
  if(val == 9){
    translate([-size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([-size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([0, size * 3.5, 0]) cylinder(r = size, h = t);
    cylinder(r = size, h = t);
    translate([size * 3.5, -size * 3.5, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, 0, 0]) cylinder(r = size, h = t);
    translate([size * 3.5, size * 3.5, 0]) cylinder(r = size, h = t);
    translate([0, -size * 3.5, 0]) cylinder(r = size, h = t);
  }
}

module label(wire_in, text_in, mold_r, text_l, text_h, text_t, dist, size, punch){
  wire_size = calc_wire_size(wire_in, dist);
  wire_len = text_l + mold_r - wire_size[1]  + wire_seal_l + 10;
  wire(wire_in, dist, wire_len);
  rotate([0, 180, 0]) wire(wire_in, dist, wire_len);
  
  color("red") hull() glue(wire_in, dist, mold_r, text_l / 2);
  color("red") hull() rotate([0, 0, 180]) glue(wire_in, dist, mold_r, text_l / 2);
  color("red") difference(){
    hull(){
      translate([-text_l / 2 + text_t / 2, 0, 0]) sphere(r = text_t / 2);
      translate([text_l / 2 - text_t / 2, 0, 0]) sphere(r = text_t / 2);
      translate([-text_l / 2 + text_t / 2, wire_size[0] / 2 + mold_r + text_h - text_t / 2, 0]) sphere(r = text_t / 2);
      translate([text_l / 2 - text_t / 2, wire_size[0] / 2 + mold_r + text_h - text_t / 2, 0]) sphere(r = text_t / 2);
    }
    if(is_num(text_in)){
      translate([0, wire_size[0] / 2 + mold_r + text_h / 2, -punch * text_t]) dice(text_in, size = size / 10, t = text_t * 3);
    }
    else{
      translate([0, wire_size[0] / 2 + mold_r + text_h / 2, -punch * text_t]) linear_extrude(text_t * 3) text(text_in, halign = "center", valign = "center", size = size);
    }
  }
}



//             _____________________________
//      ______/                             \_______
//  
// wire_left[]             mold_r             wire_right[]
//      ______                               _______
//            \_____________________________/
//             |- mold_l[0] -|– mold_l[1] -|

module make_straigth_junction(wire_left, wire_right, mold_r, mold_l, dist = [0, 0], align = [1, 1, 1, 1]){
  wire_size_left = calc_wire_size(wire_left, dist[0]);
  wire_size_right = calc_wire_size(wire_right, dist[1]);
  wire_max_r = max(wire_size_left[1], wire_size_right[1]);
  mold_r = max(mold_r, wire_max_r + min_overmold);
  wire_max_y = max(wire_size_left[0], wire_size_right[0]) + mold_r * 2;
  
  xm = max(mold_l[0] + mold_r + wire_seal_l, runner_r + wall_t);
  xp = max(mold_l[1] + mold_r + wire_seal_l, runner_r + wall_t);
  ym = gate_runner_l + wire_max_y / 2;
  yp = wire_max_y / 2 + wall_t;
  zm = max(mold_r + wall_t, runner_r + wall_t);
  zp = zm;
  
  make_mold(xm, xp, ym, yp, zm, zp, align){
    straight_junction(wire_left, wire_right, mold_r, mold_l, dist);
    runner_gate(wire_max_y / 2);
  }
}



//                     |  wire_up[]   |
//                    /                \  ___
//                   |                  |
//                   |                  | mold_l[2]
//             ______|                  |___
//      ______/                             \_______
//   
// wire_left[]             mold_r              wire_right[]
//      ______                                _______
//            \_____________________________/
//             |- mold_l[0] -|– mold_l[1] -|


module make_T_junction(wire_left, wire_right, wire_up, mold_r, mold_l, dist = [0, 0, 0], align = [1, 1, 1, 1]){
  wire_size_left = calc_wire_size(wire_left, dist[0]);
  wire_size_right = calc_wire_size(wire_right, dist[1]);
  wire_size_up = calc_wire_size(wire_up, dist[2]);
  wire_max_r = max(wire_size_left[1], wire_size_right[1], wire_size_up[1]);
  mold_r = max(mold_r, wire_max_r + min_overmold);
  wire_max_y = max(wire_size_left[0], wire_size_right[0]) + mold_r * 2;
  
  xm = max(mold_l[0] + mold_r + wire_seal_l, runner_r + wall_t);
  xp = max(mold_l[1] + mold_r + wire_seal_l, runner_r + wall_t);
  ym = gate_runner_l + wire_max_y / 2;
  yp = max(wire_max_y / 2 + wall_t, mold_l[2] + mold_r + wire_seal_l);
  zm = max(mold_r + wall_t, runner_r + wall_t);
  zp = zm;
  
  make_mold(xm, xp, ym, yp, zm, zp, align){
    T_junction(wire_left, wire_right, wire_up, mold_r, mold_l, dist);
    runner_gate(wire_max_y / 2);
  }
}



//             |- text_l -|
//               ________
//              /        \  ____
//             |          |  
//             |   text   |  text_h
//             |__________| ____
//      ______/            \_______
//  
//      wire[]     mold_r    wire[]
//      ______              _______
//            \____________/ 

module make_label(wire_in, text_in, mold_r, text_l, text_h, text_t, dist = 0, size = 4, punch = 0, align = [1, 1, 1, 1]){
  wire_size = calc_wire_size(wire_in, dist);
  wire_max_r = wire_size[1];
  mold_r = max(mold_r, wire_max_r + min_overmold);
  wire_max_y = wire_size[0] + mold_r * 2;
  
  xm = max(text_l / 2 + mold_r + wire_seal_l, runner_r + wall_t);
  xp = max(text_l / 2 + mold_r + wire_seal_l, runner_r + wall_t);
  ym = gate_runner_l + wire_max_y / 2;
  yp = wire_max_y / 2 + text_h + wall_t;
  zm = max(mold_r + wall_t, runner_r + wall_t);
  zp = zm;
  
  make_mold(xm, xp, ym, yp, zm, zp, align){
    label(wire_in, text_in, mold_r, text_l, text_h, text_t, dist, size, punch);
    runner_gate(wire_max_y / 2);
  }
}



//make_straigth_junction([0.5, 2, 2], [1, 1, 1], 4, [5, 5], [1, 0.5]);
//make_T_junction([2, 0.5, 0.5, 2], [2, 0.5, 0.5, 2], [0.5, 0.5, 1, 1], 5, [10, 10, 15], [1, 1, 0.5]);

make_label(wire_in = [0.5, 0.5], text_in = "+", mold_r = 1, text_l = 5, text_h = 5, text_t = 1, dist = 1, size = 4, punch = 1);
//translate([0, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "+", mold_r = 1, text_l = 7.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 1);
//translate([20, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "-", mold_r = 1, text_l = 7.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 1);
//translate([50, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "3.3V", mold_r = 1, text_l = 17.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 0);
//translate([80, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "5V", mold_r = 1, text_l = 12.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 0);
//for(i = [0 : 9]) translate([20 * i, 0, 0]) make_label(wire_in = [0.5, 0.5], text_in = i, mold_r = 1, text_l = 7.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 1);

