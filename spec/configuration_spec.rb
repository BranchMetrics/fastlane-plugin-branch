class ModuleInstance
  class << self
    attr_accessor :errors
    include Fastlane::Helper::ConfigurationHelper
  end
end

describe Fastlane::Helper::ConfigurationHelper do
  let(:helper) { ModuleInstance }

  before :each do
    helper.errors = []
  end

  describe "domains" do
    describe "#custom_domains_from_params" do
      it "returns a blank array if no :domains parameter" do
        expect(helper.custom_domains_from_params({})).to eq []
      end

      it "returns custom domains from a string array" do
        domains = %w{example.com www.example.com}
        expect(helper.custom_domains_from_params(domains: domains)).to eq domains
      end

      it "returns custom domains from a comma-separated string" do
        domains = "example.com,www.example.com"
        expect(helper.custom_domains_from_params(domains: domains)).to eq %w{example.com www.example.com}
      end

      it "raises for other parameter types" do
        expect do
          helper.custom_domains_from_params(domains: 123)
        end.to raise_error ArgumentError
      end
    end

    describe "#app_link_subdomains_from_params" do
      it "returns [] unless :live_key or :test_key is present" do
        expect(helper.app_link_subdomains_from_params(app_link_subdomain: "myapp")).to be_empty
      end

      it "returns a blank array if no :app_link_subdomain parameter" do
        expect(helper.app_link_subdomains_from_params(live_key: "abc")).to eq []
      end

      it "adds app.link subdomains if :live_key is present" do
        expected = %w{myapp.app.link myapp-alternate.app.link}
        expect(helper.app_link_subdomains_from_params(app_link_subdomain: "myapp", live_key: "abc")).to eq expected
      end

      it "adds test-app.link subdomains if :test_key is present" do
        expected = %w{myapp.test-app.link myapp-alternate.test-app.link}
        expect(helper.app_link_subdomains_from_params(app_link_subdomain: "myapp", test_key: "xyz")).to eq expected
      end

      it "returns four domains if :app_link_subdomain, :live_key and :test_key specified" do
        expected = %w{myapp.app.link myapp-alternate.app.link myapp.test-app.link myapp-alternate.test-app.link}
        expect(helper.app_link_subdomains_from_params(app_link_subdomain: "myapp", live_key: "abc", test_key: "xyz")).to eq expected
      end
    end

    describe "#domains_from_params" do
      it "merges the results of #custom_domains_from_params and #app_link_subdomains_from_params" do
        params = { domains: "example.com,www.example.com", app_link_subdomain: "myapp" }
        custom_domains = %w{example.com www.example.com}
        app_link_subdomains = %w{myapp.app.link myapp-alternate.app.link myapp.test-app.link myapp-alternate.test-app.link}

        # ensure that domains_from_params calls the other two methods
        expect(helper).to receive(:custom_domains_from_params).with(params).and_return custom_domains
        expect(helper).to receive(:app_link_subdomains_from_params).with(params).and_return app_link_subdomains

        # order is irrelevant. use sort.
        expect(helper.domains_from_params(params).sort).to eq (custom_domains + app_link_subdomains).sort
      end

      it "ignores duplicates" do
        params = { domains: "example.com,www.example.com,myapp.app.link", app_link_subdomain: "myapp" }
        custom_domains = %w{example.com www.example.com myapp.app.link}
        app_link_subdomains = %w{myapp.app.link myapp-alternate.app.link myapp.test-app.link myapp-alternate.test-app.link}

        # ensure that domains_from_params calls the other two methods
        expect(helper).to receive(:custom_domains_from_params).with(params).and_return custom_domains
        expect(helper).to receive(:app_link_subdomains_from_params).with(params).and_return app_link_subdomains

        # order is irrelevant. use sort.
        expect(helper.domains_from_params(params).sort).to eq (custom_domains + app_link_subdomains).uniq.sort
      end

      it "returns [] if no domains" do
        expect(helper).to receive(:custom_domains_from_params).and_return []
        expect(helper).to receive(:app_link_subdomains_from_params).and_return []

        expect(helper.domains_from_params({})).to be_empty
      end
    end
  end

  describe '#xcodeproj_path_from_params' do
    let (:root) { Bundler.root }

    it 'returns the :xcodeproj parameter if present' do
      expect(helper.xcodeproj_path_from_params(xcodeproj: "./MyProject.xcodeproj")).to eq "./MyProject.xcodeproj"
    end

    it 'returns the path if one project present' do
      expect(Dir).to receive(:[]) { ["#{root}/MyProject.xcodeproj"] }
      expect(helper.xcodeproj_path_from_params({})).to eq "#{root}/MyProject.xcodeproj"
    end

    it 'ignores projects under Pods' do
      expect(Dir).to receive(:[]) { ["#{root}/MyProject.xcodeproj", "#{root}/Pods/Pods.xcodeproj"] }
      expect(helper.xcodeproj_path_from_params({})).to eq "#{root}/MyProject.xcodeproj"
    end

    it 'returns nil and errors if no project found' do
      expect(Dir).to receive(:[]) { [] }
      expect(FastlaneCore::UI).to receive(:user_error!)
      expect(helper.xcodeproj_path_from_params({})).to be_nil
    end

    it 'returns the path if one project present' do
      expect(Dir).to receive(:[]) { ["#{root}/MyProject.xcodeproj", "#{root}/OtherProject.xcodeproj"] }
      expect(FastlaneCore::UI).to receive(:user_error!)
      expect(helper.xcodeproj_path_from_params({})).to be_nil
    end
  end
end
