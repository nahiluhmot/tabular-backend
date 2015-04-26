require 'spec_helper'

describe Tabular::Presenters::User do
  describe '#present' do
    subject { described_class.new(user) }
    let(:user) { create(:user) }

    context 'when no options are given' do
      let(:expected) { { 'username' => user.username } }

      it 'presents the user\'s username in the JSON' do
        expect(subject.present).to eq(expected)
      end
    end

    context 'when the counts are requested' do
      let(:followees_count) { 5 }
      let(:followers_count) { 10 }
      let(:expected) do
        {
          'username' => user.username,
          'followees_count' => followees_count,
          'followers_count' => followers_count
        }
      end

      before do
        followees_count.times { create(:relationship, follower: user) }
        followers_count.times { create(:relationship, followee: user) }
      end

      it 'presents the followees_count, and followers_count as well' do
        expect(subject.present(counts: true)).to eq(expected)
      end
    end
  end
end
