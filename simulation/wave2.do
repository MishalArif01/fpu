onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/fpu_adder_inst/mult/sign1
add wave -noupdate /tb/result
add wave -noupdate /tb/exp_res
add wave -noupdate /tb/fpu_adder_inst/mult/exp1
add wave -noupdate /tb/fpu_adder_inst/mult/mantissa1
add wave -noupdate /tb/fpu_adder_inst/mult/sign2
add wave -noupdate /tb/fpu_adder_inst/mult/exp2
add wave -noupdate /tb/fpu_adder_inst/mult/mantissa2
add wave -noupdate /tb/fpu_adder_inst/mult/out_sign
add wave -noupdate /tb/fpu_adder_inst/mult/out_exp
add wave -noupdate /tb/fpu_adder_inst/mult/out_mantissa
add wave -noupdate /tb/fpu_adder_inst/mult/is_signalling1
add wave -noupdate /tb/fpu_adder_inst/mult/is_quiet1
add wave -noupdate /tb/fpu_adder_inst/mult/is_signalling2
add wave -noupdate /tb/fpu_adder_inst/mult/is_quiet2
add wave -noupdate /tb/fpu_adder_inst/mult/mantissa11
add wave -noupdate /tb/fpu_adder_inst/mult/mantissa22
add wave -noupdate /tb/fpu_adder_inst/mult/out_exp_o
add wave -noupdate /tb/fpu_adder_inst/mult/out_mantissa_o
add wave -noupdate /tb/fpu_adder_inst/mult/temp_exp
add wave -noupdate /tb/fpu_adder_inst/mult/exp_norm1
add wave -noupdate /tb/fpu_adder_inst/mult/exp_norm2
add wave -noupdate /tb/fpu_adder_inst/mult/exp11
add wave -noupdate /tb/fpu_adder_inst/mult/exp22
add wave -noupdate /tb/fpu_adder_inst/mult/prod
add wave -noupdate /tb/fpu_adder_inst/mult/mant_norm1
add wave -noupdate /tb/fpu_adder_inst/mult/mant_norm2
add wave -noupdate /tb/fpu_adder_inst/mult/is_normal1
add wave -noupdate /tb/fpu_adder_inst/mult/is_subnormal1
add wave -noupdate /tb/fpu_adder_inst/mult/is_zero1
add wave -noupdate /tb/fpu_adder_inst/mult/is_inf1
add wave -noupdate /tb/fpu_adder_inst/mult/is_normal2
add wave -noupdate /tb/fpu_adder_inst/mult/is_subnormal2
add wave -noupdate /tb/fpu_adder_inst/mult/is_zero2
add wave -noupdate /tb/fpu_adder_inst/mult/is_inf2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 206
configure wave -valuecolwidth 112
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {931 ps}
