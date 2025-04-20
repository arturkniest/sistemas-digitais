onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -divider "Entradas"
add wave -noupdate /tb_Calculadora/clk
add wave -noupdate /tb_Calculadora/rst
add wave -noupdate /tb_Calculadora/CMD

add wave -divider "Saídas"
add wave -noupdate /tb_Calculadora/busy
add wave -noupdate /tb_Calculadora/error
add wave -noupdate -radix unsigned /tb_Calculadora/display_val
add wave -noupdate -radix unsigned /tb_Calculadora/display_idx
add wave -noupdate /tb_Calculadora/display_wr

add wave -divider "Estados Internos (Debug)"
add wave -noupdate -radix hex /tb_Calculadora/dut/estado_atual
add wave -noupdate -radix unsigned /tb_Calculadora/dut/operando1
add wave -noupdate -radix unsigned /tb_Calculadora/dut/operando2
add wave -noupdate -radix unsigned /tb_Calculadora/dut/resultado
add wave -noupdate -radix dec /tb_Calculadora/dut/acc_op1
add wave -noupdate -radix dec /tb_Calculadora/dut/acc_op2
add wave -noupdate -radix dec /tb_Calculadora/dut/mult_counter
add wave -noupdate /tb_Calculadora/dut/mostrar_resultado

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1

configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {500 ns}
view wave
WaveCollapseAll -1
