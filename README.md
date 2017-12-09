Takes a Gemfile.lock
Goes through each gem at its current version
Goes and finds the latest version
Fetches changelog (or commit messages?) for each step in between your current version and the newest
Outputs a log of changes (ahaha) between so you know what you're getting if you want to update

nicities:
  prints the bundler command to run to get to each version with the summary
  command-line-runnable in a project directory
  gets commit messages as well?
