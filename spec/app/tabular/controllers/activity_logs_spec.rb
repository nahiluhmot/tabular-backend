require 'spec_helper'

describe Tabular::Controllers::ActivityLogs do
  subject { last_response }
  let(:app) { described_class.new }
  let(:status) { subject.status }
  let(:body) { JSON.parse(subject.body) }

  def present_tab(tab)
    {
      'tab' => {
        'id' => tab.id,
        'artist' => tab.artist,
        'album' => tab.album,
        'title' => tab.title,
        'user' => { 'username' => tab.user.username }
      }
    }
  end

  def present_comment(comment)
    {
      'comment' => {
        'id' => comment.id,
        'body' => comment.body,
        'user' => { 'username' => comment.user.username }
      }.merge(present_tab(comment.tab))
    }
  end

  def present(activity)
    if activity.is_a?(Tabular::Models::Tab)
      present_tab(activity)
    else
      present_comment(activity)
    end
  end

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
          tabs.zip(comments).flatten.reverse.map(&method(:present))
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

  describe 'GET /users/:username/feed/' do
    let(:user) { create(:user) }
    let(:username) { user.username }
    let(:options) { { page: 1 } }

    context 'when the username is invalid' do
      let(:username) { 'bad_username' }

      it 'returns a 404' do
        get "/users/#{username}/feed/", options

        expect(status).to eq(404)
      end
    end

    context 'when the username is valid' do
      context 'but the query parameters are invalid' do
        let(:options) { { page: -1 } }

        it 'returns a 400' do
          get "/users/#{username}/feed/", options

          expect(status).to eq(400)
        end
      end

      context 'and the query is valid' do
        let(:tabs) { 10.times.map { build(:tab, user: user) } }
        let(:comments) { 10.times.map { build(:comment, user: user) } }
        let(:other_comments) { tabs.map { |tab| build(:comment, tab: tab) } }
        let(:expected_body) do
          tabs.zip(comments).flatten.reverse.map(&method(:present))
        end

        before do
          (tabs.zip(comments).flatten).each(&:save!)
          other_comments.each(&:save!)
        end

        it 'returns the recent activity for the user' do
          get "/users/#{username}/feed/", options

          expect(status).to eq(200)
          expect(body).to eq(expected_body)
        end
      end
    end
  end
end
