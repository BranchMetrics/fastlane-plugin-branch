describe Fastlane::Helper::BranchHelper do
  let(:helper) { Fastlane::Helper::BranchHelper }

  before :each do
    helper.errors = []
  end

  describe "constants" do
    it "defines APPLINKS" do
      expect(helper::APPLINKS).to eq "applinks"
    end

    it "defines ASSOCIATED_DOMAINS" do
      expect(helper::ASSOCIATED_DOMAINS).to eq "com.apple.developer.associated-domains"
    end

    it "defines CODE_SIGN_ENTITLEMENTS" do
      expect(helper::CODE_SIGN_ENTITLEMENTS).to eq "CODE_SIGN_ENTITLEMENTS"
    end

    it "defines DEVELOPMENT_TEAM" do
      expect(helper::DEVELOPMENT_TEAM).to eq "DEVELOPMENT_TEAM"
    end

    it "defines PRODUCT_BUNDLE_IDENTIFIER" do
      expect(helper::PRODUCT_BUNDLE_IDENTIFIER).to eq "PRODUCT_BUNDLE_IDENTIFIER"
    end

    it "defines RELEASE_CONFIGURATION" do
      expect(helper::RELEASE_CONFIGURATION).to eq "Release"
    end
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
        domains = %w{example.com www.example.com}
        expect(helper.custom_domains_from_params(domains: domains.join(","))).to eq domains
      end

      it "raises for other parameter types" do
        expect do
          helper.custom_domains_from_params(domains: 123)
        end.to raise_error ArgumentError
      end
    end

    describe "#app_link_subdomains_from_params" do
      it "raises unless :live_key or :test_key is present" do
        expect do
          helper.app_link_subdomains_from_params app_link_subdomain: "myapp"
        end.to raise_error ArgumentError
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

      it "raises if no domains" do
        expect(helper).to receive(:custom_domains_from_params).and_return []
        expect(helper).to receive(:app_link_subdomains_from_params).and_return []

        expect do
          helper.domains_from_params({})
        end.to raise_error ArgumentError
      end
    end
  end

  describe "#app_ids_from_aasa_file" do
    it "returns the contents of an unsigned apple-app-site-assocation file" do
      mock_response = '{"applinks":{"apps":[],"details":[{"appID":"XYZPDQ.com.example.MyApp","paths":["NOT /e/*","*","/"]}]}}'

      expect(helper).to receive(:contents_of_aasa_file).with("myapp.app.link") { mock_response }

      expect(helper.app_ids_from_aasa_file("myapp.app.link")).to eq %w{XYZPDQ.com.example.MyApp}
      expect(helper.errors).to be_empty
    end

    it "raises if the file cannot be retrieved" do
      expect(helper).to receive(:contents_of_aasa_file).and_raise RuntimeError

      expect do
        helper.app_ids_from_aasa_file("myapp.app.link")
      end.to raise_error RuntimeError
    end

    it "returns nil in case of unparseable JSON" do
      # return value missing final }
      mock_response = '{"applinks":{"apps":[],"details":[{"appID":"XYZPDQ.com.example.MyApp","paths":["NOT /e/*","*","/"]}]}'
      expect(helper).to receive(:contents_of_aasa_file).with("myapp.app.link") { mock_response }

      expect(helper.app_ids_from_aasa_file("myapp.app.link")).to be_nil
      expect(helper.errors).not_to be_empty
    end

    it "returns nil if no applinks found in file" do
      mock_response = '{"webcredentials": {}}'
      expect(helper).to receive(:contents_of_aasa_file).with("myapp.app.link") { mock_response }

      expect(helper.app_ids_from_aasa_file("myapp.app.link")).to be_nil
      expect(helper.errors).not_to be_empty
    end

    it "returns nil if no details found for applinks" do
      mock_response = '{"applinks": {}}'
      expect(helper).to receive(:contents_of_aasa_file).with("myapp.app.link") { mock_response }

      expect(helper.app_ids_from_aasa_file("myapp.app.link")).to be_nil
      expect(helper.errors).not_to be_empty
    end

    it "returns nil if no appIDs found in file" do
      mock_response = '{"applinks":{"apps":[],"details":[]}}'
      expect(helper).to receive(:contents_of_aasa_file).with("myapp.app.link") { mock_response }

      expect(helper.app_ids_from_aasa_file("myapp.app.link")).to be_nil
      expect(helper.errors).not_to be_empty
    end
  end
end
