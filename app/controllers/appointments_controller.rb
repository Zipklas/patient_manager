class AppointmentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    appointment = Appointment.new(appointment_params)
    
    if appointment.save
      render json: appointment, status: :created
    else
      render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def appointment_params
    params.require(:appointment).permit(:patient_id, :doctor_id, :appointment_date)
  end
end