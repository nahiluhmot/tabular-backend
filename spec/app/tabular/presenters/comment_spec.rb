require 'spec_helper'

describe Tabular::Presenters::Comment do
  describe '#present' do
    subject { described_class.new(comment) }
    let(:comment) { create(:comment) }

    context 'when no options are set' do
      let(:options) { {} }
      let(:expected) do
        {
          'id' => comment.id,
          'body' => comment.body
        }
      end

      it 'presents the comment' do
        expect(subject.present(options)).to eq(expected)
      end
    end

    context 'when the user is requested' do
      let(:options) { { user: true } }
      let(:expected) do
        {
          'id' => comment.id,
          'body' => comment.body,
          'user' => {
            'username' => comment.user.username
          }
        }
      end

      it 'includes the user and username' do
        expect(subject.present(options)).to eq(expected)
      end
    end

    context 'when the tab is requested' do
      let(:options) { { tab: true } }
      let(:expected) do
        {
          'id' => comment.id,
          'body' => comment.body,
          'tab' => {
            'id' => comment.tab.id,
            'artist' => comment.tab.artist,
            'album' => comment.tab.album,
            'title' => comment.tab.title
          }
        }
      end

      it 'includes the tab metadata' do
        expect(subject.present(options)).to eq(expected)
      end
    end
  end
end
