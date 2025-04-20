module tb_Calculadora;

    // Sinais
    logic clk;
    logic rst;
    logic [7:0] CMD;
    logic busy;
    logic error;
    logic [3:0] display_val;
    logic [2:0] display_idx;
    logic display_wr;

    // Clock de 10ns
    always #5 clk = ~clk;

    // Instancia o DUT (Device Under Test)
    Calculadora dut (
        .clk(clk),
        .rst(rst),
        .CMD(CMD),
        .busy(busy),
        .error(error),
        .display_val(display_val),
        .display_idx(display_idx),
        .display_wr(display_wr)
    );

    // Tarefa para simular uma entrada CMD
    task envia_cmd(input [7:0] cmd);
        begin
            CMD = cmd;
            #10;
        end
    endtask

    // Teste de sucesso: 5 + 3 = 8
    initial begin
        $display("Iniciando simulação...");
        clk = 0;
        rst = 1;
        CMD = 8'h00;
        #10 rst = 0;
    
        envia_cmd(8'h05);   // número 5
        #10;                // ESPERA para permitir captura do número
        envia_cmd(8'h0A);   // operador +
        envia_cmd(8'h03);   // número 3
        envia_cmd(8'h0D);   // igual =
    
        #200;
    
        $display("Fim da simulação.");
        $stop;
    end
    

endmodule
