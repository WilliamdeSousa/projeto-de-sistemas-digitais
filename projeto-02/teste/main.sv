module tb_1;
    bit clk;
    bit rst;
    logic [3:0] col_matriz,
    logic [3:0] lin_matriz,
    logic [3:0]	tecla_value,
    logic 		tecla_valid

    decodificador_de_teclado sub(
        .clk(clk),
        .rst(rst),
      	.col_matriz(col_matriz),
      	.lin_matriz(lin_matrix),
      	.tecla_value(tecla_value),
      	.tecla_valid(tecla_value)
    );

    initial begin
        #29900
        $dumpfile("dump.vcd");
        $dumpvars(0);
        #200
        $finish;
    end

    task apply_reset();
        rst <= 1;
        #5 rst <= 0;
    endtask

    initial begin
        $display("================================================");
      	$display($time, " ** Iniciando Teste 1 **" );
        $display("================================================");

        clk <= 0;

    end

    initial begin
        clk = 0;
          forever #0.5 clk = ~clk;
    end
endmodule