require 'spec_helper'

describe Tabular::Controllers::Users do
  let(:app) { described_class.new }

  describe 'GET /users/' do
    context 'when there is nobody logged in' do
      it 'returns a 401' do
        get '/users/'

        expect(last_response.status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }
      let(:body) { JSON.parse(last_response.body) }
      let(:expected) do
        {
          'username' => user.username,
          'followers_count' => user.followers_count,
          'followees_count' => user.followees_count
        }
      end

      before do
        header Tabular::Controllers::SESSION_KEY_HEADER, session.key
        3.times { create(:relationship, follower: user) }
        2.times { create(:relationship, followee: user) }
        user.reload
      end

      it 'returns their username' do
        get '/users/'

        expect(last_response.status).to eq(200)
        expect(body).to eq(expected)
      end
    end
  end

  describe 'GET /users/:username/' do
    before { get "/users/#{username}/" }

    context 'when the user does not exist' do
      let(:username) { 'test_username' }

      it 'returns a 404' do
        expect(last_response.status).to eq(404)
      end
    end

    context 'when the user exists' do
      let(:username) { user.username }
      let(:user) { create(:user) }
      let(:body) { JSON.parse(last_response.body) }
      let(:expected) do
        {
          'username' => user.username,
          'followers_count' => user.followers_count,
          'followees_count' => user.followees_count
        }
      end

      it 'returns a 200 and the username' do
        expect(last_response.status).to eq(200)
        expect(body).to eq(expected)
      end
    end
  end

  describe 'POST /users/' do
    let(:post_body) { options.to_json }
    let(:options) do
      {
        username: username,
        password: password,
        password_confirmation: password_confirmation
      }
    end
    let(:username) { 'nahiluhmot' }
    let(:password) { 'trustno1' }
    let(:password_confirmation) { password }
    let(:response_body) { JSON.parse(last_response.body).symbolize_keys }

    before { post '/users/', post_body }

    context 'when the POST body is malformed' do
      let(:post_body) { 'NOT JSON' }

      it 'returns a status 400' do
        expect(last_response.status).to eq(400)
      end
    end

    context 'when the POST body is valid JSON' do
      context 'but the username is invalid' do
        let(:username) { 'tom hulihan' }

        it 'returns a status 400' do
          expect(last_response.status).to eq(400)
        end
      end

      context 'and the username is valid' do
        context 'but the password is invalid' do
          let(:password_confirmation) { 'letmein' }

          it 'returns a status 400' do
            expect(last_response.status).to eq(400)
          end
        end

        context 'and the password is valid' do
          context 'but the username is taken' do
            before { post '/users/', post_body }

            it 'returns a 409 conflict' do
              expect(last_response.status).to eq(409)
            end
          end

          context 'and the username is not taken' do
            let(:session_key) { rack_mock_session.cookie_jar['session_key'] }
            let(:expected_response) { { username: username } }

            it 'returns a 201, creates a user, and signs them in' do
              expect(last_response.status).to eq(201)
              expect(response_body).to eq(expected_response)

              expect(Tabular::Models::Session.exists?(key: session_key))
                .to be true
              expect(Tabular::Models::User.exists?(username: username))
                .to be true
            end
          end
        end
      end
    end
  end

  describe 'PUT /users/' do
    let(:put_body) { options.to_json }
    let(:options) do
      {
        password: password,
        password_confirmation: confirmation
      }
    end
    let(:password) { 'trustno1' }
    let(:confirmation) { password }

    context 'when nobody is logged in' do
      it 'returns a 401' do
        put '/users/', put_body

        expect(last_response.status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the password cannot be updated' do
        let(:confirmation) { 'bad confirmation' }

        it 'returns a 400' do
          put '/users/', put_body

          expect(last_response.status).to eq(400)
        end
      end

      context 'and the password can be updated' do
        let(:session_key) { rack_mock_session.cookie_jar['session_key'] }

        it 'returns a 204, updates the password, and logs them in' do
          put '/users/', put_body

          expect(last_response.status).to eq(204)
          expect { Tabular::Services::Sessions.login!(user.username, password) }
            .to_not raise_error
          expect(Tabular::Services::Users.user_for_session!(session_key))
            .to eq(user)
        end
      end
    end
  end

  describe 'DELETE /users/' do
    context 'when nobody is logged in' do
      it 'returns a 401' do
        expect { delete '/users/' }
          .to_not change { Tabular::Models::User.count }

        expect(last_response.status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      it 'returns a 204 and deletes the user' do
        expect { delete '/users/' }
          .to change { Tabular::Models::User.exists?(id: user.id) }
          .from(true)
          .to(false)
      end
    end
  end
end
