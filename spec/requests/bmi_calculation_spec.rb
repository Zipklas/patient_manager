require 'swagger_helper'

RSpec.describe 'bmi_calculation', type: :request do
  path '/bmi_calculations/calculate' do
    post 'Рассчитать BMI пациента' do
      tags 'BMI Расчет'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :bmi_calculation, in: :body, schema: {
        type: :object,
        properties: {
          patient_id: { type: :integer, example: 1 }
        },
        required: ['patient_id']
      }

      response '200', 'BMI успешно рассчитан' do
        let(:bmi_calculation) { { patient_id: 1 } }
        
        examples 'application/json' => {
          patient_id: 1,
          patient_name: "Иван Петров",
          weight: 70,
          height: 175,
          bmi: 22.86,
          category: "Normal weight"
        }

        run_test!
      end

      response '404', 'Пациент не найден' do
        let(:bmi_calculation) { { patient_id: 999 } }
        
        examples 'application/json' => {
          error: "Пациент не найден"
        }

        run_test!
      end

      response '503', 'Внешний сервис недоступен' do
        let(:bmi_calculation) { { patient_id: 1 } }
        
        examples 'application/json' => {
          error: "Не удалось получить данные от внешнего сервиса"
        }

        run_test!
      end
    end
  end
end
