# automation
A repository of various shell scripts I've written to automate my daily tasks

# downloads_cleanup.sh
A script fired by cronjob that takes all the content in the ~/Downloads folder, moves it to a subdirectory: ~/Downloads/archive/<date>/ and cleans up any archives that are older than 30 days because they are no longer being referenced/required. This keeps the ~/Downloads directory clean and available for only stuff that has been added TODAY, and leaves me free to still find previous content as required to save elsewhere if it needs to be retained. (runs without options)

# gcp-mount.sh
A script to handle automated mounting and formatting of newly attached disks linked on google VM platforms or local endpoints for quick-formatting and re-use. Script will prompt for selection of disk, and try and map to a target destination at /mnt/disks/data after formatting (if no filesystem is found it will offer to format it for you with a new gpt schema).

# clamscan_daily.sh
A script fired by cronjob to sweep linux platform hosts using clamAV and move any affected files to a /quarantine/ directory that is set to 600 root:root to prevent access/interference. takes no options, fires as frequently as desired.
  
