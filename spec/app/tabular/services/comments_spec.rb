require 'spec_helper'

describe Tabular::Services::Comments do
  describe '#comments_for_tab!' do
    context 'when the tab does not exist' do
      it 'fails with NoSuchModel' do
        expect { subject.comments_for_tab!(1) }
          .to raise_error(Tabular::Errors::NoSuchModel)
      end
    end

    context 'when the tab exists' do
      let(:comment) { build(:comment, tab: tab) }
      let(:tab) { create(:tab) }

      before { comment.save! }

      it 'returns the comments for that tab' do
        expect(subject.comments_for_tab!(tab.id)).to eq([comment])
      end
    end
  end

  describe '#comments_for_user!' do
    context 'when the user does not exist' do
      it 'fails with NoSuchModel' do
        expect { subject.comments_for_user!('bad username') }
          .to raise_error(Tabular::Errors::NoSuchModel)
      end
    end

    context 'when the user exists' do
      let(:comment) { build(:comment, user: user) }
      let(:user) { create(:user) }

      before { comment.save! }

      it 'returns the comments for that user' do
        expect(subject.comments_for_user!(user.username)).to eq([comment])
      end
    end
  end

  describe '#create_comment!' do
    let(:key) { session.key }
    let(:tab_id) { tab.id }
    let(:body) { 'Yahoo!' }
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }
    let(:tab) { create(:tab) }

    context 'when the session key is invalid' do
      let(:key) { 'bad key' }

      it 'fails with Unauthorized' do
        expect { subject.create_comment!(key, tab_id, body) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session key is valid' do
      context 'but the tab id is invalid' do
        let(:tab_id) { -1 }

        it 'fails with NoSuchModel' do
          expect { subject.create_comment!(key, tab_id, body) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the tab id is valid' do
        context 'but the comment body is blank' do
          let(:body) { nil }

          it 'fails with MalformedRequest' do
            expect { subject.create_comment!(key, tab_id, body) }
              .to raise_error(Tabular::Errors::MalformedRequest)
          end
        end

        context 'and the comment body is present' do
          let(:options) do
            {
              user_id: user.id,
              tab_id: tab.id,
              body: body
            }
          end

          it 'returns a comment' do
            expect(subject.create_comment!(key, tab_id, body))
              .to be_a(Tabular::Models::Comment)
          end

          it 'creates a new comment' do
            expect { subject.create_comment!(key, tab_id, body) }
              .to change { Tabular::Models::Comment.where(options).count }
              .from(0)
              .to(1)
          end
        end
      end
    end
  end

  describe '#update_comment!' do
    let(:key) { session.key }
    let(:comment_id) { comment.id }
    let(:body) { 'Yahoo!' }
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }
    let(:comment) { create(:comment, user: user) }

    context 'when the session key is invalid' do
      let(:key) { create(:session).key }

      it 'fails with Unauthorized' do
        expect { subject.update_comment!(key, comment_id, body) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session key is valid' do
      context 'but the comment id is invalid' do
        let(:comment_id) { -1 }

        it 'fails with NoSuchModel' do
          expect { subject.update_comment!(key, comment_id, body) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the comment id is valid' do
        context 'but it is not owned by the user' do
          let(:comment_id) { create(:comment).id }

          it 'fails with Unauthorized' do
            expect { subject.update_comment!(key, comment_id, body) }
              .to raise_error(Tabular::Errors::Unauthorized)
          end
        end

        context 'and it is owned by the user' do
          context 'but the comment body is blank' do
            let(:body) { nil }

            it 'fails with MalformedRequest' do
              expect { subject.update_comment!(key, comment_id, body) }
                .to raise_error(Tabular::Errors::MalformedRequest)
            end
          end

          context 'and the comment body is present' do
            it 'updates the comment' do
              expect { subject.update_comment!(key, comment_id, body) }
                .to change { comment.tap(&:reload).body }
                .from(comment.body)
                .to(body)
            end
          end
        end
      end
    end
  end

  describe '#destroy_comment!' do
    let(:key) { session.key }
    let(:comment_id) { comment.id }
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }
    let(:comment) { create(:comment, user: user) }

    context 'when the session key is invalid' do
      let(:key) { create(:session).key }

      it 'fails with Unauthorized' do
        expect { subject.destroy_comment!(key, comment_id) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session key is valid' do
      context 'but the comment id is invalid' do
        let(:comment_id) { -1 }

        it 'fails with NoSuchModel' do
          expect { subject.destroy_comment!(key, comment_id) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the comment id is valid' do
        context 'but it is not owned by the user' do
          let(:comment_id) { create(:comment).id }

          it 'fails with Unauthorized' do
            expect { subject.destroy_comment!(key, comment_id) }
              .to raise_error(Tabular::Errors::Unauthorized)
          end
        end

        context 'and it is owned by the user' do
          it 'deletes the comment' do
            expect { subject.destroy_comment!(key, comment_id) }
              .to change { Tabular::Models::Comment.exists?(id: comment.id) }
              .from(true)
              .to(false)
          end
        end
      end
    end
  end
end
