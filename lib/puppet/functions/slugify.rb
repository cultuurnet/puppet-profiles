# @summary
#   Generates a slugified version of a provided string.
#
#   The following operations are performed:
#   * Accented characters are replaced by their ASCII counterparts.
#   * The string is downcased.
#   * Spaces are replaced by dashes
#   * Characters that are not letters, digits, underscores or dashes are removed.
Puppet::Functions.create_function(:slugify) do
  # @param string The string to be slugified.
  #
  # @return [String]
  #
  # @example Example Usage:
  #   slugify('Hello, World!')
  dispatch :slug do
    param 'String', :some_string
    return_type 'String'
  end

  def slug(some_string)
    some_string.strip.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase.gsub(' ', '-').gsub(/[^a-z0-9_-]*/, '').gsub(/-[-]+/, '-')
  end
end
