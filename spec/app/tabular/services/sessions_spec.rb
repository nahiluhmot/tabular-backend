require 'spec_helper'

describe Tabular::Services::Sessions do
  describe '#login!' do
    let(:user) { create(:user) }
    let(:username) { user.username }
    let(:password) { 'password' }

    context 'when the user does not exist' do
      let(:username) { 'typod username' }

      it 'fails with NoSuchModel' do
        expect { subject.login!(username, password) }
          .to raise_error(Tabular::Errors::NoSuchModel)
      end
    end

    context 'when the user exists' do
      context 'but the password is wrong' do
        let(:password) { 'letmein' }

        it 'fails with BadPassword' do
          expect { subject.login!(username, password) }
            .to raise_error(Tabular::Errors::BadPassword)
        end
      end

      context 'and the password is correct' do
        it 'creates a new session for the user' do
          expect(subject.login!(user.username, 'password'))
            .to be_a(Tabular::Models::Session)
        end
      end
    end
  end

  describe '#logout!' do
    context 'when the session does not exist' do
      it 'fails with Unauthorized' do
        expect { subject.logout!('fake session') }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the session exists' do
      let(:session) { build(:session) }

      before { session.save! }

      it 'destroys that session' do
        expect { subject.logout!(session.key) }
          .to change { Tabular::Models::Session.where(id: session.id).count }
          .from(1)
          .to(0)
      end
    end
  end
end
