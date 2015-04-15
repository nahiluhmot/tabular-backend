require 'spec_helper'

describe Tabular::Presenters::Tab do
  describe '#present' do
    subject { described_class.new(tab) }
    let(:tab) { create(:tab) }

    context 'with no options' do
      let(:options) { {} }
      let(:expected) do
        {
          'id' => tab.id,
          'artist' => tab.artist,
          'album' => tab.album,
          'title' => tab.title,
          'body' => tab.body
        }
      end

      it 'presents the tab' do
        expect(subject.present(options)).to eq(expected)
      end
    end

    context 'when the user is requested' do
      let(:expected) do
        {
          'id' => tab.id,
          'artist' => tab.artist,
          'album' => tab.album,
          'title' => tab.title,
          'body' => tab.body,
          'user' => {
            'username' => tab.user.username
          }
        }
      end
      let(:options) { { user: true } }

      it 'includes the user and username' do
        expect(subject.present(options)).to eq(expected)
      end
    end

    context 'when the short version is requested' do
      let(:expected) do
        {
          'id' => tab.id,
          'artist' => tab.artist,
          'album' => tab.album,
          'title' => tab.title
        }
      end
      let(:options) { { short: true } }

      it 'excludes the body' do
        expect(subject.present(options)).to eq(expected)
      end
    end

    context 'when the comments are requested' do
      let(:options) { { comments: true } }
      let(:comment_one) { build(:comment, tab: tab) }
      let(:comment_two) { build(:comment, tab: tab) }
      let(:comments) { [comment_one, comment_two] }
      let(:expected) do
        {
          'id' => tab.id,
          'artist' => tab.artist,
          'album' => tab.album,
          'title' => tab.title,
          'body' => tab.body,
          'comments' => comments.map do |comment|
            {
              'id' => comment.id,
              'body' => comment.body,
              'user' => {
                'username' => comment.user.username
              }
            }
          end
        }
      end

      before { comments.each(&:save!) }

      it 'includes the comments' do
        expect(subject.present(options)).to eq(expected)
      end
    end
  end
end
