module ValidatesFormatOfUrl
  def self.validates(url, allowed_schemes = ['http', 'https'])
    require 'uri/http'
    begin
      uri = URI.parse(URI.encode(url))
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
