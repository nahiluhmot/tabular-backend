require 'spec_helper'

describe Tabular::Models::Comment do
  describe '#valid?' do
    subject do
      described_class.new(tab_id: tab_id, user_id: user_id, body: body)
    end
    let(:tab_id) { create(:tab).id }
    let(:user_id) { create(:user).id }
    let(:body) { 'Cool song' }

    %i(tab_id user_id body).each do |field|
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
    subject { create(:comment, user: user) }
    let(:user) { create(:user) }

    it 'returns the comment\'s associated user' do
      expect(subject.user).to eq(user)
    end
  end

  describe '#tab' do
    subject { create(:comment, tab: tab) }
    let(:tab) { create(:tab) }

    it 'returns the comment\'s associated tab' do
      expect(subject.tab).to eq(tab)
    end
  end

  describe '#destroy' do
    subject { create(:comment) }

    it 'does not destroy the comment\'s associated user or tab' do
      user_id = subject.user_id
      tab_id = subject.tab_id
      subject.destroy!
      expect(Tabular::Models::User.exists?(id: user_id)).to be true
      expect(Tabular::Models::Tab.exists?(id: tab_id)).to be true
    end
  end
end
