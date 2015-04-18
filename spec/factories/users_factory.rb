FactoryGirl.define do
  factory_definition = proc do
    sequence(:username) { |n| "test_user_#{n}" }

    # For efficiency, use the same password salt and hash in every test.
    salt = Tabular::Services::Crypto.generate_salt
    hash = Tabular::Services::Crypto.hash_password('password', salt)
    password_salt salt
    password_hash hash
  end

  factory :user,
    aliases: [:follower, :followee],
    class: Tabular::Models::User,
    &factory_definition
end
