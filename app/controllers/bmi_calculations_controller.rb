class BmiCalculationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'net/http'
  require 'uri'
  require 'json'

  # POST /bmi_calculations/calculate
  def calculate
    # Находим пациента
    patient = Patient.find(params[:patient_id])
    
    # Подготавливаем данные для внешнего API
    height_in_meters = patient.height / 100.0  # переводим см в метры
    
    # Вызываем внешнее API
    bmi_result = call_external_bmi_api(patient.weight, height_in_meters)
    
    if bmi_result
      render json: {
        patient_id: patient.id,
        patient_name: "#{patient.first_name} #{patient.last_name}",
        weight: patient.weight,
        height: patient.height,
        bmi: bmi_result['bmi'],
        category: bmi_result['Category'],
      }
    else
      render json: { error: "Не удалось получить данные от внешнего сервиса" }, status: :service_unavailable
    end
    
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Пациент не найден" }, status: :not_found
  end

  private

  def call_external_bmi_api(weight, height)
    # URL внешнего API
    url = "https://bmicalculatorapi.vercel.app/api/bmi/#{weight}/#{height}"
    uri = URI.parse(url)
    
    # Подготавливаем GET запрос
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    
    # Отправляем запрос
    response = http.request(request)
    
    if response.code == '200'
      data = JSON.parse(response.body)
    else
      Rails.logger.error "External BMI API returned error: #{response.code}"
      nil
    end
  rescue => e
    # Логируем ошибку, но не прерываем выполнение
    Rails.logger.error "External BMI API error: #{e.message}"
    nil
  end
  end