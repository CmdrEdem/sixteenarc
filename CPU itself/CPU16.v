module CPU16 (
				clock,
				reset,
				program_counter,
				register_out,
				memory_data_register_out,
				instruction_register,
				input_port,
				output_port
				 );	

	input clock, reset;
	input[15:0] input_port;
	output [7:0] program_counter;
	output [15:0] register_out, memory_data_register_out, instruction_register, output_port;

	reg [15:0] instruction_register, register_out, output_port;
	reg [15:0] register_A; 
	reg [15:0] register_B;
	reg [15:0] register_C;
	reg [15:0] register_D;
	reg [15:0]  adder_aux;
	reg [7:0]  program_counter;
	reg [6:0]  state;
	reg [7:0]  stack_pointer;
	reg [7:0]  time_counter;
	
	reg[7:0] memory_address_register;
	reg memory_write;

	wire[15:0] memory_data_register;
	wire[15:0] memory_data_register_out = memory_data_register;
	wire[7:0]  memory_address_register_out = memory_address_register;
	wire 	   memory_write_out = memory_write;
	
	reg[7:0] program_address_register;
	reg program_write;

	wire[15:0] program_data_register;
	wire[15:0] program_data_register_out = program_data_register;
	wire[7:0]  program_address_register_out = program_address_register;
	wire	   program_write_out = program_write;

	parameter 	reset_pc = 0,
				fetch = 1,
				decode = 2,
				execute_add = 3,
				execute_store = 4,
				execute_store2 = 5,
				execute_load = 6,
				execute_jump = 7,
				execute_jneg = 8,
				execute_subt = 9,
				execute_xor = 10,
				execute_or = 11,
				execute_and = 12,
				execute_jpos = 13,
				execute_jzero = 14,
				execute_addi = 15,
				execute_shl = 16,
				execute_shr = 17,
				execute_in = 18,
				execute_out = 19,
				execute_wait = 20,
				execute_wait2 = 21,
				execute_call = 22,
				execute_return = 23,
				execute_return2 = 24,
				execute_push = 25,
				execute_pop = 26,
				execute_pop2 = 27,
				execute_storeR = 28,
				execute_loadR = 29,
				execute_loadR2 = 30,
				execute_addR = 31,
				execute_mov = 32,
				execute_movi = 33;
	
		//Mem�ria de instru��es
		altsyncram	mem_instrucoes(
					.wren_a(program_write_out),
					.clock0(clock),
					.address_a(program_address_register_out),
					.data_a(register_out),
					.q_a(program_data_register)
										  );
		
		defparam
			mem_instrucoes.operation_mode = "SINGLE_PORT",
			mem_instrucoes.width_a = 16,
			mem_instrucoes.widthad_a = 8,
			mem_instrucoes.outdata_reg_a = "UNREGISTERED",
			mem_instrucoes.lpm_type = "altsyncram",
			mem_instrucoes.init_file = "program.mif",
			mem_instrucoes.intended_device_family = "Cyclone";
	
		//Mem�ria de dados
		altsyncram 	mem_dados(
					.wren_a(memory_write_out),
					.clock0(clock),
					.address_a(memory_address_register_out),
					.data_a(register_out),
					.q_a(memory_data_register)
									);
		
		defparam
			mem_dados.operation_mode = "SINGLE_PORT",
			mem_dados.width_a = 16,
			mem_dados.widthad_a = 8,
			mem_dados.outdata_reg_a = "UNREGISTERED",
			mem_dados.lpm_type = "altsyncram",
			mem_dados.init_file = "data.mif",
			mem_dados.intended_device_family = "Cyclone";
			
			always @(posedge clock or posedge reset)
			begin
				if (reset)
					state = reset_pc;
				else
					case(state)
						reset_pc:
							begin
								program_counter = 8'h00;
								register_A = 16'h0000;
								register_B = 16'h0000;
								register_C = 16'h0000;
								register_D = 16'h0000;
								stack_pointer = 8'hFF;
								time_counter = 8'h00;
								state = fetch;
							end
							
						fetch:
							begin
								instruction_register = program_data_register;
								program_counter = program_counter + 1;
								state = decode;
							end
						
						decode:
							begin
								case(instruction_register[15:10])
									6'b000000:
										state = execute_add;
									6'b000001:
										state = execute_store;
									6'b000010:
										state = execute_load;
									6'b000011:
										state = execute_jump;
									6'b000100:
										state = execute_jneg;
									6'b000101:
										state = execute_subt;
									6'b000110:
										state = execute_xor;
									6'b000111:
										state = execute_or;
									6'b001000:
										state = execute_and;
									6'b001001:
										state = execute_jpos;
									6'b001010:
										state = execute_jzero;
									6'b001011:
										state = execute_addi;
									6'b001100:
										state = execute_shl;
									6'b001101:
										state = execute_shr;
									6'b001110:
										state = execute_in;
									6'b001111:
										state = execute_out;
									6'b010000:
										state = execute_wait;
									6'b010001:
										state = execute_call;
									6'b010010:
										state = execute_return;
									6'b010011:
										state = execute_push;
									6'b010100:
										state = execute_pop;
									6'b010101:
										state = execute_storeR;
									6'b010110:
										state = execute_loadR;
									6'b010111:
										state = execute_addR;
									default:
										state = fetch;
								endcase
							end
						
						// ADD --------------------------------------------------------------------------------------	
						execute_add:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A + memory_data_register;
									2'b01:
										register_B = register_B + memory_data_register;
									2'b10:
										register_C = register_C + memory_data_register;
									2'b11:
										register_D = register_D + memory_data_register;
								endcase
								state = fetch;
							end
						
						// STORE --------------------------------------------------------------------------------------
						execute_store:
							begin
								state = execute_store2;
							end
						
						//address-safe state
						execute_store2:
							begin
								state = fetch;
							end
						
						// LOAD --------------------------------------------------------------------------------------
						execute_load:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = memory_data_register;
									2'b01:
										register_B = memory_data_register;
									2'b10:
										register_C = memory_data_register;
									2'b11:
										register_D = memory_data_register;
								endcase
								state = fetch;
							end
						
						// JUMP --------------------------------------------------------------------------------------
						execute_jump:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
						
						// JNEG --------------------------------------------------------------------------------------	
						execute_jneg:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
						
						// SUBT --------------------------------------------------------------------------------------	
						execute_subt:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A - instruction_register[7:0];
									2'b01:
										register_B = register_B - instruction_register[7:0];
									2'b10:
										register_C = register_C - instruction_register[7:0];
									2'b11:
										register_D = register_D - instruction_register[7:0];
								endcase
								state = fetch;
							end
						
						// XOR --------------------------------------------------------------------------------------	
						execute_xor:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A ^ instruction_register[7:0];
									2'b01:
										register_B = register_B ^ instruction_register[7:0];
									2'b10:
										register_C = register_C ^ instruction_register[7:0];
									2'b11:
										register_D = register_D ^ instruction_register[7:0];
								endcase
								state = fetch;
							end
						
						// OR --------------------------------------------------------------------------------------	
						execute_or:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A | instruction_register[7:0];
									2'b01:
										register_B = register_B | instruction_register[7:0];
									2'b10:
										register_C = register_C | instruction_register[7:0];
									2'b11:
										register_D = register_D | instruction_register[7:0];
								endcase
								state = fetch;
							end
						
						// AND --------------------------------------------------------------------------------------	
						execute_and:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A & instruction_register[7:0];
									2'b01:
										register_B = register_B & instruction_register[7:0];
									2'b10:
										register_C = register_C & instruction_register[7:0];
									2'b11:
										register_D = register_D & instruction_register[7:0];
								endcase
								state = fetch;
							end
							
						// JPOS --------------------------------------------------------------------------------------
						execute_jpos:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
						
						// JZERO ------------------------------------------------------------------------------------	
						execute_jzero:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
						
						// ADDI -------------------------------------------------------------------------------------	
						execute_addi:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A + instruction_register[7:0];
									2'b01:
										register_B = register_B + instruction_register[7:0];
									2'b10:
										register_C = register_C + instruction_register[7:0];
									2'b11:
										register_D = register_D + instruction_register[7:0];
								endcase
								state = fetch;
							end

						// SHL --------------------------------------------------------------------------------------
						execute_shl:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A << instruction_register[7:0];
									2'b01:
										register_B = register_B << instruction_register[7:0];
									2'b10:
										register_C = register_C << instruction_register[7:0];
									2'b11:
										register_D = register_D << instruction_register[7:0];
								endcase
								state = fetch;
							end
						
						// SHR --------------------------------------------------------------------------------------
						execute_shr:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A >> instruction_register[7:0];
									2'b01:
										register_B = register_B >> instruction_register[7:0];
									2'b10:
										register_C = register_C >> instruction_register[7:0];
									2'b11:
										register_D = register_D >> instruction_register[7:0];
								endcase
								state = fetch;
							end
							
					//Instruc�es de I/O --------------------------------------------------------------
						execute_in:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = input_port;
									2'b01:
										register_B = input_port;
									2'b10:
										register_C = input_port;
									2'b11:
										register_D = input_port;
								endcase
								state = fetch;
							end
							
						execute_out:
							begin
								case(instruction_register[9:8])
									2'b00:
										output_port = register_A;
									2'b01:
										output_port = register_B;
									2'b10:
										output_port = register_C;
									2'b11:
										output_port = register_D;
								endcase
								state = fetch;
							end	
					
							
						execute_wait:
							begin
								if(time_counter < instruction_register[7:0])
									begin
										time_counter = time_counter + 1;
										state = execute_wait2;
									end
								else
									begin
										time_counter = 8'h00;
										state = fetch;
									end
							end
							
						execute_wait2:
							begin
								state = execute_wait;
							end
						
						execute_call:
							begin
								program_counter = instruction_register[7:0];
								stack_pointer = stack_pointer - 1;
								state = execute_store2;
							end
							
						execute_return:
							begin
								//Usa ciclo para ler da mem�ria
								state = execute_return2; 
							end
							
						execute_return2:
							begin
								program_counter = memory_data_register;
								stack_pointer = stack_pointer + 1;
								state = fetch;
							end
						
						execute_push:
							begin	
								stack_pointer = stack_pointer - 1;
								state = execute_store2;
							end
							
						execute_pop:
							begin
								state = execute_pop2;
							end
							
						execute_pop2:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = memory_data_register;
									2'b01:
										register_B = memory_data_register;
									2'b10:
										register_C = memory_data_register;
									2'b11:
										register_D = memory_data_register;
								endcase					
								stack_pointer = stack_pointer + 1;
								state = fetch;
							end
							
						execute_storeR:
							begin
								state = execute_store2;
							end
						
						execute_loadR:
							begin
								state = execute_loadR2;
							end
						
						execute_loadR2:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = memory_data_register;
									2'b01:
										register_B = memory_data_register;
									2'b10:
										register_C = memory_data_register;
									2'b11:
										register_D = memory_data_register;
								endcase
								state = fetch;
							end
							
						execute_addR:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = register_A + adder_aux;
									2'b01:
										register_B = register_B + adder_aux;
									2'b10:
										register_C = register_C + adder_aux;
									2'b11:
										register_D = register_D + adder_aux;
								endcase
								state = fetch;
							end
							
						execute_mov:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = adder_aux;
									2'b01:
										register_B = adder_aux;
									2'b10:
										register_C = adder_aux;
									2'b11:
										register_D = adder_aux;
								endcase
								state = fetch;
							end
							
						execute_movi:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = instruction_register[7:0];
									2'b01:
										register_B = instruction_register[7:0];
									2'b10:
										register_C = instruction_register[7:0];
									2'b11:
										register_D = instruction_register[7:0];
								endcase
								state = fetch;
							end
					
						default:
							begin
								state = fetch;
							end
					endcase
			
				end
			
			always @(state or program_counter or instruction_register)
			begin
			
				case(state)
					reset_pc: program_address_register = 8'h00;
					fetch: program_address_register = program_counter;
					decode: memory_address_register = instruction_register[7:0];
					execute_add: program_address_register = program_counter;
					
					// STORE -----------------------------------------------------------------------------------
					execute_store: 
						begin
							memory_address_register = instruction_register[7:0];
							
							case(instruction_register[9:8])
								2'b00:
									register_out = register_A;
								2'b01:
									register_out = register_B;
								2'b10:
									register_out = register_C;
								2'b11:
									register_out = register_D;
							endcase
						end
						
					execute_store2: program_address_register = program_counter;
					execute_load: program_address_register = program_counter;
					execute_jump: program_address_register = instruction_register[7:0];
					
					//JNEG ---------------------------------------------------------------------------------
					execute_jneg: 
					begin
						case(instruction_register[9:8])
							2'b00:
								begin
									if(register_A[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b01:
								begin
									if(register_B[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b10:
								begin
									if(register_C[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b11:
								begin
									if(register_D[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
						endcase
						
					end
					
					execute_subt: program_address_register = program_counter;
					execute_xor: program_address_register = program_counter;
					execute_or: program_address_register = program_counter;
					execute_and: program_address_register = program_counter;
					
					// JPOS ----------------------------------------------------------------------------------
					execute_jpos:
					begin
						case(instruction_register[9:8])
							2'b00:
								begin
									if(!register_A[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b01:
								begin
									if(!register_B[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b10:
								begin
									if(!register_C[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b11:
								begin
									if(!register_D[15])
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
						endcase
					end
					
					// JZERO ----------------------------------------------------------------------------------
					execute_jzero:
					begin
						case(instruction_register[9:8])
							2'b00:
								begin
									if(register_A == 16'b0)
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b01:
								begin
									if(register_B == 16'b0)
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b10:
								begin
									if(register_C == 16'b0)
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
							2'b11:
								begin
									if(register_D == 16'b0)
										program_address_register = instruction_register[7:0];
									else
										program_address_register = program_counter;
								end
						endcase
					end
					
					execute_addi: program_address_register = program_counter;
					execute_shl: program_address_register = program_counter;
					execute_shr: program_address_register = program_counter;
					
					// I/O ----------------------------------------------------------------------------------
					execute_in: program_address_register = program_counter;
					execute_out: program_address_register = program_counter;
					
					execute_wait: program_address_register = program_counter;
					execute_wait2: program_address_register = program_counter;
					
					// CALL & RETURN ------------------------------------------------------------------------
					execute_call: 
						begin
							memory_address_register = stack_pointer;
							register_out = program_counter; //Endereco de retorno
						end
					execute_return: memory_address_register = stack_pointer + 1;
					execute_return2: memory_address_register = program_counter;
					
					// PUSH --------------------------------------------------------------------------------
					execute_push: 
						begin
							memory_address_register = stack_pointer;
							
							case(instruction_register[9:8])
								2'b00:
									register_out = register_A;
								2'b01:
									register_out = register_B;
								2'b10:
									register_out = register_C;
								2'b11:
									register_out = register_D;
							endcase
						end
					
					// POP ---------------------------------------------------------------------------------
					execute_pop: memory_address_register = stack_pointer + 1;
					execute_pop2: program_address_register = program_counter;
					
					// LOAD & STORE Reg Address ------------------------------------------------------------
					execute_storeR:	
						begin
							case(instruction_register[9:8])
								2'b00:
									register_out = register_A;
								2'b01:
									register_out = register_B;
								2'b10:
									register_out = register_C;
								2'b11:
									register_out = register_D;
							endcase
							
							case(instruction_register[1:0])
								2'b00:
									memory_address_register = register_A;
								2'b01:
									memory_address_register = register_B;
								2'b10:
									memory_address_register = register_C;
								2'b11:
									memory_address_register = register_D;
							endcase
						end
					
					execute_loadR:
						begin
							case(instruction_register[1:0])
								2'b00:
									memory_address_register = register_A;
								2'b01:
									memory_address_register = register_B;
								2'b10:
									memory_address_register = register_C;
								2'b11:
									memory_address_register = register_D;
							endcase
						end
						
					execute_loadR2: program_address_register = program_counter;
					
					execute_addR: 
						begin
							case(instruction_register[1:0])
								2'b00:
									adder_aux = register_A;
								2'b01:
									adder_aux = register_B;
								2'b10:
									adder_aux = register_C;
								2'b11:
									adder_aux = register_D;
							endcase
							program_address_register = program_counter;
						end
						
					execute_mov:
						begin
							case(instruction_register[1:0])
								2'b00:
									adder_aux = register_A;
								2'b01:
									adder_aux = register_B;
								2'b10:
									adder_aux = register_C;
								2'b11:
									adder_aux = register_D;
							endcase
							program_address_register = program_counter;
						end
					
					execute_movi: program_address_register = program_counter;
					
					default: program_address_register = program_counter;
					
				endcase
				
				case(state)
					execute_store:
						memory_write = 1'b1;
						
					execute_push:
						memory_write = 1'b1;
						
					execute_call:
						memory_write = 1'b1;
					
					execute_storeR:
						memory_write = 1'b1;
					
					default:
						memory_write = 1'b0;
				endcase
				
				program_write = 1'b0;
				
			end
endmodule
			
			
			
			
			
			
			
			
			
	