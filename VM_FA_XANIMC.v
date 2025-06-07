module half_add(
    input a,
    input b,
    output sum,
    output carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

module f_add(
     input a,
    input b,
    input cin,
    output sum,
    output cout
    );
    
    wire w1,w2,w3,w4;
    xnor (w1,a,b);
    and g1(w3,a,b);
    not (w2,w1);
    or (cout,w4,w3);
    and g2(w4,w2,cin);
    assign sum = (w1) ? cin : (~cin) ;
endmodule

module csa(
    input [3:0] a,
    input [3:0] b,
    input [3:0] c,
    output [4:0] s,
    output cout
);
    wire cr1, cr2, cr3, cr4, cr5, cr6, cr7, sw1, sw2, sw3;

    f_add u1(a[0], b[0], c[0], s[0], cr1);
    f_add u2(a[1], b[1], c[1], sw1, cr2);
    f_add u3(a[2], b[2], c[2], sw2, cr3);
    f_add u4(a[3], b[3], c[3], sw3, cr4);
    f_add u5(cr1, sw1, 0, s[1], cr5);
    f_add u6(cr2, sw2, cr5, s[2], cr6);
    f_add u7(cr3, sw3, cr6, s[3], cr7);
    f_add u8(cr4, 0, cr7, s[4], cout);
endmodule

module b2_vedicM(
    input a0,
    input a1,
    input b0,
    input b1,
    output s0,
    output s1,
    output s2,
    output s3
);
    wire w1, w2, w3, w4;
    
    and u1(s0, a0, b0);
    and u2(w1, b0, a1);
    and u3(w2, a0, b1);
    and u4(w4, a1, b1);
    half_add u5(w1, w2, s1, w3);
    half_add u6(w3, w4, s2, s3);
endmodule

module VM_FA_XANIMC(
    input [3:0] a,
    input [3:0] b,
    output [7:0] s
);
    wire w2, w3, x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3, f2, f3, f4, c1, c2;

    // Instantiating 2-bit Vedic multipliers for partial products
    b2_vedicM v1(a[0], a[1], b[0], b[1], s[0], s[1], w2, w3);
    b2_vedicM v2(a[0], a[1], b[2], b[3], x0, x1, x2, x3);
    b2_vedicM v3(a[2], a[3], b[0], b[1], y0, y1, y2, y3);
    b2_vedicM v4(a[2], a[3], b[2], b[3], z0, z1, z2, z3);

    // Carry Save Adder for summing the partial products
    csa u1({0, 0, w3, w2}, {x3, x2, x1, x0}, {y3, y2, y1, y0}, {f4, f3, f2, s[3], s[2]}, c1);
    csa u2({c1, f4, f3, f2}, {0, 0, 0, 0}, {z3, z2, z1, z0}, {c2, s[7], s[6], s[5], s[4]});
endmodule
