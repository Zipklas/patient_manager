require 'swagger_helper'

RSpec.describe 'patients API', type: :request do
  path '/patients' do
    get('list patients') do
      tags 'Patients'
      description 'Get list of patients with filtering and pagination'
      parameter name: :full_name, in: :query, type: :string, required: false, description: 'Filter by full name (first, last, or middle name)'
      parameter name: :gender, in: :query, type: :string, required: false, description: 'Filter by gender'
      parameter name: :start_age, in: :query, type: :integer, required: false, description: 'Filter by minimum age'
      parameter name: :end_age, in: :query, type: :integer, required: false, description: 'Filter by maximum age'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Number of patients per page (default: 10)'
      parameter name: :offset, in: :query, type: :integer, required: false, description: 'Offset for pagination (default: 0)'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            patients: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  first_name: { type: :string },
                  last_name: { type: :string },
                  middle_name: { type: :string },
                  birthday: { type: :string, format: 'date' },
                  gender: { type: :string },
                  height: { type: :number },
                  weight: { type: :number },
                  created_at: { type: :string, format: 'date-time' },
                  updated_at: { type: :string, format: 'date-time' },
                  doctors: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        first_name: { type: :string },
                        last_name: { type: :string },
                        middle_name: { type: :string },
                        created_at: { type: :string, format: 'date-time' },
                        updated_at: { type: :string, format: 'date-time' }
                      }
                    }
                  }
                }
              }
            },
            total_count: { type: :integer },
            filtered_count: { type: :integer },
            pagination: {
              type: :object,
              properties: {
                limit: { type: :integer },
                offset: { type: :integer },
                total: { type: :integer }
              }
            }
          }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    post('create patient') do
      tags 'Patients'
      description 'Create a new patient with optional doctor assignments'
      consumes 'application/json'
      parameter name: :patient, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          middle_name: { type: :string },
          birthday: { type: :string, format: 'date' },
          gender: { type: :string },
          height: { type: :number },
          weight: { type: :number },
          doctor_ids: {
            type: :array,
            items: { type: :integer },
            description: 'Array of doctor IDs to assign to the patient'
          }
        },
        required: [ 'first_name', 'last_name', 'birthday', 'gender', 'height', 'weight' ]
      }

      response(201, 'patient created') do
        let!(:doctor1) { Doctor.create(first_name: 'Doctor1', last_name: 'Smith') }
        let!(:doctor2) { Doctor.create(first_name: 'Doctor2', last_name: 'Johnson') }
        let(:patient) {
          {
            first_name: 'John',
            last_name: 'Doe',
            middle_name: 'Smith',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180.5,
            weight: 75.2,
            doctor_ids: [ doctor1.id, doctor2.id ]
          }
        }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(422, 'invalid request') do
        let(:patient) { { first_name: '' } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/patients/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Patient ID'

    get('show patient') do
      tags 'Patients'
      description 'Get patient by ID with additional calculated fields'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            id: { type: :integer },
            first_name: { type: :string },
            last_name: { type: :string },
            middle_name: { type: :string },
            birthday: { type: :string, format: 'date' },
            gender: { type: :string },
            height: { type: :number },
            weight: { type: :number },
            age: { type: :integer },
            bmi: { type: :number },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' },
            doctors: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  first_name: { type: :string },
                  last_name: { type: :string },
                  middle_name: { type: :string },
                  created_at: { type: :string, format: 'date-time' },
                  updated_at: { type: :string, format: 'date-time' }
                }
              }
            }
          }

        let!(:doctor) { Doctor.create(first_name: 'Doctor', last_name: 'Smith') }
        let(:id) {
          patient = Patient.create(
            first_name: 'John',
            last_name: 'Doe',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180,
            weight: 75
          )
          patient.doctors << doctor
          patient.id
        }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'patient not found') do
        let(:id) { 'invalid' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    patch('update patient') do
      tags 'Patients'
      description 'Update patient with optional doctor assignments'
      consumes 'application/json'
      parameter name: :patient, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          middle_name: { type: :string },
          birthday: { type: :string, format: 'date' },
          gender: { type: :string },
          height: { type: :number },
          weight: { type: :number },
          doctor_ids: {
            type: :array,
            items: { type: :integer },
            description: 'Array of doctor IDs to assign to the patient'
          }
        }
      }

      response(200, 'successful') do
        let!(:doctor1) { Doctor.create(first_name: 'Doctor1', last_name: 'Smith') }
        let!(:doctor2) { Doctor.create(first_name: 'Doctor2', last_name: 'Johnson') }
        let(:id) {
          Patient.create(
            first_name: 'John',
            last_name: 'Doe',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180,
            weight: 75
          ).id
        }
        let(:patient) {
          {
            first_name: 'Jane',
            weight: 80.0,
            doctor_ids: [ doctor1.id, doctor2.id ]
          }
        }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(422, 'invalid request') do
        let(:id) {
          Patient.create(
            first_name: 'John',
            last_name: 'Doe',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180,
            weight: 75
          ).id
        }
        let(:patient) { { first_name: '' } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    put('update patient') do
      tags 'Patients'
      description 'Update patient with optional doctor assignments'
      consumes 'application/json'
      parameter name: :patient, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          middle_name: { type: :string },
          birthday: { type: :string, format: 'date' },
          gender: { type: :string },
          height: { type: :number },
          weight: { type: :number },
          doctor_ids: {
            type: :array,
            items: { type: :integer },
            description: 'Array of doctor IDs to assign to the patient'
          }
        }
      }

      response(200, 'successful') do
        let!(:doctor1) { Doctor.create(first_name: 'Doctor1', last_name: 'Smith') }
        let!(:doctor2) { Doctor.create(first_name: 'Doctor2', last_name: 'Johnson') }
        let(:id) {
          Patient.create(
            first_name: 'John',
            last_name: 'Doe',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180,
            weight: 75
          ).id
        }
        let(:patient) {
          {
            first_name: 'Jane',
            last_name: 'Smith',
            birthday: '1990-01-01',
            gender: 'female',
            height: 165.0,
            weight: 60.0,
            doctor_ids: [ doctor1.id, doctor2.id ]
          }
        }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(422, 'invalid request') do
        let(:id) {
          Patient.create(
            first_name: 'John',
            last_name: 'Doe',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180,
            weight: 75
          ).id
        }
        let(:patient) { { first_name: '' } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    delete('delete patient') do
      tags 'Patients'
      description 'Delete patient'

      response(204, 'successful') do
        let(:id) {
          Patient.create(
            first_name: 'John',
            last_name: 'Doe',
            birthday: '1990-01-01',
            gender: 'male',
            height: 180,
            weight: 75
          ).id
        }

        run_test!
      end

      response(404, 'patient not found') do
        let(:id) { 'invalid' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
