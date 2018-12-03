require 'spec_helper'

RSpec.describe 'Main' do
  let(:main) { Main.new }

  it { expect(main.foo).to eq 'foo' }

  it "does something useful" do
    expect(false).to eq(true)
  end
end
