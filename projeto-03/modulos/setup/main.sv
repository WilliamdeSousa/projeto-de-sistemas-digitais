import tipos_pacotes::*;

module setup (
  input		logic		    clk,
  input		logic		    rst,
  input		logic		    setup_on,
  input		senhaPac_t	digitos_value,
  input		logic		    digitos_valid,
  output	logic		    display_en,
  output	bcdPac_t	  bcd_pac,
  output	setupPac_t 	data_setup_new,
  output	logic		    data_setup_ok,
);
  enum logic [4:0] {
    setup_off,
    ativar_bip,
    temp_bip,
    temp_trancamento,
    estado_senha_master,
    senha1,
    senha2,
    senha3,
    senha4
    armazenar_setup
  } estado;

  setupPac_t config_atual;

  assign confirmar = digitos_valid && (digitos_value != 20{'hE});
  assign senha_certa = (digitos_value.digits == config_atual.senha_master.digits);
  assign exit_setup = (digitos_value.digits[0] == 'hB);

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      estado <= setup_off;
      config_atual.bip_ativado <= 1;
      config_atual.bip_time <= 5;
      config_atual.tranca_aut_time <= 5;
      config_atual.senha_master.digits <= 'h1234;
      config_atual.senha_1.digits = 20{'hF};
      config_atual.senha_2.digits = 20{'hF};
      config_atual.senha_3.digits = 20{'hF};
      config_atual.senha_4.digits = 20{'hF};
    end
    else begin
      case (estado)
        setup_off: begin
            if(setup_on) estado <= ler_senha_master;
        end
        ativar_bip: begin
            if (exit_setup) estado <= armazenar_setup
            else if(confirmar) estado <= temp_bip;
            else if(digitos_value[0] == 'h0) config_atual.bip_status <= 0;
            else if(digitos_value[0] == 'h1) config_atual.bip_status <= 1;
        end
        temp_bip: begin
            if (exit_setup) estado <= armazenar_setup
            else if (confirmar) begin
                config_atual.temp_bip <= digitos_value & 'hFF;
                estado <= temp_trancamento;
            end
        end
        temp_trancamento: begin
            if (exit_setup) estado <= armazenar_setup
            else if(confirmar) begin
                config_atual.tranca_aut_time <= digitos_value & 'hFF;
                estado <= estado_senha_master;
            end
        end
        estado_senha_master: begin
            if (exit_setup) estado <= armazenar_setup
            else if (confirmar) begin
                if(digitos_value.digits[3] != 'hF)
                    config_atual.senha_master = digitos_value;
                    estado <= senha1;
            end
        end
        senha1: begin
            if (exit_setup) estado <= armazenar_setup
            else if (confirmar) begin
                if(digitos_value.digits[3] != 'hF)
                    config_atual.senha_1 = digitos_value;
                estado <= senha2;
            end
        end
        senha2: begin
            if (exit_setup) estado <= armazenar_setup
            else if (confirmar) begin
                if(digitos_value.digits[3] != 'hF)
                    config_atual.senha_2 = digitos_value;
                estado <= senha3;
            end
        end
        senha3: begin
            if (exit_setup) estado <= armazenar_setup
            else if (confirmar) begin
                if(digitos_value.digits[3] != 'hF)
                    config_atual.senha_3 = digitos_value;
                estado <= senha4;
            end
        end
        senha4: begin
            if (exit_setup) estado <= armazenar_setup
            else if (confirmar) begin
                if(digitos_value.digits[3] != 'hF)
                    config_atual.senha_4 = digitos_value;
                estado <= armazenar_setup;
            end
        end
        armazenar_setup: begin
            data_setup_new.bip_ativado <=config_atual.bip_ativado;

            int conv <= data_setup_new.bip_time <= config_atual.bip_time[1] * 10 + config_atual.bip_time[0];
            if(conv > 60) conv <= 60;
            else if (conv < 5) conv <= 5;
            data_setup_new.bip_time <=  conv

            int conv <= config_atual.tranca_aut_time[1] * 10 + config_atual.tranca_aut_time[0];
            if(conv > 60) conv <= 60;
            else if (conv < 5) conv <= 5;
            data_setup_new.tranca_aut_time <= conv;

            data_setup_new.senha_master.digits <= config_atual.senha_master;
            data_setup_new.senha_1.digits <= config_atual.senha_1;
            data_setup_new.senha_2.digits <= config_atual.senha_2;
            data_setup_new.senha_3.digits <= config_atual.senha_3;
            data_setup_new.senha_4.digits <= config_atual.senha_4;

            estado <= setup_off;

        end
        default: estado <= setup_off;
      endcase
    end
  end

  always_comb begin
    if(rst) begin
      display_en = 0
      bcd_pac = 'hBBBBBB;
      data_setup_ok = 0
    end
    else case(estado)
      setup_off: begin
        display_en = 0;
        bcd_pac = 'hBBBBBB;
        data_setup_ok = 0
      end
      ativar_bip: begin
        display_en = 1;
        bcd_pac = 'h1BBBB0 | config_atual.bip_status;
        data_setup_ok = 0
      end
      temp_bip: begin
        display_en = 1;
        bcd_pac = (('h2BBB00) | (config_atual.bip_time));
        data_setup_ok = 0
      end
      temp_trancamento: begin
        display_en = 1;
        bcd_pac = (('h3BBB00) | (config_atual.tranca_aut_time));
        data_setup_ok = 0
      end
      estado_senha_master: begin
        display_en = 1;
        bcd_pac = 'h4BBBBB;
        data_setup_ok = 0
      end
      senha1: begin
        display_en = 1;
        bcd_pac = 'h5BBBBB;
        data_setup_ok = 0
      end
      senha2: begin
        display_en = 1;
        bcd_pac = 'h6BBBBB;
        data_setup_ok = 0
      end
      senha3: begin
        display_en = 1;
        bcd_pac = 'h7BBBBB;
        data_setup_ok = 0
      end
      senha4: begin
        display_en = 1;
        bcd_pac = 'h8BBBBB;
        data_setup_ok = 0
      end
      armazenar_setup: begin // mantive estado anterior de senha 4, para não haver inconsistência no teclado enquanto estiver no estado armazenar_setup
        display_en = 1;
        bcd_pac = 'h8BBBBB;
        data_setup_ok = 1
      end
    endcase
  end
endmodule