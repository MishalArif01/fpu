module rounding(norm_sign,norm_exp,norm_mantissa,RNE,RTZ,RDN,RVP,RMM,round_sign,round_exp,round_mantissa);

input             norm_sign;
input     [9:0]   norm_exp;
input     [26:0]  norm_mantissa;
input             RNE;
input             RTZ;
input             RDN;
input             RVP;
input             RMM;

output            round_sign;
output reg [9:0]  round_exp;
output reg [23:0] round_mantissa;

wire    [23:0] significand_RTZ;
wire    [23:0] significand_RUP;
wire    [23:0] significand_RDN;
wire    [23:0] significand_RNE;
wire    [23:0] significand_RMM;


wire    [9:0]  rnd_exp_RUP;
wire    [9:0]  rnd_exp_RDN;
wire    [9:0]  rnd_exp_RNE;
wire    [9:0]  rnd_exp_RMM;

wire    [24:0] sig;
wire    [23:0] signif;
wire    [9:0]  rnd_exp;

wire round_up;


assign significand_RTZ = norm_mantissa[26:3];

assign significand_RUP = (~norm_sign &   |norm_mantissa[2:0] == 1'b1)  ? signif : norm_mantissa[26:3];
assign rnd_exp_RUP     = (~norm_sign &   |norm_mantissa[2:0] == 1'b1)  ? rnd_exp : norm_exp;

assign significand_RDN = (norm_sign  &   |norm_mantissa[2:0] == 1'b1)  ? signif : norm_mantissa[26:3];
assign rnd_exp_RDN     = (norm_sign  &   |norm_mantissa[2:0] == 1'b1)  ? rnd_exp: norm_exp;

assign significand_RNE = (((norm_mantissa[2:0] == 3'b100) & (norm_mantissa[3] == 1'b1)) | (norm_mantissa[2] == 1'b1 & |norm_mantissa[1:0] == 1'b1)) ? signif : norm_mantissa[26:3];
assign rnd_exp_RNE     = (((norm_mantissa[2:0] == 3'b100) & (norm_mantissa[3] == 1'b1)) | (norm_mantissa[2] == 1'b1 & |norm_mantissa[1:0] == 1'b1)) ? rnd_exp: norm_exp; 

assign significand_RMM =  (norm_mantissa[2] == 1'b1) ? signif : norm_mantissa[26:3];
assign rnd_exp_RMM     =  (norm_mantissa[2] == 1'b1) ? rnd_exp: norm_exp; 

assign sig             = {1'b0,norm_mantissa[26:3]} + 1'b1;
assign signif          = (sig[24] == 1'b1) ? (sig[24:0] >> 1'b1) : sig;
assign rnd_exp         = (sig[24] == 1'b1) ? (norm_exp + 1'b1)   : norm_exp;

assign round_sign      = norm_sign;


always@(*)
begin

case({RMM,RTZ,RVP,RDN,RNE})

5'b10000: begin
         round_mantissa = significand_RMM;
	 round_exp      = rnd_exp_RMM;
	 end

5'b01000: begin
         round_mantissa = significand_RTZ;
	 round_exp      = norm_exp;
	 end
			
5'b00100: begin
         round_mantissa = significand_RUP;
	 round_exp      = rnd_exp_RUP;
	 end
			
5'b00010: begin
         round_mantissa = significand_RDN;
	 round_exp      = rnd_exp_RDN;
	 end
			
5'b00001: begin
         round_mantissa = significand_RNE;
	 round_exp      = rnd_exp_RNE;
	 end
			
default: begin
         round_mantissa = significand_RTZ;
	 round_exp      = norm_exp;
	 end

endcase

end 



endmodule
