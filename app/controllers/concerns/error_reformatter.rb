module ErrorReformatter
  def errors_as_jsonapi(errors, status: "422")
    return if errors.nil?

    json = {}
    new_hash = errors.to_hash(true).map do |k, v|
      v.map do |msg|
        { title: k, detail: msg, status: status }
      end
    end.flatten
    json[:errors] = new_hash
    json
  end
end
