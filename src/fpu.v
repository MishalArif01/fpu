module fpu(sign1,exp1,mantissa1,sign2,exp2,mantissa2,sign3,exp3,mantissa3,RNE,RTZ,RDN,RVP,RMM,round_sign,round_exp,round_mantissa,inexact,invalid,overflow,underflow,infinite);

//FP 1
input         sign1;
input  [7:0]  exp1;
input  [22:0] mantissa1;

//FP 2
input         sign2;
input  [7:0]  exp2;
input  [22:0] mantissa2;

//FP 3
input         sign3;
input  [7:0]  exp3;
input  [22:0] mantissa3;

input             RNE;
input             RTZ;
input             RDN;
input             RVP;
input             RMM;

output reg         round_sign;
output reg  [7:0]  round_exp;
output reg  [23:0] round_mantissa;

output wire inexact;
output reg  invalid;
output reg  overflow;
output reg  underflow;
output reg  infinite;


wire        out_sign;
wire [9:0]  out_exp;
wire [26:0] out_mantissa;

wire         round_sign_o;
wire  [9:0]  round_exp_o;
wire  [23:0] round_mantissa_o;

reg        sign_ov;
reg [7:0]  exp_ov;
reg [23:0] mant_ov;

reg        sign_un;
reg [7:0]  exp_un;
reg [23:0] mant_un;

reg        mul_sign;
reg [9:0]  mul_exp;
reg [47:0] mul_mantissa;


reg infinite1;
reg infinite2;

wire         is_signalling1; // is the value a signalling NaN
wire         is_quiet1;      // is the value a quiet NaN

wire         is_signalling2; // is the value a signalling NaN
wire         is_quiet2;      // is the value a quiet NaN

wire         is_signalling3; // is the value a signalling NaN
wire         is_quiet3;      // is the value a quiet NaN

fpu_multiplier mult
(

                         .sign1         (sign1),
			 .exp1          (exp1),
			 .mantissa1     (mantissa1),
			 .sign2         (sign2),
			 .exp2          (exp2),
			 .mantissa2     (mantissa2),
			 .out_sign      (mul_sign),
			 .out_exp       (mul_exp),
			 .out_mantissa  (mul_mantissa),
			 .is_signalling1 (is_signalling1),
			 .is_quiet1      (is_quiet1),
			 .is_signalling2 (is_signalling2),
			 .is_quiet2      (is_quiet2)
			 
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
			 .invalid1      (invalid),
			 .is_signalling2 (is_signalling3),
			 .is_quiet2      (is_quiet3)
		  );

rounding  round
        (
		    .norm_sign      (out_sign),
			 .norm_exp       (out_exp),
			 .norm_mantissa  (out_mantissa),
			 .RNE            (RNE),
			 .RTZ            (RTZ),
			 .RDN            (RDN),
			 .RVP            (RVP),
			 .RMM            (RMM),
			 .round_sign     (round_sign_o),
			 .round_exp      (round_exp_o),
			 .round_mantissa (round_mantissa_o)
			 
		 );

assign inexact = (|out_mantissa[1:0] | out_mantissa[2]) | underflow | overflow;
assign infinite = infinite1 | infinite2;

always@(*)
begin
overflow  = 1'b0;
underflow = 1'b0;

if(is_signalling1 | is_quiet1)
begin
  round_sign     = sign1;
  round_exp      = 8'b11111111;
  round_mantissa = {1'b1,1'b1,mantissa1[21:0]};
end

else if(is_signalling2 | is_quiet2)
begin
  round_sign     = sign2;
  round_exp      = 8'b11111111;
  round_mantissa = {1'b1,1'b1,mantissa2[21:0]};
end

else if(is_signalling3 | is_quiet3)
begin
  round_sign     = sign3;
  round_exp      = 8'b11111111;
  round_mantissa = {1'b1,1'b1,mantissa3[21:0]};
end

/*else if(({sign1,exp1,mantissa1} == 32'd0) & ({sign2,exp2,mantissa2} == 32'd0))
begin
   round_sign     = 1'b0;
   round_exp      = round_exp_o;
   round_mantissa = round_mantissa_o;
end*/

else if(RDN & (round_exp_o == 8'd0) & (round_mantissa_o[22:0] == 23'd0) & (mant_un == 24'd0))
begin

   round_sign     = 1'b1;
   round_exp      = round_exp_o;
   round_mantissa = round_mantissa_o;
 
end

else if((($signed(round_exp_o)) >= 255) & ((exp1 != 8'hff) & (exp2 != 8'hff) & (exp3 != 8'hff)))
begin

   round_sign     = sign_ov;
   round_exp      = exp_ov;
   round_mantissa = mant_ov;
   overflow       = 1'b1;
   
end

else if((($signed(round_exp_o)) == 0) & round_mantissa_o[23])
begin

   round_sign     = round_sign_o;
   round_exp      = (exp3 == 8'd0) ? (round_exp_o+1'b1) : round_exp_o;
   round_mantissa = (exp3 == 8'd0) ? round_mantissa_o   : {1'b1,(round_mantissa_o>>1'b1)}; 
   
end

else if(((($signed(round_exp_o)) < 0) & round_mantissa_o[23]))
begin

   round_sign     = sign_un;
   round_exp      = exp_un;
   round_mantissa = mant_un;
   underflow      = 1'b1;  //1'b0
   
end


else
begin

   round_sign     = round_sign_o;
   round_exp      = round_exp_o[7:0];
   round_mantissa = round_mantissa_o;
   
end
end

always@(*)
begin
infinite2 = 1'b0;
if(RNE | RMM | (RVP & ~round_sign_o) | (RDN & round_sign_o))
begin
{sign_ov,exp_ov,mant_ov} = {round_sign_o,8'b11111111,24'b100000000000000000000000};
infinite2                = 1'b1;
end

else
begin
{sign_ov,exp_ov,mant_ov} = {round_sign_o,8'b11111110,24'b111111111111111111111111};
end

end

always@(*)
begin
   sign_un = round_sign_o;
   exp_un  = 8'd0;
   mant_un = (exp3==8'd0)? (round_mantissa_o >> (-round_exp_o + 1'b1 - ($signed(mul_exp) < 0))) : (round_mantissa_o >> (-round_exp_o + 1'b1));
end


endmodule
