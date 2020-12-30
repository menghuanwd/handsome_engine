# frozen_string_literal: true

data = yield
json.data Oj.load(data)
if @pagination.present?
  json.meta do
    json.current_page @pagination[:current_page] || 0
    json.total_pages @pagination[:total_pages] || 0
    json.next_page @pagination[:next_page] || 0
    json.total_count @pagination[:total_count] || 0
    json.per @pagination[:per] || 0
  end
end
