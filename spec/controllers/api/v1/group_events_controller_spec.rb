require "rails_helper"


RSpec.describe Api::V1::GroupEventsController, :type => :controller do
  describe "POST #create" do
    let(:group_event_attrs){ FactoryGirl.attributes_for(:group_event) }
    context "successful created a group event" do
      before{post :create, params: {group_event: group_event_attrs}}
      it{ expect(response).to be_success }
      it{ expect(response).to have_http_status(201) }
      it{ expect(assigns(:group_event)).to be_persisted}
    end

    context "Unsuccessful group event creation" do
      before{ post :create, params: {group_event: {start_date: Time.zone.now.to_date}}}
      it{ expect(response).to have_http_status(422) }
      it{ expect(JSON.parse(response.body)).to include("errors")}
      it{ expect(JSON.parse(response.body)["meta"]).to include("fields_errors")}
    end
  end

  describe "PUT #update" do
    let(:group_event){ FactoryGirl.create(:group_event) }
    context "successful updated a group event, start date and duration sent", focus: true do
      before{put :update, params: {id: group_event.id, group_event: {start_date: "2017-06-18", duration_days: 3}}}
      it{ expect(response).to be_success }
      it{ expect(response).to have_http_status(200) }
      it{ expect(assigns(:group_event).start_date).to eq(Time.parse("2017-06-18").to_date)}
      it{ expect(assigns(:group_event).duration_days).to eq(3)}
      it{ expect(assigns(:group_event).end_date).to eq(Time.parse("2017-06-20").to_date)}
    end

    context "successful updated a group event, end date and duration sent", focus: true do
      before{put :update, params: {id: group_event.id, group_event: {end_date: "2017-06-20", duration_days: 3}}}
      it{ expect(response).to be_success }
      it{ expect(response).to have_http_status(200) }
      it{ expect(assigns(:group_event).start_date).to eq(Time.parse("2017-06-18").to_date)}
      it{ expect(assigns(:group_event).duration_days).to eq(3)}
      it{ expect(assigns(:group_event).end_date).to eq(Time.parse("2017-06-20").to_date)}
    end

    context "successful updated a group event, only duration sent, but event has already start date", focus: true do
      before{put :update, params: {id: group_event.id, group_event: {end_date: "2017-06-20", duration_days: 3}}}
      it{ expect(response).to be_success }
      it{ expect(response).to have_http_status(200) }
      it{ expect(assigns(:group_event).start_date).to eq(Time.parse("2017-06-18").to_date)}
      it{ expect(assigns(:group_event).duration_days).to eq(3)}
      it{ expect(assigns(:group_event).end_date).to eq(Time.parse("2017-06-20").to_date)}
    end

    context "Unsuccessful group event creation" do
      before{ post :create, params: {group_event: {start_date: Time.zone.now.to_date}}}
      it{ expect(response).to have_http_status(422) }
      it{ expect(JSON.parse(response.body)).to include("errors")}
      it{ expect(JSON.parse(response.body)["meta"]).to include("fields_errors")}
    end
  end

  describe "GET #show" do
    let(:group_event){FactoryGirl.create(:group_event)}
    context "found group event" do
      before{ get :show, params: {id: group_event.id}}
      it{ expect(response).to be_success }
      it{ expect(response).to have_http_status(200) }
      it{ expect(assigns(:group_event).id).to eq(group_event.id)}
    end

    context "not found group event" do
      before{ get :show, params: {id: 54434}}
      it{ expect(response).to have_http_status(404) }
      it{ expect(JSON.parse(response.body)).to include("errors")}
    end
  end

  describe "GET #index" do
    context "retrieving all records" do
      before{FactoryGirl.create_list(:group_event, 14)}
      before{ get :index }
      it{ expect(assigns(:group_events).count).to eq(14) }
      it{ expect(response).to have_http_status(200) }
    end
  end

  describe "DELETE #destroy" do
    context "successfully marked as deleted" do
      let(:group_event){FactoryGirl.create(:group_event)}
      before{ delete :destroy, params: {id: group_event.id}}
      it{ expect(assigns(:group_event).deleted?).to eq true }
      it{ expect(assigns(:group_event)).to be_persisted }
    end
  end

  describe "POST #publish" do
    context "Group event could be published" do
      let(:group_event){FactoryGirl.create(:group_event, location: "New York")}
      before{ post :publish, params: {id: group_event.id}}
      it{ expect(assigns(:group_event).published?).to eq true }
      # it{ expect(response).to have_http_status(200) }

    end
    context "Group Event could not be published" do
      let(:group_event){FactoryGirl.create(:group_event)}
      before{ post :publish, params: {id: group_event.id}}
      it{ expect(assigns(:group_event).published?).to eq false }
      it{ expect(response).to have_http_status(500) }
    end
  end

  describe "POST #recover" do
    context "Group event could be recovered" do
      let(:group_event){FactoryGirl.create(:group_event, location: "New York")}
      before{ group_event.mark_as_deleted! ; post :recover, params: {id: group_event.id}}
      it{ expect(assigns(:group_event).draft?).to eq true }
      it{ expect(response).to have_http_status(200) }
    end

    context "Group Event could not be recovered" do
      let(:group_event){FactoryGirl.create(:group_event)}
      before{ post :recover, params: {id: group_event.id}}
      it{ expect(assigns(:group_event).draft?).to eq true }
      it{ expect(response).to have_http_status(500) }
    end
  end
end