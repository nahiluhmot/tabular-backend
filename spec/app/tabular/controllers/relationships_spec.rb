require 'spec_helper'

describe Tabular::Controllers::Relationships do
  subject { last_response }
  let(:app) { described_class.new }

  describe 'GET /users/:username/followers' do
    let(:username) { followee.username }
    let(:followee) { create(:user) }
    let(:follower) { create(:user) }
    let(:session) { create(:session, user: follower) }

    before do
      Tabular::Services::Relationships.follow!(session.key, followee.username)
      get "/users/#{username}/followers"
    end

    context 'when the username does not exist' do
      let(:username) { 'bad_username' }

      it 'returns a 404' do
        expect(subject.status).to eq(404)
      end
    end

    context 'when the username exists' do
      let(:expected) do
        [
          {
            'username' => follower.username
          }
        ]
      end

      it 'returns that user\'s followers' do
        expect(subject.status).to eq(200)
        expect(JSON.parse(subject.body)).to eq(expected)
      end
    end
  end

  describe 'GET /users/:username/followees' do
    let(:username) { follower.username }
    let(:followee) { create(:user) }
    let(:follower) { create(:user) }
    let(:session) { create(:session, user: follower) }

    before do
      Tabular::Services::Relationships.follow!(session.key, followee.username)
      get "/users/#{username}/followees"
    end

    context 'when the username does not exist' do
      let(:username) { 'bad_username' }

      it 'returns a 404' do
        expect(subject.status).to eq(404)
      end
    end

    context 'when the username exists' do
      let(:expected) do
        [
          {
            'username' => followee.username
          }
        ]
      end

      it 'returns that user\'s followers' do
        expect(subject.status).to eq(200)
        expect(JSON.parse(subject.body)).to eq(expected)
      end
    end
  end

  describe 'POST /users/:username/followers' do
    let(:username) { followee.username }
    let(:key) { session.key }
    let(:follower) { create(:user) }
    let(:followee) { create(:user) }
    let(:session) { create(:session, user: follower) }

    context 'when the user is not logged in' do
      it 'returns a 401' do
        post "/users/#{username}/followers/"

        expect(subject.status).to eq(401)
      end
    end

    context 'when the user is logged in' do
      before { header Tabular::Controllers::SESSION_KEY_HEADER, key }

      context 'but the username does not exist' do
        let(:username) { 'bad_username' }

        it 'returns a 404' do
          post "/users/#{username}/followers/"

          expect(subject.status).to eq(404)
        end
      end

      context 'and the username exists' do
        context 'but the follower already follows the followee' do
          before do
            Tabular::Services::Relationships.follow!(session.key, username)
          end

          it 'returns a 409' do
            post "/users/#{username}/followers/"

            expect(subject.status).to eq(409)
          end
        end

        context 'and the follower does not yet follow the followee' do
          it 'allows the user to follow the followee' do
            expect(Tabular::Services::Relationships.followers!(username))
              .to be_empty

            post "/users/#{username}/followers/"

            expect(Tabular::Services::Relationships.followers!(username))
              .to eq([follower])

            expect(subject.status).to eq(201)
          end
        end
      end
    end
  end

  describe 'DELETE /users/:username/followers' do
    let(:username) { followee.username }
    let(:key) { session.key }
    let(:follower) { create(:user) }
    let(:followee) { create(:user) }
    let(:session) { create(:session, user: follower) }

    context 'when the user is not logged in' do
      it 'returns a 401' do
        delete "/users/#{username}/followers/"

        expect(subject.status).to eq(401)
      end
    end

    context 'when the user is logged in' do
      before { header Tabular::Controllers::SESSION_KEY_HEADER, key }

      context 'but the username does not exist' do
        let(:username) { 'bad_username' }

        it 'returns a 404' do
          delete "/users/#{username}/followers/"

          expect(subject.status).to eq(404)
        end
      end

      context 'and the username exists' do
        context 'but the follower does not follow the followee' do
          it 'returns a 404' do
            delete "/users/#{username}/followers/"

            expect(subject.status).to eq(404)
          end
        end

        context 'and the follower follows the followee' do
          before do
            Tabular::Services::Relationships.follow!(session.key, username)
          end

          def followers
            Tabular::Services::Relationships.followers!(username)
          end

          it 'allows the user to follow the followee' do
            expect(followers).to eq([follower])
            delete "/users/#{username}/followers/"
            expect(followers).to be_empty

            expect(subject.status).to eq(204)
          end
        end
      end
    end
  end
end
