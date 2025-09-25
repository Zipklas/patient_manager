class BmrCalculation < ApplicationRecord
  belongs_to :patient

  # Валидации 
  validates :formula, presence: true, inclusion: { in: %w[mifflin harris] }
  validates :bmr_value, presence: true, numericality: { greater_than: 0 }
  validates :calculation_date, presence: true
end
