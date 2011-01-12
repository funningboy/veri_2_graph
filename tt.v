module T10_iso2 (iso, in, out1, out2);
  input iso, in;
  output out1, out2;
    Block1 u1 (.in(in), .out(n1));
    Block2 u2 (.in(n1), .iso(iso), .out(out1));
    IsoAND_TL_1P ui (.A(n1), .Ib(iso), .Y(n2));
    Block3 u3 (.in(n2), .out(out2));
endmodule
module Block1 (in, out);
  input in;
  output out;
    SC_INV u0 (.A(in), .Y(out));
endmodule
module Block2 (iso, in, out);
  input iso, in;
  output out;
    IsoAND_TL_1P u_iso (.A(in), .Ib(iso), .Y(n1));
    SC_INV u1 (.A(n1), .Y(out));
endmodule
module Block3 (in, out);
  input in;
  output out;
    SC_INV u1 (.A(in), .Y(out));
endmodule

module SC_INV  (A, Y);
  input  A;
  output Y;
     not (Y, A);
endmodule
module IsoAND_TL_1P (A, Ib, Y);
  input  A, Ib;
  output Y;
     and (Y, Ib, A);
endmodule

