// Testbench

`timescale 1ns/1ps

module alu_tb;

    reg  [3:0] A;
    reg  [3:0] B;
    reg        SUB;
    reg  [1:0] S;

    wire [3:0] R;
    wire       C, Z, P, OVF;

    alu dut (
        .A(A), .B(B), .SUB(SUB), .S(S),
        .R(R), .C(C), .Z(Z), .P(P), .OVF(OVF)
    );

    initial begin
        $dumpfile("sim/alu.vcd");
        $dumpvars(0, alu_tb);
    end

    integer pass_count, fail_count;

    task check;
        input [3:0] exp_r;
        input       exp_c, exp_z, exp_p, exp_ovf;
        begin
            if (R===exp_r && C===exp_c && Z===exp_z && P===exp_p && OVF===exp_ovf) begin
                $display("PASS | A=%b B=%b SUB=%b S=%b | R=%b C=%b Z=%b P=%b OVF=%b",
                          A, B, SUB, S, R, C, Z, P, OVF);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL | A=%b B=%b SUB=%b S=%b", A, B, SUB, S);
                $display("       got R=%b C=%b Z=%b P=%b OVF=%b", R, C, Z, P, OVF);
                $display("       exp R=%b C=%b Z=%b P=%b OVF=%b",
                          exp_r, exp_c, exp_z, exp_p, exp_ovf);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;
        A=0; B=0; SUB=0; S=2'b00; #20;

        $display("ALU Testbench");

        $display("\nADD (SUB=0, S=00)");

        A=4'b0101; B=4'b0011; SUB=0; S=2'b00; #10;
        check(4'b1000, 0, 0, 1, 1);

        A=4'b1111; B=4'b0001; SUB=0; S=2'b00; #10;
        check(4'b0000, 1, 1, 0, 0);

        A=4'b0000; B=4'b0000; SUB=0; S=2'b00; #10;
        check(4'b0000, 0, 1, 0, 0);

        A=4'b0111; B=4'b0001; SUB=0; S=2'b00; #10;
        check(4'b1000, 0, 0, 1, 1);

        A=4'b0001; B=4'b0001; SUB=0; S=2'b00; #10;
        check(4'b0010, 0, 0, 1, 0);

        #20;

        $display("\nSUB (SUB=1, S=00)");

        A=4'b1000; B=4'b0001; SUB=1; S=2'b00; #10;
        check(4'b0111, 1, 0, 1, 1);

        A=4'b0101; B=4'b0101; SUB=1; S=2'b00; #10;
        check(4'b0000, 1, 1, 0, 0);

        A=4'b0011; B=4'b0101; SUB=1; S=2'b00; #10;
        check(4'b1110, 0, 0, 1, 0);

        A=4'b0000; B=4'b0001; SUB=1; S=2'b00; #10;
        check(4'b1111, 0, 0, 0, 0);

        #20;

        $display("\nAND (SUB=0, S=01)");

        A=4'b1100; B=4'b1010; SUB=0; S=2'b01; #10;
        check(4'b1000, 1, 0, 1, 1);

        A=4'b1111; B=4'b0000; SUB=0; S=2'b01; #10;
        check(4'b0000, 0, 1, 0, 0);

        A=4'b1111; B=4'b1111; SUB=0; S=2'b01; #10;
        check(4'b1111, 1, 0, 0, 0);

        A=4'b1010; B=4'b0101; SUB=0; S=2'b01; #10;
        check(4'b0000, 0, 1, 0, 0);

        #20;

        $display("\nOR (SUB=0, S=10)");

        A=4'b1100; B=4'b1010; SUB=0; S=2'b10; #10;
        check(4'b1110, 1, 0, 1, 1);

        A=4'b0000; B=4'b0000; SUB=0; S=2'b10; #10;
        check(4'b0000, 0, 1, 0, 0);

        A=4'b1010; B=4'b0101; SUB=0; S=2'b10; #10;
        check(4'b1111, 0, 0, 0, 0);

        A=4'b0001; B=4'b0010; SUB=0; S=2'b10; #10;
        check(4'b0011, 0, 0, 0, 0);

        #20;

        $display("\nXOR (SUB=0, S=11)");

        A=4'b1100; B=4'b1010; SUB=0; S=2'b11; #10;
        check(4'b0110, 1, 0, 0, 1);

        A=4'b1111; B=4'b1111; SUB=0; S=2'b11; #10;
        check(4'b0000, 1, 1, 0, 0);

        A=4'b1010; B=4'b0101; SUB=0; S=2'b11; #10;
        check(4'b1111, 0, 0, 0, 0);

        A=4'b0000; B=4'b0000; SUB=0; S=2'b11; #10;
        check(4'b0000, 0, 1, 0, 0);

        #20;

        $display("\nParity verification");

        A=4'b0001; B=4'b0000; SUB=0; S=2'b00; #10;
        if (R===4'b0001 && P===1'b1) begin
            $display("PASS | R=0001 P=1 (odd parity)");
            pass_count=pass_count+1;
        end else begin
            $display("FAIL | R=0001 expected P=1, got P=%b", P);
            fail_count=fail_count+1;
        end

        A=4'b0010; B=4'b0001; SUB=0; S=2'b00; #10;
        if (R===4'b0011 && P===1'b0) begin
            $display("PASS | R=0011 P=0 (even parity)");
            pass_count=pass_count+1;
        end else begin
            $display("FAIL | R=0011 expected P=0, got P=%b", P);
            fail_count=fail_count+1;
        end

        A=4'b0100; B=4'b0011; SUB=0; S=2'b00; #10;
        if (R===4'b0111 && P===1'b1) begin
            $display("PASS | R=0111 P=1 (odd parity)");
            pass_count=pass_count+1;
        end else begin
            $display("FAIL | R=0111 expected P=1, got P=%b", P);
            fail_count=fail_count+1;
        end

        A=4'b1000; B=4'b0111; SUB=0; S=2'b00; #10;
        if (R===4'b1111 && P===1'b0) begin
            $display("PASS | R=1111 P=0 (even parity)");
            pass_count=pass_count+1;
        end else begin
            $display("FAIL | R=1111 expected P=0, got P=%b", P);
            fail_count=fail_count+1;
        end

        #20;

        $display("  Results: %0d passed, %0d failed", pass_count, fail_count);
        $finish;
    end

endmodule
