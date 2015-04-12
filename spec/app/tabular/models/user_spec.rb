require 'spec_helper'

describe Tabular::Models::User do
  describe '#valid?' do
    subject do
      described_class.new(
        username: username,
        password_hash: password_hash,
        password_salt: password_salt
      )
    end
    let(:username) { 'tom_hulihan1' }
    let(:password_hash) { 'HASH' }
    let(:password_salt) { 'SALT' }

    context 'when the username is invalid' do
      let(:usernames) { [nil, '', 'howdy!']  }

      it 'is not valid' do
        expect(usernames).to be_none do |username|
          subject.username = username
          subject.valid?
        end
      end
    end

    context 'when the username is valid' do
      context 'but the password_hash is invalid' do
        let(:password_hash) { nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end

      context 'and the password_hash is valid' do
        context 'but the password_salt is invalid' do
          let(:password_salt) { nil }

          it 'is not valid' do
            expect(subject).to_not be_valid
          end
        end

        context 'and the password_salt is valid' do
          it 'is valid' do
            expect(subject).to be_valid
          end
        end
      end
    end
  end

  describe '#sessions' do
    subject { create(:user) }
    let(:session_one) { build(:session, user: subject) }
    let(:session_two) { build(:session, user: subject) }
    let(:sessions) { [session_one, session_two] }

    before { sessions.each(&:save!) }

    it 'returns the users sessions' do
      expect(subject.sessions).to eq(sessions)
    end

    context 'when the user is destroyed' do
      it 'destroyes the sessions as well' do
        user_id = subject.id
        subject.destroy!
        expect(Tabular::Models::Session.exists?(user_id: user_id)).to be false
      end
    end
  end

  describe '#tabs' do
    subject { create(:user) }
    let(:tab_one) { build(:tab, user: subject) }
    let(:tab_two) { build(:tab, user: subject) }
    let(:tabs) { [tab_one, tab_two] }

    before { tabs.each(&:save!) }

    it 'returns the users tabs' do
      expect(subject.tabs).to eq(tabs)
    end

    context 'when the user is destroyed' do
      it 'destroyes the tabs as well' do
        user_id = subject.id
        subject.destroy!
        expect(Tabular::Models::Tab.exists?(user_id: user_id)).to be false
      end
    end
  end
end
