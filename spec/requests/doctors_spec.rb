require 'swagger_helper'

RSpec.describe 'doctors', type: :request do

  path '/doctors' do

    get('list doctors') do
      tags 'Doctors'
      description 'Get list of doctors with pagination'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Number of doctors per page (default: 10)'
      parameter name: :offset, in: :query, type: :integer, required: false, description: 'Offset for pagination (default: 0)'
      
      response(200, 'successful') do
        schema type: :object,
          properties: {
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
                  updated_at: { type: :string, format: 'date-time' },
                  patients: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        first_name: { type: :string },
                        last_name: { type: :string },
                        middle_name: { type: :string },
                        phone: { type: :string },
                        created_at: { type: :string, format: 'date-time' },
                        updated_at: { type: :string, format: 'date-time' }
                      }
                    }
                  }
                }
              }
            },
            total_count: { type: :integer },
            pagination: {
              type: :object,
              properties: {
                limit: { type: :integer },
                offset: { type: :integer }
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

    post('create doctor') do
      tags 'Doctors'
      description 'Create a new doctor'
      consumes 'application/json'
      parameter name: :doctor, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          middle_name: { type: :string }
        },
        required: ['first_name', 'last_name']
      }

      response(201, 'doctor created') do
        let(:doctor) { { first_name: 'John', last_name: 'Doe', middle_name: 'Smith' } }

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
        let(:doctor) { { first_name: '' } }

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

  path '/doctors/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Doctor ID'

    get('show doctor') do
      tags 'Doctors'
      description 'Get doctor by ID'
      
      response(200, 'successful') do
        let(:id) { Doctor.create(first_name: 'John', last_name: 'Doe').id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'doctor not found') do
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

    patch('update doctor') do
      tags 'Doctors'
      description 'Update doctor'
      consumes 'application/json'
      parameter name: :doctor, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          middle_name: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:id) { Doctor.create(first_name: 'John', last_name: 'Doe').id }
        let(:doctor) { { first_name: 'Jane' } }

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
        let(:id) { Doctor.create(first_name: 'John', last_name: 'Doe').id }
        let(:doctor) { { first_name: '' } }

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

    put('update doctor') do
      tags 'Doctors'
      description 'Update doctor'
      consumes 'application/json'
      parameter name: :doctor, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          middle_name: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:id) { Doctor.create(first_name: 'John', last_name: 'Doe').id }
        let(:doctor) { { first_name: 'Jane', last_name: 'Smith' } }

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
        let(:id) { Doctor.create(first_name: 'John', last_name: 'Doe').id }
        let(:doctor) { { first_name: '' } }

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

    delete('delete doctor') do
      tags 'Doctors'
      description 'Delete doctor'

      response(204, 'successful') do
        let(:id) { Doctor.create(first_name: 'John', last_name: 'Doe').id }

        run_test!
      end

      response(404, 'doctor not found') do
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