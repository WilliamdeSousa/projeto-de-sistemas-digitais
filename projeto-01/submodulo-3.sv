
module submodulo_3  #(
	parameter AUTO_SHUTDOWN_T = 30000)
(input 	logic 	clk,
input	logic	rst,
input 	logic	enable,
input 	logic	infravermelho,
output 	logic 	C);
  
  bit [15:0] Tc = 0;
  enum logic [1:0] {inicial, contando, temp} estado;
  
  always_ff @ (posedge rst or posedge clk)
    if (rst) begin
      Tc <= 0;
      estado <= inicial;
    end
  	else
      case (estado)
        inicial: begin
          Tc <= 0;
          if (!infravermelho && enable) estado <= contando;
          else estado <= inicial;
        end
        contando: begin
          Tc <= Tc + 1;
          if (infravermelho || !enable) estado <= inicial;
          else if (Tc >= AUTO_SHUTDOWN_T) estado <= temp;
          else estado <= contando;
        end
        temp: begin
          Tc <= 0;
          estado <= inicial;
        end
		    default: begin
          Tc <= 0;
          estado <= inicial;
        end
      endcase

  always_comb begin
    if (rst) begin
      C = 0;
    end
    else
      case (estado)
        inicial: C = 0;
        contando: C = 0;
        temp: C = 1;
        default: C = 0;
      endcase
  end
endmodule
