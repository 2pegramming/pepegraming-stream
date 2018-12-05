require_relative './ast_parser'
require_relative './rpn_executor'
require_relative './rpn_converter'

# Homework:
# 1. PI and E consts
# 2. ^ operation
# 3. CLI
#   * > 1 + 2
#     => 3
#   * $ calculator '1 + 2'

class Calc
  attr_reader :parser, :converter, :executor

  def initialize(parser: ASTParser.new, converter: RPNConverter.new, executor: RPNExecutor.new)
    @parser = parser
    @converter = converter
    @executor = executor
  end

  def call(query)
    executor.(converter.(parser.(query)))
  end
end

