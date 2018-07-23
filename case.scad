$fs = 0.01;

inner_width = 112.00;
inner_height = 80.00;
//inner_width = 110.50;
//inner_height = 78.50;

wall = 2;
plate = 3;
holesize = 14;
outer_width = inner_width + (2 * wall);
outer_height = inner_height + (2 * wall);
depth = 15;
pro_micro_cutout = 18;
case_radious = 2;
bottom_shrink = 0.8;
standoff_radious = 2.4;
case_cut_angle = 3.6;

module case(x, y, z)
{
    radious = case_radious;

    minkowski() {
        cube([x - 2 * radious, y - 2 * radious, z]);
        translate ([radious, radious, 0]) {
            cylinder(r = radious, h = 0.1);
        }
    }
}

module case_hole(x, y, z)
{
    translate([wall, wall, plate]) {
        cube([x, y, z]);
    }
}

module case_diagonal_cut(x, y, z)
{
    translate([0 - wall / 2, 0, z]) {
        rotate([-case_cut_angle, 0, 0]) {
            cube([x + wall, y + wall, z]);
        }
    }
}

module case_cover_cutout(x, y, z)
{
    radious = case_radious;

    translate([0 + wall / 2, 0 + wall / 2, z - 1.5]) {
        rotate([-case_cut_angle, 0, 0]) {
            minkowski() {
                cube([x + wall - 2 * radious, y + wall - 2 * radious, z]);
                translate ([radious, radious, 0]) {
                    cylinder(r = radious, h = 0.1);
                }
            }
        }
    }
}

module standoff_hole(thread)
{
    if (thread) {
        cylinder(r = 1, h = depth);
    } else {
        cylinder(r = 1.1, h = depth);
    }
}

module standoff(r, z, thread = true)
{
    if (thread) {
        difference() {
            cylinder(h = z, r = r);
            translate([0, 0, plate + 2]) {
                standoff_hole(thread);
            }
        }
    } else {
        union() {
            cylinder(h = z, r = r);
            translate([0, 0, -plate]) {
                standoff_hole(thread);
            }
        }
    }
}

module standoffs(r, z, s, thread)
{
    if (thread) {
        translate([outer_width - wall - 11.6 - r, wall + 1.5 + r + 1, s]) standoff(r, z, thread);
    } else {
        translate([outer_width - 2 * wall - (11.3 - 0.6) - r, wall + (1.5 - 0.6) + r + 1, s]) standoff(r, z, thread);
    }

    if (thread) {
        translate([outer_width - wall - 15.6 - r, outer_height - wall - 14.7 - r - 0.75, s]) standoff(r, z, thread);
    } else {
        translate([outer_width - 2 * wall - (15.6 - 0.6) - r, outer_height - 2 * wall - (14.7 - 0.6) - r - 0.75, s]) standoff(r, z, thread);
    }

    if (thread) {
        translate([wall + 15.4 + r, outer_height - wall - 14.7 - r - 0.75, s]) standoff(r, z, thread);
    } else {
        translate([wall + (15.4 - 0.6) + r, outer_height - 2 * wall - (14.7 - 0.6) - r - 0.75, s]) standoff(r, z, thread);
    }

    if (thread) {
        translate([wall + 15.4 + r, wall + 20.7 + r + 1, s]) standoff(r, z, thread);
    } else {
        translate([wall + (15.4 - 0.6) + r, wall + (20.7 - 0.6) + r + 1, s]) standoff(r, z, thread);
    }
}

module switch_hole()
{
    hole_cutout = 1.6;

    union() {
        translate([0, 0, -wall]) {
            cube([holesize, holesize, depth]);
            translate([0 - hole_cutout / 2, 0.98, 0]) {
                cube([holesize + hole_cutout, 3.5, depth]);
            }
            translate([0 - hole_cutout / 2, holesize - 3.5 - 0.98, 0]) {
                cube([holesize + hole_cutout, 3.5, depth]);
            }
        }
    }
}

module switch_holes(columns, rows)
{
    spacer = 5;
    width_offset = (inner_width - (columns * holesize + (columns - 1) * spacer)) / 2;
    height_offset = (inner_height - (rows * holesize + (rows - 1) * spacer));   

    translate ([wall + width_offset, wall + height_offset - width_offset, 0]) {
        for (row = [0:rows - 1]) {
            for (column = [0:columns - 1]) {
                translate([column * (holesize + spacer), row * (holesize + spacer), 0]) {
                    switch_hole();
                }
            }
        }
    }
}

module pro_micro(width, height)
{
    translate([0, 0 - wall / 2, 0]) {
        difference() {
            cube([width, wall * 2, height]);
            translate([width / 2, 0, -height - (height / 1.5)]) {
                rotate([0, -30, 0]) {
                    cube([width, wall * 2, height]);
                }
            }
            mirror() {
                translate([-width / 2, 0, -height - (height / 1.5)]) {
                    rotate([0, -30, 0]) {
                        cube([width, wall * 2, height]);
                    }
                }
            }
        }
    }
}

module pro_micro_right(outer_width, left = false)
{
    distance = 11;
    side = 25;
    height = 3;
    width = 8;

    translate([outer_width - width - side, 0, distance]) {
        if (!left) {
            pro_micro(width, height);
        } else {
            rotate([0, 180, 0]) translate([-width + 0.8, 0, 1.4]) pro_micro(width, height);
        }
    }
}

module pro_micro_left(outer_width)
{
    pro_micro_right(outer_width, left = true);
}

module pro_micro_space(outer_width)
{
    reset_width = 11;
    width = 18 + reset_width;
    height = 1;
    side = 17.5;

    translate([outer_width - wall - width - side, 0, 0]) {
        translate([0, wall / 2, plate]) {
            cube([width, height + 1, depth - 1.5 - plate]);
        }
    }
}

module trrs_body(radious)
{
    rotate([90, 0, 0]) {
        cylinder(r = radious, h = wall * 2);
    }
}

module trrs(left = false)
{
    radious = 3;
    side = 15.7;
    distance = 6;

    if (!left) {
        translate([radious + side, wall + wall / 2, radious + distance]) {
            trrs_body(radious);
        }
    } else {
        translate([radious + side + 2.3, wall + wall / 2, radious + distance]) {
            trrs_body(radious);
        }
    }
}

module levinson_bottom(x, y, z)
{
    radious = case_radious;
    
    translate([bottom_shrink / 2, bottom_shrink / 2, 0]) {
        minkowski() {
            cube([x + wall - 2 * radious - bottom_shrink, y + wall - 2 * radious - bottom_shrink, z]);
            translate ([radious, radious, 0]) {
                cylinder(r = radious, h = 0.1);
            }
        }
    }
}

module levinson_bottom_rigth()
{
    space = 1.5; 
    bottom_depth = 2.4;

    translate([0 + wall / 2, 0 + wall / 2 + outer_height + 5, 0]) {
    //translate([0 + wall / 2, 0 + wall / 2, 14]) {
        difference() {
            levinson_bottom(inner_width, inner_height, bottom_depth);
            standoffs(2, depth, bottom_depth - space, thread = false);
        }
    }
}

module levinson_bottom_left()
{
    mirror() {
        levinson_bottom_rigth();
    }
}

module levinson_top_right(left = false)
{
    rows = 4;
    columns = 6;

    difference() {
        difference() {
            union() {
                difference() {
                    case(outer_width, outer_height, depth);
                    case_hole(inner_width, inner_height, depth);
                }
                standoffs(standoff_radious, depth, 0, true);
            }
            switch_holes(columns, rows);
            if (!left) {
                pro_micro_right(outer_width);
                pro_micro_space(outer_width);
            } else {
                pro_micro_left(outer_width);
                pro_micro_space(outer_width);
            }
            trrs(left);
        }
        case_diagonal_cut(outer_width, outer_height, depth);
        case_cover_cutout(inner_width, inner_height, depth);
    }
}

module levinson_top_left()
{
    mirror() {
        levinson_top_right(left = true);
    }
}

module levinson()
{
    translate([5, 0, 0]) {
        levinson_top_right();
        levinson_bottom_rigth();
    }

    translate([-5, 0, 0]) {
        levinson_top_left();
        levinson_bottom_left();
    }
}

levinson();
