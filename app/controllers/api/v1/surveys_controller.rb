class Api::V1::SurveysController < ApplicationController
  
  before_action :find_survey, only: %i[show update mark_inactive mark_active]
  before_action :authorize_admin!, only: %i[create update]
  
  def index
    @surveys = @current_user&.admin? ? Survey.all : Survey.active
    render json: @surveys
  end

  def show
    render json: @survey
  end

  def create
    survey = @current_user.surveys.build(survey_params)
    if survey.save
      render json: survey, status: :created
    else
      render json: { errors: survey.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @survey.update(survey_params)
      render json: @survey
    else
      render json: { errors: @survey.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def mark_active
    response = ElasticSearchApi.get_questions(@survey.id.to_i)
    render json: { errors: 'Please add atleast 1 Questions before making it Active' }, status: :unprocessable_entity and return if response[:data].blank?
    if @survey.update(status: 'active')
      render json: @survey
    else
      render json: { errors: @survey.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def mark_inactive
    if @survey.update(status: 'inactive')
      render json: @survey
    else
      render json: { errors: @survey.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private

  def survey_params
    params.permit(:title, :description, :starting_date, :closing_date)
  end

  def find_survey
    @survey = Survey.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Survey not found' }, status: :not_found
  end

  def authorize_admin!
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden if !@current_user&.admin?
  end
end