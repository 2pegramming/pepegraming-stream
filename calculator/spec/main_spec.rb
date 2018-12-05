require 'spec_helper'

def tokens(query)
  ASTParser.new.call(query)
end

RSpec.describe 'RPNExecutor' do
  let(:ex) { RPNExecutor.new }

  it { expect(ex.call(tokens '1 2 +')).to eq 3 }
  it { expect(ex.call(tokens '1 2 3 + +')).to eq 6 }

  it { expect(ex.call(tokens '2 1 -')).to eq(1) } # => 2 - 1 == -1
  it { expect(ex.call(tokens '3 2 - 1 -')).to eq(0) } # => 3 - 2 - 1 == -4

  it { expect { ex.call(tokens '3 2 1 -') }.to raise_error }

  it { expect(ex.call(tokens '2 1 *')).to eq(2) } # => 1 * 2 == 2
  it { expect(ex.call(tokens '3 2 1 * *')).to eq(6) } # => 1 * 2 * 3 == 6

  it { expect(ex.call(tokens '2 1 /')).to eq(2) } # => 2 / 1 == 2
  it { expect(ex.call(tokens '4 2 1 / /')).to eq(2) } # => 4 / 2 / 1 == 2

  it { expect(ex.call(tokens '1 2 3 * +')).to eq 7 }
  it { expect(ex.call(tokens '1 0 3 * +')).to eq 1 }

  it { expect { ex.call(tokens '1 3 ^') }.to raise_error }
end

RSpec.describe RPNConverter do
  it { expect(subject.call(tokens('1 + 2'))).to eq tokens('1 2 +') }
  it { expect(subject.call(tokens('3 + 2 - 1'))).to eq tokens('3 2 + 1 -') }

  it { expect(subject.call(tokens('1 * 2'))).to eq tokens('1 2 *') }
  it { expect(subject.call(tokens('3 * 2 / 1'))).to eq tokens('3 2 * 1 /') }

  it { expect(subject.call(tokens('1 + 2 * 3'))).to eq tokens('1 2 3 * +') }

  it { expect(subject.call(tokens('(1 + 2) * 3'))).to eq tokens('1 2 + 3 *') }
  it { expect(subject.call(tokens('9 - (1 + 2 + 3) * 4'))).to eq tokens('9 1 2 + 3 + 4 * -') }
end

RSpec.describe Calc do
  it { expect(subject.call('1 + 2')).to eq 3 }
  it { expect(subject.call('3 + 2 - 1')).to eq 4 }

  it { expect(subject.call('1 * 2')).to eq 2 }
  it { expect(subject.call('3 * 2 / 1')).to eq 6 }

  it { expect(subject.call('1 + 2 * 3')).to eq 7 }

  it { expect(subject.call('(1 + 2) * 3')).to eq 9 }
  it { expect(subject.call('9 - (1 + 2 + 3) * 4')).to eq(-15) }
end

RSpec.describe ASTParser do
  let(:num_1) { Token.new(:number, 1) }
  let(:num_2) { Token.new(:number, 2) }

  let(:left_b) { Token.new(:bracket, '(') }
  let(:right_b) { Token.new(:bracket, ')') }

  context 'with + operation' do
    let(:op) { Token.new(:operation, '+') }

    it { expect(subject.call('1 + 2')).to eq [num_1, op, num_2] }
  end

  context 'with - operation' do
    let(:op) { Token.new(:operation, '-') }

    it { expect(subject.call('1 - 2')).to eq [num_1, op, num_2] }
  end

  context 'with * operation' do
    let(:op) { Token.new(:operation, '*') }

    it { expect(subject.call('1 * 2')).to eq [num_1, op, num_2] }
  end

  context 'with / operation' do
    let(:op) { Token.new(:operation, '/') }

    it { expect(subject.call('1 / 2')).to eq [num_1, op, num_2] }
  end

  context 'with brackets operation' do
    let(:op1) { Token.new(:operation, '+') }
    let(:op2) { Token.new(:operation, '*') }

    it { expect(subject.call('(1 + 2) * 2')).to eq [left_b, num_1, op1, num_2, right_b, op2, num_2] }
  end
end
