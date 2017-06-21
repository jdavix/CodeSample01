FactoryGirl.define do
  factory :group_event do
    start_date Time.zone.now.to_date
    end_date (Time.zone.now.to_date + 3.days)
    sequence(:name){|n| "Event group {n}" }
    description "Aha!, You went into reading this file or you inspected this field in the logs of the tests"
  end
end