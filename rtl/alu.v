// 4-bit ALU

module alu (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       SUB,
    input  wire [1:0] S,
    output wire [3:0] R,
    output wire       C,
    output wire       Z,
    output wire       P,
    output wire       OVF
);

    wire [3:0] B_sel;
    xor g_bxor0 (B_sel[0], B[0], SUB);
    xor g_bxor1 (B_sel[1], B[1], SUB);
    xor g_bxor2 (B_sel[2], B[2], SUB);
    xor g_bxor3 (B_sel[3], B[3], SUB);

    wire [3:0] sum;
    wire       c0, c1, c2;
    wire       c3_in;

    full_adder fa0 (.A(A[0]), .B(B_sel[0]), .Cin(SUB),  .Sum(sum[0]), .Cout(c0));
    full_adder fa1 (.A(A[1]), .B(B_sel[1]), .Cin(c0),   .Sum(sum[1]), .Cout(c1));
    full_adder fa2 (.A(A[2]), .B(B_sel[2]), .Cin(c1),   .Sum(sum[2]), .Cout(c2));
    full_adder fa3 (.A(A[3]), .B(B_sel[3]), .Cin(c2),   .Sum(sum[3]), .Cout(C));

    assign c3_in = c2;

    wire [3:0] and_out, or_out, xor_out;

    and g_and0 (and_out[0], A[0], B[0]);
    and g_and1 (and_out[1], A[1], B[1]);
    and g_and2 (and_out[2], A[2], B[2]);
    and g_and3 (and_out[3], A[3], B[3]);

    or  g_or0  (or_out[0],  A[0], B[0]);
    or  g_or1  (or_out[1],  A[1], B[1]);
    or  g_or2  (or_out[2],  A[2], B[2]);
    or  g_or3  (or_out[3],  A[3], B[3]);

    xor g_xor0 (xor_out[0], A[0], B[0]);
    xor g_xor1 (xor_out[1], A[1], B[1]);
    xor g_xor2 (xor_out[2], A[2], B[2]);
    xor g_xor3 (xor_out[3], A[3], B[3]);

    wire S1n, S0n;
    not g_s1n (S1n, S[1]);
    not g_s0n (S0n, S[0]);

    wire sel00, sel01, sel10, sel11;
    and g_sel00 (sel00, S1n, S0n);
    and g_sel01 (sel01, S1n, S[0]);
    and g_sel10 (sel10, S[1], S0n);
    and g_sel11 (sel11, S[1], S[0]);

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : mux_bit
            wire m0, m1, m2, m3;
            and ga0 (m0, sel00, sum[i]);
            and ga1 (m1, sel01, and_out[i]);
            and ga2 (m2, sel10, or_out[i]);
            and ga3 (m3, sel11, xor_out[i]);
            or  go  (R[i], m0, m1, m2, m3);
        end
    endgenerate

    wire or_r10, or_r32, or_r3210;
    or  g_zor0  (or_r10,   R[1], R[0]);
    or  g_zor1  (or_r32,   R[3], R[2]);
    or  g_zor2  (or_r3210, or_r32, or_r10);
    not g_znot  (Z, or_r3210);

    xor g_ovf (OVF, c3_in, C);

    wire xp0, xp1;
    xor g_p0 (xp0, R[3], R[2]);
    xor g_p1 (xp1, R[1], R[0]);
    xor g_p2 (P,   xp0,  xp1);

endmodule
