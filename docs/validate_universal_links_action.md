# validate_universal_links


Validates Universal Link configuration for an Xcode project.




> This command validates all Universal Link domains configured in a project without making any
modification. It validates both Branch and non-Branch domains. Unlike web-based Universal
Link validators, this command operates directly on the project. It finds the bundle and
signing team identifiers in the project as well as the app's Associated Domains. It requests
the apple-app-site-association file for each domain and validates the file against the
project's settings.
Only app targets are supported for this command. By default, it will validate the first.
If your project has multiple app targets, specify the target option to validate other
targets.
All parameters are optional. If domains is specified, the list of Universal Link domains in
the Associated Domains entitlement must exactly match this list, without regard to order. If
no domains are provided, validation passes if at least one Universal Link domain is
configured and passes validation, and no Universal Link domain is present that does not pass
validation.
See https://github.com/BranchMetrics/branch_io_cli#validate-command for more information.



validate_universal_links |
-----|----
Supported platforms | ios
Author | @Branch <integrations@branch.io>, @Jimmy Dee <jgvdthree@gmail.com>
Returns | If validation passes, this command returns 0. If validation fails, it returns 1.



**4 Examples**

```ruby
validate_universal_links
```

```ruby
validate_universal_links(xcodeproj: "MyProject.xcodeproj")
```

```ruby
validate_universal_links(xcodeproj: "MyProject.xcodeproj", target: "MyProject")
```

```ruby
validate_universal_links(domains: %w{example.com www.example.com})
```





**Parameters**

Key | Description
----|------------
  `domains` | Comma-separated list of domains to validate (Branch domains or non-Branch domains)
  `xcodeproj` | Path to an Xcode project to update
  `target` | Name of a target to validate in the Xcode project




<hr />
To show the documentation in your terminal, run
```no-highlight
fastlane action validate_universal_links
```

<a href="https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/validate_universal_links.rb" target="_blank">View source code</a>

<hr />

<a href="/actions"><b>Back to actions</b></a>
