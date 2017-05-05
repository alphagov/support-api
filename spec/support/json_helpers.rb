module JsonHelpers
  def json_response
    JSON.parse(response.body)
  end

  def get_json(url)
    get url, headers: {
      "CONTENT_TYPE" => 'application/json',
      'HTTP_ACCEPT' => 'application/json',
    }
  end
end

RSpec.configure { |c| c.include JsonHelpers }
