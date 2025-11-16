
module submodulo_1(
	input	logic 	clk,
	input	logic	rst,
	input	logic 	a, 
	input	logic 	b,
	input	logic 	c,
	input	logic	d,
	output	logic	enable_sub_3,
	output	logic 	led, 
	output	logic	saida
);
	enum logic [1:0] {LLA, LDA, LLM, LDM} estado;

	always_ff @ (posedge rst or posedge clk)
		if(rst) estado <= LDA;
		else begin
			case (estado)
			LDA: begin
				if (d) estado <= LLA;
				else if (a) estado <= LDM;
				else estado <= LDA;
			end
			LLA: begin
				if (c) estado <= LDA;
				else if(a) estado <= LDM;
				else estado <= LLA;
			end
			LDM: begin
				if (a) estado <= LLA;
				else if (b) estado <= LLM;
				else estado <= LDM;
			end
			LLM: begin
				if (a) estado <= LLA;
				else if (b) estado <= LDM;
				else estado <= LLM;
			end
			default: estado <= LDA;
			endcase
		end

	always_comb begin
		if (rst) begin 
			led = 0;
			saida = 0;
			enable_sub_3 = 0;
		end
		else
		case(estado)
			LDA: begin
				led = 0;
				saida = 0;
				enable_sub_3 = 0;
			end
			LLA: begin
				led = 0;
				saida = 1;
				enable_sub_3 = 1;

			end
			LDM: begin
				led = 1;
				saida = 0;
				enable_sub_3 = 0;
			end
			LLM: begin
				led = 1;
				saida = 1;
				enable_sub_3 = 0;
			end
			default: begin
				led = 0;
				saida = 0;
				enable_sub_3 = 0;
			end
		endcase
	end
endmodule