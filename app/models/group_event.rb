class GroupEvent < ApplicationRecord
  include AASM
  REQUIRED_FIELDS_TO_PUBLISH=["name", "description", "location"]

  attribute :duration_days, :integer

  validate :dates_presence_validation
  validate :end_date_position
  validates :duration_days, presence:true, numericality: {greater_than: 0, only_integer: true }


  before_validation :setup_date_fields

  after_initialize :setup_duration_days

  aasm column: :state do # default column: aasm_state
    state :draft, :initial => true
    state :published
    state :deleted

    event :publish do
      transitions :from => :draft, :to => :published, guard: :check_completeness
    end

    event :recover do
      transitions :from => :deleted, :to => :draft
    end

    event :mark_as_deleted do
      transitions :from => [:draft, :published], :to => :deleted
    end
  end

  def ready_to_publish?
    self.missing_fields.size == 0
  end

  def missing_fields
    fields = REQUIRED_FIELDS_TO_PUBLISH
    fields = fields.map{ |field|  field if !self.send((field+"?").to_sym) }
    fields.compact
  end

  private
    def setup_date_fields
      #Order of calling below methods matters
      set_duration_days
      ensure_end_date
      ensure_start_date
    end

    #set_duration_days calculates how many duration days are between start_date and end_date
    #I add 1 day to the result to include the start_date as part of the event duration date. 
    def set_duration_days
      if !self.duration_days? && self.end_date && self.start_date
        self.duration_days = ((self.end_date - self.start_date) + 1)
      elsif self.duration_days_changed? && self.start_date_changed? && !self.end_date_changed?
        self.end_date = nil
      elsif self.duration_days_changed? && !self.start_date_changed? && self.end_date_changed?
        self.start_date = nil
      elsif self.duration_days_changed? && !self.start_date_changed? && !self.end_date_changed?
        self.end_date = nil
      end

    end

    #This method updates duration day, when start date and end date are received. 
    def setup_duration_days
      if self.end_date && self.start_date
        self.duration_days = ((self.end_date - self.start_date) + 1)
      end
    end

    #ensure_endate calculates end_date in case the user provides duration_days and no end_date.
    def ensure_end_date
      if self.duration_days? && !self.end_date? && self.start_date?
        #Extract 1 day since my convention is to count the start_date as part of the total duration days. 
        self.end_date = self.start_date + (self.duration_days - 1).days
      end
    end

    #by default subsctraction gives how many days are between the two days, but we need to include both days
    #Example, Tue, 20 Jun 2017 minus 4 days gives 
    def ensure_start_date
      if self.duration_days? && !self.start_date? && self.end_date?
        self.start_date = self.end_date - (self.duration_days - 1).days
      end
    end


    def end_date_position
      if self.start_date? && self.end_date? && self.start_date > self.end_date
        self.errors.add(:start_date, "can't be greater than end_date")
      end
    end

    def dates_presence_validation
      if self.start_date? && !self.end_date? && !self.duration_days?
        self.errors.add(:end_date, "can't be blank, Please provide end date value or duration days")
      end

      if self.end_date? && !self.start_date? && !self.duration_days?
        self.errors.add(:start_date, "can't be blank, Please provide start date value or duration days")
      end

      if !self.end_date? && !self.start_date?
        self.errors.add(:start_date, "can't be blank")
        self.errors.add(:end_date, "can't be blank")
      end
    end

    #stop to publish the event in case the event is not complete
    def check_completeness
      if !self.ready_to_publish?
        return false
      end
      return true
    end
end