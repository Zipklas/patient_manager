
class BmrHistoryService
  def initialize(patient, limit: 10, offset: 0)
    @patient = patient
    @limit = limit.to_i.positive? ? limit.to_i : 10
    @offset = offset.to_i.positive? ? offset.to_i : 0
  end

  def history
    {
      patient_id: @patient.id,
      patient_name: @patient.full_name,
      total_calculations: @patient.bmr_calculations.count,
      calculations: calculations_data,
      pagination: pagination_info
    }
  end

  private

  def calculations_data
    @patient.bmr_calculations
            .order(calculation_date: :desc, created_at: :desc)
            .limit(@limit)
            .offset(@offset)
            .map do |calc|
      {
        id: calc.id,
        formula: calc.formula,
        bmr_value: calc.bmr_value,
        calculation_date: calc.calculation_date,
        created_at: calc.created_at
      }
    end
  end

  def pagination_info
    {
      limit: @limit,
      offset: @offset,
      total: @patient.bmr_calculations.count
    }
  end
end