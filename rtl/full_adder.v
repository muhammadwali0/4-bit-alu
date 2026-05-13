// Full adder

module full_adder (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire Sum,
    output wire Cout
);

    wire xor1;
    wire and1, and2, and3;
    wire or1;

    // Sum path
    xor g_xor1 (xor1, A,    B);
    xor g_xor2 (Sum,  xor1, Cin);

    // Carry path
    and g_and1 (and1, A,    B);
    and g_and2 (and2, B,    Cin);
    and g_and3 (and3, A,    Cin);
    or  g_or1  (or1,  and1, and2);
    or  g_or2  (Cout, or1,  and3);

endmodule
