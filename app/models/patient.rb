class Patient < ApplicationRecord
  has_many :appointments
  has_many :doctors, through: :appointments
  
  has_many :bmr_calculations, dependent: :destroy

  validates :first_name, :last_name, :birthday, :gender, :height, :weight, presence: true
  validates :height, :weight, numericality: { greater_than: 0 }
  validates :gender, inclusion: { in: %w[male female] }
  
  # Ограничение уникальности
  validates_uniqueness_of :first_name, scope: [:last_name, :middle_name, :birthday]

  # Метод для расчета возраста
  def age
     AgeCalculatorService.calculate(birthday)
  end

  def full_name
    "#{first_name} #{last_name} #{middle_name}".strip
  end

 
  # Оставляем только простые scopes если они действительно нужны
  scope :by_gender, ->(gender) { where(gender: gender) if gender.present? }
  scope :recent, -> { order(created_at: :desc) }

end
