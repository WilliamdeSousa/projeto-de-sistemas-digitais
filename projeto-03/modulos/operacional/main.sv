import tipos_pacotes::*;

module operacional#(
  parameter FECHAR_AUT = 5000,
  parameter DEBOUNCE = 100,
  parameter DURACAO = 50,
  parameter SENHA_ERRADA = 1000,
  parameter BLOQUEADO = 30000
) (
  input		logic		    clk,
	input		logic		    rst,
	input		logic		    sensor_contato,
	input		logic		    botao_interno,
	input		logic		    botao_bloqueio,
	input		logic		    botao_config,
  input		setupPac_t 	data_setup_new,
	input		logic		    data_setup_ok,
	input		senhaPac_t	digitos_value,
	input		logic		    digitos_valid,
	output	bcdPac_t	  bcd_pac,
	output 	logic 		  teclado_en,
	output	logic		    display_en,
	output	logic		    setup_on,
  output	logic		    tranca,
	output	logic		    bip
);
  enum logic [4:0] {
    reset,
    porta_trancada,
    porta_encostada,
    porta_aberta,
    setup,
    bloqueado,
    nao_pertube,
    senha_errada,
    validar_mask,
    comparar_mask,
    validar_senha,
    validar_senhadenovo,
    bipar_senha_incompleta,
    bipar_porta_aberta,
    debounce_nao_pertube,
    debounce_sair_nao_pertube,
    debounce_trancar,
    debounce_destrancar,
    leitura_senha_master,
    validar_senha_master
  } estado;
  logic [4:0] cont, contFechado, tent;
  logic [19:0] [3:0] senha, mask1, mask2, mask3, mask4;
  logic senha_valida1, senha_valida2, senha_valida3, senha_valida4, senha_master_valida;

  assign exit_setup = (digitos_value.digits[0] == 'hB);
  assign erro_teclado = digitos_valid && (digitos_value.digits[0] == 'hE);
  assign confirmar = digitos_valid && (digitos_value.digits[0] != 'hE && digitos_value.digits[0] != 'hB );
  assign senha_certa = (senha_valida1 || senha_valida2 || senha_valida3 || senha_valida4);

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      estado <= reset;
      cont <= 0;
      tent <= 0;
      contFechado <= 0;
    end
    else begin
      case (estado)
        reset: begin
          if (!sensor_contato) begin
            estado <= porta_trancada;
            tent <= 0;
          end
        end
        porta_trancada: begin
          if (erro_teclado) begin
            estado <= bipar_senha_incompleta;
            cont <= 0;
          end
          else if (botao_bloqueio) begin
            estado <= debounce_nao_pertube;
            cont <= 0;
          end
          else if (botao_interno) begin
            estado <= debounce_destrancar;
            cont <= 0;
          end
          else if (confirmar) begin
            estado <= validar_mask;
            tent <= tent + 1;
          end
        end
        porta_encostada: begin
          if (botao_interno) begin
            estado <= debounce_trancar;
            cont <= 0;
          end
          else if (sensor_contato) begin
            estado <= porta_aberta;
            cont <= 0;
          end
          else if (contFechado >= FECHAR_AUT) begin
            estado <= porta_trancada;
          end
          else begin
            contFechado <= contFechado + 1;
          end
        end
        porta_aberta: begin
          if (botao_config) begin
            estado <= leitura_senha_master;
          end
          else if (!sensor_contato) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else if (cont >= data_setup_new.bip_time) begin
            estado <= bipar_porta_aberta;
          end
          else begin
            cont <= cont + 1;
          end
        end
        setup: begin
          if (data_setup_ok) begin
            estado <= porta_aberta;
          end
        end
        bloqueado: begin
          if (cont >= BLOQUEADO) begin
            cont <= 0;
            tent <= 0;
            estado <= porta_trancada;
          end
          else begin
            cont <= cont + 1;
          end
        end
        nao_pertube: begin
          if (botao_interno) begin
            estado <= debounce_sair_nao_pertube;
            cont <= 0;
          end
        end
        senha_errada: begin
          if (cont < SENHA_ERRADA) begin
            cont <= cont + 1;
          end
          else if (tent < 5) begin
            estado <= porta_trancada;
          end
          else if (tent >= 5) begin
            estado <= bloqueado;
            cont <= 0;
          end
        end
        validar_mask: begin
          senha <= data_setup_new.senha_1.digits;
          if (senha[3*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFFFFFFFFFFF;
          else if (senha[4*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFFFFFFF0000;
          else if (senha[5*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFFFFFF00000;
          else if (senha[6*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFFFFF000000;
          else if (senha[7*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFFFF0000000;
          else if (senha[8*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFFF00000000;
          else if (senha[9*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFFF000000000;
          else if (senha[10*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFFF0000000000;
          else if (senha[11*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFFF00000000000;
          else if (senha[12*4 +:4] == 'hF)
            mask1 <= 'hFFFFFFFF000000000000;
          else 	mask1 <= 80'hFFFFFFFFFFFFFFFFFFFF;

          senha <= data_setup_new.senha_2.digits;
          if (senha[3*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFFFFFFFFFFF;
          else if (senha[4*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFFFFFFF0000;
          else if (senha[5*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFFFFFF00000;
          else if (senha[6*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFFFFF000000;
          else if (senha[7*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFFFF0000000;
          else if (senha[8*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFFF00000000;
          else if (senha[9*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFFF000000000;
          else if (senha[10*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFFF0000000000;
          else if (senha[11*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFFF00000000000;
          else if (senha[12*4 +:4] == 'hF)
            mask2 <= 'hFFFFFFFF000000000000;
          else 	mask2 <= 80'hFFFFFFFFFFFFFFFFFFFF;

          senha <= data_setup_new.senha_3.digits;
          if (senha[3*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFFFFFFFFFFF;
          else if (senha[4*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFFFFFFF0000;
          else if (senha[5*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFFFFFF00000;
          else if (senha[6*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFFFFF000000;
          else if (senha[7*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFFFF0000000;
          else if (senha[8*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFFF00000000;
          else if (senha[9*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFFF000000000;
          else if (senha[10*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFFF0000000000;
          else if (senha[11*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFFF00000000000;
          else if (senha[12*4 +:4] == 'hF)
            mask3 <= 'hFFFFFFFF000000000000;
          else 	mask3 <= 80'hFFFFFFFFFFFFFFFFFFFF;

          senha <= data_setup_new.senha_4.digits;
          if (senha[3*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFFFFFFFFFFF;
          else if (senha[4*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFFFFFFF0000;
          else if (senha[5*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFFFFFF00000;
          else if (senha[6*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFFFFF000000;
          else if (senha[7*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFFFF0000000;
          else if (senha[8*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFFF00000000;
          else if (senha[9*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFFF000000000;
          else if (senha[10*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFFF0000000000;
          else if (senha[11*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFFF00000000000;
          else if (senha[12*4 +:4] == 'hF)
            mask4 <= 'hFFFFFFFF000000000000;
          else 	mask4 <= 80'hFFFFFFFFFFFFFFFFFFFF;
          estado <= comparar_mask;
        end
        comparar_mask: begin
          senha_valida1 <= ((((~((~digitos_value)>>(0*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(1*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(2*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(3*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(4*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(5*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(6*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(7*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(8*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(9*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(10*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(11*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(12*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(13*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(14*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(15*4)))|mask1)==senha) |
            (((~((~digitos_value)>>(16*4)))|mask1)==senha));

            senha_valida2 <= ((((~((~digitos_value)>>(0*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(1*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(2*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(3*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(4*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(5*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(6*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(7*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(8*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(9*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(10*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(11*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(12*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(13*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(14*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(15*4)))|mask2)==senha) |
            (((~((~digitos_value)>>(16*4)))|mask2)==senha));

            senha_valida3 <= ((((~((~digitos_value)>>(0*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(1*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(2*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(3*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(4*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(5*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(6*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(7*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(8*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(9*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(10*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(11*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(12*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(13*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(14*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(15*4)))|mask3)==senha) |
            (((~((~digitos_value)>>(16*4)))|mask3)==senha));

            senha_valida1 <= ((((~((~digitos_value)>>(0*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(1*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(2*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(3*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(4*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(5*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(6*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(7*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(8*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(9*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(10*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(11*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(12*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(13*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(14*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(15*4)))|mask4)==senha) |
            (((~((~digitos_value)>>(16*4)))|mask4)==senha));
            estado<=validar_senha;
        end
        validar_senha: begin
          senha_certa = (senha_valida1 || senha_valida2 || senha_valida3 || senha_valida4);
          estado<= validar_senhadenovo
        end
        validar_senhadenovo:begin
          if (senha_certa) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else begin
            estado <= senha_errada;
            cont <= 0;
          end
        end
        bipar_senha_incompleta: begin
          if (cont < DURACAO) begin
            cont++;
          end
          else begin
            estado <= porta_trancada;
          end
        end
        bipar_porta_aberta: begin
          if (!sensor_contato) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else if(botao_config) begin
            estado <= leitura_senha_master;
          end
        end
        debounce_nao_pertube: begin
          if (cont >= DEBOUNCE) begin
            estado <= nao_pertube;
          end
          else if (!botao_bloqueio) begin
            estado <= porta_trancada;
          end
          else begin
            cont <= cont + 1;
          end
        end
        debounce_sair_nao_pertube: begin
          if (cont >= DEBOUNCE) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else if (!botao_interno) begin
            estado <= nao_pertube;
          end
          else begin
            cont <= cont + 1;
          end
        end
        debounce_trancar: begin
          if (cont >= DEBOUNCE) begin
            estado <= porta_trancada;
          end
          else if (!botao_interno) begin
            estado <= porta_encostada;
          end
          else begin
            cont <= cont +1;
          end
        end
        debounce_destrancar: begin
          if (cont >= DEBOUNCE) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else if (!botao_interno) begin
            estado <= porta_trancada;
          end
          else begin
            cont <= cont + 1;
          end
        end
        leitura_senha_master: begin
          if(exit_setup) begin
            estado <= porta_aberta;
          end
          else if(confirmar) begin
            estado <= validar_senha_master;
          end
        end
        validar_senha_master: begin
          //Validar senha master
          senha <= data_setup_new.senha_master.digits;
          if (senha[3*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFFFFFFFFFFF;
          else if (senha[4*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFFFFFFF0000;
          else if (senha[5*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFFFFFF00000;
          else if (senha[6*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFFFFF000000;
          else if (senha[7*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFFFF0000000;
          else if (senha[8*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFFF00000000;
          else if (senha[9*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFFF000000000;
          else if (senha[10*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFFF0000000000;
          else if (senha[11*4 +:4] == 'hF)
            mask <= 'hFFFFFFFFF00000000000;
          else if (senha[12*4 +:4] == 'hF)
            mask <= 'hFFFFFFFF000000000000;
          else 	mask <= 80'hFFFFFFFFFFFFFFFFFFFF;

          senha_master_valida <= ((((~((~digitos_value)>>(0*4)))|mask)==senha) |
            (((~((~digitos_value)>>(1*4)))|mask)==senha) |
            (((~((~digitos_value)>>(2*4)))|mask)==senha) |
            (((~((~digitos_value)>>(3*4)))|mask)==senha) |
            (((~((~digitos_value)>>(4*4)))|mask)==senha) |
            (((~((~digitos_value)>>(5*4)))|mask)==senha) |
            (((~((~digitos_value)>>(6*4)))|mask)==senha) |
            (((~((~digitos_value)>>(7*4)))|mask)==senha) |
            (((~((~digitos_value)>>(8*4)))|mask)==senha) |
            (((~((~digitos_value)>>(9*4)))|mask)==senha) |
            (((~((~digitos_value)>>(10*4)))|mask)==senha) |
            (((~((~digitos_value)>>(11*4)))|mask)==senha) |
            (((~((~digitos_value)>>(12*4)))|mask)==senha) |
            (((~((~digitos_value)>>(13*4)))|mask)==senha) |
            (((~((~digitos_value)>>(14*4)))|mask)==senha) |
            (((~((~digitos_value)>>(15*4)))|mask)==senha) |
            (((~((~digitos_value)>>(16*4)))|mask)==senha));

          if(senha_master_valida) begin
            estado <= setup;
          end
          else estado <= leitura_senha_master;
        end
        default: estado <= reset;
      endcase
    end
  end

  always_comb begin
    if(rst) begin
      bcd_pac = 'hBBBBBB;
      teclado_en = 0;
      display_en = 1;
      setup_on = 0;
      tranca = 0;
      bip = 0;
    end
    else begin
      case(estado)
        reset: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 0;
        end
        porta_trancada: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 1;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        porta_encostada: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 0;
        end
        porta_aberta: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 0;
        end
        setup: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 1;
          display_en = 1;
          setup_on = 1;
          tranca = 0;
          bip = 0;
        end
        bloqueado: begin
          bcd_pac = 'hBAAAAA;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        nao_pertube: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 0;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        senha_errada: begin
          case(tent)
            1: bcd_pac = 'hBBBBBA;
            2: bcd_pac = 'hBBBBAA;
            3: bcd_pac = 'hBBBAAA;
            4: bcd_pac = 'hBBAAAA;
            5: bcd_pac = 'hBAAAAA;
          endcase
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        validar_senha: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        bipar_senha_incompleta: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 1;
        end
        bipar_porta_aberta: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 1;
        end
        debounce_nao_pertube: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        debounce_sair_nao_pertube: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        debounce_trancar: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 0;
        end
        debounce_destrancar: begin
          bcd_pac = 'hBBBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 1;
          bip = 0;
        end
        leitura_senha_master: begin
          bcd_pac = 'h0BBBBB;
          teclado_en = 1;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 0;
        end
        validar_senha_master: begin
          bcd_pac = 'h0BBBBB;
          teclado_en = 0;
          display_en = 1;
          setup_on = 0;
          tranca = 0;
          bip = 0;
        end
      endcase
    end
  end
endmodule