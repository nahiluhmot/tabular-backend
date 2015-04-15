require 'spec_helper'

describe Tabular::Controllers::Comments do
  subject { last_response }
  let(:status) { subject.status }
  let(:response_body) { JSON.parse(subject.body) }
  let(:app) { described_class.new }

  describe 'GET /user/:username/comments/' do
    context 'when the username does not exist' do
      it 'returns a 404' do
        get '/users/bad_username/comments/'

        expect(status).to eq(404)
      end
    end

    context 'when the username exists' do
      let(:user) { create(:user) }
      let(:comment_one) { build(:comment, user: user) }
      let(:comment_two) { build(:comment, user: user) }
      let(:comments) { [comment_one, comment_two] }

      let(:expected_response) do
        comments.map do |comment|
          comment.as_json(
            only: Tabular::Controllers::Comments::COMMENT_ATTRIBUTE_WHITELIST,
            include: {
              tab: { only: Tabular::Controllers::Tabs::TAB_ATTRIBUTE_WHITELIST }
            }
          )
        end
      end

      before { comments.each(&:save!) }

      it 'returns a 200 with the comments in the body' do
        get "/users/#{user.username}/comments/"

        expect(status).to eq(200)
        expect(response_body).to eq(expected_response)
      end
    end
  end

  describe 'GET /tabs/:tab_id/comments/' do
    context 'when the tab does not exist' do
      it 'returns a 404' do
        get '/tabs/-1/comments/'

        expect(status).to eq(404)
      end
    end

    context 'when the tab exists' do
      let(:tab) { create(:tab) }
      let(:comment_one) { build(:comment, tab: tab) }
      let(:comment_two) { build(:comment, tab: tab) }
      let(:comments) { [comment_one, comment_two] }

      let(:expected_response) do
        comments.map do |comment|
          comment.as_json(
            only: Tabular::Controllers::Comments::COMMENT_ATTRIBUTE_WHITELIST,
            include: {
              user: { only: :username }
            }
          )
        end
      end

      before { comments.each(&:save!) }

      it 'returns a 200 with the comments in the body' do
        get "/tabs/#{tab.id}/comments/"

        expect(status).to eq(200)
        expect(response_body).to eq(expected_response)
      end
    end
  end

  describe 'POST /tabs/:tab_id/comments/' do
    let(:path) { "/tabs/#{tab_id}/comments/" }
    let(:post_body) { { body: body }.to_json }

    let(:tab_id) { tab.id }
    let(:tab) { create(:tab) }
    let(:body) { 'Good job!' }

    context 'when nobody is logged in' do
      it 'returns a 401' do
        post path, post_body

        expect(status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the tab id does not exist' do
        let(:tab_id) { -1 }

        it 'returns a 404' do
          post path, post_body

          expect(status).to eq(404)
        end
      end

      context 'and the tab id exists' do
        context 'but there is no comment body' do
          let(:body) { nil }

          it 'returns a 400' do
            post path, post_body

            expect(status).to eq(400)
          end
        end

        context 'and there is a comment body' do
          it 'creates a new comment and returns it' do
            post path, post_body

            expect(status).to eq(201)
            expect(response_body).to include('body' => body)
            expect(response_body['id']).to be_a(Integer)
          end
        end
      end
    end
  end

  describe 'PUT /comments/:comment_id/' do
    let(:path) { "/comments/#{comment_id}/" }
    let(:put_body) { { body: body }.to_json }

    let(:user) { create(:user) }
    let(:comment_id) { comment.id }
    let(:comment) { create(:comment, user: user) }
    let(:body) { 'Good job!' }

    context 'when nobody is logged in' do
      it 'returns a 401' do
        put path, put_body

        expect(status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the comment id does not exist' do
        let(:comment_id) { -1 }

        it 'returns a 404' do
          put path, put_body

          expect(status).to eq(404)
        end
      end

      context 'and the comment id exists' do
        context 'but the user does not own that comment' do
          let(:comment) { create(:comment) }

          it 'returns a 401' do
            put path, put_body

            expect(status).to eq(401)
          end
        end

        context 'and the user owns that comment' do
          context 'but there is no new comment body' do
            let(:body) { nil }

            it 'returns a 400' do
              put path, put_body

              expect(status).to eq(400)
            end
          end

          context 'and there is a comment body' do
            it 'updates the comment' do
              expect { put path, put_body }
                .to change { comment.tap(&:reload).body }
                .from(comment.body)
                .to(body)

              expect(status).to eq(204)
            end
          end
        end
      end
    end
  end

  describe 'DELETE /comments/:comment_id/' do
    let(:path) { "/comments/#{comment_id}/" }

    let(:user) { create(:user) }
    let(:comment_id) { comment.id }
    let(:comment) { create(:comment, user: user) }

    context 'when nobody is logged in' do
      it 'returns a 401' do
        delete path

        expect(status).to eq(401)
      end
    end

    context 'when a user is logged in' do
      let(:session) { create(:session, user: user) }

      before { header Tabular::Controllers::SESSION_KEY_HEADER, session.key }

      context 'but the comment id does not exist' do
        let(:comment_id) { -1 }

        it 'returns a 404' do
          delete path

          expect(status).to eq(404)
        end
      end

      context 'and the comment id exists' do
        context 'but the user does not own that comment' do
          let(:comment) { create(:comment) }

          it 'returns a 401' do
            delete path

            expect(status).to eq(401)
          end
        end

        context 'and the user owns that comment' do
          it 'deletes the comment' do
            expect { delete path }
              .to change { Tabular::Models::Comment.exists?(id: comment.id) }
              .from(true)
              .to(false)

            expect(status).to eq(204)
          end
        end
      end
    end
  end
end
