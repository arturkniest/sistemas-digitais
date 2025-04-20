module Calculadora (
    input  logic        clk,         //clock
    input  logic        rst,         //reset
    input  logic [7:0]  CMD,         //comando do usuario
    output logic        busy,        //indica se a calculadora está ocupada
    output logic        error,       //indica se houve erro
    output logic [3:0]  display_val, //valor numerico que vai ser mostrado no display
    output logic [2:0]  display_idx, //posição (entre zero e 7) em que estara o digito
    output logic        display_wr   //sinal de escrita no display
);
    //MAQUINA DE ESTADOS
    typedef enum logic [2:0] {
        IDLE,
        RECEBE_OP1, //esperando primeiro número
        RECEBE_OP2, //esperando segundo número
        OPERANDO,   //realizando a operação 
        MOSTRA_RES, //exibe o resultado
        ERRO        //estado de erro
    } state_t;

    //TIPOS DE OPERAÇÃO
    typedef enum logic [1:0] {
        NENHUM = 2'b00,
        SOMA   = 2'b01,
        SUB    = 2'b10,
        MULT   = 2'b11
    } op_t;

    state_t estado_atual, estado_proximo;
    op_t operador;

    //REGISTRADORES PRINCIPAIS
    logic [31:0] operando1, operando2, resultado;
    logic [31:0] acc_op1, acc_op2, mult_counter; //acumuladores que recebem os dígitos pra exibir corretamente na calculadora 
    logic [2:0]  display_pos;
    logic [2:0]  display_count;
    logic        iniciou_operacao;
    logic [3:0]  resultado_digitos[7:0];

    logic [3:0] cmd_valor;
    logic cmd_valid_num, cmd_valid_op, cmd_exec, cmd_reset;

    //TRADUZ OS SINAIS CMD EM SINAIS INTERNOS
    always_comb begin
        cmd_valid_num = 0; //se é número
        cmd_valid_op  = 0; //se é um operador
        cmd_exec      = 0; //se é sinal de =
        cmd_reset     = 0; //reset
        cmd_valor     = 0; 

        case (CMD)
            8'h00: cmd_valor = 4'd0;
            8'h01: cmd_valor = 4'd1;
            8'h02: cmd_valor = 4'd2;
            8'h03: cmd_valor = 4'd3;
            8'h04: cmd_valor = 4'd4;
            8'h05: cmd_valor = 4'd5;
            8'h06: cmd_valor = 4'd6;
            8'h07: cmd_valor = 4'd7;
            8'h08: cmd_valor = 4'd8;
            8'h09: cmd_valor = 4'd9;
            8'h0A: begin cmd_valid_op = 1; operador = SOMA; end
            8'h0B: begin cmd_valid_op = 1; operador = SUB;  end
            8'h0C: begin cmd_valid_op = 1; operador = MULT; end
            8'h0D: cmd_exec  = 1;
            8'h0E: cmd_reset = 1;
            default: ;
        endcase

        if (CMD <= 8'h09)
          cmd_valid_num = 1;
    end

    //TRANSIÇÃO DE ESTADOS
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
          estado_atual <= IDLE;
        else
          estado_atual <= estado_proximo;
    end

    //DECIDE O PRÓXIMO ESTADO COM BASE NO VALOR DE ENTRADA
    always_comb begin
        estado_proximo = estado_atual;

        case (estado_atual)
            IDLE:
                if (cmd_valid_num) estado_proximo = RECEBE_OP1;
            RECEBE_OP1:
                if (cmd_valid_op) estado_proximo = RECEBE_OP2;
            RECEBE_OP2:
                if (cmd_exec) estado_proximo = OPERANDO;
            OPERANDO:
                if (operador == MULT && mult_counter != 0) estado_proximo = OPERANDO;
                else estado_proximo = MOSTRA_RES;
            MOSTRA_RES:
                if (display_count == 7) estado_proximo = IDLE;
            ERRO:
                if (cmd_reset) estado_proximo = IDLE;
        endcase
    end

   //BLOCO DE OPERAÇÃO LÓGICA
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_op1 <= 0; acc_op2 <= 0;
            operando1 <= 0; operando2 <= 0;
            resultado <= 0; mult_counter <= 0;
            iniciou_operacao <= 0;
            error <= 0;
            display_count <= 0;
        end else begin
            case (estado_atual)
                RECEBE_OP1: begin
                    if (cmd_valid_num) acc_op1 <= acc_op1 * 10 + cmd_valor;
                    if (cmd_valid_op) begin
                        operando1 <= acc_op1;
                        acc_op2 <= 0;
                    end
                end
                RECEBE_OP2: begin
                    if (cmd_valid_num) acc_op2 <= acc_op2 * 10 + cmd_valor;
                    if (cmd_exec) operando2 <= acc_op2;
                end
                OPERANDO: begin
                    if (!iniciou_operacao) begin
                        iniciou_operacao <= 1;
                        case (operador)
                            SOMA: resultado <= operando1 + operando2;
                            SUB:  resultado <= operando1 - operando2;
                            MULT: begin
                                resultado <= 0;
                                mult_counter <= operando2;
                            end
                        endcase
                    end else if (operador == MULT && mult_counter > 0) begin
                        resultado <= resultado + operando1;
                        mult_counter <= mult_counter - 1;
                    end
                end
                MOSTRA_RES: begin
                    if (resultado > 99999999) begin
                        error <= 1;
                    end else begin
                        integer i;
                        integer temp;
                        temp = resultado;
                        for (i = 7; i >= 0; i--) begin
                            resultado_digitos[i] = temp % 10;
                            temp = temp / 10;
                        end
                    end
                end
                ERRO: begin
                    acc_op1 <= 0; acc_op2 <= 0;
                    resultado <= 0;
                    operando1 <= 0; operando2 <= 0;
                    iniciou_operacao <= 0;
                    display_count <= 0;
                end
                IDLE: begin
                    acc_op1 <= 0; acc_op2 <= 0;
                    resultado <= 0;
                    iniciou_operacao <= 0;
                    display_count <= 0;
                    error <= 0;
                end
            endcase
        end
    end

    //CONTROLE DO DISPLAY
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            display_val <= 0;
            display_idx <= 0;
            display_wr  <= 0;
            display_count <= 0;
        end else if (estado_atual == MOSTRA_RES && !error) begin
            display_val <= resultado_digitos[display_count];
            display_idx <= display_count;
            display_wr  <= 1;
            display_count <= display_count + 1;
        end else if (estado_atual == ERRO) begin
            display_wr <= 1;
            case (display_count)
                0: display_val <= 4'hE;
                1: display_val <= 4'hC;
                2: display_val <= 4'hC;
                3: display_val <= 4'h0;
                default: display_val <= 4'h0;
            endcase
            display_idx <= display_count;
            display_count <= (display_count < 3) ? display_count + 1 : 0;
        end else begin
            display_wr <= 0;
        end
    end

    //SINAL DE OCUPADO
    assign busy = (estado_atual == OPERANDO && operador == MULT && mult_counter != 0);

endmodule
