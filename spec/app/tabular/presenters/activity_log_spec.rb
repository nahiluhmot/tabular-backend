require 'spec_helper'

describe Tabular::Presenters::ActivityLog do
  describe '#present' do
    subject { described_class.new(activity_log) }
    let(:activity_log) { activity.activity_log }

    context 'when the activity is a comment' do
      let(:activity) { create(:comment) }
      let(:expected) do
        {
          'comment' => {
            'id' => activity.id,
            'body' => activity.body,
            'user' => {
              'username' => activity.user.username
            },
            'tab' => {
              'id' => activity.tab.id,
              'artist' => activity.tab.artist,
              'album' => activity.tab.album,
              'title' => activity.tab.title,
              'user' => {
                'username' => activity.tab.user.username
              }
            }
          }
        }
      end

      it 'presents the comment' do
        expect(subject.present).to eq(expected)
      end
    end

    context 'when the activity is a tab' do
      let(:activity) { create(:tab) }
      let(:expected) do
        {
          'tab' => {
            'id' => activity.id,
            'artist' => activity.artist,
            'album' => activity.album,
            'title' => activity.title,
            'user' => {
              'username' => activity.user.username
            }
          }
        }
      end

      it 'presents the tab' do
        expect(subject.present).to eq(expected)
      end
    end
  end
end
