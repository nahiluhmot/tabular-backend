require 'spec_helper'

describe Tabular::Services::Relationships do
  describe '#followees!' do
    let(:username) { user.username }
    let(:user) { create(:user) }
    let(:followee) { create(:user) }
    let(:session) { create(:session, user: user) }

    before { subject.follow!(session.key, followee.username) }

    context 'when the username is blank' do
      let(:username) { nil }

      it 'fails with MalformedRequest' do
        expect { subject.followees!(username) }
          .to raise_error(Tabular::Errors::MalformedRequest)
      end
    end

    context 'when the username is present' do
      context 'but the username is invalid' do
        let(:username) { 'invalid username' }

        it 'fails with NoSuchModel' do
          expect { subject.followees!(username) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the username is valid' do
        it 'returns the followees' do
          expect(subject.followees!(username)).to eq([followee])
        end
      end
    end
  end

  describe '#followers!' do
    let(:username) { user.username }
    let(:user) { create(:user) }
    let(:follower) { create(:user) }
    let(:session) { create(:session, user: follower) }

    before { subject.follow!(session.key, user.username) }

    context 'when the username is blank' do
      let(:username) { nil }

      it 'fails with MalformedRequest' do
        expect { subject.followers!(username) }
          .to raise_error(Tabular::Errors::MalformedRequest)
      end
    end

    context 'when the username is present' do
      context 'but the username is invalid' do
        let(:username) { 'bad username' }

        it 'fails with NoSuchModel' do
          expect { subject.followers!(username) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the username is valid' do
        it 'returns the followers' do
          expect(subject.followers!(username)).to eq([follower])
        end
      end
    end
  end

  describe '#follows?' do
    let(:session_key) { session.key }
    let(:username) { followee.username }

    let(:followee) { create(:user) }
    let(:follower) { create(:user) }
    let(:session) { create(:session, user: follower) }

    context 'when the session_key is invalild' do
      let(:session_key) { 'boo bad key' }

      it 'fails with Unauthorized' do
        expect { subject.follows?(session_key, username) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session_key is valid' do
      context 'but the username does not exist' do
        let(:username) { 'boo bad username' }

        it 'fails with NoSuchModel' do
          expect { subject.follows?(session_key, username) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the username exists' do
        context 'and the authenticated user is already following them' do
          before { subject.follow!(session_key, username) }

          it 'returns true' do
            expect(subject.follows?(session_key, username)).to be true
          end
        end

        context 'and the authenticated user is not yet following them' do
          it 'returns false' do
            expect(subject.follows?(session_key, username)).to be false
          end
        end
      end
    end
  end

  describe '#follow!' do
    let(:session_key) { session.key }
    let(:username) { followee.username }

    let(:followee) { create(:user) }
    let(:follower) { create(:user) }
    let(:session) { create(:session, user: follower) }

    context 'when the session_key is invalild' do
      let(:session_key) { 'boo bad key' }

      it 'fails with Unauthorized' do
        expect { subject.follow!(session_key, username) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session_key is valid' do
      context 'but the username does not exist' do
        let(:username) { 'boo bad username' }

        it 'fails with NoSuchModel' do
          expect { subject.follow!(session_key, username) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the username exists' do
        context 'but the authenticated user is already following them' do
          before { subject.follow!(session_key, username) }

          it 'fails with Conflict' do
            expect { subject.follow!(session_key, username) }
              .to raise_error(Tabular::Errors::Conflict)
          end
        end

        context 'and the authenticated user is not yet following them' do
          let(:options) do
            {
              follower_id: follower.id,
              followee_id: followee.id
            }
          end

          it 'follows that user' do
            expect { subject.follow!(session_key, username) }
              .to change { Tabular::Models::Relationship.exists?(options) }
              .from(false)
              .to(true)
          end
        end
      end
    end
  end

  describe '#unfollow!' do
    let(:session_key) { session.key }
    let(:username) { followee.username }

    let(:followee) { create(:user) }
    let(:follower) { create(:user) }
    let(:session) { create(:session, user: follower) }

    context 'when the session_key is invalild' do
      let(:session_key) { 'boo bad key' }

      it 'fails with Unauthorized' do
        expect { subject.unfollow!(session_key, username) }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session_key is valid' do
      context 'but the username does not exist' do
        let(:username) { 'boo bad username' }

        it 'fails with NoSuchModel' do
          expect { subject.unfollow!(session_key, username) }
            .to raise_error(Tabular::Errors::NoSuchModel)
        end
      end

      context 'and the username exists' do
        context 'but the authenticated user is not following them' do
          it 'fails with NoSuchModel' do
            expect { subject.unfollow!(session_key, username) }
              .to raise_error(Tabular::Errors::NoSuchModel)
          end
        end

        context 'and the authenticated user is following them' do
          let(:options) do
            {
              follower_id: follower.id,
              followee_id: followee.id
            }
          end

          before { subject.follow!(session_key, username) }

          it 'unfollows that user' do
            expect { subject.unfollow!(session_key, username) }
              .to change { Tabular::Models::Relationship.exists?(options) }
              .from(true)
              .to(false)
          end
        end
      end
    end
  end
end
