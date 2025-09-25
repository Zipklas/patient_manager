require 'swagger_helper'

RSpec.describe 'bmr_calculation', type: :request do

  path '/bmr_calculations/calculate' do

    post('Расчитать BMR') do
      tags 'BMR Calculations'
      description 'Calculate BMR (Basal Metabolic Rate) for a patient'
      consumes 'application/json'
      parameter name: :calculation_params, in: :body, schema: {
        type: :object,
        properties: {
          patient_id: { type: :integer, description: 'ID of the patient' },
          formula: { 
            type: :string, 
            enum: ['mifflin', 'harris_benedict'],
            description: 'Formula to use for calculation (default: mifflin)'
          }
        },
        required: ['patient_id']
      }

      response(200, 'successful calculation') do
        schema type: :object,
          properties: {
            patient_id: { type: :integer },
            patient_name: { type: :string },
            formula: { type: :string },
            bmr: { type: :number, format: :float },
            calculation_date: { type: :string, format: 'date' }
          },
          example: {
            patient_id: 1,
            patient_name: 'John Doe',
            formula: 'mifflin',
            bmr: 1650.5,
            calculation_date: '2024-01-15'
          }

        let(:calculation_params) { 
          { 
            patient_id: 1,
            formula: 'mifflin'
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

      response(400, 'validation error') do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:calculation_params) { 
          { 
            patient_id: 1,
            formula: 'invalid_formula'
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

      response(404, 'patient not found') do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:calculation_params) { 
          { 
            patient_id: 999999,
            formula: 'mifflin'
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

      response(422, 'calculation error') do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:calculation_params) { 
          { 
            patient_id: 1,
            formula: 'mifflin'
          } 
        }

        before do
          allow_any_instance_of(BmrCalculatorService).to receive(:calculate_and_save)
            .and_raise(BmrCalculatorService::CalculationError, 'Calculation failed')
        end

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

  path '/bmr_calculations/history' do

    get('История BMR') do
      tags 'BMR Calculations'
      description 'Get BMR calculation history for a patient'
      parameter name: :patient_id, in: :query, type: :integer, required: true, description: 'ID of the patient'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Number of records per page (default: 10)'
      parameter name: :offset, in: :query, type: :integer, required: false, description: 'Offset for pagination (default: 0)'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            calculations: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  patient_id: { type: :integer },
                  formula: { type: :string },
                  bmr_value: { type: :number, format: :float },
                  calculation_date: { type: :string, format: 'date' },
                  created_at: { type: :string, format: 'date-time' },
                  updated_at: { type: :string, format: 'date-time' }
                }
              }
            },
            total_count: { type: :integer },
            pagination: {
              type: :object,
              properties: {
                limit: { type: :integer },
                offset: { type: :integer },
                total: { type: :integer }
              }
            }
          },
          example: {
            calculations: [
              {
                id: 1,
                patient_id: 1,
                formula: 'mifflin',
                bmr_value: 1650.5,
                calculation_date: '2024-01-15',
                created_at: '2024-01-15T10:30:00Z',
                updated_at: '2024-01-15T10:30:00Z'
              }
            ],
            total_count: 1,
            pagination: {
              limit: 10,
              offset: 0,
              total: 1
            }
          }

        let(:patient_id) { 1 }
        let(:limit) { 10 }
        let(:offset) { 0 }

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
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:patient_id) { 999999 }

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