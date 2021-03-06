require 'spec_helper'

describe Tabular::Services::ActivityLogs do
  describe '.feed_for!' do
    let(:user) { create(:user) }
    let(:followee_one) { create(:user) }
    let(:followee_two) { create(:user) }
    let(:tab) { build(:tab, user: followee_one) }
    let(:comment) { build(:tab, user: followee_two) }
    let(:activities)  { [comment, tab] }
    let(:options) { { page: 1, limit: 25 } }
    let(:session) { create(:session, user: user) }
    let(:key) { session.key }

    before do
      tab.save!
      Tabular::Services::Relationships.follow!(key, followee_one.username)
      Tabular::Services::Relationships.follow!(key, followee_two.username)
      comment.save!
    end

    context 'when the session key is invalid' do
      it 'fails with Unauthorized' do
        expect { subject.feed_for!('bad_key', options) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session key is valid' do
      context 'but limit or offset is invalid' do
        let(:options) { { page: 0, limit: 1 } }

        it 'fails with MalformedRequest' do
          expect { subject.feed_for!(key, options) }
            .to raise_error(Tabular::Errors::MalformedRequest)
        end
      end

      context 'and the limit and offset are valid' do
        let(:feed) { subject.feed_for!(key, options) }

        it 'returns the activity feed for the user' do
          expect(feed.length).to eq(2)
          expect(feed.map(&:activity)).to eq(activities)
        end
      end
    end
  end

  describe '.recent_activity_for!' do
    let(:user) { create(:user) }
    let(:tab) { build(:tab, user: user) }
    let(:comment) { build(:tab, user: user) }
    let(:activities)  { [comment, tab] }
    let(:options) { { page: 1, limit: 25 } }

    before { activities.each(&:save!) }

    context 'when the session key is invalid' do
      it 'fails with NoSuchModel' do
        expect { subject.recent_activity_for!('bad_username', options) }
          .to raise_error(Tabular::Errors::NoSuchModel)
      end
    end

    context 'when the session key is valid' do
      context 'but limit or offset is invalid' do
        it 'fails with MalformedRequest' do
          expect { subject.recent_activity_for!(user.username, nil) }
            .to raise_error(Tabular::Errors::MalformedRequest)
        end
      end

      context 'and the limit and offset are valid' do
        let(:feed) { subject.recent_activity_for!(user.username, options) }

        it 'returns the activity feed for the user' do
          expect(feed.length).to eq(2)
          expect(feed.map(&:activity)).to eq(activities.reverse)
        end
      end
    end
  end
end
