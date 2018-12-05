class RPNConverter
  MEDIUM_OPERATIONS = ['*', '/']
  LOW_OPERATIONS = ['+', '-']

  def call(tokens)
    output = []
    stack = []

    tokens.each do |token|
      if token.number?
        output.push(token)
      elsif MEDIUM_OPERATIONS.include?(token.value)
        if MEDIUM_OPERATIONS.include?(stack.last&.value)
          output.push(stack.pop)
        end

        stack.push(token)
      elsif LOW_OPERATIONS.include?(token.value)
        if (LOW_OPERATIONS + MEDIUM_OPERATIONS).include?(stack.last&.value)
          output.push(stack.pop)
        end

        stack.push(token)
      elsif token.left?
        stack.push(token)
      elsif token.right?
        stack_token = stack.pop

        while !stack_token.left?
          output.push(stack_token)
          stack_token = stack.pop
        end
      else
        fail
      end
    end

    while stack.any?
      output.push(stack.pop)
    end

    output
  end
end
