# branch_report


TODO




> Work in progress
This command optionally cleans and then builds a workspace or project, generating a verbose
report with additional diagnostic information suitable for opening a support ticket.



branch_report |
-----|----
Supported platforms | ios
Author | @Branch <integrations@branch.io>, @Jimmy Dee <jgvdthree@gmail.com>



**3 Examples**

```ruby
branch_report
```

```ruby
branch_report(header_only: true)
```

```ruby
branch_report(workspace: "MyWorkspace.xcworkspace")
```





**Parameters**

Key | Description
----|------------
  `workspace` | Path to an Xcode workspace
  `xcodeproj` | Path to an Xcode project
  `scheme` | A scheme from the project or workspace to build
  `target` | A target to build
  `configuration` | The build configuration to use (default: Scheme-dependent)
  `sdk` | Passed as -sdk to xcodebuild
  `podfile` | Path to the Podfile for the project
  `cartfile` | Path to the Cartfile for the project
  `clean` | Clean before attempting to build
  `header_only` | Write a report header to standard output and exit
  `pod_repo_update` | Update the local podspec repo before installing
  `out` | Report output path




<hr />
To show the documentation in your terminal, run
```no-highlight
fastlane action branch_report
```

<a href="https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/branch_report.rb" target="_blank">View source code</a>

<hr />

<a href="/actions"><b>Back to actions</b></a>
