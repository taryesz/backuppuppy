# Name

BackupPuppy is a script, which allows its users to create manual or
automatic backups for their files and folders.

# Synopsis

**./program.sh \[options\]**

Available options: see **Options**

# Description

This script is a tool that allows users to perform manual and automatic
backups, as well as restore files from backups. The script utilizes the
Zenity utility to create graphical dialog boxes for user interaction.
Throughout the script, error handling and logging are implemented.
Errors and important information are logged in the \'log.txt\' file. The
script provides a user-friendly interface for performing manual and
automatic backups and restoring files from backups, making it a
convenient backup tool.

# Options

**-h** Show help message.

**-v** Show the script\'s, version, author and last modification date.

# Author

Name: **Taras Shuliakevych**

Contact: **hello.szulakiewicz@gmail.com**

# Reporting Bugs

In case you find any bugs, errors or other weird stuff going on in this
script, please, don\'t hesitate to contact the author of this script.

# Copyright

The script is available under the MIT license, which means you can
freely use, modify, and distribute this script. However, please,
remember to retain the copyright information.

# Overview

Upon execution, the script presents a main menu with three options:
\'Manual backup\', \'Automatic Backup\', and \'Restore\'. The user can
select an option using Zenity dialog boxes.

If the user chooses \'Manual backup\', the script prompts the user to
select either a single file or a folder for backup. After the selection
is made, the script gives an option to compress the backup into a .zip
file. If selected, the script generates a unique backup name based on
the current date and time and compresses the selected file or folder
into a .zip file. If compression is not selected, the script creates a
copy of the selected file or folder with a modified name. The backup is
then saved in the specified backup path.

If the user chooses \'Automatic Backup\', the script provides four
options: \'Specific date\', \'Daily\', \'Weekly\' and \'Monthly\'.
Depending on the chosen option, the script prompts the user to select
backup parameters such as backup time, day, and month. The script
creates a cron job based on the selected parameters to schedule
automatic backups.

If the user selects \'Restore\', the script presents two options:
\'Restore a file or .zip\' and \'Restore a folder\'. The user can choose
to restore a specific file or a folder from a backup. The script prompts
the user to select the backup file or folder and the destination folder
for restoration. If the selected backup is a .zip file, it is extracted
to the specified destination folder. Otherwise, the selected file or
folder is copied to the destination folder.

# Examples

Say you want to set an automatic backup that would create copies of your
university-related files, saved in UNISTUFF folder, every day at some
specific time, i.e. 10:00 AM.

To do that, go to \'Automatic Backup\' in main menu, choose \'Daily\',
type time HH:MM, where HH is an hour, MM - minutes, and then click
\'OK\'.

Choose \'FOLDER\' and then browse your file system to find your UNISTUFF
folder and click \'OK\'. You\'ll receive a communication message showing
the path to your folder.

Then, you will be asked if you want to compress your backups or not. Say
we do, click \'Yes\' - then browse you file system to choose a place for
your copies and click \'OK\'. You will be informed again by showing the
path you just chose.

That\'s it! You\'ve just set an automatic backuping!

The process is similar with other options available in this script -
just follow the program: it will tell you what to do :)


