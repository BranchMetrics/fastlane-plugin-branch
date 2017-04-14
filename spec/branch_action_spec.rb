describe Fastlane::Actions::BranchAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The branch plugin is working!")

      Fastlane::Actions::BranchAction.run(nil)
    end
  end
end
