class Api::V1::QuestionsController < ApplicationController

  before_action :find_survey
  before_action :authorize_admin!, only: %i[create destroy]

  def index
    response = ElasticSearchApi.get_questions(@survey.id.to_i)
    render json: response
  end

  def show
    question = DynamoDbService.new('questions').get_question(params[:id], @survey.id.to_i)
    if question
      render json: question
    else
      render json: { error: 'Question not found' }, status: :not_found
    end
  end

  def create
    question_data = {
      'id' => SecureRandom.uuid,
      'survey_id' => @survey.id.to_i,
      'text' => params[:text],
      'question_type' => params[:question_type],
      'options' => params[:options].presence || " "
    }
    DynamoDbService.new('questions').add_datails(question_data)
    render json: { message: 'Question created successfully', question: question_data }, status: :created
  end

  def destroy
    result = DynamoDbService.new('questions').delete_question(params[:id], @survey.id.to_s)
    if result
      render json: { message: 'Question deleted successfully' }
    else
      render json: { error: 'Question not found' }, status: :not_found
    end
  end

  private

  def find_survey
    @survey = Survey.find_by(id: params[:survey_id])
    render json: { error: 'Survey not found' }, status: :not_found unless @survey
  end

  def authorize_admin!
    render json: { error: 'Forbidden' }, status: :forbidden unless @current_user&.admin?
  end
end
