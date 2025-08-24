# Sintaxe SystemVerilog

## Conversões Léxicas

### Números constantes

Tem o formato: `[tamanho]'[base]<valor>`, onde:

* **tamanho (opcional, calculado automaticamente):** quantidade de bits
* **base (opcional, com padrão decimal):** uma letra representando a base numérica que pode ser **h**exadecimal, **d**ecimal e **b**inário
* **valor:** valor numérico da constante na base fornecida

#### Exemplos

* `6'd30` é a constante de 6 bits com o valor `30` em decimal
* `'h1A` é a constante de 8 bits (quantidade automático) com o valor `1A` em hexadecimal
* `'4b1010` é a constante de 4 bits com o valor `1010` em binário
* `18` é a constante de 32 bits (quantidade automático para decimais) com valor `18` em decimal

### Cadeia de Caracteres (Strings)

Delimitada por aspas numa mesma linha, com **máximo de 1024 caracteres**.

### Identificadores

Padrão, pode ter de qualquer letra (maiúscula ou minúscula), dígitos (0 a 9) e *underscore* `_`. Mas não pode começar com dígitos.

## Operadores Lógicos

### Lógicos

Operador  | Função
----------|---------------
`&&`      | AND lógico
`!`       | NOR lógico
`\|\|`    | OR lógico
`&`       | AND bit-a-bit
`~`       | NOT bit-a-bit
`\|`      | OR bit-a-bit
`^`       | XOR bit-a-bit
`<<`      | Deslocamento a esquerda
`>>`      | Deslocamento a direita
`==`      | Comparação de igualdade
`!=`      | Comparação de diferença
`<`       | Menor
`<=`      | Menor ou igual
`>`       | Maior
`>=`      | Maior ou igual

### Aritméticos

Operador  | Função
----------|---------------
`+`       | Adição
`-`       | Subtração
`*`       | Multiplicação
`/`       | Divisão
`%`       | Módulo

[**OBS:** Se um dos bits envolvidos for X ou Z, o resultado é X](#tipos-inteiros-com-4-estados-0-1-x-ou-y)

## Tipos de Dados

### Tipos inteiros com 2 estados (0 ou 1)

Tipo      | Descrição           | Exemplo
----------|---------------------|-----------------
bit       | Tamanho variável    | `bit[3:0] x;`
byte      | 8 bits, com sinal   | `byte y, z;`
shortint  | 16 bits, com sinal  | `shortint a, b;`
int       | 32 bits, com sinal  | `int k;`
longint   | 64 bits, com sinal  | `longint w;`

### Tipos inteiros com 4 estados (0, 1, X ou Y)

* **X**: Desconhecido
* **Y**: Alta Impedância

Tipo      | Descrição           | Exemplo
----------|---------------------|-----------------
reg       | Tamanho variável    | `reg[7:0] x;`
logic     | Tamanho variável    | `logic[7:0] y;`
integer   | 32 bits, com sinal  | `integer k;`

### Não Inteiros

Tipo      | Descrição                 | Exemplo
----------|---------------------------|-----------------
time      | 64 bits, sem sinal        | `time now;`
shortreal | Semelhante ao float em C  | `shortreal f;`
real      | Semelhante ao double me C | `real g;`
realtime  | Semelhante ao double me C | `realtime now;`

### Arrays

Podem ser arrays lineares ou matrizes:

```verilog
logic mem[3:0][15:0]; // 4 registros de 16 bits
logic mem2[63:0];     // um registro de 64 bits
```

### Enumerações

```verilog
enum logic[1:0]{solteiro, casado, viúvo} estado_civil;
```

## Módulos

```verilog
module nome_do_modulo( portas entrada e saída );
  ...
  Declarações de variáveis;
  ...
  Descrição do comportamento;
  ...
endmodule: nome_do_modulo;
```

### Exemplo

* [hello.sv](src/hello.sv)

```verilog
module hello();
  initial begin
    $display("*** Hello World ***");
    $finish();
  end
endmodule: hello;
```

* [alarme.sv](src/alarme.sv)

```verilog
module Alarme(
  input ignicao,
  input cintoMotorista,
  input bancoMotorista,
  input cintoCarona,
  input bancoCarona,
  output alarme,
);

  assign alarme = ignicao & ((!cintoMotorista &   bancoMotorista) | (!cintoCarona & bancoCarona));

endmodule
```

### Instanciando um módulo

```verilog
module xpto(
  input a, b, 
  output s,
)

// Conectado por posição
xpto m1(a, b, s);

// Conectado implicitamente
xpto m1(.*);

// Conectado por nome (explícita)
xpto m1(.a(a), .b(b), .s(s)); 
```
