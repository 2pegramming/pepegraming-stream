require 'spec_helper'

RSpec.describe 'CardChecker' do
  let(:checker) { CardChecker.new }
  let(:card) { '4024007166387919' }

  subject { checker.call(card) }

  # visa
  it { expect(checker.call('4024007166387919')).to eq true }
  it { expect(checker.call('4024017166387919')).to eq false }

  # mastercard
  it { expect(checker.call('5327158863049822')).to eq true }
  it { expect(checker.call('5327158763049822')).to eq false }

  # Visa Electron
  it { expect(checker.call('4844891187509140')).to eq true }
  it { expect(checker.call('4844891187519140')).to eq false }

  # worng card object
  it { expect { checker.call(Object.new) }.to raise_error }
  it { expect { checker.call('123') }.to raise_error }
end

RSpec.describe 'CardGenerator' do
  let(:generator) { CardGenerator.new }

  # visa
  it { expect(generator.call(type: :visa).size).to eq 16 }
  it { expect(generator.call(type: :visa)[0]).to eq '4' }
  it { expect(CardChecker.new.call(generator.call(type: :visa))).to eq true }

  # mastercard
  it { expect(generator.call(type: :mastercard).size).to eq 16 }
  it { expect(generator.call(type: :mastercard)[0]).to eq '5' }
  it { expect(CardChecker.new.call(generator.call(type: :mastercard))).to eq true }

  # wrong type
  it { expect { generator.call(type: :wrong) }.to raise_error }
end
