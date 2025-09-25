class Doctor < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
  
  validates :first_name, :last_name, presence: true

   # Метод для пагинации
  def self.paginated(limit = 10, offset = 0)
    limit = limit.to_i.positive? ? limit.to_i : 10
    offset = offset.to_i.positive? ? offset.to_i : 0
    
    limit(limit).offset(offset)
  end


end
