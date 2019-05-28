module SQLHelper
  def sql_like?(like_query, string_to_match)
    sql_like_to_regexp(like_query).match? string_to_match
  end

  def sql_like_to_regexp(like_query)
    pattern = Regexp.escape like_query
    pattern = pattern.gsub "%", ".*"
    pattern = pattern.gsub "\\?", "."
    pattern = "\\A#{pattern}\\z"
    Regexp.new pattern
  end
end
