class DynamoDbService

  def initialize(table_name)
    @client = Aws::DynamoDB::Client.new
    @table_name = table_name
  end

  def add_datails(payload)
    @client.put_item(
      table_name: @table_name,
      item: payload
    )
  end

  def get_questions_by_survey(survey_id)
    @client.query(
      table_name: @table_name,
      key_condition_expression: 'survey_id = :survey_id',
      expression_attribute_values: {
        ':survey_id' => survey_id
      }
    ).items
  end

  def delete_question(question_id, survey_id)
    @client.delete_item(
      table_name: @table_name,
      key: {
        'question_id' => question_id,
        'survey_id' => survey_id
      }
    )
  end
end