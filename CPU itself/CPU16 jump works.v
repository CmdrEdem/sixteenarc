module CPU16 (clock,reset,program_counter,register_A,memory_data_register_out,instruction_register);	

	input clock, reset;
	output [7:0] program_counter;
	output [15:0] register_A, memory_data_register_out, instruction_register;

	reg[15:0] register_A, instruction_register;
	reg [7:0] program_counter;
	reg [3:0] state;

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
				execute_addi = 16;
				execute_shl = 17;
				execute_shr = 18;
				execute_in = 19;
				execute_out = 20;
				execute_wait = 21;
				execute_call = 22;
				execute_return 23;
				
	reg[7:0] memory_address_register;
	reg memory_write;

	wire[15:0] memory_data_register;
	wire[15:0] memory_data_register_out = memory_data_register;
	wire[15:0] memory_address_register_out = memory_address_register;
	wire[15:0] memory_write_out = memory_write;

	altsyncram 	altsyncram_component(
					.wren_a(memory_write_out),
					.clock0(clock),
					.address_a(memory_address_register_out),
					.data_a(register_A),
					.q_a(memory_data_register));
		
		defparam
			altsyncram_component.operation_mode = "SINGLE_PORT",
			altsyncram_component.width_a = 16,
			altsyncram_component.widthad_a = 8,
			altsyncram_component.outdata_reg_a = "UNREGISTERED",
			altsyncram_component.lpm_type = "altsyncram",
			altsyncram_component.init_file = "program.mif",
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
									case(instruction_register[15:8])
											8'b00000000:
												state = execute_add;
											8'b00000001:
												state = execute_store;
											8'b00000010:
												state = execute_load;
											8'b00000011:
												state = execute_jump;
											8'b00000100:
												state = execute_jneg;
											8'b00000101:
												state = execute_subt;
											8'b00000110:
												state = execute_xor;
											8'b00000111:
												state = execute_or;
											8'b00001000:
												state = execute_and;
											8'b00001001:
												state = execute_jpos;
											8'b00001010:
												state = execute_jzero;
											8'b00001011:
												state = execute_addi;
											default:
												state = fetch;
									endcase
							end
							
						execute_add:
							begin
									register_A = register_A + memory_data_register;
									state = fetch;
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
									register_A = memory_data_register;
									state = fetch;
							end
						
						execute_jump :
							begin
									program_counter = instruction_register[7:0];
									state = fetch;
							end
						execute_jneg :
							begin
									if(register_A[15])
										memory_address_register = instruction_register[7:0];
									state = fetch;
							end
						execute_subt :
							begin
									register_A = register_A - memory_data_register;
									state = fetch;
							end
						execute_xor :
							begin
									register_A = register_A ^ memory_data_register;
									state = fetch;
							end
						execute_or :
							begin
									register_A = register_A | memory_data_register;
									state = fetch;
							end
						execute_and :
							begin
									register_A = register_A & memory_data_register;
									state = fetch;
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
					default: memory_write = 1'b0;
				endcase
			end
endmodule