require 'spec_helper'

describe Tabular::Services::Session do
  let(:session) { create(:session) }
  subject { described_class.new(session.key) }

  describe '#initialize' do
    context 'when the given key is in the database' do
      it 'creates a new session service' do
        expect(subject).to be_a(Tabular::Services::Session)
      end
    end

    context 'when the given key is not in the database' do
      it 'fails with NoSuchModel' do
        expect { described_class.new('bad key') }
          .to raise_error(Tabular::Errors::NoSuchModel)
      end
    end
  end

  describe '#read' do
    it 'returns the database model' do
      expect(subject.read).to eq(session)
    end
  end

  describe '#destroy!' do
    before { subject.destroy! }

    it 'destroys the session' do
      expect { session.reload }.to raise_error
    end
  end
end
