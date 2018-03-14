# frozen_string_literal: true

def json_data(filename)
  file_content = file_fixture("#{filename}.json").read
  JSON.parse(file_content, symbolize_names: true)
end
