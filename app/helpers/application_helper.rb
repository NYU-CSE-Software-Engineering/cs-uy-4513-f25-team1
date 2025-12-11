module ApplicationHelper
  SAFE_URL_PROTOCOLS = %w[http https].freeze

  def safe_url(url)
    return nil if url.blank?

    uri = URI.parse(url)
    return url if uri.scheme.present? && SAFE_URL_PROTOCOLS.include?(uri.scheme.downcase)

    nil
  rescue URI::InvalidURIError
    nil
  end
end
