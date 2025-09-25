# Contributing to Spotlight

Spotlight is a collaborative, open source project produced by developers, designers, product owners from several organizations. Spotlight mostly uses the [contribution model](https://github.com/projectblacklight/blacklight/blob/main/CONTRIBUTING.md) from its parent project [Blacklight](https://github.com/projectblacklight/blacklight). There are a few differences from the Blacklight process that this document will highlight.

## Code contributions

* Fork the project. Committers can skip this step and use the project directly.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.
* After making your changes, be sure to run the tests to make sure everything works.
* Make sure your changes pass [RuboCop](https://github.com/bbatsov/rubocop).
* Submit your change as a [[Pull Request|http://help.github.com/pull-requests/]].
 * Make sure a clear and atomic commit history is represented in a pull request. Commit messages should say why changes were made.

Please note that backwards compatibility and deprecation notices are preferred for breaking API and user facing changes

## User experience changes

Spotlight has been designed by a team of user experience designers. While there are a lot of great opportunities to improve the user experience, sometimes contributions that seem to make sense in a specific context can negatively affect the broader user experience of Spotlight that we've worked hard over the years to improve. When contributing updates or changes to the Spotlight user experience here are some useful guidelines to follow.
 - Determine if there is a way to contribute this in a backwards compatible or configurable way
 - [Open an issue](https://github.com/projectblacklight/spotlight/issues/new) on the project as a way to engage with core UX designers and developers on your proposed change or update
 - Contribute user stories to an issue or engage with the [Spotlight community](/README.md#spotlight-community)

## Becoming a Committer

Anyone can contribute to Spotlight using pull requests, the issue tracker, and participating in community slack channels. Being a committer means that you contribute to an extent that requires greater repository access. Currently the only defined way to be added as a committer is to participate in a community sprint.
