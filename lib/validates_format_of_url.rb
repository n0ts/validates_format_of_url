module ValidatesFormatOfUrl
  def self.validates(url, allowed_schemes = ['http', 'https'])
    require 'uri/http'
    begin
      uri = URI.parse(url)
      if !allowed_schemes.include?(uri.scheme)
        raise URI::InvalidURIError
      end
      if [:scheme, :host].any? { |i| uri.send(i).blank? }
        raise URI::InvalidURIError
      end
    rescue URI::InvalidURIError
      return false
    end
    return true
  end
end

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_format_of_url(*attr_names)
        configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid], :on => :save, :schemes => %w(http https) }
        configuration.update(attr_names.extract_options!)

        allowed_schemes = [*configuration[:schemes]].map(&:to_s)

        attr_accessor(* (attr_names.map { |n| "#{n}_invalid" }))

        validates_each(attr_names, configuration) do |record, attr_name, value|
          if !ValidatesFormatOfUrl.validates(value, allowed_schemes)
            record.errors.add(attr_name, configuration[:message])
          end
        end
      end
    end
  end
end


class ActiveRecord::Base
  def validates_format_of_url(url, allowed_schemes = ['http', 'https'])
    return ValidatesFormatOfUrl.validates(url, allowed_schemes)
  end
end
