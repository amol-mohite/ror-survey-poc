class ElasticSearchApi
  OPENSEARCH_ENDPOINT = 'https://search-my-es-domain-wm24gpt2t2hrxdfawj4wirxce4.aos.eu-north-1.on.aws'
  INDEX_NAME = 'sampleindex'
  USERNAME = '8692891755'
  PASSWORD = 'Amol@755'

  def self.get_questions(survey_id)
    return {status_code: 400, error: 'survey_id is required' } if survey_id.blank?
    # query = {
    #   query: {bool: {must: [
    #     { match: { survey_id: survey_id } },
    #     { match: { table_name: 'questions'} }
    #   ]}}
    query = {
      query: {
        bool: {
          must: [
            { match: { survey_id: survey_id } },
            { exists: { field: "question_type" } },
            { bool: { must_not: { exists: { field: "answer" } } } }
          ]
        }
      }
    }
    response = search_es(query)
    if response.code.to_i == 200
      {status_code: response.code, data:  extract_es_data(JSON.parse(response.body))}
    else
      {status_code: response.code, error: response.message, details: response.body}
    end
  end

  def self.get_answers(survey_id, user_id)
    return {status_code: 400, error: 'survey_id or user_id is missing.' } if survey_id.blank? || user_id.blank?

    query = {
      query: {bool: {must: [
        { match: { survey_id: survey_id } },
        { match: { user_id: user_id } }
      ]}}
    }
    response = search_es(query)
    if response.code.to_i == 200
      {status_code: response.code, data:  extract_es_data(JSON.parse(response.body))}
    else
      {status_code: response.code, error: response.message, details: response.body}
    end
  end


  def self.test(survey_id)
    return {status_code: 400, error: 'survey_id is required' } if survey_id.blank?

    query = {
      query: {
        match: { table_name: survey_id }
      }
    }
    response = search_es(query)
    if response.code.to_i == 200
      {status_code: response.code, data:  extract_es_data(JSON.parse(response.body))}
    else
      {status_code: response.code, error: response.message, details: response.body}
    end
  end

  def self.search_es(query)
    uri = URI("#{OPENSEARCH_ENDPOINT}/#{INDEX_NAME}/_search")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(USERNAME, PASSWORD)
    request['Content-Type'] = 'application/json'
    request.body = query.to_json

    send_request(uri, request)
  end

  def self.send_request(uri, request)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end

  def self.extract_es_data(data)
    hits = data.dig('hits', 'hits')
    return [] unless hits.is_a?(Array)
    hits.map { |hit| hit['_source']}
  end
end