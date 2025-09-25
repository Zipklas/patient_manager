class DoctorsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # GET /doctors или /doctors?limit=10&offset=0
  def index
    doctors = Doctor.paginated(params[:limit], params[:offset])
    
    render json: {
      doctors: doctors.as_json(include: :patients),
      total_count: Doctor.count,
      pagination: {
        limit: params[:limit] || 10,
        offset: params[:offset] || 0
      }
    }
  end

  # GET /doctors/1
  def show
    doctor = Doctor.find(params[:id])
    render json: doctor.as_json(include: :patients)
  end

  # POST /doctors
  def create
    doctor = Doctor.new(doctor_params)
    
    if doctor.save
      render json: doctor, status: :created
    else
      render json: { errors: doctor.errors.full_messages }, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /doctors/1
  def update
    doctor = Doctor.find(params[:id])
    
    if doctor.update(doctor_params)
      render json: doctor
    else
      render json: { errors: doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /doctors/1
  def destroy
    doctor = Doctor.find(params[:id])
    doctor.destroy
    head :no_content
  end

   private

  def doctor_params
    params.require(:doctor).permit(:first_name, :last_name, :middle_name)
  end
  

end
