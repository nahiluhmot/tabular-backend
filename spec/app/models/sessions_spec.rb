require 'spec_helper'

describe Tabular::Models::Session do
  describe '#valid?' do
    subject { described_class.new(key: key, user_id: user.id) }
    let(:user) { create(:user) }
    let(:key) { 'TEST-KEY' }

    context 'when the key is invalid' do
      let(:key) { '' }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when the key is valid' do
      context 'when there is no valid user associated' do
        before { subject.user_id = nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end

      context 'when there is a valid user associated' do
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe '#user' do
    subject { create(:session, user: user) }
    let(:user) { create(:user) }

    it 'returns the session\'s associated user' do
      expect(subject.user).to eq(user)
    end
  end

  describe '#destroy' do
    let(:session) { create(:session) }

    it 'does not destroy the session\'s associated user' do
      user_id = session.user_id
      session.destroy!
      expect(Tabular::Models::User.exists?(id: user_id)).to be true
    end
  end
end
