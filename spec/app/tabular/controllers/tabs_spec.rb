require 'spec_helper'

describe Tabular::Controllers::Tabs do
  let(:app) { described_class.new }
  let(:status) { last_response.status }
  let(:body) { JSON.parse(last_response.body) }

  describe 'GET /tabs/' do
    let(:tab_one) { build(:tab, artist: 'Nirvana') }
    let(:tab_two) { build(:tab, artist: 'Nirvana') }
    let(:tab_three) { build(:tab, artist: 'Beck') }
    let(:matched_tabs) { [tab_one, tab_two] }
    let(:tabs) { [tab_one, tab_two, tab_three] }
    let(:expected_body) do
      matched_tabs.map do |tab|
        tab.as_json(only: Tabular::Controllers::Tabs::TAB_DISPLAY_KEYS)
      end
    end

    before { tabs.each(&:save!) }

    it 'searches the database for the given query' do
      get '/tabs/', query: 'Nirvana', page: 1

      expect(status).to eq(200)
      expect(body).to eq(expected_body)
    end
  end

  describe 'POST /tabs/' do
    let(:post_body) { options.to_json }
    let(:options) do
      build(:tab).as_json(
        only: Tabular::Controllers::Tabs::TAB_ATTRIBUTE_WHITELIST
      )
    end

    context 'when no user is logged in' do
      it 'returns 401 Unauthorized' do
        post '/tabs/', post_body

        expect(status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the POST body is not the expected JSON schema' do
        before { options.delete('artist') }

        it 'returns a 400' do
          post '/tabs/', post_body

          expect(status).to eq(400)
        end
      end

      context 'and the POST body is the expected JSON schema' do
        it 'returns a 201 and creates a new tab' do
          post '/tabs/', post_body

          expect(status).to eq(201)
          expect(body).to include(options.merge('user_id' => user.id))
          expect(body['id']).to be_a(Integer)
        end
      end
    end
  end

  describe 'GET /tabs/:id/' do
    context 'when the queried id is not in the database' do
      it 'returns a 404' do
        get '/tabs/-1/'

        expect(status).to eq(404)
      end
    end

    context 'when the queried id is in the database' do
      let(:tab) { create(:tab) }
      let(:expected_body) do
        tab.as_json(only: Tabular::Controllers::Tabs::TAB_DISPLAY_KEYS)
      end

      it 'returns the tab associated with the given id' do
        get "/tabs/#{tab.id}/"

        expect(status).to eq(200)
        expect(body).to eq(expected_body)
      end
    end
  end

  describe 'PUT /tabs/:id/' do
    let(:put_body) { options.to_json }
    let(:options) { { title: title } }
    let(:title) { 'Creep' }

    let(:user) { create(:user) }
    let(:tab) { create(:tab, user: user) }

    context 'when no user is logged in' do
      it 'returns 401' do
        put "/tabs/#{tab.id}/", put_body

        expect(status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the no post that user owns has that id' do
        let(:tab) { create(:tab) }

        it 'returns a 404' do
          put "/tabs/#{tab.id}/", put_body

          expect(status).to eq(404)
        end
      end

      context 'and the user owns the post associated with that id' do
        context 'but the PUT body is not the expected JSON schema' do
          let(:put_body) { 'some nonsense' }

          it 'returns a 400' do
            put "/tabs/#{tab.id}/", put_body

            expect(status).to eq(400)
          end
        end

        context 'and the PUT body is the expected JSON schema' do
          it 'updates the tab' do
            expect { put "/tabs/#{tab.id}/", put_body }
              .to change { Tabular::Models::Tab.find_by(id: tab.id).title }
              .from(tab.title)
              .to(title)

            expect(status).to eq(204)
          end
        end
      end
    end
  end

  describe 'DELETE /tabs/:id/' do
    let(:user) { create(:user) }
    let(:tab) { create(:tab, user: user) }

    context 'when no user is logged in' do
      it 'returns 401' do
        delete "/tabs/#{tab.id}/"

        expect(status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the no post that user owns has that id' do
        let(:tab) { create(:tab) }

        it 'returns a 404' do
          delete "/tabs/#{tab.id}/"

          expect(status).to eq(404)
        end
      end

      context 'and the user owns the post associated with that id' do
        it 'deletes the tab' do
          expect { delete "/tabs/#{tab.id}/" }
            .to change { Tabular::Models::Tab.where(id: tab.id).count }
            .by(-1)

          expect(status).to eq(204)
        end
      end
    end
  end
end
