`define DEBOUNCE 2000

module reset_tb();
  logic clk, reset_in, reset_out;
  bit [13:0] cont;
  bit [1:0] test;

  resetHold5s #(
    .TIME_TO_RST(`DEBOUNCE / 1000)
  ) dut (
    .clk(clk),
    .reset_in(reset_in),
    .reset_out(reset_out)
  );

  // Clock de 1 GHz (periodo = 1 ns)
  initial begin
    clk = 0;
    forever #0.5 clk = ~clk;  // 1ns
  end

  // Testes
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);





    $display("=== TESTES MÓDULO RESET ===");

    reset_in <= 0;
    cont <= 0;
    test <= 0;





    test <= 1;
    #100 $display("TESTE 1: após %4d pulsos com reset_in=1 deve setar reset_out", `DEBOUNCE);
    // estimulos
    reset_in <= 1;
    cont <= 0;

    // espera
    while (!reset_out && cont < `DEBOUNCE * 1.1)
      #1 cont <= cont + 1;

    // validação
    if (cont > `DEBOUNCE * 1.1)
      $display("[Falhou] O módulo não setou reset_out depois de %4d pulsos", `DEBOUNCE * 1.1);
    else if (cont < `DEBOUNCE)
      $display("[Falhou] O módulo setou reset_out antes de %4d pulsos", `DEBOUNCE);
    else
      $display("[Passou] Demorou %4d pulsos para setar reset_out", cont);

    // reiniciar
    #100 reset_in <= 0;
    cont <= 0;





    test <= 2;
    #100 $display("TESTE 2: se reset_in=1 por menos de %4d pulsos não deve setar reset_out", `DEBOUNCE);

    // estimolo
    reset_in <= 1;
    #(`DEBOUNCE * 0.9) reset_in <= 0;
    cont <= 0;

    // espera
    while (!reset_out && cont < 600)
      #1 cont <= cont + 1;

    // validação
    if (cont < 600)
      $display("[Falhou] O módulo setou reset_out depois de %4d pulsos", cont);
    else
      $display("[Passou] O módulo não setou reset_out quando reset_in=0");

    // reiniciar
    #100 reset_in <= 0;
    cont <= 0;





    test <= 3;
    #100 $display("TESTE 3: deve resetar reset_out depois que reset_in=0");

    // estimolo
    reset_in <= 1;
    #(`DEBOUNCE * 1.1) reset_in <= 0;
    cont <= 0;

    // espera
    while (reset_out && cont < 50)
      #1 cont <= cont + 1;

    // validação
    if (cont >= 50)
      $display("[Falhou] O módulo não resetou reset_out após 50 pulsos");
    else
      $display("[Passou] O módulo resetou reset_out quando reset_in=0 depois de %4d pulsos", cont);

    // reiniciar
    #100 reset_in <= 0;
    cont <= 0;





    #100 $finish;
  end
endmodule
