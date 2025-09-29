class PatientsController < ApplicationController
 skip_before_action :verify_authenticity_token
  # GET /patients
  def index
    search_service = PatientSearchService.new(filter_params)
    result = search_service.results_with_metadata

    render json: {
      patients: result[:patients].as_json(include: :doctors),
      total_count: result[:total_count],
      filtered_count: result[:patients].size,
      pagination: result[:pagination]
    }
  end

  # GET /patients/1
  def show
    patient = Patient.find(params[:id])
    render json: patient.as_json(
      include: :doctors,
      methods: [ :age, :bmi ]
    )
  end

# POST /patients
def create
  patient = PatientManagementService.create(patient_params)

  if patient.persisted?
    render json: patient.as_json(include: :doctors), status: :created
  else
    render json: { errors: patient.errors.full_messages }, status: :unprocessable_entity
  end
end

def update
  patient = Patient.find(params[:id])
  patient = PatientManagementService.update(patient, patient_params)

  if patient.valid?
    render json: patient.as_json(include: :doctors)
  else
    render json: { errors: patient.errors.full_messages }, status: :unprocessable_entity
  end
end

  # DELETE /patients/1
  def destroy
    patient = Patient.find(params[:id])
    patient.destroy
    head :no_content
  end

  private

  def patient_params
    params.require(:patient).permit(
      :first_name, :last_name, :middle_name,
      :birthday, :gender, :height, :weight,
      doctor_ids: []
    )
  end

  def filter_params
    params.permit(:full_name, :gender, :start_age, :end_age, :limit, :offset)
  end
end
