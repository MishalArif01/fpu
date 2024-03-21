module fpu_adder(sign1,exp1,mantissa1,sign2,exp2,mantissa2,infinite1,invalid1,out_sign,out_exp,out_mantissa,is_signalling2,is_quiet2);

//FP 1
input         sign1;
input  [9:0]  exp1;
input  [47:0] mantissa1;

//FP 2
input         sign2;
input  [7:0]  exp2;
input  [22:0] mantissa2;

//Sum
output reg        out_sign;
output reg [9:0]  out_exp;
output reg [26:0] out_mantissa;
output reg        infinite1;
output wire        invalid1;

output reg         is_signalling2; // is the value a signalling NaN
output reg         is_quiet2;      // is the value a quiet NaN



reg  [7:0]   t;
wire  [7:0]   t1;
wire  [7:0]   tdec;
reg  [7:0]   temp_exp;
reg  [8:0]   temp_exp_add;
reg  [8:0]   temp_exp_sub;
wire [9:0]   diff_exp;
reg  [9:0]   diff;
wire [9:0]   shift;
wire [9:0]   d;
wire [9:0]   d1;
wire [9:0]   d2;
wire [9:0]   d3;
wire [9:0]   d4;
reg  [74:0]  significand1;
reg  [74:0]  significand2;
reg  [75:0]  sum;
reg  [75:0]  sub;
reg  [74:0]  mul_add;
reg  [74:0]  mul_add1;
reg  [26:0]  sum_norm;
reg  [74:0]  sub_norm;
reg          out_sign_o;
reg  [9:0]   out_exp_o;
reg  [26:0]  out_mantissa_o;
reg  [73:0]  mant;
reg          s;
wire tdec1;
reg  [9:0]   exp_norm2;

reg  [9:0]   sh;

reg [1:0]  check;

wire [73:0]  mantissa11;
wire [73:0]  mantissa22;

reg  [23:0] mant_norm2;

wire [9:0]  shift_neg;

reg         is_normal1;     // is the value normal
reg         is_subnormal1;  // is the value subnormal
reg         is_zero1;       // is the value zero
reg         is_inf1;        // is the value infinity
reg         is_signalling1; // is the value a signalling NaN
reg         is_quiet1;      // is the value a quiet NaN

reg         is_normal2;     // is the value normal
reg         is_subnormal2;  // is the value subnormal
reg         is_zero2;       // is the value zero
reg         is_inf2;        // is the value infinity

reg z1;
reg z2;

reg [47:0] out_mantissa_s;


assign mantissa11 = {24'd0,2'b00,mantissa1};
assign mantissa22 = is_subnormal2 ? {1'b0,mantissa2,2'b00,48'd0} : {1'b1,mantissa2,2'b00,48'd0};
assign invalid1   = is_signalling1 | is_signalling2 | infinite1;


assign diff_exp   = $signed({2'b00,exp2}) - $signed(exp1); 
assign shift      = 27-$signed(diff_exp);
assign d          = (($signed(d4) < 0)) ? 10'd0: d4;
assign d4         = (/*(is_subnormal1  & is_subnormal2) |*/ (~is_subnormal1  & is_subnormal2)) ? (d3-1'b1) : d3;
assign d3         = ($signed(diff_exp) >= 0)       ?  d2    : d1;
assign d1         = ($signed(shift)    < 10'd74)   ?  shift : 10'd74;
assign d2         = ($signed(shift)    > 0)        ?  shift : 10'd0;


always@(*)
begin

is_normal1       = 1'b0;    
  is_subnormal1    = 1'b0;  
  is_zero1         = 1'b0;      
  is_inf1          = 1'b0;        
  is_signalling1   = 1'b0;
  is_quiet1        = 1'b0;

if((exp1 == 8'b11111111) & (mantissa1[46] == 1'b0) & (|mantissa1[45:0] == 1'b1))
begin
  is_signalling1 = 1'b1;
end

else if((exp1 == 8'b11111111) & (mantissa1[46] == 1'b1))
begin
  is_quiet1      = 1'b1;
end

else if((exp1 == 8'b11111111) & (mantissa1[46:0] == 23'd0))
begin
  is_inf1        = 1'b1;
end

else if((exp1 == 8'd0) & (mantissa1[46:0] == 23'd0))
begin
  is_zero1       = 1'b1;
end

else if((exp1 == 8'd0) & (mantissa1[47] == 1'b0) & (|mantissa1[46:0] == 1'b1))
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

else if((exp2 == 8'b11111111) & (mantissa2[22:0] == 48'd0))
begin
  is_inf2        = 1'b1;
end

else if((exp2 == 8'd0) & (mantissa2[22:0] == 48'd0))
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
infinite1 = 1'b0;
z1 = 1'b0;
z2 = 1'b0;
out_mantissa_s = 48'd0;

/*if(is_signalling1 | is_quiet1)
begin
  out_sign     = sign1;
  out_exp      = exp1;
  out_mantissa = {1'b1,1'b1,mantissa1[45:24], 3'b0};
end*/

if(is_inf1 & is_inf2 & (sign1 == sign2))
begin
  out_sign     = sign1;
  out_exp      = exp1;
  out_mantissa = {1'b1,23'd0, 3'b0};
end

else if(is_inf1 & is_inf2 & (sign1 != sign2))
begin
  out_sign     = 1'b1;
  out_exp      = 8'b11111111;
  out_mantissa = {1'b1,1'b1,22'd0, 3'b0};
  infinite1    = 1'b1;
end

else if(is_inf1 | is_inf2)
begin
  out_sign     = (sign1 & is_inf1) | (sign2 & is_inf2);
  out_exp      = 8'b11111111;
  out_mantissa = {1'b1,26'd0};
end

else if(is_zero1 & ~is_zero2)
begin
  out_sign     = sign2;
  out_exp      = exp2;
  out_mantissa = {~is_subnormal2, mantissa2,3'b0};
  z2 = 1'b1;
end

else if(~is_zero1 & is_zero2)
begin
  out_sign     = sign1;
  if($signed(exp1)>0)
  begin
  out_exp      = (mantissa1[47]) ? (exp1+1'b1) : exp1;
  out_mantissa = (mantissa1[47]) ? {mantissa1[47:24],3'b0}:{mantissa1[46:23],3'b0};
  end
  
  else if($signed(exp1)==0)
  begin
  out_exp      = exp1;
  out_mantissa = {mantissa1[47:24],3'b0};
  end
  
  else
  begin
   out_exp      = 10'd0;
   out_mantissa_s = mantissa1 >> $signed(shift_neg) ;
   out_mantissa   = {out_mantissa_s[47:24],3'd0};
  end
  z1 = 1'b1;
end

else if(is_zero1 & is_zero2)
begin
  out_sign     = sign1 & sign2;
  out_exp      = 8'd0;
  out_mantissa = 27'd0;
end

else if((significand1 == significand2) & (exp1 == exp2) & (sign1!=sign2))
begin
  out_sign     = 1'b0;
  out_exp      = 8'd0;
  out_mantissa = 27'd0;
end


else

 begin
  out_sign     = out_sign_o;
  out_exp      = out_exp_o;
  out_mantissa = out_mantissa_o;
 end

end

assign shift_neg = 10'd0 - $signed(exp1);

always@(*)
begin
 if($signed(exp1) > $signed({2'b00,exp2}))
 begin
   temp_exp     = exp1 ;
   check        = 2'd1;
   significand1 =  {mantissa11,1'b0};
   significand2 = {mantissa22 >> d,s};
 end
 
 else if($signed(exp1) < $signed({2'b00,exp2}))
 begin
   temp_exp     = exp2;
   check        = 2'd2;
significand1 =  {mantissa11,1'b0};
significand2 = {mantissa22 >> d,s};
 end
 
 else
 begin
   temp_exp     = exp1 + ((exp1 == 10'd0) & (mantissa1[47] == 1'b1));
   check        = 2'd3;
significand1 = {mantissa11,1'b0};
significand2 = {mantissa22 >> d,s};
 end

end


assign tdec  = $signed((74-$signed(d))-$signed(t)) * (($signed((74-$signed(d))-$signed(t))>0)  & (($signed((74-$signed(d))-$signed(t))<74))) ;
assign tdec1 = ((74-$signed(d)) <= 46 ) & (mul_add[46] == 1'b0) & ~((mul_add[47] == 1'b1)) & ~((mul_add[48] == 1'b1));

always@(*)
begin
  if(sign1 & sign2)
  begin
 sum            = significand1 + significand2;
 sub            = 0;
 mul_add         = sum[75:1];
 out_sign_o     = sign1;
 out_exp_o      = temp_exp + ((mul_add[47] == 1'b1) & (d>=27)) + ((mul_add[74-d] == 1'b1) & (d<27)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) 
                  - tdec - tdec1;
 out_mantissa_o = {sub_norm[73:50],sub_norm[49],sub_norm[48],|sub_norm[47:0]};
  end
 
  else if(~sign1 & ~sign2)
  begin
     sum        = significand1 + significand2;
 sub            = 0;
   mul_add         = sum[75:1];
 out_sign_o     = sign1;
 out_exp_o      = temp_exp + ((mul_add[47] == 1'b1) & (d>=27)) + ((mul_add[74-d] == 1'b1) & (d<27)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) 
                  - tdec- tdec1;
 out_mantissa_o = {sub_norm[73:50],sub_norm[49],sub_norm[48],|sub_norm[47:0]};
  end
 
  else
  begin
   if(significand2 < significand1)
begin
 sum            =  0;
 sub            = significand1 - significand2;
   mul_add         = sub[75:1];
 out_sign_o     = sign1;
 out_exp_o      = temp_exp + ((mul_add[47] == 1'b1) & (d>=27)) + ((mul_add[74-d] == 1'b1) & (d<27)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) 
                   - tdec- tdec1;
 out_mantissa_o = {sub_norm[73:50],sub_norm[49],sub_norm[48],|sub_norm[47:0]};
end
 
else
begin
 sum            = 0;
 sub            = significand2 - significand1;
  mul_add       = sub[75:1];
 out_sign_o     = sign2;
 out_exp_o      = temp_exp  + ((mul_add[47] == 1'b1) & (d>=27)) + ((mul_add[74-d] == 1'b1) & (d<27)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) + ((mul_add[48] == 1'b1) & ((74-$signed(d))<=47)) 
                   - tdec- tdec1;
 out_mantissa_o = {sub_norm[73:50],sub_norm[49],sub_norm[48],|sub_norm[47:0]};
end
 
  end

end



always@(*)
begin
if(($signed(d)>50) & ($signed(d)<74) )
  begin
    sh   = 10'd24-($signed(d)-10'd50);
    mant = mantissa22 << sh;
    s    = |mant;
  end
  
else if(d>=74)
begin
sh   = 10'd0;
mant = 24'd0;
s    = |mantissa22;  
end

else
begin
sh   = 10'd0;
mant = 24'd0;
s    = 1'b0;
end

end

always @ ( * )
begin

  if(mul_add[74] == 1'b1)
  begin
    sub_norm       = mul_add >> 1'b1;
    temp_exp_sub  = {1'b0,temp_exp + 1'b1};
    sub_norm[0]    = |mul_add[1:0];
  end

else if(mul_add[73:0] == 74'b000000000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd73;
          t            = 1;
          sub_norm     = mul_add << 73;
end

else if(mul_add[73:1] == 73'b00000000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd72;
          t            = 2;
          sub_norm     = mul_add << 72;
end

else if(mul_add[73:2] == 72'b0000000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd71;
          t            = 3;
          sub_norm     = mul_add << 71;
end

else if(mul_add[73:3] == 71'b000000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd70;
          t            = 4;
          sub_norm     = mul_add << 70;
end

else if(mul_add[73:4] == 70'b00000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd69;
          t            = 5;
          sub_norm     = mul_add << 69;
end

else if(mul_add[73:5] == 69'b0000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd68;
          t            = 6;
          sub_norm     = mul_add << 68;
end

else if(mul_add[73:6] == 68'b000000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd67;
          t            = 7;
          sub_norm     = mul_add << 67;
end

else if(mul_add[73:7] == 67'b00000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd66;
          t            = 8;
          sub_norm     = mul_add << 66;
end

else if(mul_add[73:8] == 66'b0000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd65;
          t            = 9;
          sub_norm     = mul_add << 65;
end

else if(mul_add[73:9] == 65'b000000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd64;
          t            = 10;
          sub_norm     = mul_add << 64;
end

else if(mul_add[73:10] == 64'b00000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd63;
          t            = 11;
          sub_norm     = mul_add << 63;
end

else if(mul_add[73:11] == 63'b0000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd62;
          t            = 12;
          sub_norm     = mul_add << 62;
end

else if(mul_add[73:12] == 62'b000000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd61;
          t            = 13;
          sub_norm     = mul_add << 61;
end

else if(mul_add[73:13] == 61'b00000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd60;
           t            = 14;
          sub_norm     = mul_add << 60;
end

else if(mul_add[73:14] == 60'b0000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd59;
           t            = 15;
          sub_norm     = mul_add << 59;
end

else if(mul_add[73:15] == 59'b000000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd58;
           t            = 16;
          sub_norm     = mul_add << 58;
end

else if(mul_add[73:16] == 58'b00000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd57;
           t            = 17;
          sub_norm     = mul_add << 57;
end

else if(mul_add[73:17] == 57'b0000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd56;
           t            = 18;
          sub_norm     = mul_add << 56;
end

else if(mul_add[73:18] == 56'b000000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd55;
           t            = 19;
          sub_norm     = mul_add << 55;
end

else if(mul_add[73:19] == 55'b00000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd54;
           t            = 20;
          sub_norm     = mul_add << 54;
end

else if(mul_add[73:20] == 54'b0000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd53;
           t            = 21;
          sub_norm     = mul_add << 53;
end

else if(mul_add[73:21] == 53'b000000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd52;
           t            = 22;
          sub_norm     = mul_add << 52;
end

else if(mul_add[73:22] == 52'b00000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd51;
          t            = 23;
          sub_norm     = mul_add << 51;
end

else if(mul_add[73:23] == 51'b0000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd50;
          t            = 24;
          sub_norm     = mul_add << 50;
end

else if(mul_add[73:24] == 50'b000000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd49;
          t            = 25;
          sub_norm     = mul_add << 49;
end

else if(mul_add[73:25] == 49'b00000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd48;
          t            = 26;
          sub_norm     = mul_add << 48;
end

else if(mul_add[73:26] == 48'b00000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd47;
          t            = 27;
          sub_norm     = mul_add << 47;
end

else if(mul_add[73:27] == 47'b0000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd46;
          t            = 28;
          sub_norm     = mul_add << 46;
end

else if(mul_add[73:28] == 46'b0000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd45;
          t            = 29;
          sub_norm     = mul_add << 45;
end

else if(mul_add[73:29] == 45'b000000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd44;
          t            = 30;
          sub_norm     = mul_add << 44;
end

else if(mul_add[73:30] == 44'b00000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd43;
          t            = 31;
          sub_norm     = mul_add << 43;
end

else if(mul_add[73:31] == 43'b0000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd42;
          t            = 32;
          sub_norm     = mul_add << 42;
end

else if(mul_add[73:32] == 42'b000000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd41;
          t            = 33;
          sub_norm     = mul_add << 41;
end
 
else if(mul_add[73:33] == 41'b00000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd40;
          t            = 34;
          sub_norm     = mul_add << 40;
end

else if(mul_add[73:34] == 40'b0000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd39;
          t            = 35;
          sub_norm     = mul_add << 39;
end

else if(mul_add[73:35] == 39'b000000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd38;
          t            = 36;
          sub_norm     = mul_add << 38;
end

else if(mul_add[73:36] == 38'b00000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd37;
          t            = 37;
          sub_norm     = mul_add << 37;
end

else if(mul_add[73:37] == 37'b0000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd36;
          t            = 38;
          sub_norm     = mul_add << 36;
end

else if(mul_add[73:38] == 36'b000000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd35;
          t            = 39;
          sub_norm     = mul_add << 35;
end

else if(mul_add[73:39] == 35'b00000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd34;
          t            = 40;
          sub_norm     = mul_add << 34;
end

else if(mul_add[73:40] == 34'b0000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd33;
          t            = 41;
          sub_norm     = mul_add << 33;
end

else if(mul_add[73:41] == 33'b000000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd32;
          t            = 42;
          sub_norm     = mul_add << 32;
end

else if(mul_add[73:42] == 32'b00000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd31;
          t            = 43;
          sub_norm     = mul_add << 31;
end

else if(mul_add[73:43] == 31'b0000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd30;
          t            = 44;
          sub_norm     = mul_add << 30;
end

else if(mul_add[73:44] == 30'b000000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd29;
          t            = 45;
          sub_norm     = mul_add << 29;
end

else if(mul_add[73:45] == 29'b00000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd28;
          t            = 46;
          sub_norm     = mul_add << 28;
end

else if(mul_add[73:46] == 28'b0000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd27;
          t            = 47;
          sub_norm     = mul_add << 27;
end

else if(mul_add[73:47] == 27'b000000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd26;
          t            = 48;
          sub_norm     = mul_add << 26;
end

else if(mul_add[73:48] == 26'b00000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd25;
          t            = 49;
          sub_norm     = mul_add << 25;
end

else if(mul_add[73:49] == 25'b0000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd24;
          t            = 50;
sub_norm     = mul_add << 24;
end

else if(mul_add[73:50] == 24'b000000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd23;
          t            = 51;
sub_norm     = mul_add << 23;
end

else if (mul_add[73:51] == 23'b00000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd22;
          t            = 52;
sub_norm     = mul_add << 22;
end

else if (mul_add[73:52] == 22'b0000000000000000000001)
begin
          //temp_exp_sub = temp_exp - 8'd21;
          t            = 53;
sub_norm     = mul_add << 21;
end

else if (mul_add[73:53] == 21'b000000000000000000001)
begin 
          //temp_exp_sub = temp_exp - 8'd20;
          t            = 54;
sub_norm     = mul_add << 20;
end

else if (mul_add[73:54] == 20'b00000000000000000001)
begin
//temp_exp_sub = temp_exp - 8'd19;
t            = 55;
sub_norm     = mul_add << 19;
end

else if (mul_add[73:55] == 19'b0000000000000000001)
begin
//temp_exp_sub = temp_exp - 8'd18;
t            = 56;
sub_norm     = mul_add << 18;
end

else if (mul_add[73:56] == 18'b000000000000000001)
begin
//temp_exp_sub = temp_exp - 8'd17;
t            = 57;
sub_norm     = mul_add << 17;
end

else if (mul_add[73:57] == 17'b00000000000000001)
begin
//temp_exp_sub = temp_exp - 8'd16;
t            = 58;
sub_norm     = mul_add << 16;
end

else if (mul_add[73:58] == 16'b0000000000000001)
begin
//temp_exp_sub = temp_exp - 8'd15;
t            = 59;
sub_norm     = mul_add << 15;
end

else if (mul_add[73:59] == 15'b000000000000001)
begin
//temp_exp_sub = temp_exp - 8'd14;
t            = 60;
sub_norm     = mul_add << 14;
end

else if (mul_add[73:60] == 14'b00000000000001)
begin
//temp_exp_sub = temp_exp - 8'd13;
t            = 61;
sub_norm     = mul_add << 13;
end

else if (mul_add[73:61] == 13'b0000000000001)
begin
//temp_exp_sub = temp_exp - 8'd12;
t            = 62;
sub_norm     = mul_add << 12;
end

else if (mul_add[73:62] == 12'b000000000001)
begin
//temp_exp_sub = temp_exp - 8'd11;
t            = 63;
sub_norm     = mul_add << 11;
end

else if (mul_add[73:63] == 11'b00000000001)
begin
//temp_exp_sub = temp_exp - 8'd10;
t            = 64;
sub_norm     = mul_add << 10;
end

else if (mul_add[73:64] == 10'b0000000001)
begin
//temp_exp_sub = temp_exp - 8'd9;
t            = 65;
sub_norm     = mul_add << 9;
end

else if (mul_add[73:65] == 9'b000000001)
begin
//temp_exp_sub = temp_exp - 8'd8;
t            = 66;
sub_norm     = mul_add << 8;
end

else if (mul_add[73:66] == 8'b00000001)
begin
//temp_exp_sub = temp_exp - 8'd7;
t            = 67;
sub_norm     = mul_add << 7;
end

else if (mul_add[73:67] == 7'b0000001)
begin
//temp_exp_sub = temp_exp - 8'd6;
t            = 68;
sub_norm     = mul_add << 6;
end

else if (mul_add[73:68] == 6'b000001)
begin
//temp_exp_sub = temp_exp - 8'd5;
t            = 69;
sub_norm     = mul_add << 5;
end

else if (mul_add[73:69] == 5'b00001)
begin
//temp_exp_sub = temp_exp - 8'd4;
t            = 70;
sub_norm     = mul_add << 4;
end

else if (mul_add[73:70] == 4'b0001)
begin
//temp_exp_sub = temp_exp - 8'd3;
t            = 71;
sub_norm     = mul_add << 3;
end

else if (mul_add[73:71] == 3'b001)
begin
//temp_exp_sub = temp_exp - 8'd2;
t            = 72;
sub_norm     = mul_add << 2;
end

else if (mul_add[73:72] == 2'b01)
begin
//temp_exp_sub = temp_exp - 8'd1;
t            = 73;
sub_norm     = mul_add << 1;
end

else
begin
   //temp_exp_sub = temp_exp;
   t            = 0;
   sub_norm     = mul_add;
end
 
end



endmodule
