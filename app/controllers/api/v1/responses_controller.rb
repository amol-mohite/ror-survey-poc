class Api::V1::ResponsesController < ApplicationController
  before_action :find_survey
  before_action :validate_response, only: [:create]

  def create
    responses = params[:responses]
    survey_id = params[:survey_id]

    if survey_id.blank? || responses.blank?
      return render json: { error: 'Survey ID and responses are required' }, status: :bad_request
    end

    saved_responses = []
    dynamo_service = DynamoDbService.new('answers')

    responses.each do |response|
      question_id = response[:question_id]
      answer = response[:answer]

      next if question_id.blank? || answer.nil?
        
      response_data = {
        'id' => SecureRandom.uuid,
        'survey_id' => survey_id,
        'question_id' => question_id,
        'answer' => answer,
        'user_id' => @current_user.id,
        'submitted_at' => Time.now.to_s
      }

      dynamo_service.add_datails(response_data)
      saved_responses << response_data
    end
    if saved_responses.empty?
      render json: { error: 'No valid responses provided' }, status: :unprocessable_entity
    else
      @survey.update(is_submitted: true)
      render json: { message: 'Responses saved successfully', responses: saved_responses }, status: :created
    end
  rescue StandardError => e
    render json: { error: 'Failed to save responses', details: e.message }, status: :internal_server_error
  end

  def index
    response = ElasticSearchApi.get_answers(@survey.id.to_i, @current_user.id)
    render json: response
  end

  private

  def find_survey
    @survey = Survey.find_by(id: params[:survey_id])
    render json: { error: 'Survey not found' }, status: :not_found unless @survey
  end

  def validate_response
    render json: { error: 'Survey ID and responses are required' }, status: :bad_request if params[:responses].blank?
  end 
end
