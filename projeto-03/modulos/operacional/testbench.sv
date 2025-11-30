`timescale 1ns/1ps

module testBranch_operacional();

  logic [6:0] teste;
  logic falhou;
  logic [6:0] X;

  // Entradas
  logic clk;
  logic rst;
  logic sensor_contato;
  logic botao_interno;
  logic botao_bloqueio;
  logic botao_config;
  senhaPac_t  digitos_value;
  logic digitos_valid;
  setupPac_t  data_setup_new;
  logic       data_setup_ok;

  // Saídas
  bcdPac_t bcd_pac;
  logic teclado_en, display_en, setup_on, tranca, bip;

  // DUT
  operacional dut(
    .clk(clk),
    .rst(rst),
    .sensor_contato(sensor_contato),
    .botao_interno(botao_interno),
    .botao_bloqueio(botao_bloqueio),
    .botao_config(botao_config),
    .data_setup_new(data_setup_new),
    .data_setup_ok(data_setup_ok),
    .digitos_value(digitos_value),
    .digitos_valid(digitos_valid),
    .bcd_pac(bcd_pac),
    .teclado_en(teclado_en),
    .display_en(display_en),
    .setup_on(setup_on),
    .tranca(tranca),
    .bip(bip)
  );

  // Clock
  always #0.5 clk = ~clk;

  initial begin
    #20000
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

  initial begin
    $display("\n\n\n=== TESTBENCH DO OPERACIONAL ===");

    teste = X;
    falhou = X;

    clk = 1;
    rst = 1;
    sensor_contato = 1;
    botao_interno = 0;
    botao_bloqueio = 0;
    botao_config = 0;
    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;
    digitos_valid = 0;
    data_setup_new.bip_status = 1;
    data_setup_new.bip_time = 5;
    data_setup_new.tranca_aut_time = 5;
    data_setup_new.senha_master = 80'hFFFFFFFFFFFFFFFF1234;
    data_setup_new.senha_1 = 80'hFFFFFFFFFFFFFFFFFFFF;
    data_setup_new.senha_2 = 80'hFFFFFFFFFFFFFFFFFFFF;
    data_setup_new.senha_3 = 80'hFFFFFFFFFFFFFFFFFFFF;
    data_setup_new.senha_4 = 80'hFFFFFFFFFFFFFFFFFFFF;
    data_setup_ok = 0;

    #10

    rst = 0;

    #10








    // ------------------------------------------------------------------------------------------
    //                                      TESTE 1
    // ------------------------------------------------------------------------------------------
    teste = 1;
    falhou = 0;
    $display("\nTeste 1: deve se manter no estado de reset até a porta fechar");

    #1

    if (tranca == 1) begin
      $error("[FAIL] A tranca fechou antes da hora");
      falhou = 1;
    end

    #1

    sensor_contato = 0; // fecha a porta

    #1

    if (tranca == 0) begin
      $error("[FAIL] A tranca não fechou quando a porta fechou");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 1 finalizado!");

    teste = X;
    falhou = X;

    #200







    // ------------------------------------------------------------------------------------------
    //                                      TESTE 2
    // ------------------------------------------------------------------------------------------
    teste = 2;
    falhou = 0;
    $display("\nTeste 2: deve bipar quando receber 'hE do módulo do teclado");

    #1

    digitos_value = {20{4'hE}}; // coloca os dados no barramento

    if (bip == 1) begin
      $error("[FAIL] O bip ligou antes do que deveria");
      falhou = 1;
    end

    #0.5

    digitos_valid = 1; // sinaliza que o barramento tá válido

    #1

    digitos_valid = 0;

    if (bip == 0) begin
      $error("[FAIL] O bip não ligou");
      falhou = 1;
    end

    #0.5


    digitos_value = {20{4'hF}}; // limpa o barramento

    #1

    if (!falhou) $display("[PASS] Teste 2 finalizado!");

    teste = X;
    falhou = X;

    #200










    // ------------------------------------------------------------------------------------------
    //                                      TESTE 3
    // ------------------------------------------------------------------------------------------
    teste = 3;
    falhou = 0;
    $display("\nTeste 3: deve ir para porta encostada quando apertar o botão interno");

    #1

    botao_interno = 1;

    #105

    botao_interno = 0;

    #1

    if (tranca == 1) begin
      $error("[FAIL] A tranca continua fechada após apertar o botão interno");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 3 finalizado!");

    teste = X;
    falhou = X;

    #200














    // ------------------------------------------------------------------------------------------
    //                                      TESTE 4
    // ------------------------------------------------------------------------------------------
    teste = 4;
    falhou = 0;
    $display("\nTeste 4: deve fechar a tranca quando apertar o botão interno novamente");

    #1

    botao_interno = 1;

    #105

    botao_interno = 0;

    #1

    if (tranca == 0) begin
      $error("[FAIL] A tranca continua aberta após apertar o botão interno");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 4 finalizado!");

    teste = X;
    falhou = X;

    #200















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 5
    // ------------------------------------------------------------------------------------------
    teste = 5;
    falhou = 0;
    $display("\nTeste 5: deve ir para o não pertube quando apertar o botão de bloqueio");

    #1

    botao_bloqueio = 1;

    #5005

    botao_bloqueio = 0;

    #1

    if (teclado_en == 1) begin
      $error("[FAIL] Não entrou no modo não pertube");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 5 finalizado!");

    teste = X;
    falhou = X;

    #200














    // ------------------------------------------------------------------------------------------
    //                                      TESTE 6
    // ------------------------------------------------------------------------------------------
    teste = 6;
    falhou = 0;
    $display("\nTeste 6: deve ir para porta encostada depois de apertar o botão interno");

    #1

    botao_interno = 1;

    #105

    botao_interno = 0;

    #1

    if (tranca == 1) begin
      $error("[FAIL] A porta continua trancada depois de apertar o botão interno");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 6 finalizado!");

    teste = X;
    falhou = X;

    #200



















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 7
    // ------------------------------------------------------------------------------------------
    teste = 7;
    falhou = 0;
    $display("\nTeste 7: deve abrir a porta e esperar senha quando clicar em botao_config");

    #1

    sensor_contato = 1; // abriu a porta

    #1

    botao_config = 1;

    #1

    botao_config = 0;

    #1

    if (bcd_pac != 24'h0BBBBB) begin
      $error("O display não mostra 0BBBBB (mostra %6h)", bcd_pac);
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 7 finalizado!");

    teste = X;
    falhou = X;

    #200















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 8
    // ------------------------------------------------------------------------------------------
    teste = 8;
    falhou = 0;
    $display("\nTeste 8: deve continuar lendo a senha quando digitar uma senha errada");

    #1

    digitos_value = 80'hFFFFFFFFFFFFFFFF1235; // senha errada

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (!display_en) begin
      $display("Ele foi para o modo setup mesmo digitando a senha errada");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 8 finalizado!");

    teste = X;
    falhou = X;

    #200


















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 9
    // ------------------------------------------------------------------------------------------
    teste = 9;
    falhou = 0;
    $display("\nTeste 9: deve desligar o display e ligar setup_on quando digitar a senha certa");

    #1

    digitos_value = 80'hFFFFFFFFFFFFF0012340; // senha certa

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (display_en) begin
      $error("[FAIL] Não desligou o display");
      falhou = 1;
    end
    if (!setup_on) begin
      $error("[FAIL] Não ligou o setup on");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 9 finalizado!");

    teste = X;
    falhou = X;

    #200


















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 10
    // ------------------------------------------------------------------------------------------
    teste = 10;
    falhou = 0;
    $display("\nTeste 10: deve retornar para o módulo operacional quando ler data_setup_ok");

    #1

    data_setup_new.bip_status = 1;
    data_setup_new.bip_time = 6;
    data_setup_new.tranca_aut_time = 6;
    data_setup_new.senha_master = 80'hFFFFFFFFFFFFFFF13013;
    data_setup_new.senha_1      = 80'hFFFFFFFFFFFFFFFF1235;
    data_setup_new.senha_2      = 80'hFFFFFFFF123456789012;
    data_setup_new.senha_3      = 80'hFFFFFFFFFFFFFFFFFFFF;
    data_setup_new.senha_4      = 80'hFFFFFFFFFFFFF1111111;

    #1

    data_setup_ok = 1;

    #1

    data_setup_ok = 0;

    #1

    if (setup_on) begin
      $error("[FAIL] Não saiu do modo setup ao receber data_setup_ok");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 10 finalizado!");

    teste = X;
    falhou = X;

    #200












    // ------------------------------------------------------------------------------------------
    //                                      TESTE 11
    // ------------------------------------------------------------------------------------------
    teste = 11;
    falhou = 0;
    $display("\nTeste 11: não deve bipar após 5 segundos (porque foi configurado 6 segundos)");

    #5005

    if (bip) begin
      $error("[FAIL] A configuração não foi salva");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 11 finalizado!");

    teste = X;
    falhou = X;

    #200

















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 12
    // ------------------------------------------------------------------------------------------
    teste = 12;
    falhou = 0;
    $display("\nTeste 12: deve bipar depois de mais 1 segundo (total 6 segundos)");

    #1000

    if (!bip) begin
      $error("[FAIL] Não bipou após 6 segundos");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 12 finalizado!");

    teste = X;
    falhou = X;

    #200














    // ------------------------------------------------------------------------------------------
    //                                      TESTE 13
    // ------------------------------------------------------------------------------------------
    teste = 13;
    falhou = 0;
    $display("\nTeste 13: deve parar de bipar quando fechar a porta");

    #1

    sensor_contato = 0; // fecha a porta

    #1

    if (bip) begin
      $error("[FAIL] Não parou de bipar quando fechou a porta");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 13 finalizado!");

    teste = X;
    falhou = X;

    #200

















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 14
    // ------------------------------------------------------------------------------------------
    teste = 14;
    falhou = 0;
    $display("\nTeste 14: não deve trancar automaticamente depois de 5s (mudou a configuração)");

    #5005

    if (tranca) begin
      $error("[FAIL] Trancou antes da hora");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 14 finalizado!");

    teste = X;
    falhou = X;

    #200














    // ------------------------------------------------------------------------------------------
    //                                      TESTE 15
    // ------------------------------------------------------------------------------------------
    teste = 15;
    falhou = 0;
    $display("\nTeste 15: deve trancar automaticamente depois de 6 segundos (configuração)");

    #1005

    if (!tranca) begin
      $error("[FAIL] Não trancou");
      falhou = 1;
    end

    #1

    if (!falhou) $display("[PASS] Teste 15 finalizado!");

    teste = X;
    falhou = X;

    #200















    // ------------------------------------------------------------------------------------------
    //                                      TESTE 16
    // ------------------------------------------------------------------------------------------
    teste = 16;
    falhou = 0;
    $display("\nTeste 16: deve bloquear depois de 5 vezes com a senha errada");

    #1

    digitos_value = 80'hFFFFFFFFFFFFFFFF6969;

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (bcd_pac != 24'hBBBBBA) begin
      $error("[FAIL] Deveria mostrar %6h e mostrou %6h", 24'hBBBBBA, bcd_pac);
      falhou = 1;
    end

    #1000

    digitos_value = 80'hFFFFFFFFFFFFFFFF6969;

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (bcd_pac != 24'hBBBBAA) begin
      $error("[FAIL] Deveria mostrar %6h e mostrou %6h", 24'hBBBBAA, bcd_pac);
      falhou = 1;
    end

    #1000

    digitos_value = 80'hFFFFFFFFFFFFFFFF6969;

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (bcd_pac != 24'hBBBAAA) begin
      $error("[FAIL] Deveria mostrar %6h e mostrou %6h", 24'hBBBAAA, bcd_pac);
      falhou = 1;
    end

    #1000

    digitos_value = 80'hFFFFFFFFFFFFFFFF6969;

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (bcd_pac != 24'hBBAAAA) begin
      $error("[FAIL] Deveria mostrar %6h e mostrou %6h", 24'hBBAAAA, bcd_pac);
      falhou = 1;
    end

    #1000

    digitos_value = 80'hFFFFFFFFFFFFFFFF6969;

    #0.5

    digitos_valid = 1;

    #1

    digitos_valid = 0;

    #0.5

    digitos_value = 80'hFFFFFFFFFFFFFFFFFFFF;

    #1

    if (bcd_pac != 24'hBAAAAA) begin
      $error("[FAIL] Deveria mostrar %6h e mostrou %6h", 24'hBAAAAA, bcd_pac);
      falhou = 1;
    end

    #1000

    #30000

    if (!falhou) $display("[PASS] Teste 16 finalizado!");

    teste = X;
    falhou = X;

    #200








    // (inconcluido)
    // // ------------------------------------------------------------------------------------------
    // //                                      TESTE 17
    // // ------------------------------------------------------------------------------------------
    // teste = 17;
    // falhou = 0;
    // $display("\nTeste 17: deve");

    // #1

    // #1

    // if (!falhou) $display("[PASS] Teste 17 finalizado!");

    // teste = X;
    // falhou = X;

    // #200









    // // ------------------------------------------------------------------------------------------
    // //                                      TESTE X
    // // ------------------------------------------------------------------------------------------
    // teste = X;
    // falhou = 0;
    // $display("\nTeste X: deve");

    // #1

    // #1

    // if (!falhou) $display("[PASS] Teste X finalizado!");

    // teste = X;
    // falhou = X;

    // #200

    $finish;
  end

endmodule
