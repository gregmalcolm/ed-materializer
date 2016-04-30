# File: config/initializers/jsonapi_param_key_transform.rb
# Transform JSONAPI request param keys from dasherized to
# Rails-conventional snake_case:
Rails.application.config.middleware.swap(
  ::ActionDispatch::ParamsParser, ::ActionDispatch::ParamsParser,
  ::Mime::Type.lookup('application/vnd.api+json') => Proc.new { |raw_post|

    # Borrowed from action_dispatch/middleware/params_parser.rb except for
    # data.deep_transform_keys!(&:underscore) :
    data = ::ActiveSupport::JSON.decode(raw_post)
    data = {:_json => data} unless data.is_a?(::Hash)
    data = ::ActionDispatch::Request::Utils.deep_munge(data)

    # Transform camelCase param keys to snake_case:
    data.deep_transform_keys!(&:underscore)

    data.with_indifferent_access
  }
)
