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

  describe '#comments' do
    subject { create(:user) }
    let(:comment) { build(:comment, user: subject) }

    before { comment.save! }

    it 'returns the user\'s comments' do
      expect(subject.comments).to eq([comment])
    end

    context 'when the user is destroyed' do
      it 'destroys the comments as well' do
        expect { subject.destroy! }
          .to change { Tabular::Models::Comment.where(user: subject).count }
          .from(1)
          .to(0)
      end
    end
  end

  describe '#follower_relationships' do
    subject { create(:user) }
    let(:relationship) { build(:relationship, follower: subject) }

    before { relationship.save! }

    it 'returns the relationships where the subject is being followed' do
      expect(subject.follower_relationships.to_a).to eq([relationship])
    end

    context 'when the user is destroyed' do
      def exists?(id)
        Tabular::Models::Relationship.exists?(follower_id: id)
      end

      it 'destroys the relationship as well' do
        expect { subject.destroy! }
          .to change { exists?(subject.id) }
          .from(true)
          .to(false)
      end
    end
  end

  describe '#activity_logs' do
    subject { create(:user) }
    let(:comment) { build(:comment, user: subject) }
    let(:tab) { build(:comment, user: subject) }
    let(:models) { [comment, tab] }
    let(:logs) { models.map(&:activity_log) }

    before { models.each(&:save!) }

    it 'returns the users activity logs' do
      expect(subject.activity_logs).to eq(logs)
    end

    context 'when the user is destroyed' do
      let(:ids) { logs.map(&:id) }

      it 'destroys the logs as well' do
        expect { subject.destroy! }
          .to change { Tabular::Models::ActivityLog.exists?(id: ids) }
          .from(true)
          .to(false)
      end
    end
  end

  describe '#followee_relationships' do
    subject { create(:user) }
    let(:relationship) { build(:relationship, followee: subject) }

    before { relationship.save! }

    it 'returns the relationships where the subject is following somebody' do
      expect(subject.followee_relationships.to_a).to eq([relationship])
    end

    context 'when the user is destroyed' do
      def exists?(id)
        Tabular::Models::Relationship.exists?(followee_id: id)
      end

      it 'destroys the relationship as well' do
        expect { subject.destroy! }
          .to change { exists?(subject.id) }
          .from(true)
          .to(false)
      end
    end
  end

  describe 'following associations' do
    subject { create(:user) }

    let(:followees) { [create(:user), create(:user)] }
    let(:followers) { [create(:user), create(:user)] }

    before do
      followees.each do |user|
        create(:relationship, follower: subject, followee: user)
      end

      followers.each do |user|
        create(:relationship, follower: user, followee: subject)
      end
    end

    describe '#followees' do
      it 'returns users that the subject is following' do
        expect(subject.followees).to eq(followees)
      end
    end

    describe '#followers' do
      it 'returns users that the subject is following' do
        expect(subject.followers).to eq(followers)
      end
    end

    context 'when the user is destroyed' do
      before { subject.destroy! }

      it 'does not destroy the other users' do
        expect(followers + followees).to be_all do |user|
          Tabular::Models::User.exists?(id: user.id)
        end
      end
    end
  end
end
