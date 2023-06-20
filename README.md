# automation
A repository of various shell scripts I've written to automate my daily tasks

# downloads_cleanup.sh
A script fired by cronjob that takes all the content in the ~/Downloads folder, moves it to a subdirectory: ~/Downloads/archive/<date>/ and cleans up any archives that are older than 30 days because they are no longer being referenced/required. This keeps the ~/Downloads directory clean and available for only stuff that has been added TODAY, and leaves me free to still find previous content as required to save elsewhere if it needs to be retained.
