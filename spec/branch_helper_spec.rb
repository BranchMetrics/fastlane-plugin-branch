describe Fastlane::Helper::BranchHelper do
  let(:helper) { Fastlane::Helper::BranchHelper }

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
      it "returns a blank array if no :app_link_subdomain parameter" do
        expect(helper.app_link_subdomains_from_params({})).to eq []
      end

      it "returns four domains if :app_link_subdomain specified" do
        expected = %w{myapp.app.link myapp-alternate.app.link myapp.test-app.link myapp-alternate.test-app.link}
        expect(helper.app_link_subdomains_from_params(app_link_subdomain: "myapp")).to eq expected
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
    it "returns the contents of an apple-app-site-assocation file" do
      expect(Net::HTTP).to receive(:get).with("myapp.app.link", "/apple-app-site-association").and_return '{"applinks":{"apps":[],"details":[{"appID":"XYZPDQ.com.example.MyApp","paths":["NOT /e/*","*","/"]}]}}'

      expect(helper.app_ids_from_aasa_file("myapp.app.link")).to eq %w{XYZPDQ.com.example.MyApp}
    end

    it "raises if the file cannot be retrieved" do
      expect(Net::HTTP).to receive(:get).and_raise IOError

      expect do
        helper.app_ids_from_aasa_file "myapp.app.link"
      end.to raise_error IOError
    end

    it "raises in case of unparseable JSON" do
      # return value missing final }
      expect(Net::HTTP).to receive(:get).and_return '{"applinks":{"apps":[],"details":[{"appID":"XYZPDQ.com.example.MyApp","paths":["NOT /e/*","*","/"]}]}'

      expect do
        helper.app_ids_from_aasa_file "myapp.app.link"
      end.to raise_error JSON::ParserError
    end

    it "raises if no applinks found in file" do
      expect(Net::HTTP).to receive(:get).and_return '{"webcredentials": {}}'

      expect do
        helper.app_ids_from_aasa_file "myapp.app.link"
      end.to raise_error RuntimeError
    end

    it "raises if no details found for applinks" do
      expect(Net::HTTP).to receive(:get).and_return '{"applinks": {}}'

      expect do
        helper.app_ids_from_aasa_file "myapp.app.link"
      end.to raise_error RuntimeError
    end

    it "raises if no appIDs found in file" do
      expect(Net::HTTP).to receive(:get).and_return '{"applinks":{"apps":[],"details":[]}}'

      expect do
        helper.app_ids_from_aasa_file "myapp.app.link"
      end.to raise_error RuntimeError
    end
  end
end
