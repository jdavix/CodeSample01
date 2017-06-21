require 'rails_helper'
RSpec.describe GroupEvent do


  describe '.ready_to_publish?' do
    let(:event){GroupEvent.new}

    it "returns false when there are missing fields" do
      expect(event.ready_to_publish?).to eq false
    end
    it "returns true when there are not missing fields" do
      event.description = "Awesome description"
      event.name = "Uniq Name"
      event.location = "Las Vegas"
      expect(event.ready_to_publish?).to eq true
    end
  end

  describe '.missing_fields' do
    let(:event){GroupEvent.new}
    it "gives the list of missing fields" do
      expect(event.missing_fields.sort).to eq(GroupEvent::REQUIRED_FIELDS_TO_PUBLISH.sort)
    end

    it "gives the list of remaining fields missing" do
      event.name = "wow name"
      event.description = "description here"
      remaining_fields = GroupEvent::REQUIRED_FIELDS_TO_PUBLISH - ["name", "description"]
      expect(event.missing_fields.sort).to eq(remaining_fields.sort)
    end
  end

  describe '.publish' do
    let(:event){GroupEvent.new}

    context "can be published when is ready_to_publish" do
      before{
        event.name = "my event"
        event.description = "my description"
        event.location = "new york city"
        event.start_date = Time.zone.now
        event.end_date = Time.zone.now + 5.days
        event.publish 
      }
      it{expect(event.ready_to_publish?).to eq true}
      it{expect(event.published?).to eq true}
      it{expect(event.state).to eq 'published'}

    end

    context "can not be published when is not ready_to_publish" do
      it{expect{event.publish}.to raise_error AASM::InvalidTransition}
      it{expect(event.ready_to_publish?).to eq false}
    end
  end

  describe 'auto populate event date related fields' do
    context "start date and duration provided" do
      let(:event){
        event = GroupEvent.create!( start_date: Time.parse("Wed, 21 Jun 2017").to_date,
                   duration_days: 4,
                   name: "Event awesome name",
                   description: "totally got it"
                 )
      }
      it{expect(event.end_date).to eq(Time.parse("Sat, 24 Jun 2017").to_date)}
    end

    context "end date and duration provided" do
      let(:event){

        event = GroupEvent.create!( end_date: Time.parse("Wed, 21 Jun 2017").to_date,
                   duration_days: 4,
                   name: "Event awesome name",
                   description: "totally got it"
                 )
      }
      it{expect(event.start_date).to eq(Time.parse("Sun, 18 Jun 2017").to_date)}
    end

    context "end_date and start_date" do
      let(:event){

        event = GroupEvent.create!( end_date: Time.parse("Wed, 21 Jun 2017").to_date,
                   start_date: Time.parse("Wed, 15 Jun 2017").to_date,
                   name: "Event awesome name",
                   description: "totally got it"
                 )
      }
      it{expect(event.duration_days).to eq(7)}
    end
  end

  describe "validations" do
    context "invalid record" do
      let(:event){
        GroupEvent.new
      }
      it{expect(event).to_not be_valid}
      it "is not valid with just an start_date" do
        event.start_date = Time.zone.now.to_date
        expect(event).to_not be_valid
        expect(event.duration_days).to eq(nil)
        expect(event.end_date).to eq(nil)
      end
      it "is not valid with just an start_date" do
        event.start_date = nil
        event.end_date = Time.zone.now.to_date
        expect(event).to_not be_valid
        expect(event.duration_days).to eq(nil)
        expect(event.start_date).to eq(nil)
      end
      it "is not valid with just duration_days" do
        event.start_date = nil
        event.end_date = nil
        event.duration_days = 5
        expect(event).to_not be_valid
        expect(event.end_date).to eq(nil)
        expect(event.start_date).to eq(nil)
      end
      it "is not valid without, duration, start and end date" do
        event.start_date = nil
        event.end_date = nil
        event.duration_days = nil
        expect(event).to_not be_valid
      end

      it "is not valid if start_date is greater than end_date" do
        event.start_date = Time.zone.now.to_date + 10.days
        event.end_date = event.start_date - 4.days
        event.duration_days = nil
        expect(event).to_not be_valid
      end
      it "is not valid if duration_days is zero" do
        event.start_date = Time.zone.now.to_date + 10.days
        event.duration_days = 0
        expect(event).to_not be_valid
      end
    end
  end

end