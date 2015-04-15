require 'spec_helper'

describe Tabular::Services::Logger do
  describe '.raw_logger' do
    it 'returns a logger' do
      expect(subject.raw_logger).to be_a(Logger)
    end
  end

  Tabular::Services::Logger::LOG_LEVELS.each do |method|
    describe ".#{method}" do
      it 'returns a logger' do
        expect(subject.raw_logger).to receive(method)

        subject.public_send(method)
      end
    end
  end
end
