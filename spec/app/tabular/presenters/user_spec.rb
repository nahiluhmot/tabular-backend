require 'spec_helper'

describe Tabular::Presenters::User do
  describe '#present' do
    subject { described_class.new(user) }
    let(:user) { create(:user) }

    it 'presents the user\'s username in the JSON' do
      expect(subject.present).to eq('username' => user.username)
    end
  end
end
