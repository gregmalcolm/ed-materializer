module JsonApiCustomizations
  private

  def jsonapi_data_params
    params[:data]
  end

  def jsonapi_attribute_params
    jsonapi_data_params[:attributes]
  end
  
  def jsonapi_relationship_params
    jsonapi_data_params[:relationships]
  end

  def add_relationship_id(new_params, key)
    id = params[:data][:relationships]
    id = id[:key] if id
    id = id[:id] if id
    new_params["#{key.to_s}_id".to_sym] = id if id
    new_params
  end
end
