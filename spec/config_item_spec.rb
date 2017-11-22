describe FastlaneCore::ConfigItem do
  it 'from_branch_option maps fields' do
    BranchOption = Struct.new :name, :env_name, :type, :default_value, :description

    option = BranchOption.new :foo, "BRANCH_FOO", String, "bar", "A field called foo"

    config_item = FastlaneCore::ConfigItem.from_branch_option option

    expect(config_item.key).to eq :foo
    expect(config_item.env_name).to eq "BRANCH_FOO"
    expect(config_item.data_type).to be String
    expect(config_item.default_value).to eq "bar"
    expect(config_item.description).to eq "A field called foo"
    expect(config_item.optional).to be true
  end
end
