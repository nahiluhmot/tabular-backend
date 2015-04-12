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

    %i(artist album title body user_id).each do |field|
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

    it 'returns the session\'s associated user' do
      expect(subject.user).to eq(user)
    end
  end

  describe '#destroy' do
    subject { create(:tab) }

    it 'does not destroy the tab\'s associated user' do
      user_id = subject.user_id
      subject.destroy!
      expect(Tabular::Models::User.exists?(id: user_id)).to be true
    end
  end
end
