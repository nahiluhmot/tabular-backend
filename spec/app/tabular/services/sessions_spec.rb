require 'spec_helper'

describe Tabular::Services::Sessions do
  let(:user) { create(:user) }

  describe '#login!' do
    it 'creates a new session for the user' do
      expect(subject.login!(user, 'password')).to be_a(Tabular::Models::Session)
    end
  end

  describe '#logout!' do
    let(:session) { build(:session, user: user) }

    before do
      session.save!
      subject.logout!(session.key)
    end

    it 'destroys all of the sessions for the user' do
      expect(Tabular::Models::Session.where(id: session.id)).to be_empty
    end
  end
end
