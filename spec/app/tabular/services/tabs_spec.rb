require 'spec_helper'

describe Tabular::Services::Tabs do
  describe '.search_tabs' do
    context 'when there are no matching records' do
      it 'returns no records' do
        expect(subject.search_tabs('No Matches')).to be_empty
      end
    end

    context 'when there are matching records' do
      let(:tab_one) do
        build :tab,
          artist: 'Grizzly Bear',
          album: 'Shields',
          title: 'Sleeping Ute'
      end
      let(:tab_two) do
        build :tab,
          artist: 'Ben Folds',
          album: 'Rockin\' the Suburbs',
          title: 'Rockin\' the Suburbs'
      end
      let(:tab_three) do
        build :tab,
          artist: 'Arcade Fire',
          album: 'The Suburbs',
          title: 'The Suburbs'
      end

      let(:tabs) { [tab_one, tab_two, tab_three] }
      let(:query) { 'The Suburbs' }
      let(:matched_tabs) { [tab_two, tab_three] }

      before { tabs.each(&:save!) }

      it 'returns those records' do
        expect(subject.search_tabs(query)).to eq(matched_tabs)
      end
    end

    context 'when there is an attempted SQL injection' do
      it 'is escaped' do
        expect(subject.search_tabs('; DROP TABLE tabs; --')).to be_empty
        expect { subject.search_tabs('valid query') }.to_not raise_error
      end
    end
  end

  describe '#create_tab!' do
    let(:session) { create(:session) }
    let(:key) { session.key }
    let(:artist) { 'Beck' }
    let(:album) { 'Mellow Gold' }
    let(:title) { 'Loser' }
    let(:body) { 'Some chords and stuff' }

    context 'when the key is invalid' do
      let(:key) { 'bad key' }

      it 'fails with Unauthorized' do
        expect { subject.create_tab!(key, artist, album, title, body) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the key is valid' do
      it 'creates a new tab' do
        expect { subject.create_tab!(key, artist, album, title, body) }
          .to change { Tabular::Models::Tab.where(user: session.user).count }
          .by(1)
      end
    end
  end

  describe '#update_tab!' do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }
    let(:tab) { create(:tab, user: user) }

    let(:key) { session.key }
    let(:id) { tab.id }
    let(:options) do
      {
        artist: artist,
        album: album,
        title: title,
        body: body
      }
    end
    let(:artist) { 'Radiohead' }
    let(:album) { 'Pablo Honey' }
    let(:title) { 'Creep' }
    let(:body) { 'I\'M A WEIRDO' }

    context 'when the key is invalid' do
      let(:key) { 'bad key' }

      it 'fails with Unauthorized' do
        expect { subject.update_tab!(key, id, options) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the key is valid' do
      context 'but the id is not in the database' do
        let(:id) { -1 }

        it 'fails with NoSuchModel' do
          expect { subject.update_tab!(key, id, options) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the id is in the database' do
        context 'but it does not belong to the logged in user' do
          let(:tab) { create(:tab) }

          it 'fails with NoSuchModel' do
            expect { subject.update_tab!(key, id, options) }
              .to raise_error(Tabular::Errors::NoSuchModel)
          end
        end

        context 'and it belongs to the logged in user' do
          it 'updates the tab' do
            expect { subject.update_tab!(key, id, options) }
              .to change { tab.tap(&:reload).artist }
          end
        end
      end
    end
  end

  describe '#destroy_tab' do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }
    let(:tab) { create(:tab, user: user) }

    let(:key) { session.key }
    let(:id) { tab.id }

    context 'when the key is invalid' do
      let(:key) { 'bad key' }

      it 'fails with Unauthorized' do
        expect { subject.destroy_tab!(key, id) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the key is valid' do
      context 'but the id is not in the database' do
        let(:id) { -1 }

        it 'fails with NoSuchModel' do
          expect { subject.destroy_tab!(key, id) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the id is in the database' do
        context 'but it does not belong to the logged in user' do
          let(:tab) { create(:tab) }

          it 'fails with NoSuchModel' do
            expect { subject.destroy_tab!(key, id) }
              .to raise_error(Tabular::Errors::NoSuchModel)
          end
        end

        context 'and it belongs to the logged in user' do
          it 'destroys the tab' do
            expect { subject.destroy_tab!(key, id) }
              .to change { Tabular::Models::Tab.where(id: id).count }
              .by(-1)
          end
        end
      end
    end
  end
end
