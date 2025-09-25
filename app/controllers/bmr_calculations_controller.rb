class BmrCalculationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # POST /bmr_calculations/calculate
  # Расчет BMR для пациента
  def calculate
    patient = Patient.find(params[:patient_id])
    formula = params[:formula] || 'mifflin'

    bmr_value = BmrCalculatorService.new(patient, formula).calculate_and_save

    render json: success_response(patient, formula, bmr_value)

  rescue BmrCalculatorService::ValidationError => e
    render json: { error: e.message }, status: :bad_request
  rescue BmrCalculatorService::CalculationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Пациент не найден" }, status: :not_found
  end

  # GET /bmr_calculations/history
  def history
    patient = Patient.find(params[:patient_id])
    history_service = BmrHistoryService.new(
      patient, 
      limit: params[:limit], 
      offset: params[:offset]
    )

    render json: history_service.history

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Пациент не найден" }, status: :not_found
  end

  private

  def success_response(patient, formula, bmr_value)
    {
      patient_id: patient.id,
      patient_name: patient.full_name,
      formula: formula,
      bmr: bmr_value,
      calculation_date: Date.current
    }
  end
end

