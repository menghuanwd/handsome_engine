module HandsomeEngine::BaseModelPlugin
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { order(created_at: :desc) }
    
    scope :today, -> { where(created_at: Time.zone.now.all_day) }
    scope :yesterday, -> { where(created_at: Time.zone.yesterday.all_day) }
    
    scope :this_week, -> { where(created_at: Time.zone.now.all_week) }
    scope :last_week, -> { where(created_at: (Time.zone.now - 1.week).all_week) }

    scope :last_7_days, -> { where(created_at: (Time.zone.now - 1.week).beginning_of_day..Time.zone.now) }
    
    scope :this_month, -> { where(created_at: Time.zone.now.all_month) }
    scope :last_month, -> { where(created_at: (Time.zone.now - 1.month).all_month) }
    
    scope :this_year, -> { where(created_at: Time.zone.now.all_year) }
    scope :last_year, -> { where(created_at: (Time.zone.now - 1.year).all_year) }

    scope :created_after, ->(time) { where("created_at > ?", time) if time.present? }
    scope :created_before, ->(time) { where("created_at < ?", time) if time.present? }
    scope :created_between, -> (start_at, end_at) { where(created_at: start_at .. end_at) if start_at.present? && end_at.present? }

    scope :like, -> (column, content) { where("#{column} LIKE ?", "%#{content}%") if content.present? }
  end

end
