FactoryGirl.define do
  factory :session, class: Tabular::Models::Session do
    sequence(:key) { |n| "test_key_#{n}" }
    user
  end
end
