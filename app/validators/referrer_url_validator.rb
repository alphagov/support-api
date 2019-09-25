class ReferrerUrlValidator < UrlValidator
  # Referrer URLs can come from a variety of places
  # eg web URLs as well as app URLs such as
  # android-app://com.google.android.googlequicksearchbox
  # Simply check the URL can be parsed
  def url_valid?(url)
    !!URI.parse(url)
  rescue StandardError
    false
  end
end
