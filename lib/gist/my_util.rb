module MyUtil

  def numeric?(str)
    str.to_i.to_s == str
  end

  def get_body(url, limit=2)
    raise Gist::RedirectError, 'HTTP redirect too deep' if limit.zero?

    uri = URI(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true if uri.port == 443
    res = https.get(uri.path)
    case res
    when Net::HTTPSuccess
      res.body
    when Net::HTTPFound # 302
      get_body(res['location'], limit-1)
    end
  end
end
