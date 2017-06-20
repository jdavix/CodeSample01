class GroupEvent < ApplicationRecord
  include AASM

  attribute :duration_days, :integer

  validates :duration_days, presence:true, numericality: {greater_than: 0, only_integer: true }
  validates :end_date, date: {after_or_equal_to:  :start_date}
  validates :start_date
  validate :dates_presence_validation

  before_validation :set_duration_days
  before_validation :ensure_end_date
  before_validation :ensure_start_date


  aasm column: :state do # default column: aasm_state
    state :draft, :initial => true
    state :published
    state :deleted

    event :publish do
      transitions :from => :draft, :to => :published
    end

    event :recover do
      transitions :from => :deleted, :to => :draft
    end

    event :mark_as_deleted do
      transitions :from => [:draft, :published], :to => :deleted
    end
  end


  private

    #set_duration_days calculates how many duration days are between start_date and end_date
    #I add 1 day to the result to include the start_date as part of the event duration date. 
    def set_duration_days
      if self.end_date && self.start_date
        self.duration_days = (self.end_date - self.start_date) + 1
      end
    end

    #ensure_endate calculates end_date in case the user provides duration_days and no end_date.
    def ensure_end_date
      if self.duration_days? && !self.end_date? && self.start_date?
        #Extract 1 day since my convention is to count the start_date as part of the total duration days. 
        self.end_date = self.start_date + (self.duration_days - 1).days
      end
    end

    def ensure_start_date
      if self.duration_days? && !self.start_date? && self.end_date?
        self.start_date = self.end_date - (self.duration_days + 1).days
      end
    end

    def dates_presence_validation
      if self.start_date? && !self.end_date? && !self.duration_days?
        self.errors.add(:end_date, "End date can't be blank, Please provide end date value or duration days")
      end

      if self.end_date? && !self.start_date? && !self.duration_days?
        self.errors.add(:start_date, "Start date can't be blank, Please provide start date value or duration days")
      end

      if !self.end_date? && !self.start_date?
        self.errors.add(:start_date, "Start date can't be blank")
        self.errors.add(:end_date, "End date can't be blank")
      end
    end
end