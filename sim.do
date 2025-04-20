if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

vlog -work work Calculadora.sv
vlog -work work tb_Calculadora.sv

vsim -voptargs=+acc work.tb_Calculadora

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

do wave.do
run 500ns
