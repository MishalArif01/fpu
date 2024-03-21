module fpu_multiplier(sign1,exp1,mantissa1,sign2,exp2,mantissa2,out_sign,out_exp,out_mantissa,is_signalling1,is_quiet1,is_signalling2,is_quiet2);

//FP 1
input         sign1;
input  [7:0]  exp1;
input  [22:0] mantissa1;

//FP 2
input         sign2;
input  [7:0]  exp2;
input  [22:0] mantissa2;

//Sum
output  reg        out_sign;
output  reg [9:0]  out_exp;
output  reg [47:0] out_mantissa;

output reg         is_signalling1; // is the value a signalling NaN
output reg         is_quiet1;      // is the value a quiet NaN

output reg         is_signalling2; // is the value a signalling NaN
output reg         is_quiet2;      // is the value a quiet NaN


wire [23:0]  mantissa11;
wire [23:0]  mantissa22;
wire [9:0]   out_exp_o;
wire [47:0]  out_mantissa_o;

reg  [9:0]   temp_exp;
reg  [9:0]   exp_norm1;
reg  [9:0]   exp_norm2;
reg  [9:0]   exp11;
reg  [9:0]   exp22;
reg  [47:0]  prod;

reg  [23:0] mant_norm1;
reg  [23:0] mant_norm2;

reg         is_normal1;     // is the value normal
reg         is_subnormal1;  // is the value subnormal
reg         is_zero1;       // is the value zero
reg         is_inf1;        // is the value infinity

reg         is_normal2;     // is the value normal
reg         is_subnormal2;  // is the value subnormal
reg         is_zero2;       // is the value zero
reg         is_inf2;        // is the value infinity



assign mantissa11     = is_subnormal1 ? mant_norm1:{1'b1,mantissa1};
assign mantissa22     = is_subnormal2 ? mant_norm2:{1'b1,mantissa2};
assign exp11          = is_subnormal1 ? exp_norm1 :exp1;
assign exp22          = is_subnormal2 ? exp_norm2 :exp2;
assign out_exp_o      = temp_exp;
assign out_mantissa_o = prod;

always@(*)
begin
  is_normal1       = 1'b0;    
  is_subnormal1    = 1'b0;  
  is_zero1         = 1'b0;      
  is_inf1          = 1'b0;        
  is_signalling1   = 1'b0;
  is_quiet1        = 1'b0;
  
if((exp1 == 8'b11111111) & (mantissa1[22] == 1'b0) & (|mantissa1[21:0] == 1'b1))
begin
  is_signalling1 = 1'b1;
end

else if((exp1 == 8'b11111111) & (mantissa1[22] == 1'b1))
begin
  is_quiet1      = 1'b1;
end

else if((exp1 == 8'b11111111) & (mantissa1[22:0] == 23'd0))
begin
  is_inf1        = 1'b1;
end

else if((exp1 == 8'd0) & (mantissa1[22:0] == 23'd0))
begin
  is_zero1       = 1'b1;
end

else if((exp1 == 8'd0) & (|mantissa1[22:0] == 1'b1))
begin
  is_subnormal1  = 1'b1;
end

else
begin
  is_normal1     = 1'b1;
end

end


always@(*)
begin

  is_normal2       = 1'b0;    
  is_subnormal2    = 1'b0;  
  is_zero2         = 1'b0;      
  is_inf2          = 1'b0;        
  is_signalling2   = 1'b0;
  is_quiet2        = 1'b0;

if((exp2 == 8'b11111111) & (mantissa2[22] == 1'b0) & (|mantissa2[21:0] == 1'b1))
begin
  is_signalling2  = 1'b1;
end

else if((exp2 == 8'b11111111) & (mantissa2[22] == 1'b1))
begin
  is_quiet2      = 1'b1;
end

else if((exp2 == 8'b11111111) & (mantissa2[22:0] == 23'd0))
begin
  is_inf2        = 1'b1;
end

else if((exp2 == 8'd0) & (mantissa2[22:0] == 23'd0))
begin
  is_zero2       = 1'b1;
end

else if((exp2 == 8'd0) & (|mantissa2[22:0] == 1'b1))
begin
  is_subnormal2  = 1'b1;
end

else
begin
  is_normal2     = 1'b1;
end

end


always@(*)
begin

if((is_inf1 & is_zero2) | (is_inf2 & is_zero1))
begin
  out_sign     = 1'b1;
  out_exp      = 8'b11111111;
  out_mantissa = {1'b1,1'b1,mantissa1[21:0],3'b0};
end

else if((is_inf1 & ~is_zero2) | (is_inf2 & ~is_zero1))
begin
  out_sign      = sign1 ^ sign2;
  out_exp      = 8'b11111111;
  out_mantissa = {1'b1,47'd0};
end

else if(is_zero1 | is_zero2)
begin
  out_sign      = sign1 ^ sign2;
  out_exp      = 8'd0;
  out_mantissa = {1'b1,47'd0};
end

else
begin
  out_exp      = out_exp_o;
  out_mantissa = out_mantissa_o;
  out_sign     = sign1 ^ sign2;
end

end

always @ ( * )
begin

if(mantissa1[22:0] ==        23'b00000000000000000000001)
begin
exp_norm1      = exp1 - 8'd23;
mant_norm1     = {1'b0,mantissa1[22:0]} << 23;
end

else if(mantissa1[22:1] ==   22'b0000000000000000000001)
begin
exp_norm1      = exp1 - 8'd22;
mant_norm1     = {1'b0,mantissa1[22:0]} << 22;
end

else if(mantissa1[22:2] ==   21'b000000000000000000001)
begin
exp_norm1      = exp1 - 8'd21;
mant_norm1     = {1'b0,mantissa1[22:0]} << 21;
end

else if (mantissa1[22:3] ==  20'b00000000000000000001)
begin
exp_norm1      = exp1 - 8'd20;
mant_norm1     = {1'b0,mantissa1[22:0]} << 20;
end

else if (mantissa1[22:4] ==  19'b0000000000000000001)
begin
exp_norm1      = exp1 - 8'd19;
mant_norm1     = {1'b0,mantissa1[22:0]} << 19;
end

else if (mantissa1[22:5] ==  18'b000000000000000001)
begin 
exp_norm1      = exp1 - 8'd18;
mant_norm1     = {1'b0,mantissa1[22:0]} << 18;
end

else if (mantissa1[22:6] ==  17'b00000000000000001)
begin
exp_norm1      = exp1 - 8'd17;
mant_norm1     = {1'b0,mantissa1[22:0]} << 17;
end

else if (mantissa1[22:7] ==  16'b0000000000000001)
begin
exp_norm1      = exp1 - 8'd16;
mant_norm1     = {1'b0,mantissa1[22:0]} << 16;
end

else if (mantissa1[22:8] ==  15'b000000000000001)
begin
exp_norm1      = exp1 - 8'd15;
mant_norm1     = {1'b0,mantissa1[22:0]} << 15;
end

else if (mantissa1[22:9] ==  14'b00000000000001)
begin
exp_norm1      = exp1 - 8'd14;
mant_norm1     = {1'b0,mantissa1[22:0]} << 14;
end

else if (mantissa1[22:10] == 13'b0000000000001)
begin
exp_norm1      = exp1 - 8'd13;
mant_norm1     = {1'b0,mantissa1[22:0]} << 13;
end

else if (mantissa1[22:11] == 12'b000000000001)
begin
exp_norm1      = exp1 - 8'd12;
mant_norm1     = {1'b0,mantissa1[22:0]} << 12;
end

else if (mantissa1[22:12] == 11'b00000000001)
begin
exp_norm1      = exp1 - 8'd11;
mant_norm1     = {1'b0,mantissa1[22:0]} << 11;
end

else if (mantissa1[22:13] == 10'b0000000001)
begin
exp_norm1      = exp1 - 8'd10;
mant_norm1     = {1'b0,mantissa1[22:0]} << 10;
end

else if (mantissa1[22:14] == 9'b000000001)
begin
exp_norm1      = exp1 - 8'd9;
mant_norm1     = {1'b0,mantissa1[22:0]} << 9;
end

else if (mantissa1[22:15] == 8'b00000001)
begin
exp_norm1      = exp1 - 8'd8;
mant_norm1     = {1'b0,mantissa1[22:0]} << 8;
end

else if (mantissa1[22:16] == 7'b0000001)
begin
exp_norm1      = exp1 - 8'd7;
mant_norm1     = {1'b0,mantissa1[22:0]} << 7;
end

else if (mantissa1[22:17] == 6'b000001)
begin
exp_norm1      = exp1 - 8'd6;
mant_norm1     = {1'b0,mantissa1[22:0]} << 6;
end

else if (mantissa1[22:18] == 5'b00001)
begin
exp_norm1      = exp1 - 8'd5;
mant_norm1     = {1'b0,mantissa1[22:0]} << 5;
end

else if (mantissa1[22:19] == 4'b0001)
begin
exp_norm1      = exp1 - 8'd4;
mant_norm1     = {1'b0,mantissa1[22:0]} << 4;
end

else if (mantissa1[22:20] == 3'b001)
begin
exp_norm1      = exp1 - 8'd3;
mant_norm1     = {1'b0,mantissa1[22:0]} << 3;
end

else if (mantissa1[22:21] == 2'b01)
begin
exp_norm1      = exp1 - 8'd2;
mant_norm1     = {1'b0,mantissa1[22:0]} << 2;
end

else
begin
exp_norm1      = exp1 - 8'd1;
mant_norm1     = {1'b0,mantissa1[22:0]} << 1;
end


end

always @ ( * )
begin

if(mantissa2[22:0] ==        23'b00000000000000000000001)
begin
exp_norm2      = exp2 - 8'd23;
mant_norm2     = {1'b0,mantissa2[22:0]} << 23;
end

else if(mantissa2[22:1] ==   22'b0000000000000000000001)
begin
exp_norm2      = exp2 - 8'd22;
mant_norm2     = {1'b0,mantissa2[22:0]} << 22;
end

else if(mantissa2[22:2] ==   21'b000000000000000000001)
begin
exp_norm2      = exp2 - 8'd21;
mant_norm2     = {1'b0,mantissa2[22:0]} << 21;
end

else if (mantissa2[22:3] ==  20'b00000000000000000001)
begin
exp_norm2      = exp2 - 8'd20;
mant_norm2     = {1'b0,mantissa2[22:0]} << 20;
end

else if (mantissa2[22:4] ==  19'b0000000000000000001)
begin
exp_norm2      = exp2 - 8'd19;
mant_norm2     = {1'b0,mantissa2[22:0]} << 19;
end

else if (mantissa2[22:5] ==  18'b000000000000000001)
begin 
exp_norm2      = exp2 - 8'd18;
mant_norm2     = {1'b0,mantissa2[22:0]} << 18;
end

else if (mantissa2[22:6] ==  17'b00000000000000001)
begin
exp_norm2      = exp2 - 8'd17;
mant_norm2     = {1'b0,mantissa2[22:0]} << 17;
end

else if (mantissa2[22:7] ==  16'b0000000000000001)
begin
exp_norm2      = exp2 - 8'd16;
mant_norm2     = {1'b0,mantissa2[22:0]} << 16;
end

else if (mantissa2[22:8] ==  15'b000000000000001)
begin
exp_norm2      = exp2 - 8'd15;
mant_norm2     = {1'b0,mantissa2[22:0]} << 15;
end

else if (mantissa2[22:9] ==  14'b00000000000001)
begin
exp_norm2      = exp2 - 8'd14;
mant_norm2     = {1'b0,mantissa2[22:0]} << 14;
end

else if (mantissa2[22:10] == 13'b0000000000001)
begin
exp_norm2      = exp2 - 8'd13;
mant_norm2     = {1'b0,mantissa2[22:0]} << 13;
end

else if (mantissa2[22:11] == 12'b000000000001)
begin
exp_norm2      = exp2 - 8'd12;
mant_norm2     = {1'b0,mantissa2[22:0]} << 12;
end

else if (mantissa2[22:12] == 11'b00000000001)
begin
exp_norm2      = exp2 - 8'd11;
mant_norm2     = {1'b0,mantissa2[22:0]} << 11;
end

else if (mantissa2[22:13] == 10'b0000000001)
begin
exp_norm2      = exp2 - 8'd10;
mant_norm2     = {1'b0,mantissa2[22:0]} << 10;
end

else if (mantissa2[22:14] == 9'b000000001)
begin
exp_norm2      = exp2 - 8'd9;
mant_norm2     = {1'b0,mantissa2[22:0]} << 9;
end

else if (mantissa2[22:15] == 8'b00000001)
begin
exp_norm2      = exp2 - 8'd8;
mant_norm2     = {1'b0,mantissa2[22:0]} << 8;
end

else if (mantissa2[22:16] == 7'b0000001)
begin
exp_norm2      = exp2 - 8'd7;
mant_norm2     = {1'b0,mantissa2[22:0]} << 7;
end

else if (mantissa2[22:17] == 6'b000001)
begin
exp_norm2      = exp2 - 8'd6;
mant_norm2     = {1'b0,mantissa2[22:0]} << 6;
end

else if (mantissa2[22:18] == 5'b00001)
begin
exp_norm2      = exp2 - 8'd5;
mant_norm2     = {1'b0,mantissa2[22:0]} << 5;
end

else if (mantissa2[22:19] == 4'b0001)
begin
exp_norm2      = exp2 - 8'd4;
mant_norm2     = {1'b0,mantissa2[22:0]} << 4;
end

else if (mantissa2[22:20] == 3'b001)
begin
exp_norm2      = exp2 - 8'd3;
mant_norm2     = {1'b0,mantissa2[22:0]} << 3;
end

else if (mantissa2[22:21] == 2'b01)
begin
exp_norm2      = exp2 - 8'd2;
mant_norm2     = {1'b0,mantissa2[22:0]} << 2;
end

else
begin
exp_norm2      = exp2 - 8'd1;
mant_norm2     = {1'b0,mantissa2[22:0]} << 1;
end


end

always@(*)
begin

  temp_exp = $signed(exp11) + $signed(exp22) - 8'd127 + (is_subnormal1 ^ is_subnormal2);
  prod     = mantissa11 * mantissa22;
  
end


endmodule
