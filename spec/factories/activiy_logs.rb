FactoryGirl.define do
  factory :activity_log, class: Tabular::Models::ActivityLog do
    activity { create(:comment, user: user) }
    user
  end
end
