1. Takes a Gemfile.lock
2. Goes through each gem at its current version
3. Finds the latest version
4. Fetches changelog (or commit messages?) for each step in between your current version and the newest
5. Outputs a log of changes (ahaha) between so you know what you're getting if you want to update

Nicities:
- prints the bundler command to run to get to each version with the summary
- command-line-runnable in a project directory
- gets commit messages as well?
