class BmrCalculatorService
  FORMULAS = {
    'mifflin' => {
      male: ->(weight, height, age) { (10 * weight + 6.25 * height - 5 * age + 5).round(2) },
      female: ->(weight, height, age) { (10 * weight + 6.25 * height - 5 * age - 161).round(2) }
    },
    'harris' => {
      male: ->(weight, height, age) { (88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)).round(2) },
      female: ->(weight, height, age) { (447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)).round(2) }
    }
  }.freeze

  def initialize(patient, formula = 'mifflin')
    @patient = patient
    @formula = formula
  end

  def calculate
    validate_input
    formula = FORMULAS[@formula]
    formula[@patient.gender.to_sym].call(@patient.weight, @patient.height, @patient.age)
  end

  def calculate_and_save
    bmr_value = calculate
    BmrCalculation.create!(
      patient: @patient,
      formula: @formula,
      bmr_value: bmr_value,
      calculation_date: Date.current
    )
    bmr_value
  rescue => e
    raise CalculationError, "BMR calculation failed: #{e.message}"
  end

  private

  def validate_input
    raise ValidationError, "Patient not found" unless @patient
    raise ValidationError, "Formula must be 'mifflin' or 'harris'" unless FORMULAS.key?(@formula)
    raise ValidationError, "Patient data incomplete" unless @patient.height && @patient.weight && @patient.age
  end

  class ValidationError < StandardError; end
  class CalculationError < StandardError; end
end