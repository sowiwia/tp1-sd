/* verilator lint_off IMPORTSTAR */
import tp1_pkg::*;

module alu #(
    parameter int DATA_WIDTH = 32
) (
    alu_if.alu alu_io
);
  logic [DATA_WIDTH-1:0] operand_a, operand_b;
  logic [DATA_WIDTH-1:0] suma, resta, resultado;
  logic carry_suma, overflow_suma, carry_resta, overflow_resta;
  logic carry_resultado, overflow_resultado, opcode_valido;
  logic es_cero, es_negativo;

  assign operand_a = alu_io.operand_a;
  assign operand_b = alu_io.operand_b;
  assign alu_io.result = resultado;

  sumador_flags #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_suma (
      .a(operand_a),
      .b(operand_b),
      .sum(suma),
      .carry(carry_suma),
      .overflow(overflow_suma)
  );
  restador_flags #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_resta (
      .a(operand_a),
      .b(operand_b),
      .resta(resta),
      .carry(carry_resta),
      .overflow(overflow_resta)
  );
  // Un comparador y un detector de signo compartidos por todas las operaciones.
  comparador #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_zero (
      .a(operand_a),
      .b(operand_b),
      .iguales(es_cero)
  );
  negativo #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_negativo (
      .dato(alu_io.result),
      .negativo(es_negativo)
  );

  // COMPLETAR: las conexiones de las cuatro instancias anteriores.
  // Completar la selección del resultado y de C/V según el opcode.
  always_comb begin
    resultado = '0;
    carry_resultado = 1'b0;
    overflow_resultado = 1'b0;
    opcode_valido = 1'b1;
    case (alu_io.opcode)
      OP_ADD: begin
        resultado = suma;
        overflow_resultado = overflow_suma;
        carry_resultado = carry_suma;
      end
      OP_SUB: begin
        resultado = resta;
        overflow_resultado = overflow_resta;
        carry_resultado = carry_resta;
      end
      OP_AND: begin
        resultado = operand_a & operand_b;
      end
      OP_OR: begin
        resultado = operand_a | operand_b;
      end
      default: begin
        opcode_valido = 1'b0;
      end
    endcase
  end

  // COMPLETAR: flags Z/N a partir de los detectores y C/V seleccionadas.
  // Respetar la excepción de opcode inválido (Z/N/C/V = 0100).
  assign alu_io.flags = opcode_valido ?  {es_cero, es_negativo, carry_resultado, overflow_resultado} : {4'b0100};

endmodule
