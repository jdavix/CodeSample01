class GroupEventSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :created_at, :updated_at, :location, :description, :name
end