require 'spec_helper'

describe Tabular::Models::Tab do
  describe '#valid?' do
    subject do
      described_class.new(
        artist: artist,
        album: album,
        title: title,
        body: body,
        user_id: user_id
      )
    end
    let(:artist) { 'Test Artist' }
    let(:album) { 'Test Album' }
    let(:title) { 'Test Title' }
    let(:body) { 'Some Tab' }
    let(:user_id) { create(:user).id }

    [:artist, :album, :title, :body, :user_id].each do |field|
      context "when the #{field} is not set" do
        let(field) { nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end
    end

    context 'when every required field is set' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe '#user' do
    subject { create(:tab, user: user) }
    let(:user) { create(:user) }

    it 'returns the tab\'s associated user' do
      expect(subject.user).to eq(user)
    end
  end

  describe '#comments' do
    subject { create(:tab) }

    let(:comment_one) { build(:comment, tab: subject) }
    let(:comment_two) { build(:comment) }
    let(:comments) { [comment_one, comment_two] }

    before { comments.each(&:save!) }

    it 'returns every comment for that tab' do
      expect(subject.comments).to eq([comment_one])
    end
  end

  describe 'creation' do
    subject { build(:tab) }
    let(:query) do
      {
        activity_type: described_class.name,
        activity_id: subject.id
      }
    end

    it 'creates an activity log as well' do
      subject.save!
      expect(Tabular::Models::ActivityLog.exists?(query)).to be true
    end
  end

  describe '#destroy!' do
    subject { create(:tab) }

    it 'only destroys the tab and activity log' do
      user_id = subject.user_id
      log_id = subject.activity_log.id
      subject.destroy!
      expect(Tabular::Models::User.exists?(id: user_id)).to be true
      expect(Tabular::Models::ActivityLog.exists?(id: log_id)).to be false
    end
  end
end
