import tipos_pacotes::*;

module operacional#(
  FECHAR_AUT,
  DEBOUNCE,
  DURACAO,
  BIPAR,
  SENHA_ERRADA,
  BLOQUEADO,
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
    validar_senha,
    bipar_senha_incompleta,
    bipar_porta_aberta,
    debounce_nao_pertube,
    debounce_sair_nao_pertube,
    debounce_trancar,
    debounce_destrancar,
  } estado;
  logic [4:0] cont, contFechado;

  assign erro_teclado = digitos_valid && (digitos_value[0] >= 10);
  assign confirmar = digitos_valid && (digitos_value[0] != 'hE);
  assign senha_certa = (
    digitos_value == senha_master ||
    digitos_value == senha1 ||
    digitos_value == senha2 ||
    digitos_value == senha3 ||
    digitos_value == senha4
  );

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
            estado <= validar_senha;
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
            contFechado++;
          end
        end
        porta_aberta: begin
          if (botao_config) begin
            estado <= setup;
          end
          else if (!sensor_contato) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else if (cont >= BIPAR) begin
            estado <= bipar_porta_aberta;
          end
          else begin
            cont++;
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
          end
          else begin
            cont++;
          end
        end
        nao_pertube: begin
          if (botao_interno) begin
            estado <= debounce_sair_nao_pertube;
            cont <= 0;
          end
        end
        senha_errada: begin
          tent++;
          if (cont < SENHA_ERRADA) begin
            cont++;
          end
          else if (tent < 5) begin
            estado <= porta_trancada;
          end
          else if (tent >= 5) begin
            estado <= bloqueado;
            cont <= 0;
          end
        end
        validar_senha: begin
          if (senha_certa) begin
            estado <= porta_encostada;
            contFechado <= 0;
          end
          else begin
            estado <= senha_errada;
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
        end
        debounce_nao_pertube: begin
          if (cont >= DEBOUNCE) begin
            estado <= nao_pertube;
          end
          else if (!botao_bloqueio) begin
            estado <= porta_trancada;
          end
          else begin
            cont++;
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
            cont++;
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
            cont++;
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
            cont++;
          end
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
          display_en = 0;
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
      endcase
    end
  end
endmodule