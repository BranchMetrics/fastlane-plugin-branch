describe Fastlane::Helper::BranchHelper do
  describe "constants" do
    let(:helper) { Fastlane::Helper::BranchHelper }

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
end
