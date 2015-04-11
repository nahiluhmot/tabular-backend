FactoryGirl.define do
  factory :user, class: Tabular::Models::User do
    sequence(:username) { |n| "test_user_#{n}" }
    password_salt { 10.times.map { (65 + rand(25)).chr }.join }
    password_hash { 15.times.map { (65 + rand(25)).chr }.join }
  end
end
