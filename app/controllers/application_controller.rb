class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from AASM::InvalidTransition, with: :invalid_aasm_transition

  # Response structure:
  #   {
  #     data: ...,
  #     meta: {
  #       message: string
  #     }
  #   }
  # method for returning a successful response and preserve the same json layout over all responses
  def standard_response(message: "", data: {}, status: 200, meta: {}, serializer: nil)
    meta.merge!(message: message)

    if(data.is_a?(Array) || data.is_a?(ActiveRecord::Relation))
      data = data.map{ |item| serializer.new(item).as_json }
    elsif !data.is_a? Hash
      data = serializer.new(data).as_json
    end

    render(json: {"meta" => meta }.merge({data: data}).to_json,
           status: status)
  end


  # Error response structure:
  # {
  #   errors: message,
  #   meta: {
  #     fields_errors: fields_errors
  #   }
  # }
  #this is our standard json response render
  def error_response(message: nil, fields_errors: nil, status: 500)
    err = {
      errors: message,
      meta: {
        fields_errors: fields_errors
      }
    }
    render(json: err.to_json, status: status)
  end

  #method used by the rescue of the 404 error
  def record_not_found
    error_response(message: "record not found", status: 404)
  end

  def invalid_aasm_transition(error)
    error_response(message: error.message)
  end

end
