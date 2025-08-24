// exemplo do vídeo: https://www.youtube.com/watch?v=X7tdZUho7xg

module Alarme(
  input ignicao,
  input cintoMotorista,
  input bancoMotorista,
  input cintoCarona,
  input bancoCarona,
  output alarme,
);

  assign alarme = ignicao & ((!cintoMotorista & bancoMotorista) | (!cintoCarona & bancoCarona));
  
endmodule