import tipos_pacotes::*;

module display (
  input  logic       clk,
  input  logic       rst,
  input  logic       enable_o, enable_s,
  input  bcdPac_t    bcd_packet_operacional, bcd_packet_setup,
  output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
  enum logic [1:0] { disponivel, operacional, setup } estado;

  always_ff @(posedge clk) begin
    if (rst) begin
      estado <= disponivel;
    end
    else begin
      case (estado)
        disponivel: begin
          if (enable_o) estado <= operacional;
          else if (enable_s) estado <= setup;
          end
        operacional: begin
          if (!enable_o) estado <= disponivel;
        end
        setup: begin
          if (!enable_s) estado <= disponivel;
        end
        default: estado <= disponivel;
      endcase
    end
  end

  always_comb begin
    if (rst) begin
      HEX0 = 7'b1111111;
      HEX1 = 7'b1111111;
      HEX2 = 7'b1111111;
      HEX3 = 7'b1111111;
      HEX4 = 7'b1111111;
      HEX5 = 7'b1111111;
    end
    else begin
      case (estado)
        disponivel: begin
          HEX0 = 7'b1111111;
          HEX1 = 7'b1111111;
          HEX2 = 7'b1111111;
          HEX3 = 7'b1111111;
          HEX4 = 7'b1111111;
          HEX5 = 7'b1111111;
        end

        operacional: begin
          case (bcd_packet_operacional.BCD0)
            4'h0: HEX0 = 7'b1000000;
            4'h1: HEX0 = 7'b1111001;
            4'h2: HEX0 = 7'b0100100;
            4'h3: HEX0 = 7'b0110000;
            4'h4: HEX0 = 7'b0011001;
            4'h5: HEX0 = 7'b0010010;
            4'h6: HEX0 = 7'b0000010;
            4'h7: HEX0 = 7'b1111000;
            4'h8: HEX0 = 7'b0000000;
            4'h9: HEX0 = 7'b0011000;
            4'hA: HEX0 = 7'b0111111;
            4'hB: HEX0 = 7'b1111111;
          endcase
          case (bcd_packet_operacional.BCD1)
            4'h0: HEX1 = 7'b1000000;
            4'h1: HEX1 = 7'b1111001;
            4'h2: HEX1 = 7'b0100100;
            4'h3: HEX1 = 7'b0110000;
            4'h4: HEX1 = 7'b0011001;
            4'h5: HEX1 = 7'b0010010;
            4'h6: HEX1 = 7'b0000010;
            4'h7: HEX1 = 7'b1111000;
            4'h8: HEX1 = 7'b0000000;
            4'h9: HEX1 = 7'b0011000;
            4'hA: HEX1 = 7'b0111111;
            4'hB: HEX1 = 7'b1111111;
          endcase
          case (bcd_packet_operacional.BCD2)
            4'h0: HEX2 = 7'b1000000;
            4'h1: HEX2 = 7'b1111001;
            4'h2: HEX2 = 7'b0100100;
            4'h3: HEX2 = 7'b0110000;
            4'h4: HEX2 = 7'b0011001;
            4'h5: HEX2 = 7'b0010010;
            4'h6: HEX2 = 7'b0000010;
            4'h7: HEX2 = 7'b1111000;
            4'h8: HEX2 = 7'b0000000;
            4'h9: HEX2 = 7'b0011000;
            4'hA: HEX2 = 7'b0111111;
            4'hB: HEX2 = 7'b1111111;
          endcase
          case (bcd_packet_operacional.BCD3)
            4'h0: HEX3 = 7'b1000000;
            4'h1: HEX3 = 7'b1111001;
            4'h2: HEX3 = 7'b0100100;
            4'h3: HEX3 = 7'b0110000;
            4'h4: HEX3 = 7'b0011001;
            4'h5: HEX3 = 7'b0010010;
            4'h6: HEX3 = 7'b0000010;
            4'h7: HEX3 = 7'b1111000;
            4'h8: HEX3 = 7'b0000000;
            4'h9: HEX3 = 7'b0011000;
            4'hA: HEX3 = 7'b0111111;
            4'hB: HEX3 = 7'b1111111;
          endcase
          case (bcd_packet_operacional.BCD4)
            4'h0: HEX4 = 7'b1000000;
            4'h1: HEX4 = 7'b1111001;
            4'h2: HEX4 = 7'b0100100;
            4'h3: HEX4 = 7'b0110000;
            4'h4: HEX4 = 7'b0011001;
            4'h5: HEX4 = 7'b0010010;
            4'h6: HEX4 = 7'b0000010;
            4'h7: HEX4 = 7'b1111000;
            4'h8: HEX4 = 7'b0000000;
            4'h9: HEX4 = 7'b0011000;
            4'hA: HEX4 = 7'b0111111;
            4'hB: HEX4 = 7'b1111111;
          endcase
          case (bcd_packet_operacional.BCD5)
            4'h0: HEX5 = 7'b1000000;
            4'h1: HEX5 = 7'b1111001;
            4'h2: HEX5 = 7'b0100100;
            4'h3: HEX5 = 7'b0110000;
            4'h4: HEX5 = 7'b0011001;
            4'h5: HEX5 = 7'b0010010;
            4'h6: HEX5 = 7'b0000010;
            4'h7: HEX5 = 7'b1111000;
            4'h8: HEX5 = 7'b0000000;
            4'h9: HEX5 = 7'b0011000;
            4'hA: HEX5 = 7'b0111111;
            4'hB: HEX5 = 7'b1111111;
          endcase
        end

        setup: begin
          case (bcd_packet_setup.BCD0)
            4'h0: HEX0 = 7'b1000000;
            4'h1: HEX0 = 7'b1111001;
            4'h2: HEX0 = 7'b0100100;
            4'h3: HEX0 = 7'b0110000;
            4'h4: HEX0 = 7'b0011001;
            4'h5: HEX0 = 7'b0010010;
            4'h6: HEX0 = 7'b0000010;
            4'h7: HEX0 = 7'b1111000;
            4'h8: HEX0 = 7'b0000000;
            4'h9: HEX0 = 7'b0011000;
            4'hA: HEX0 = 7'b0111111;
            4'hB: HEX0 = 7'b1111111;
          endcase
          case (bcd_packet_setup.BCD1)
            4'h0: HEX1 = 7'b1000000;
            4'h1: HEX1 = 7'b1111001;
            4'h2: HEX1 = 7'b0100100;
            4'h3: HEX1 = 7'b0110000;
            4'h4: HEX1 = 7'b0011001;
            4'h5: HEX1 = 7'b0010010;
            4'h6: HEX1 = 7'b0000010;
            4'h7: HEX1 = 7'b1111000;
            4'h8: HEX1 = 7'b0000000;
            4'h9: HEX1 = 7'b0011000;
            4'hA: HEX1 = 7'b0111111;
            4'hB: HEX1 = 7'b1111111;
          endcase
          case (bcd_packet_setup.BCD2)
            4'h0: HEX2 = 7'b1000000;
            4'h1: HEX2 = 7'b1111001;
            4'h2: HEX2 = 7'b0100100;
            4'h3: HEX2 = 7'b0110000;
            4'h4: HEX2 = 7'b0011001;
            4'h5: HEX2 = 7'b0010010;
            4'h6: HEX2 = 7'b0000010;
            4'h7: HEX2 = 7'b1111000;
            4'h8: HEX2 = 7'b0000000;
            4'h9: HEX2 = 7'b0011000;
            4'hA: HEX2 = 7'b0111111;
            4'hB: HEX2 = 7'b1111111;
          endcase
          case (bcd_packet_setup.BCD3)
            4'h0: HEX3 = 7'b1000000;
            4'h1: HEX3 = 7'b1111001;
            4'h2: HEX3 = 7'b0100100;
            4'h3: HEX3 = 7'b0110000;
            4'h4: HEX3 = 7'b0011001;
            4'h5: HEX3 = 7'b0010010;
            4'h6: HEX3 = 7'b0000010;
            4'h7: HEX3 = 7'b1111000;
            4'h8: HEX3 = 7'b0000000;
            4'h9: HEX3 = 7'b0011000;
            4'hA: HEX3 = 7'b0111111;
            4'hB: HEX3 = 7'b1111111;
          endcase
          case (bcd_packet_setup.BCD4)
            4'h0: HEX4 = 7'b1000000;
            4'h1: HEX4 = 7'b1111001;
            4'h2: HEX4 = 7'b0100100;
            4'h3: HEX4 = 7'b0110000;
            4'h4: HEX4 = 7'b0011001;
            4'h5: HEX4 = 7'b0010010;
            4'h6: HEX4 = 7'b0000010;
            4'h7: HEX4 = 7'b1111000;
            4'h8: HEX4 = 7'b0000000;
            4'h9: HEX4 = 7'b0011000;
            4'hA: HEX4 = 7'b0111111;
            4'hB: HEX4 = 7'b1111111;
          endcase
          case (bcd_packet_setup.BCD5)
            4'h0: HEX5 = 7'b1000000;
            4'h1: HEX5 = 7'b1111001;
            4'h2: HEX5 = 7'b0100100;
            4'h3: HEX5 = 7'b0110000;
            4'h4: HEX5 = 7'b0011001;
            4'h5: HEX5 = 7'b0010010;
            4'h6: HEX5 = 7'b0000010;
            4'h7: HEX5 = 7'b1111000;
            4'h8: HEX5 = 7'b0000000;
            4'h9: HEX5 = 7'b0011000;
            4'hA: HEX5 = 7'b0111111;
            4'hB: HEX5 = 7'b1111111;
          endcase
        end
      endcase
    end
  end
endmodule