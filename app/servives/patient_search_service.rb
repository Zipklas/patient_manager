class PatientSearchService
  DEFAULT_LIMIT = 10
  DEFAULT_OFFSET = 0

  def initialize(filters = {})
    @filters = filters
  end

  def call
    patients = Patient.all
    patients = filter_by_full_name(patients)
    patients = filter_by_gender(patients)
    patients = filter_by_age_range(patients)
    patients = apply_pagination(patients)
    
    patients
  end

  def results_with_metadata
    patients = call
    {
      patients: patients,
      total_count: patients.except(:limit, :offset).count,
      pagination: {
        limit: limit,
        offset: offset,
        total: Patient.count
      }
    }
  end

  private

  def filter_by_full_name(patients)
    return patients unless @filters[:full_name].present?
    
    query = @filters[:full_name]
    patients.where(
      "first_name ILIKE :query OR last_name ILIKE :query OR middle_name ILIKE :query", 
      query: "%#{query}%"
    )
  end

  def filter_by_gender(patients)
    return patients unless @filters[:gender].present?
    
    patients.where(gender: @filters[:gender])
  end

  def filter_by_age_range(patients)
    start_age = @filters[:start_age]
    end_age = @filters[:end_age]
    
    return patients unless start_age.present? || end_age.present?

    end_date = start_age.present? ? Date.current - start_age.to_i.years : Date.current
    start_date = end_age.present? ? Date.current - end_age.to_i.years : 100.years.ago
    
    patients.where(birthday: start_date..end_date)
  end

  def apply_pagination(patients)
    patients.limit(limit).offset(offset)
  end

  def limit
    @filters[:limit].to_i.positive? ? @filters[:limit].to_i : DEFAULT_LIMIT
  end

  def offset
    @filters[:offset].to_i.positive? ? @filters[:offset].to_i : DEFAULT_OFFSET
  end
end