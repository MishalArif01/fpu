module fpu_
mul_add(sign1,exp1,mantissa1,sign2,exp2,mantissa2,sign3,exp3,mantissa3,out_sign,out_exp,out_mantissa);
//FP 1
input         sign1;
input  [7:0]  exp1;
input  [22:0] mantissa1;

//FP 2
input         sign2;
input  [7:0]  exp2;
input  [22:0] mantissa2;

//FP 2
input         sign3;
input  [7:0]  exp3;
input  [22:0] mantissa3;

//Sum
output reg        out_sign;
output reg [8:0]  out_exp;
output reg [26:0] out_mantissa;

reg        mul_sign;
reg [9:0]  mul_exp;
reg [47:0] mul_mantissa;


fpu_multiplier mult
(

                         .sign1         (sign1),
			 .exp1          (exp1),
			 .mantissa1     (mantissa1),
			 .sign2         (sign2),
			 .exp2          (exp2),
			 .mantissa2     (mantissa2),
			 .out_sign      (out_sign),
			 .out_exp       (out_exp),
			 .out_mantissa  (out_mantissa)
			 
);

fpu_adder add
        (

                         .sign1         (mul_sign),
			 .exp1          (mul_exp),
			 .mantissa1     (mul_mantissa),
			 .sign2         (sign3),
			 .exp2          (exp3),
			 .mantissa2     (mantissa3),
			 .out_sign      (out_sign),
			 .out_exp       (out_exp),
			 .out_mantissa  (out_mantissa),
			 .infinite1     (infinite1),
			 .invalid1      (invalid)
		  );

endmodule
