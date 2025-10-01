
module submodulo_2 #(
	parameter DEBOUNCE_P = 300,
	parameter SWITCH_MODE_MIN_T = 5000)
(
	input 	logic 	clk, 
	input	logic	rst,
	input	logic	push_button,
	output 	logic   A,
	output	logic	B
);
  
	bit [15:0] Tp = 0;
	enum logic [2:0] { inicial, db, a, b, temp } estado;
	logic reg_a, reg_b;

	always_ff @ (posedge rst or posedge clk)
		if (rst) begin
			Tp = 0;
			estado <= inicial;
		end else
			case (estado)
				inicial: begin 
					if (push_button == 1) estado <= db;
					else estado <= inicial;
				end
				db: begin
					if (Tp >= 300) estado <= b;
					else if (Tp < 300) estado <= db;
					else if (push_button == 0) estado <= inicial;
					else Tp <= Tp + 1;
				end
				b: begin 
					if (Tp >= 5000) estado <= a;
					else if (Tp <500) estado <= b;
					else if (push_button == 0) begin
						estado <= temp;
						reg_b <= 1;
					end 
				end
				a: begin
					if (push_button == 0) begin
						estado <= temp;
						reg_a <= 1;
					end 
					else estado <= a;
				end
				temp: begin
					estado <= inicial;
					Tp<=0;
				end
				default: estado <= inicial;
			endcase

	always_comb begin
		if (rst) begin
			A = 0;
			B = 0;
		end
		else
			case (estado)
				inicial: begin
					A = 0;
					B = 0;
				end
				db: begin
					A = 0;
					B = 0;
				end
				b: begin
					A = 0;
					B = reg_b;
				end
				a: begin
					A = reg_a;
					B = 0;
				end
				default: begin
					A = 0;
					B = 0;
				end
			endcase
	end
endmodule
