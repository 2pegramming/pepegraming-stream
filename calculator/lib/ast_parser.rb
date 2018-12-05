class Token
  attr_reader :type, :value

  def initialize(type, value = nil)
    @type = type
    @value = value
  end

  def number?
    type == :number
  end

  def ==(other_token)
    (self.type == other_token.type) && (self.value == other_token.value)
  end

  def left?
    value == '('
  end

  def right?
    value == ')'
  end
end

class ASTParser
  NUMBER = /\d+/
  OPERATION = %r[[-+*/]]
  OTHER = /./
  BRACKETS = %r[[)(]]
  SPACE = /\s/

  def call(query)
    tokens = []
    str = StringScanner.new(query)

    while !str.eos?
      if value = str.scan(NUMBER)
        tokens.push(Token.new(:number, value.to_i))
      elsif value = str.scan(OPERATION)
        tokens.push(Token.new(:operation, value))
      elsif value = str.scan(BRACKETS)
        tokens.push(Token.new(:bracket, value))
      elsif str.scan(SPACE)
      elsif str.scan(OTHER)
      end
    end

    tokens
  end
end
