
module decodificador_de_teclado (
input 	logic		clk,
input		logic		rst,
input		logic 		enable,
input 	logic [3:0] 	col_matriz,
output 	logic [3:0] 	lin_matriz,
output 	senhaPac_t	digitos_value,
output	logic 		digitos_valid
);
  logic [5:0] Tr;

  enum logic [1:0] {esperando, debounce, reset_valido} estado;

  always_ff @(posedge clk) begin
    case (estado)
      esperando: begin
        if (reset_in) begin
          Tr <= 0;
          estado <= debounce;
        end
      end
      debounce: begin
        Tr++;
        if (!reset_in) estado <= esperando;
        else if (Tr > TIME_TO_RST * 1000) estado <= reset_valido;
      end
      reset_valido: begin
        if (!reset_in) estado <= esperando;
      end
      default: estado <= esperando;
    endcase
  end

  always_comb begin
    case (estado)
      esperando: reset_out = 0;
      debounce: reset_out = 0;
      reset_valido: reset_out = 1;
      default: reset_out = 0;
    endcase
  end
endmodule