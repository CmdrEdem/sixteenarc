module CPU16 (
				clock,
				reset,
				program_counter,
				register_out,
				memory_data_register_out,
				instruction_register
				 );	

	input clock, reset;
	output [7:0] program_counter;
	output [15:0] register_out, memory_data_register_out, instruction_register;

	reg [15:0] register_A, register_B, register_C, register_D, instruction_register, register_out;
	reg [7:0] program_counter;
	reg [4:0] state;
	reg [7:0] stack_pointer;
	
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
				execute_call = 21,
				execute_return = 22,
				execute_push = 23,
				execute_pop = 24,
				execute_pop2 = 25;
	
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
									default:
										state = fetch;
								endcase
							end
							
						execute_add:
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
						
						execute_store:
							begin
								state = execute_store2;
							end
						
						execute_store2:
							begin
								state = fetch;
							end
						
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
						
						execute_jump:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
							
						execute_jneg:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
							
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
							
						execute_jpos:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
							
						execute_jzero:
							begin
								program_counter = program_address_register;
								state = fetch;
							end
							
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
							
					// -----------------------------------TODO----------------------------------------
					//Instruc�es de I/O --------------------------------------------------------------
					/*	execute_in:
							begin
								case(instruction_register[9:8])
									2'b00:
										register_A = io.in;
									2'b01:
										register_B = io.in;
									2'b10:
										register_C = io.in;
									2'b11:
										register_D = io.in;
								endcase
								state = fetch;
							end
						execute_out:
							begin
								case(instruction_register[9:8])
									2'b00:
										io.out = register_A;
									2'b01:
										io.out = register_B;
									2'b10:
										io.out = register_C;
									2'b11:
										io.out = register_D;
								endcase
								state = fetch;
							end	
					*/
							
						//execute_wait:
						//execute_call:
						//execute_return:
						
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
								
								if(stack_pointer != 8'hFF)										
									stack_pointer = stack_pointer + 1;
								
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
					//execute_in: program_address_register = program_counter;
					//execute_out: program_address_register = program_counter;
					//execute_wait:
					//execute_call: 
					//execute_return:
					
					// PUSH --------------------------------------------------------------------------------
					execute_push: 
						begin
							memory_address_register = stack_pointer - 1;
							
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
					execute_pop: memory_address_register = stack_pointer;
					execute_pop2: program_address_register = program_counter;
					
					default: program_address_register = program_counter;
					
				endcase
				
				
				case(state)
					execute_store:
						memory_write = 1'b1;
						
					execute_push:
						memory_write = 1'b1;
					
					default:
						begin
							memory_write = 1'b0;
							program_write = 1'b0;
						end
						
				endcase
				
			end
endmodule
			
			
			
			
			
			
			
			
			
	