class Api::V1::GroupEventsController < ApplicationController

  #returns all records, no pagination
  def index
    @group_events = GroupEvent.all
    standard_response(message: "Group event found", data: @group_events, serializer: GroupEventSerializer)
  end

  def show
    @group_event = find_group_event
    standard_response(message: "Group event found", data: @group_event, serializer: GroupEventSerializer)
  end

  def create
    @group_event = GroupEvent.new(group_event_params)
    if @group_event.save
      standard_response(message: "Group Event created successfully", data: @group_event, serializer: GroupEventSerializer, status: 201)
    else
      response_with_unprocessable
    end
  end

  def update
    @group_event = find_group_event

    if @group_event.update_attributes(group_event_params)
      
      standard_response(message: "Group Event updated successfully", data: @group_event, serializer: GroupEventSerializer)
    else
      response_with_unprocessable
    end
  end

  def publish
    @group_event = find_group_event
    

    if @group_event.ready_to_publish?
      @group_event.publish!
      standard_response(message: "Group event published successfully")
    else
      error_response( message: "Group event can not be publish, missing fields #{@group_event.missing_fields}"
                    )
    end
  end

  def destroy
    @group_event = find_group_event
    @group_event.mark_as_deleted!
    standard_response(message: "Group event deleted successfully", data: @group_event, serializer: GroupEventSerializer)
  end

  def recover
    @group_event = find_group_event
    @group_event.recover!
    standard_response(message: "Group event is back to draft state", data: @group_event, serializer: GroupEventSerializer)
  end

  private
    def group_event_params
      params.require(:group_event).permit(
        :start_date,
        :end_date,
        :duration_days,
        :name,
        :description,
        :location
      )
    end

    #This method with some enhancements can be moved to parent class
    def response_with_unprocessable
      error_response( message: @group_event.errors.full_messages.to_sentence,
                      fields_errors: @group_event.errors.full_messages,
                      status: 422
                    )
    end

    def find_group_event
      GroupEvent.find(params[:id])
    end
end