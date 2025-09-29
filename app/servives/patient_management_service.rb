# app/services/patient_management_service.rb
class PatientManagementService
  def self.create(patient_attributes)
    patient = Patient.new(patient_attributes.except(:doctor_ids))

    if patient.save
      assign_doctors(patient, patient_attributes[:doctor_ids]) if patient_attributes[:doctor_ids]
      patient
    else
      patient
    end
  end

  def self.update(patient, patient_attributes)
    if patient.update(patient_attributes.except(:doctor_ids))
      assign_doctors(patient, patient_attributes[:doctor_ids]) if patient_attributes[:doctor_ids]
      patient
    else
      patient
    end
  end

  private

  def self.assign_doctors(patient, doctor_ids)
    patient.doctors = Doctor.where(id: doctor_ids)
  end
end
