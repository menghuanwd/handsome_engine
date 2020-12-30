module BaseGenerator
  def singular_plural_name
    plural_name.singularize
  end

  def scope
    class_path[0]
  end

  def chinese_name
    options['name']
  end

  def properties
    columns.map do |column|
      "#{column.name}: { type: :#{column.type}, description: '#{column.name}'}"
    end.join(",\n          ")
  end

  def request_params
    columns.map do |column|
      "#{column.name}: '#{column.name}'" if column.name != 'id'
    end.compact.join(",\n            ")
  end

  def columns
    singular_plural_name.camelize.constantize.columns.delete_if{|column|column.name.in? %(id created_at updated_at)}
  end

  def generate_example(example)
    example.metadata[:response][:examples] = {'application/json' => JSON.parse(response.body, symbolize_names: true)}
  end
end
