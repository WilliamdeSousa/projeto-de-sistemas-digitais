typedef struct packed {
  logic [19:0] [3:0] digits;
} senhaPac_t;

module decodificador_de_teclado (
input 	logic		    clk,
input	  logic		    rst,
input	  logic 		  enable,
input 	logic [3:0] col_matriz,
output  logic [3:0] lin_matriz,
output 	senhaPac_t	digitos_value,
output	logic 		  digitos_valid
);

  logic [3:0] col_lida;
  logic c0;
  logic c1;

  enum logic [3:0] {
    leitura,
    db,
    decodificar,
    arrayValido,
    arrayComB,
    arrayComE,
    limparArray,
    reset,
    inserirNoArray,
    tecladoDesativado
  } estado;

  logic [6:0] ta; // 0 - 127
  logic [6:0] td; // 0 - 127
  assign c0 = col_matriz == 4'b0111 || col_matriz == 4'b1011 || col_matriz == 4'b1101 || col_matriz == 4'b1110;
  assign c1 = col_matriz == 4'b1111;

  always_ff @(posedge rst or posedge clk) begin
    if (rst) begin
      estado <= leitura;
      ta <= 0;
      td <= 0;
      lin_matriz <= 4'b0111;
    end else
      case (estado)
        reset: begin
          ta <= 0;
          td <= 0;
          estado <= leitura;
        end
        leitura: begin
          ta <= ta + 1;
          if (c0) begin
            col_lida <= col_matriz;
            td <= 0;
            estado <= db;
          end
          else if (ta >= 5000) begin
            estado <= arrayComE;
          end
          else if (enable) begin
            estado <= tecladoDesativado;
          end
          else
            case(lin_matriz)
              4'b0111: lin_matriz <= 4'b1011;
              4'b1011: lin_matriz <= 4'b1101;
              4'b1101: lin_matriz <= 4'b1110;
              4'b1110: lin_matriz <= 4'b0111;
              default: lin_matriz <= 4'b0111;
            endcase
        end
        db: begin
          td <= td + 1;
          if (c1) begin
            ta <= 0;
            estado <= leitura;
          end
          else if(td >= 100) estado <=decodificar;
          else estado <= db;
        end
        decodificar: begin
          td <= 0;
          if (((lin_matriz << 4) | col_matriz) == 8'b01111110 ) begin
            estado <= arrayValido;
          end
          else if(((lin_matriz << 4) | col_matriz) == 8'b10111110)
            estado <= arrayComB;
          else estado <= inserirNoArray;
        end
        arrayValido: begin
          td <= 0;
          estado <= limparArray;
        end
        arrayComB: begin
          td <= 0;
          estado <= limparArray;
        end
        arrayComE: begin
          td <= 0;
          estado <= limparArray;
        end
        limparArray: begin
          if(c1) begin
            ta <= 0;
            estado <= leitura;
          end
        end
        inserirNoArray: begin
          if (c1) begin
            ta <= 0;
            estado <= leitura;
          end
        end
        tecladoDesativado: begin
          if(enable) begin
            estado <= leitura;
          end
        end
        default: begin
          td <= 0;
          ta <= 0;
          estado <= leitura;
          lin_matriz <= 4'b0111;
        end
      endcase
  end

  always_comb begin
    if (rst) begin;
      digitos_valid = 0;
      digitos_value = '{default:'hF};
    end else
      case (estado)
        reset:  begin
          digitos_valid = 0;
          digitos_value = '{default:'hF};
        end
        leitura: begin
          digitos_valid = 0;
        end
        db: begin
          digitos_valid = 0;
        end
        decodificar: begin
          logic [3:0] tecla_lida;
          logic nova_tecla;

          case ((lin_matriz << 4) | col_lida)

            8'b01110111: begin tecla_lida = 4'h1; nova_tecla = 1; end
            8'b01111011: begin tecla_lida = 4'h2; nova_tecla = 1; end
            8'b01111101: begin tecla_lida = 4'h3; nova_tecla = 1; end

            8'b10110111: begin tecla_lida = 4'h4; nova_tecla = 1; end
            8'b10111011: begin tecla_lida = 4'h5; nova_tecla = 1; end
            8'b10111101: begin tecla_lida = 4'h6; nova_tecla = 1; end

            8'b11010111: begin tecla_lida = 4'h7; nova_tecla = 1; end
            8'b11011011: begin tecla_lida = 4'h8; nova_tecla = 1; end
            8'b11011101: begin tecla_lida = 4'h9; nova_tecla = 1; end

            8'b11101011: begin tecla_lida = 4'h0; nova_tecla = 1; end

            default: begin
              tecla_lida = 4'hF;
              nova_tecla = 0;
            end
          endcase

          if (nova_tecla) begin
            digitos_value.digits = {digitos_value[18:0], tecla_lida};
          end
          digitos_valid = 0;
        end
        arrayValido: begin
          digitos_valid = 1;
        end
        arrayComB: begin
          digitos_valid = 1;
          digitos_value = '{default:'hB};
        end
        arrayComE: begin
          digitos_valid = 1;
          digitos_value = '{default:'hE};
        end
        limparArray: begin
          digitos_valid = 1;
          digitos_value = '{default:'hF};
        end
        inserirNoArray: begin
          digitos_valid = 0;
        end
        tecladoDesativado: begin
          digitos_valid = 0;
        end
        default: begin
          digitos_valid = 0;
        end
      endcase
  end
endmodule