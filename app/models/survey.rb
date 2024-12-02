class Survey < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  validates :title, presence: true, length: { maximum: 255 }
  validates :starting_date, :closing_date, presence: true
  validate :end_date_after_start_date
  scope :active, -> { where(status: 'active') }

  private

  def end_date_after_start_date
    return if closing_date.blank? || starting_date.blank?
    errors.add(:closing_date, "must be after the starting date") if closing_date <= starting_date
  end
end
