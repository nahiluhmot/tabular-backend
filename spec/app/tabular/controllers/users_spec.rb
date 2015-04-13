require 'spec_helper'

describe Tabular::Controllers::Users do
  let(:app) { described_class.new }

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
            let(:model) { Tabular::Models::User.find_by(username: username) }
            let(:expected_response) do
              {
                id: model.id,
                username: username
              }
            end

            it 'returns a 201 and creates a user' do
              expect(last_response.status).to eq(201)
              expect(response_body).to eq(expected_response)
            end
          end
        end
      end
    end
  end
end
