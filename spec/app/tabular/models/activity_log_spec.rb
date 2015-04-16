require 'spec_helper'

describe Tabular::Models::ActivityLog do
  describe '#valid?' do
    subject { described_class.new(user: user, activity: activity) }
    let(:user) { create(:user) }
    let(:activity) { create(:comment) }

    context 'when the user is not present' do
      let(:user) { nil }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when the user is present' do
      context 'but the association is nil' do
        let(:activity) { nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end

        context 'and the association is present' do
          context 'but the association is not a comment or tab' do
            let(:activity) { create(:session) }

            it 'is not valid' do
              expect(subject).to_not be_valid
            end
          end

          context 'and the association is a comment' do
            subject do
              described_class.find_by(
                activity_id: activity.id,
                activity_type: activity.class.name
              )
            end
            let(:activity) { create(:comment) }

            it 'is valid' do
              expect(subject).to be_valid
            end
          end

          context 'and the association is a tab' do
            subject do
              described_class.find_by(
                activity_id: activity.id,
                activity_type: activity.class.name
              )
            end

            let(:activity) { create(:tab) }

            it 'is valid' do
              expect(subject).to be_valid
            end
          end
        end
      end
    end
  end

  describe '#user' do
    subject { comment.activity_log }
    let(:user) { create(:user) }
    let(:comment) { create(:comment, user: user) }

    it 'returns the user' do
      expect(subject.user).to eq(user)
    end
  end

  describe '#activity' do
    subject { activity.activity_log }

    context 'when the activity is a comment' do
      let(:activity) { create(:comment) }

      it 'returns the comment' do
        expect(subject.activity).to eq(activity)
      end
    end

    context 'when the activity is a tab' do
      let(:activity) { create(:tab) }

      it 'returns the tab' do
        expect(subject.activity).to eq(activity)
      end
    end
  end

  describe '#destroy!' do
    subject { tab.activity_log }
    let(:user) { create(:user) }
    let(:tab) { create(:tab, user: user) }

    before { subject.destroy! }

    it 'does not destroy the activity or user' do
      expect(Tabular::Models::User.exists?(id: user.id)).to be true
      expect(Tabular::Models::Tab.exists?(id: tab.id)).to be true
    end
  end
end
