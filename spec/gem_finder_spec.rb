require 'rspec'
require_relative '../gem_finder.rb'

RSpec.describe GemfileReader do
  subject { GemfileReader.new }

  it "reads a Gemfile.lock" do
    expect(subject.gemfile).to include("GEM\n")
    expect(subject.gemfile).to include("BUNDLED WITH\n")
  end

  it "reads a Gemfile.lock to get current gems" do
    current_hash = {
      "braintree" => 2.47,
    }
    expect(subject.current_gems).to eq(current_hash)
  end
end

RSpec.describe GemFinder do
  subject { GemFinder.new(gem_name: "braintree", current_version: 2.47) }

  # TODO: mock network call
  it "uses the ruby gems api to grab source url for a gem" do
    expect(subject.gem_source_code_uri).to eq("http://github.com/braintree/braintree_ruby")
  end

  it "can assemble a github api uri for the contents of a changelog" do
    expect(subject.github_changelog_contents_uri("https://github.com/braintree/braintree_ruby")).to eq("https://api.github.com/repos/braintree/braintree_ruby/contents/CHANGELOG.rdoc")
    expect(subject.github_changelog_contents_uri("http://github.com/braintree/braintree_ruby")).to eq("https://api.github.com/repos/braintree/braintree_ruby/contents/CHANGELOG.rdoc")
  end

  # TODO: mock network call
  it "captures an owner and repo name from a gem's source code URI if it's on github" do
    expect(subject.changelog).to include("Initial release")
  end

  it "only outputs the changlog up to the next change after the version you're on" do
    full_changelog = File.read("spec/CHANGELOG.rdoc")
    changelog_after_version = File.read("spec/CHANGELOG_AFTER_2.47.rdoc")
    expect(subject.changelog_truncator(full_changelog)).to eq(changelog_after_version)
  end
end
