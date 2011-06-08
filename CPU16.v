module CPU16 (clock,reset,program_counter,register_out,memory_data_register_out,instruction_register);	

	input clock, reset;
	output [7:0] program_counter;
	output [15:0] register_out, memory_data_register_out, instruction_register;

	reg[15:0] register_A, register_B, register_C, register_D, instruction_register, register_out;
	reg [7:0] program_counter;
	reg [4:0] state;

	parameter 	reset_pc = 0,
				fetch = 1,
				decode = 2,
				execute_add = 3,
				execute_store = 4,
				execute_store2 = 5,
				execute_store3 = 6,
				execute_load = 7,
				execute_jump = 8,
				execute_jneg = 9,
				execute_subt = 10,
				execute_xor = 11,
				execute_or = 12,
				execute_and = 13,
				execute_jpos = 14,
				execute_jzero = 15,
				execute_addi = 16,
				execute_shl = 17,
				execute_shr = 18,
				execute_in = 19,
				execute_out = 20,
				execute_wait = 21,
				execute_call = 22,
				execute_return 23;
				
	reg[7:0] memory_address_register;
	reg memory_write;

	wire[15:0] memory_data_register;
	wire[15:0] memory_data_register_out = memory_data_register;
	wire[15:0] memory_address_register_out = memory_address_register;
	wire[15:0] memory_write_out = memory_write;
	
	reg[7:0] program_address_register;
	reg program_write;

	wire[15:0] program_data_register;
	wire[15:0] program_data_register_out = program_data_register;
	wire[15:0] program_address_register_out = program_address_register;
	wire[15:0] program_write_out = program_write;
	
	

	altsyncram 	altsyncram_component(
					.wren_a(program_write_out),
					.clock0(clock),
					.address_a(program_address_register_out),
					.data_a(register_out),
					.q_a(program_data_register));
		
		defparam
			altsyncram_component.operation_mode = "SINGLE_PORT",
			altsyncram_component.width_a = 16,
			altsyncram_component.widthad_a = 8,
			altsyncram_component.outdata_reg_a = "UNREGISTERED",
			altsyncram_component.lpm_type = "altsyncram",
			altsyncram_component.init_file = "program.mif",
			altsyncram_component.intended_device_family = "Cyclone";
			
	altsyncram 	altsyncram_component(
					.wren_a(memory_write_out),
					.clock0(clock),
					.address_a(memory_address_register_out),
					.data_a(register_out),
					.q_a(memory_data_register));
		
		defparam
			altsyncram_component.operation_mode = "SINGLE_PORT",
			altsyncram_component.width_a = 16,
			altsyncram_component.widthad_a = 8,
			altsyncram_component.outdata_reg_a = "UNREGISTERED",
			altsyncram_component.lpm_type = "altsyncram",
			altsyncram_component.init_file = "data.mif",
			altsyncram_component.intended_device_family = "Cyclone";
			
			always @(posedge clock or posedge reset)
			begin
				if (reset)
					state = reset_pc;
				else
					case(state)
						reset_pc:
							begin
									program_counter = 8'b00000000;
									register_A = 16'b0000000000000000;
									state = fetch;
							end
							
						fetch:
							begin
									instruction_register = memory_data_register;
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
											default:
												state = fetch;
									endcase
							end
							
						execute_add:
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											register_A = register_A + memory_data_register;
											state = fetch;
										end
									2'01
										begin
											register_B = register_B + memory_data_register;
											state = fetch;
										end
									2'10
										begin
											register_C = register_C + memory_data_register;
											state = fetch;
										end
									2'11
										begin
											register_D = register_D + memory_data_register;
											state = fetch;
										end
								endcase
							end
						
						execute_store:
							begin
									state = execute_store2;
							end
						
						execute_store2:
							begin
									state = execute_store3;
							end
						
						execute_load:
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											register_A = memory_data_register;
											state = fetch;
										end
									2'01
										begin
											register_B = memory_data_register;
											state = fetch;
										end
									2'10
										begin
											register_C = memory_data_register;
											state = fetch;
										end
									2'11
										begin
											register_D = memory_data_register;
											state = fetch;
										end
								endcase
							end
						
						execute_jump :
							begin
									program_counter = instruction_register[7:0];
									state = fetch;
							end
						execute_jneg :
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											if(register_A[15])
												memory_address_register = instruction_register[7:0];
											state = fetch;
										end
									2'01
										begin
											if(register_B[15])
												memory_address_register = instruction_register[7:0];
											state = fetch;
										end
									2'10
										begin
											if(register_C[15])
												memory_address_register = instruction_register[7:0];
											state = fetch;
										end
									2'11
										begin
											if(register_D[15])
												memory_address_register = instruction_register[7:0];
											state = fetch;
										end
								endcase
							end
						execute_subt :
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											register_A = register_A - memory_data_register;
											state = fetch;
										end
									2'01
										begin
											register_B = register_B - memory_data_register;
											state = fetch;
										end
									2'10
										begin
											register_C = register_C - memory_data_register;
											state = fetch;
										end
									2'11
										begin
											register_D = register_D - memory_data_register;
											state = fetch;
										end
								endcase
							end
						execute_xor :
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											register_A = register_A ^ memory_data_register;
											state = fetch;
										end
									2'01
										begin
											register_B = register_B ^ memory_data_register;
											state = fetch;
										end
									2'10
										begin
											register_C = register_C ^ memory_data_register;
											state = fetch;
										end
									2'11
										begin
											register_D = register_D ^ memory_data_register;
											state = fetch;
										end
								endcase
							end
						execute_or :
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											register_A = register_A | memory_data_register;
											state = fetch;
										end
									2'01
										begin
											register_B = register_B | memory_data_register;
											state = fetch;
										end
									2'10
										begin
											register_C = register_C | memory_data_register;
											state = fetch;
										end
									2'11
										begin
											register_D = register_D | memory_data_register;
											state = fetch;
										end
								endcase
							end
						execute_and :
							begin
								case(instruction_register[9:8])
									2'00:
										begin
											register_A = register_A & memory_data_register;
											state = fetch;
										end
									2'01
										begin
											register_B = register_B & memory_data_register;
											state = fetch;
										end
									2'10
										begin
											register_C = register_C & memory_data_register;
											state = fetch;
										end
									2'11
										begin
											register_D = register_D & memory_data_register;
											state = fetch;
										end
								endcase
							end
						execute_jpos :
							begin
									state = fetch;
							end
						execute_jzero :
							begin
									state = fetch;
							end
						execute_addi :
							begin
									register_A = register_A | memory_data_register;
									state = fetch;
							end
						execute_in :
							begin
								//register_A = io.in;
								state = fetch;
							end
						execute_out :
							begin
								//io.out = register_A;
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
					reset_pc: memory_address_register = 8'h00;
					fetch: memory_address_register = program_counter;
					decode: memory_address_register = instruction_register[7:0];
					execute_add: memory_address_register = program_counter;
					execute_store: memory_address_register = instruction_register[7:0];
					execute_store2: memory_address_register = program_counter;
					execute_load: memory_address_register = program_counter;
					execute_jump: memory_address_register = instruction_register[7:0];
					execute_jneg: 
					begin
						if(register_A[15])
							memory_address_register = instruction_register[7:0];
						else
							memory_address_register = program_counter;
					end
					default: memory_address_register = program_counter;
				endcase
				case(state)
					execute_store : memory_write = 1'b1;
					default:
						begin
							memory_write = 1'b0;
							program_write = 1'b0;
						end
				endcase
			end
endmodule
			
			
			
			
			
			
			
			
			
	