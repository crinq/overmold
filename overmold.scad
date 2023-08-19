$fn = 20;
wall_t = 5;
wire_seal_l = 2.5;
gate_r = 0.75;
gate_l = 0.5;
runner_r = 3;
runner_l = 5;
inlet_l = 2;
min_overmold = 1;
align = [1, 1, 1, 1];
screw = 3; // 0 = no screw tabs
half_screw_tab = 1;

include <overmold_lib.scad>


//////////////////  straight connection  //////////////////////
//                                                           //
//                         _____   ____                      //
//                        /     \                            //
//            screw ->   |   O   | 3 * screw                 //
//             __________|_______|__________                 //
//      ______/                             \_______         //
//                                                           //
// wire_left[]             mold_r             wire_right[]   //
//      ______                               _______         //
//            \_____________________________/                //
//                       |       |                           //
//            screw ->   |   O   | 2 * screw                 //
//                        \_____/  _______                   //
//                                                           //
//             |- mold_l[0] -|– mold_l[1] -|                 //
//                                                           //
///////////////////////////////////////////////////////////////

//////////////////////  T junction  ///////////////////////////
//                                                           //
//                     |  wire_up[]   |                      //
//                 __ /                \ __     _____        //
//                /  |                  |  \                 //
//      screw -> / O |                  | O \    mold_l[2]   //
//             _|____|                  |___|_               //
//      ______/                               \_______       //
//                                                           //
// wire_left[]             mold_r              wire_right[]  //
//      ______                                 _______       //
//            \_______________________________/              //
//                       |       |                           //
//            screw ->   |   O   | 2 * screw                 //
//                        \_____/  _______                   //
//                                                           //
//             |- mold_l[0] -|– mold_l[1] -|                 // 
//                                                           //
///////////////////////////////////////////////////////////////

////////////////  label  ///////////////////
//                                        //
//             |- text_l -|               //
//               ________   ____          //
//              /        \                //
//             | text_in  |  text_h       //
//             |__________| ____          //
//      ______/            \_______       //
//                                        //
//   wire_in[]    mold_r    wire_in[]     //
//      ______              _______       //
//            \____________/              //
//              |       |                 //
//   screw ->   |   O   | 2 * screw       //
//               \_____/  _______         //
//                                        //
////////////////////////////////////////////

///////////////  grommet  ///////////////////////
//                                             //
//    mold_r[0]       mold_r[0]                //
//             \     /  mold_r[2]              //
//              _   _  /       mold_r[3]       //
//             / |_| \________/                //
//      ______/               \_______         //
//                |                            //
// wire_left[]  mold_r[1]       wire_right[]   //
//      ______                ________         //
//            \   _   _______/                 //
//             \_| |_/\      |                 //
//             / | | \ mold_l[2]               //
//      mold_l[0]| | mold_l[0]                 //
//             mold_l[1]                       //
//                                             //
/////////////////////////////////////////////////

//make_straigth_junction(wire_left = [2.25], wire_right = [0.62, 0.62, 0.62, 0.62], mold_r = 4, mold_l = [5, 5], dist = [1, 0.5]);
//make_T_junction(wire_left = [0.62, 0.62], wire_right = [0.62, 0.62], wire_up = [2.25], mold_r = 5, mold_l = [7.5, 7.5, 7.5], dist = [0.5, 0.5, 0.5]);
//make_grommet(wire_left = [1.5, 1.5, 0.62, 0.62], wire_right = [3], mold_r = [7.5, 5, 5, 4], mold_l = [1.5, 2, 20], dist = [0.5, 0.5]);

make_label(wire_in = [0.5, 0.5], text_in = "test", mold_r = 1, text_l = 5, text_h = 5, text_t = 1, dist = 1, size = 4, punch = 0);
//make_label(wire_in = [0.5, 0.5], text_in = "+", mold_r = 1, text_t = 1, dist = 1, size = 4, punch = 1);
//translate([0, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "+", mold_r = 1, text_l = 7.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 1);
//translate([20, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "-", mold_r = 1, text_l = 7.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 1);
//translate([50, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "3.3V", mold_r = 1, text_l = 17.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 0);
//translate([80, 70, 0]) make_label(wire_in = [0.5, 0.5], text_in = "5V", mold_r = 1, text_l = 12.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 0);
//for(i = [0 : 9]) translate([20 * i, 0, 0]) make_label(wire_in = [0.5, 0.5], text_in = i, mold_r = 1, text_l = 7.5, text_h = 7.5, text_t = 1, dist = 1, size = 5, punch = 1);

