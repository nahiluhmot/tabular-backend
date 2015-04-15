require 'spec_helper'

describe Tabular::Models::Relationship do
  describe '#valid?' do
    subject { described_class.new(options) }
    let(:options) { { follower_id: follower_id, followee_id: followee_id } }
    let(:follower_id) { follower.id }
    let(:followee_id) { followee.id }
    let(:follower) { create(:user) }
    let(:followee) { create(:user) }

    context 'when the follower is not a valid user' do
      let(:follower_id) { nil }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when the follower is a valid user' do
      context 'when the follwee is not a valid user' do
        let(:followee_id) { nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end

      context 'when the follwee is a valid user' do
        context 'but the relationship is already in the database' do
          before { described_class.create!(options) }

          it 'is not valid' do
            expect(subject).to_not be_valid
          end
        end

        context 'but the user is trying to follow themself' do
          let(:followee_id) { follower_id }

          it 'is not valid' do
            expect(subject).to_not be_valid
          end
        end

        context 'and the relationship is not yet in the database' do
          it 'is valid' do
            expect(subject).to be_valid
          end
        end
      end
    end
  end

  describe '#follower' do
    subject { build(:relationship, follower: user) }
    let(:user) { create(:user) }

    it 'returns the follower' do
      expect(subject.follower).to eq(user)
    end
  end

  describe '#followee' do
    subject { build(:relationship, followee: user) }
    let(:user) { create(:user) }

    it 'returns the followee' do
      expect(subject.followee).to eq(user)
    end
  end

  describe '#destroy' do
    subject { create(:relationship, follower: follower, followee: followee) }
    let(:follower) { create(:user) }
    let(:followee) { create(:user) }
    let(:ids) { [follower.id, followee.id] }

    it 'does not destroy follower or followee' do
      subject.destroy!
      expect(ids).to be_all { |id| Tabular::Models::User.exists?(id: id) }
    end
  end
end
