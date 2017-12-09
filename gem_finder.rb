require 'httparty'
require 'json'

class GemfileReader
  GEM_REGEX = /\s{4}(?<gem_name>\w+)\s\((?<version>[\d\.]+)\)\n/ # four whitespace, one or more word characters (the gem name), one whitespace, an open paren, one or more characters including digits and periods (the gem version), a close paren, a newline
  # this is super brittle
  attr_reader :gemfile

  def initialize
    @gemfile = File.read('Gemfile.lock').lines
  end

  def current_gems
    @current_gems = {}
    @gemfile.each do |line|
      if captures = line.match(GEM_REGEX)
        @current_gems[captures[:gem_name]] = captures[:version].to_f
      end
    end
    @current_gems
  end

  # def truncate_gemfile(version)
  #   # how about: strip all dots from strings that contain digits
  #   version_regex = /^[^a-zA-Z0-9]*#{version.to_s}/ # that doesn't work because the dot in the string is interpreted as regex dot any, and is not escaped as a literal. makes sense
  #   @gemfile.each do |line|
  #     if line.match(version_regex)
  #       break
  #     end
  #     truncated_gemfile << line
  #   end
  #   truncated_gemfile
  # end
end

class GemFinder
  RUBY_GEMS_API_BASE = "https://rubygems.org/api/v1/gems/"
  GITHUB_API_REPOS_BASE = "https://api.github.com/repos/"

  GITHUB_REPO_REGEX = /http[s]{0,1}:\/\/github.com\/(?<owner>[-\w]+)\/(?<repo_name>[-\w\.]+)/

  def initialize(gem_name:, current_version:)
    @gem = gem_name
    @version = current_version
  end

  def changelog
    # calls other methods to output the changelog for the gem from most recent version to the version you currently have
    changelog_uri = github_changelog_contents_uri(gem_source_code_uri)
    puts changelog_uri
    response = HTTParty.get(changelog_uri)
    # puts response.code
    if response.code == 200
      # if encoding is base64
      changelog = Base64.decode64(response["content"])
      # end
      puts changelog
      trimmed_changelog = changelog_truncator(changelog)
    else
      #return unsuccessful response
    end
  end

  def gem_source_code_uri
    body = HTTParty.get("#{RUBY_GEMS_API_BASE}#{@gem}.json").body
    json_data = JSON.parse(body)
    json_data["source_code_uri"]
  end

  def github_changelog_contents_uri(repo_uri)
    # need to accomodate variety of possible extensions
    # use an enumerable like find, maybe?
    # also should see if the rubygem api just has one already defined.
    if captures = repo_uri.match(GITHUB_REPO_REGEX)
      "#{GITHUB_API_REPOS_BASE}#{captures[:owner]}/#{captures[:repo_name]}/contents/CHANGELOG.rdoc"
    end
  end

  def changelog_truncator(changelog)
    # how about: strip all dots from strings that contain digits
    version_regex = /^[^a-zA-Z0-9]*#{@version.to_s}/ # that doesn't work because the dot in the string is interpreted as regex dot any, and is not escaped as a literal. makes sense
    lines = StringIO.new(changelog, "r")
    truncated_gemfile = ""
    lines.each do |line|
      puts line
      if line.match(version_regex)
        break
      end
      truncated_gemfile << line
    end
    truncated_gemfile
  end
end
