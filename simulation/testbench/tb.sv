

module tb
`ifdef VERILATOR
(

    input [31:0] opA,
    input [31:0] opB,
    input [31:0] opC,
    input [2:0] rnd,
    output [31:0] result,
    output [4:0]  flags_o
    //output status_t flags_o
)
`endif ;


`ifdef VERILATOR
logic [1:0] rs;
logic [31:0] u_result;
logic round_en;
logic exp_cout;
logic [1:0] urs;
logic [22:0] urpr;
`else
logic [1:0] rs;
logic [31:0] result;
logic [31:0] u_result;
logic round_en;
integer outfile0; 
logic [31:0] opA,opB,opC,exp_res;
logic [4:0] exc;
integer err_cnt;
integer test_cnt;
    logic [2:0] rnd;


initial begin
    outfile0=$fopen("testbench/test_rtz.txt","r");
    err_cnt = 0;
    test_cnt = 0;
    rnd = 1; //1--->RTZ, 0--->RNE, 2--->RDOWN, 3---> RUP
    while (! $feof(outfile0)) begin
        $fscanf(outfile0,"%h %h %h %h %h\n",opA,opB,opC,exp_res,exc);
         #10;
        if (!(opA[30-:8] == 0 || opB[30-:8] == 0/*|| opC[30-:8] == 0  || exp_res[30-:8] == 0*/ || exp_res[30-:8] == 255 || exp_res == 32'h7f7fffff || exp_res == 32'hff7fffff))
        begin
            test_cnt = test_cnt + 1;
            if((exp_res != result))
            begin
                $display("%h %h %h Expected=%h Actual=%h %d %d", opA,opB,opC,exp_res,result,exp_res[30:23],result[30:23]);
               // if(exp_res == 32'h00000000)
               if(err_cnt == 20)
               $stop();
                err_cnt = err_cnt + 1;
            end
        end
    end
    $display("Total Errors = %d/%d\t (%0.2f%%)", err_cnt, test_cnt, err_cnt*100.0/test_cnt);
    $fclose(outfile0);
    $stop();
end
`endif

/*
fp_add fp_add_inst
(
    .a_i(opA),
    .b_i(opB),
    .sub(1'b1),
    .rnd_i(rnd),
    .result_o(u_result),
    .rs_o(rs),
    .round_en_o(round_en),
    .invalid_o(invalid),
    .exp_cout_o(exp_cout)
);

fp_rnd fp_rnd_inst
(
    .a_i(u_result),
    .rnd_i(rnd),
    .rs_i(rs),
    .round_en_i(round_en),
    .out_o(result),
    .invalid_i(invalid),
    .exp_cout_i(exp_cout),
    .flags_o(flags_o)
);
*/
logic [23:0]out_mant;
logic [7:0]out_exp;
logic out_sign;
logic sign_o;
logic [7:0] exp_o;
logic [22:0] mant_o;

logic round_bit;
logic round_up;
logic sticky_bit;
logic [24:0] rounded_mant;

logic  inexact;
logic  invalid;
logic  overflow;
logic  underflow;
logic  infinite;


assign result[31] = out_sign;
assign result[30:23] = /*round_en ? exp_o :*/ out_exp;
assign result[22:0] = /*round_en ? mant_o : */out_mant[22:0];
assign flags_o = {invalid,1'b0,(overflow & ~invalid),(underflow & ~invalid),(inexact & ~invalid)};

fpu fpu_adder_inst
	(
		.sign1		(opA[31]),
		.exp1		(opA[30:23]),
		.mantissa1	(opA[22:0]),
		
		.sign2		(opB[31]),
		.exp2		(opB[30:23]),
		.mantissa2	(opB[22:0]),
		
		.sign3		(opC[31]),
		.exp3		(opC[30:23]),
		.mantissa3	(opC[22:0]),
		
		.RNE            (1'b0),
		.RTZ            (1'b1),
		.RDN            (1'b0),
		.RVP            (1'b0),
                .RMM            (1'b0),
		.round_sign     (out_sign),
		.round_exp      (out_exp),
		.round_mantissa (out_mant),
		.inexact        (inexact),
		.invalid        (invalid),
		.overflow       (overflow),
		.underflow      (underflow),
		.infinite       (infinite)
	);

endmodule
