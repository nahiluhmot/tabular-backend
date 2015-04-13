require 'spec_helper'

describe Tabular::Controllers::Sessions do
  let(:app) { described_class.new }

  describe 'POST /sessions/' do
    let(:post_body) { options.to_json }
    let(:options) { { username: username, password: password } }
    let(:username) { 'nahiluhmot' }
    let(:password) { 'trustno1' }
    let(:response_body) { JSON.parse(last_response.body).symbolize_keys }

    context 'when the POST body is malformed' do
      let(:options) { 'NOT JSON' }

      it 'returns a 400 bad request' do
        post '/sessions/', post_body

        expect(last_response.status).to eq(400)
      end
    end

    context 'when the POST body is valid JSON' do
      context 'but the username is not in the database' do
        it 'returns a 404 not found' do
          post '/sessions/', post_body

          expect(last_response.status).to eq(404)
        end
      end

      context 'and the username is in the database' do
        before do
          Tabular::Services::Users.create_user!(username, password, password)
        end

        context 'but the password is incorrect' do
          let(:options) { { username: username, password: 'badpassword' } }

          it 'returns a 403 forbidden' do
            post '/sessions/', post_body

            expect(last_response.status).to eq(403)
          end
        end

        context 'and the username and password can be verified' do
          let(:session_key) { rack_mock_session.cookie_jar['session_key'] }

          it 'creates a new session' do
            post '/sessions/', post_body

            expect(last_response.status).to eq(201)
            expect(session_key).to be_present
            expect(Tabular::Models::Session.exists?(key: session_key))
              .to be true
            expect(response_body).to eq(key: session_key)
          end
        end
      end
    end
  end

  describe 'DELETE /sessions/' do
    context 'when there is no logged in user' do
      it 'returns a 401 unauthorized' do
        delete '/sessions/'
        expect(last_response.status).to eq(401)
      end
    end

    context 'when there is a logged in user' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }
      let(:key) { session.key }

      it 'logs them out', :cur do
        header Tabular::Controllers::SESSION_KEY_HEADER, key
        delete '/sessions/'
        expect(last_response.status).to eq(204)
        expect(Tabular::Models::Session.exists?(key: key)).to be false
      end
    end
  end
end
