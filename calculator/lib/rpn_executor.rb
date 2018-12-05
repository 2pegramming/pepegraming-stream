class RPNExecutor
  OPERATORS = {
    '+' => -> (x, y) { x + y },
    '-' => -> (x, y) { x - y },
    '*' => -> (x, y) { x * y },
    '/' => -> (x, y) { x / y }
  }

  def call(tokens)
    stack = []

    tokens.each do |token|
      if token.number?
        stack.push(token.value)
      else
        second = stack.pop
        first = stack.pop

        # instead OPERATORS[token].call you can use first.send(token, second) # => first.+(second)
        stack.push(OPERATORS.fetch(token.value).call(first, second))
      end
    end

    fail('invalid query string') if stack.size > 1

    stack.pop # => result
  end
end
