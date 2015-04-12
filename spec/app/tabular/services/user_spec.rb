require 'spec_helper'

describe Tabular::Services::User do
  let(:user) { create(:user) }
  subject { described_class.new(user.username) }

  describe '#initialize' do
    subject { described_class }

    context 'when the username is not in the database' do
      let(:username) { 'lil_joey' }

      it 'fails with NoSuchModel' do
        expect { subject.new(username) }
          .to raise_error(Tabular::Errors::NoSuchModel)
      end
    end

    context 'when the username exists in the database' do
      it 'creates a new user service' do
        expect { subject.new(user.username) }
          .to_not raise_error
      end
    end
  end

  describe '#read' do
    it 'returns the corresponding database model' do
      expect(subject.read).to eq(user)
    end
  end

  describe '#update_password!' do
    context 'when the password cannot be updated' do
      it 'fails with InvalidModel' do
        expect { subject.update_password!('password', 'drowssap') }
          .to raise_error(Tabular::Errors::InvalidModel)
      end
    end

    context 'when the password can be updated' do
      it 'updates the password' do
        old_username = user.username
        old_password_salt = user.password_salt
        old_password_hash = user.password_hash
        subject.update_password!('password', 'password')
        user.reload
        expect(user.username).to eq(old_username)
        expect(user.password_salt).to_not eq(old_password_salt)
        expect(user.password_hash).to_not eq(old_password_hash)
      end
    end
  end

  describe '#destroy!' do
    before { subject.destroy! }

    it 'destroy!s the user' do
      expect { user.tap(&:reload) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
