require 'spec_helper'

describe Tabular::Services::Sessions do
  let(:user) { create(:user) }
  subject { described_class.new(user) }

  describe '#create!' do
    it 'creates a new session for the user' do
      expect(subject.create!).to be_a(Tabular::Models::Session)
    end
  end

  describe '#read' do
    let(:session_one) { build(:session, user: user) }
    let(:session_two) { build(:session, user: user) }
    let(:session_three) { build(:session) }
    let(:sessions) { [session_one, session_two, session_three] }
    let(:users_sessions) { [session_one, session_two] }

    before { sessions.each(&:save!) }

    it 'returns all of the sessions for the user' do
      expect(subject.read).to eq(users_sessions)
    end
  end

  describe '#destroy!' do
    let(:session_one) { build(:session, user: user) }
    let(:session_two) { build(:session, user: user) }
    let(:session_three) { build(:session) }
    let(:sessions) { [session_one, session_two, session_three] }

    before do
      sessions.each(&:save!)
      subject.destroy!
    end

    it 'destroys all of the sessions for the user' do
      expect { session_one.reload }.to raise_error
      expect { session_two.reload }.to raise_error
      expect { session_three.reload }.to_not raise_error
    end
  end
end
