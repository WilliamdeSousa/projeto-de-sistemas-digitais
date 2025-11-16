module controladora #(
	parameter DEBOUNCE_P = 300,
	parameter SWITCH_MODE_MIN_T = 5000,
	parameter AUTO_SHUTDOWN_T = 30000
) (
  	input 	logic	clk, 
  	input 	logic	rst,
  	input	logic	infravermelho,
  	input	logic	push_button,
  	output	logic	led,
  	output	logic	saida
);
	logic a, b, c, enable_sub_3;
  
	submodulo_1 s1(
		.clk(clk),
		.rst(rst),
		.a(a),
		.b(b),
		.c(c),
		.d(infravermelho),
		.enable_sub_3(enable_sub_3),
		.led(led),
		.saida(saida)
	);

	submodulo_2#(
		.DEBOUNCE_P(300),
		.SWITCH_MODE_MIN_T(5000)
	) s2 (
		.clk(clk),
		.rst(rst),
		.push_button(push_button),
		.A(a),
		.B(b)
	);

	submodulo_3#(
		.AUTO_SHUTDOWN_T(30000)
	) s3 (
		.clk(clk),
		.rst(rst),
		.enable(enable_sub_3),
		.infravermelho(infravermelho),
		.C(c)
	);
endmodule
