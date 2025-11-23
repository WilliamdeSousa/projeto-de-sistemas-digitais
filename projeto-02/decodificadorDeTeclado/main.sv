module decodificador_de_teclado (
    input 	logic		clk,
    input	logic		rst,
    input 	logic [3:0] 	col_matriz,
    output 	logic [3:0] 	lin_matriz,
    output 	logic [3:0]	tecla_value,
    output	logic 		tecla_valid
);
  logic [6:0] tp; // 0 - 127
  logic c0;
  logic c1;
  enum logic [2:0] {leitura, debounce, decodificar, dispSaida, teclaValid} estado;

  assign c0 = col_matriz == 4'b0111 || col_matriz == 4'b1011 || col_matriz == 4'b1101 || col_matriz == 4'b1110;
  assign c1 = col_matriz == 4'b1111;

  always_ff @(posedge rst or posedge clk) begin
      if (rst) begin
        estado <= leitura;
        tp <= 0;
      end else
        case (estado)
          leitura: begin
            tp <= 0;
            if (c0) estado <= db;
            else
              case(lin_matriz)
                4'0111: lin_matriz <= 4'1011;
                4'1011: lin_matriz <= 4'1101;
                4'1101: lin_matriz <= 4'1110;
                4'1110: lin_matriz <= 4'0111;
                default: lin_matriz <= 4'0111;
              endcase
          end
          db: begin
            tp <= tp + 1;
            if (c1) estado <= leitura;
            else if(tp >= 100) estado <=decodificar;
            else estado <= db;
          end
          decodificar: begin
            tp <= 0;
            if (c1) estado <= leitura;
            else estado <= dispSaida;
          end
          dispSaida: begin
            tp <= 0;
            if (c1) estado <= leitura;
            else estado <= teclaValid;
          end
          teclaValid: begin
            tp <= 0;
            if (c1) estado <= leitura;
            else estado <= teclaValid;
          end
          default: begin
            tp <= 0;
            estado <= leitura;
          end
        endcase
  end

  always_comb begin
    if (rst) begin
      lin_matriz = 4'b0111;
      tecla_value = 0xF;
      tecla_valid = 0;
    end case (estado)
      leitura: begin
        tecla_value = 0xF;
        tecla_valid = 0;
      end
      db: begin
        tecla_value = 0xF;
        tecla_valid = 0;
      end
      decodificar: begin
        case ((lin_matriz << 4) | col_matriz)
          8'b01110111: tecla_value = 0x1;
          8'b01111011: tecla_value = 0x2;
          8'b01111101: tecla_value = 0x3;
          8'b01111110: tecla_value = 0xA;
          8'b10110111: tecla_value = 0x4;
          8'b10111011: tecla_value = 0x5;
          8'b10111101: tecla_value = 0x6;
          8'b10111110: tecla_value = 0xB;
          8'b11010111: tecla_value = 0x7;
          8'b11011011: tecla_value = 0x8;
          8'b11011101: tecla_value = 0x9;
          8'b11011110: tecla_value = 0xC;
          8'b11100111: tecla_value = 0xF;
          8'b11101011: tecla_value = 0x0;
          8'b11101101: tecla_value = 0xE;
          8'b11101110: tecla_value = 0xD;
        endcase
        tecla_valid = 0;
      end
      dispSaida: begin
        tecla_valid = 0;
      end
      teclaValid: begin
        tecla_valid = 1;
      end
      default: begin
        lin_matriz = 4'b0111;
        tecla_value = 0xF;
        tecla_valid = 0;
      end
    endcase
  end
endmodule