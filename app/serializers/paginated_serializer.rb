class PaginatedSerializer < ActiveModel::Serializer::ArraySerializer
  def initialize(object, options={})
    meta_key = options[:meta_key] || :meta
    options[meta_key] ||= {}
    options[meta_key] = {
      page:        object.current_page,
      count:       object.size,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
    super(object, options)
  end
end
