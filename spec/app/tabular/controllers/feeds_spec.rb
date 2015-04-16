require 'spec_helper'

describe Tabular::Controllers::Feeds do
  subject { last_response }
  let(:app) { described_class.new }
  let(:status) { subject.status }
  let(:body) { JSON.parse(subject.body) }

  describe 'GET /feed/' do
    let(:options) { { page: 1 } }

    context 'when nobody is signed in' do
      it 'returns a 401' do
        get '/feed/', options

        expect(status).to eq(401)
      end
    end

    context 'when a user is signed in' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }
      let(:key) { session.key }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, key }

      context 'but the query is malformed' do
        let(:options) { { page: -1 } }

        it 'returns a 400' do
          get '/feed/', options

          expect(status).to eq(400)
        end
      end

      context 'and the query is well formed' do
        let(:followee_one) { create(:user) }
        let(:followee_two) { create(:user) }
        let(:followees) { [followee_one, followee_two] }
        let(:non_followee) { create(:user) }

        let(:tabs) { 10.times.map { build(:tab, user: followee_one) } }
        let(:comments) { 10.times.map { build(:comment, user: followee_two) } }
        let(:other_tabs) { 5.times.map { build(:tab, user: non_followee) } }

        let(:expected_body) do
          tabs.zip(comments).flatten.reverse.map do |activity|
            if activity.is_a?(Tabular::Models::Tab)
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
            else
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
                    'title' => activity.tab.title
                  }
                }
              }
            end
          end
        end

        before do
          Tabular::Services::Relationships.follow!(key, followee_one.username)
          tabs.zip(comments, other_tabs).flatten.compact.each(&:save!)
          Tabular::Services::Relationships.follow!(key, followee_two.username)
        end

        it 'returns the activity feed for the user' do
          get '/feed/', options

          expect(status).to eq(200)
          expect(body).to eq(expected_body)
        end
      end
    end
  end
end
