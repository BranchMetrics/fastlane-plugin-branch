describe Fastlane::Actions::SetupBranchAction do
  describe '#run' do
    it 'prints a message' do
      pending "No meaningful tests yet"
      expect(Fastlane::UI).to receive(:message).at_least(1)

      Fastlane::Actions::SetupBranchAction.run({})
    end
  end
end
