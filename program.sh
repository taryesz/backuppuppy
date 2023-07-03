# Author           : Taras Shuliakevych ( hello.szulakiewicz@gmail.com )
# Created On       : 20.05.2023
# Last Modified By : Taras Shuliakevych ( hello.szulakiewicz@gmail.com )
# Last Modified On : 21.05.2023
# Version          : 0.1
#
# Description      :
# 
# This script is a tool that allows users to perform manual and automatic backups, as well as restore files from backups. 
# The script utilizes the Zenity utility to create graphical dialog boxes for user interaction.
#
# Upon execution, the script presents a main menu with three options: "Manual backup," "Automatic Backup," and "Restore." 
# The user can select an option using Zenity dialog boxes.
#
# If the user chooses "Manual backup," the script prompts the user to select either a single file or a folder for backup. 
# After the selection is made, the script gives an option to compress the backup into a .zip file. 
# If selected, the script generates a unique backup name based on the current date and time and compresses the selected file or 
# folder into a .zip file. If compression is not selected, the script creates a copy of the selected file or folder with a 
# modified name. The backup is then saved in the specified backup path.
#
# If the user chooses "Automatic Backup," the script provides four options: "Specific date", "Daily", "Weekly" and "Monthly". 
# Depending on the chosen option, the script prompts the user to select backup parameters such as backup time, day, and month. 
# The script creates a cron job based on the selected parameters to schedule automatic backups.
#
# If the user selects "Restore", the script presents two options: "Restore a file or .zip" and "Restore a folder". 
# The user can choose to restore a specific file or a folder from a backup. The script prompts the user to select the backup file or
# folder and the destination folder for restoration. If the selected backup is a .zip file, it is extracted to the specified 
# destination folder. Otherwise, the selected file or folder is copied to the destination folder.
#
# Throughout the script, error handling and logging are implemented. Errors and important information are logged in the "log.txt" file.
#
# The script provides a user-friendly interface for performing manual and automatic backups and restoring files from backups, 
# making it a convenient backup tool.
#
#
#
# The script is available under the MIT license, which means you can freely use, modify, and distribute this script. 
# However, please remember to retain the copyright information.

#!/bin/bash

# global variables
OPTION=0
FORF=0
FILE=""
SAVE_PATH=$(dirname "$0")
#SAVE_PATH="$HOME/Documents/backup_script/saves" 
backup_path=""  
backup_time=""
log_file="log.txt" 
pattern=""

# function to show help message
show_help() {
    	echo "How to use: $0 [*options*]"
    	echo "Available options:

	-h  Show this help message.
    	-v  Show the script's version.
    	
Descrition:

This script is a tool that allows users to perform manual and automatic backups, as well as restore files from backups.
The script utilizes the Zenity utility to create graphical dialog boxes for user interaction.

Upon execution, the script presents a main menu with three options: 'Manual backup', 'Automatic Backup', and 'Restore'.
The user can select an option using Zenity dialog boxes.

If the user chooses 'Manual backup', the script prompts the user to select either a single file or a folder for backup.
After the selection is made, the script gives an option to compress the backup into a .zip file.
If selected, the script generates a unique backup name based on the current date and time and compresses the selected file or
folder into a .zip file. If compression is not selected, the script creates a copy of the selected file or folder with a
modified name. The backup is then saved in the specified backup path.

If the user chooses 'Automatic Backup', the script provides four options: 'Specific date', 'Daily', 'Weekly' and 'Monthly'.
Depending on the chosen option, the script prompts the user to select backup parameters such as backup time, day, and month.
The script creates a cron job based on the selected parameters to schedule automatic backups.

If the user selects 'Restore', the script presents two options: 'Restore a file or .zip' and 'Restore a folder'.
The user can choose to restore a specific file or a folder from a backup. The script prompts the user to select the backup file or
folder and the destination folder for restoration. If the selected backup is a .zip file, it is extracted to the specified
destination folder. Otherwise, the selected file or folder is copied to the destination folder.

Throughout the script, error handling and logging are implemented. Errors and important information are logged in the 'log.txt' file.

The script provides a user-friendly interface for performing manual and automatic backups and restoring files from backups,
making it a convenient backup tool.

The script is available under the MIT license, which means you can freely use, modify, and distribute this script.
However, please remember to retain the copyright information.

WARNING:

Please beware that you might need to install some additional command-line utilities to make this script work: 

	- zenity
	- zip
	- cp
	- mv
	- cron
	"
}

# function to show script version
show_version() {
    echo "Script version: 0.1"
    echo "Author: Taras Shuliakevych (hello.szulakiewicz@gmail.com)"
    echo "Last modified: 21.05.2023"
}

# parsing command-line options
while getopts ":hv" option; do
    case "$option" in
        h)
            show_help
            exit 0
            ;;
        v)
            show_version
            exit 0
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift "$((OPTIND-1))"

# function that allows to get a file/folder from user's system
choose() {
	
    	fileorfolder=("Single file" "Folder")				      # option buttons
    	FORF=$(zenity --list --column=menu "${fileorfolder[@]}" --height 400) # creating a menu for user choice

	# if "Single file" is chosen
    	if [ "$FORF" = "Single file" ]; then
    		# create a window to choose a file from user's system
        	FILE=$(zenity --file-selection --title="Select a file" --filename="$HOME")
        	if [ -z "$FILE" ]; then  		  # if no file is chosen
            	zenity --error --text="No file selected." # error message
           	echo "No file selected." >> "$log_file"   # save the error message to logs
                main_menu				  # return to main menu
        	fi
        # if "Folder" is chosen
    	else
    		# create a window to choose a folder from user's system
        	FILE=$(zenity --file-selection --title="Select a folder" --filename="$HOME" --directory)
        	if [ -z "$FILE" ]; then			    # if no folder is chosen
            	zenity --error --text="No folder selected." # error message
            	echo "No folder selected." >> "$log_file"   # save the error message to logs
            	main_menu				    # return to main menu
        	fi
    	fi

	zenity --info --text="Selected file/folder: $FILE"  # show a file the user's chosen
}

# function that compress files
zipping() {

    	response=$(zenity --question --text="Do you want to compress the backup to .zip?") # ask if compress a file or not
    	
    	if [ "$?" -eq 0 ]; then							# if "yes" is chosen..
        	if [ -z "$FILE" ]; then						# if no folder is chosen
            		zenity --error --text="No file or folder selected."	# error message
            		echo "No file or folder selected." >> "$log_file" 	# save the error message to logs
            		main_menu						# return to main menu
        	else
            		directory="$(dirname "$FILE")"				# save chosen file's path
            		base_name="$(basename "$FILE")"				# get file's name
            		current_date=$(date +%Y-%m-%d_%H-%M-%S)			# get current date
            		backup_name="${base_name%.*}_copy_$current_date.zip"	# create a new unique name
            		backup_path="$SAVE_PATH/$backup_name"			# create a save-path

            		if [ -e "$backup_path" ]; then						# if such file already exists
                		zenity --error --text="Backup file/folder already exists."	# error message
                		echo "Backup file/folder already exists." >> "$log_file"	# save the error message to logs
                		main_menu							# return to main menu
            		fi

            		if [ "$FORF" = "Single file" ]; then	# if user's choice was a file
                		zip -j "$backup_path" "$FILE"	# compress it without a path, just the file
            		else					# if user's choice was a folder
                		zip -r "$backup_path" "$FILE"	# compress it including its inside stuff
            		fi
        	fi
    	else									# if "no" is chosen..
        	if [ -z "$FILE" ]; then						# if no folder is chosen
            		zenity --error --text="No file or folder selected."	# error message
            		echo "No file or folder selected." >> "$log_file" 	# save the error message to logs
            		main_menu						# return to main menu
        	else
            		directory="$(dirname "$FILE")"				# save chosen file's path
            		base_name="$(basename "$FILE")"				# get file's name
            		current_date=$(date +%Y-%m-%d_%H-%M-%S)			# get current date
            		backup_name="${base_name}_copy_$current_date"		# create a new unique name
		    	backup_path="$SAVE_PATH/$backup_name"			# create a save-path

             		if [ -e "$backup_path" ]; then						# if such file already exists
                		zenity --error --text="Backup file/folder already exists."	# error message
                		echo "Backup file/folder already exists." >> "$log_file"	# save the error message to logs
                		main_menu							# return to main menu
            		fi

            		if [ "$FORF" = "Single file" ]; then	# if user's choice was a file
                		cp "$FILE" "$backup_path"	# copy it to a save-path
            		else					# if user's choice was a folder
                		cp -r "$FILE" "$backup_path"	# copy it including its inside stuff
            		fi
            		
        	fi
    	fi
}

# function that saves backuped files to custom path
save() {
	if [ -z "$FILE" ]; then						# if no folder is chosen
            	zenity --error --text="No file or folder selected."	# error message
            	echo "No file or folder selected." >> "$log_file" 	# save the error message to logs
            	main_menu						# return to main menu
    	fi

	# creating a window for choosing a path
    	NEW_PATH=$(zenity --file-selection --title="Select a path to save the backup" --directory)

    	if [ -z "$NEW_PATH" ]; then							# if no path is chosen
        	zenity --info --text="No save path selected. Backup not moved."		# error message
        	echo "No save path selected. Backup not moved." >> "$log_file"		# save the error message to logs
        	main_menu								# return to main menu
    	else
        	if [ -n "$backup_path" ]; then						# if a save-path is not empty
            		if [ -e "$backup_path" ]; then					# if a save-path exists
                		mv "$backup_path" "$NEW_PATH/"				# move it to chosen path
                		zenity --info --text="Backup moved to: $NEW_PATH/$(basename "$backup_path")"	# show a message
            		else								# if a save-path doesn't exist 
                		zenity --error --text="No backup available to move."	# error message
                		echo "No backup available to move." >> "$log_file" 	# save the error message to logs
                		main_menu						# return to main menu
            		fi
        	else									# if a save-path is empty
            		zenity --error --text="No backup available to move."		# error message
            		echo "No backup available to move." >> "$log_file" 		# save the error message to logs
            		main_menu							# return to main menu
        	fi
    	fi
}

# function that automates backuping
auto() {
    	local howOften="$1"	# a passing variable is taken

	choose
	zipping
	save
	
    	hours=$(echo "$backup_time" | cut -d ":" -f 1)		# get current hour
    	minutes=$(echo "$backup_time" | cut -d ":" -f 2)	# get current minutes

	idx=$$

    	extension="${backup_name##*.}"				# get extension type from a file
    	filename="${backup_name%.*}"				# get a file's name
    	backup_name_modified="${filename}_${idx}.${extension}"	# create a unique name using the index

    	if [ "$howOften" == "daily" ]; then			# if user chose to create backups daily
        	pattern="$minutes $hours * * * cp -r $NEW_PATH/$backup_name $NEW_PATH/$backup_name_modified"	# set cron command
    	elif [ "$howOften" == "weekly" ]; then			# if user chose to create backups weekly
        	pattern="$minutes $hours * * 1 cp -r $NEW_PATH/$backup_name $NEW_PATH/$backup_name_modified"	# set cron command
    	elif [ "$howOften" == "monthly" ]; then			# if user chose to create backups monthly
        	pattern="$minutes $hours 1 * * cp -r $NEW_PATH/$backup_name $NEW_PATH/$backup_name_modified"	# set cron command
    	elif [ "$howOften" == "specific" ]; then		# if user chose to create a backup once on a specific day
        	pattern="$minutes $hours $day $month * cp -r '$NEW_PATH/$backup_name' '$NEW_PATH/$backup_name_modified'" # set cron comm.
    	fi

    	(crontab -u "$(whoami)" -l; echo "$pattern") | crontab -u "$(whoami)" -	# add command to cron 
}

# function that creates a menu to automate backups
automatic_backup() {

    	options=("Specific date" "Daily" "Weekly" "Monthly")	# button options
    	backup_option=$(zenity --list --column=menu "${options[@]}" --height 300 --title="Automatic Backup")	# create a menu

    	if [ $? -eq 1 ]; then	# if some error occured
        	main_menu		# return to main menu
    	fi			

    	case "$backup_option" in
    	
        	"Specific date")									# if specific day is chosen
            	backup_date=$(zenity --calendar --text="Select a date" --date-format="%Y-%m-%d")	# choose a day in calendar
            	if [ $? -eq 1 ]; then	
            		echo "yes"
                	main_menu
            	elif [ -z "$backup_date" ]; then							# if no date was chosen
                	zenity --error --text="No backup date selected."				# error message
                	echo "No backup date selected." >> "$log_file"					# save the error message to logs
                	main_menu									# return to main menu
            	else
                	day=$(date -d "$backup_date" +"%d")	# get current day
                	month=$(date -d "$backup_date" +"%m")	# get current month
                	backup_time=$(zenity --entry --title="Select backup time" --text="Enter the backup time (HH:MM)" --entry-text="00:00")	# create a menu to input time to create a backup
                	if [ $? -eq 1 ]; then
                    		main_menu
                	elif [ -z "$backup_time" ]; then				# if no time was input
                    		zenity --error --text="No backup time selected."	# error message
                    		echo "No backup time selected." >> "$log_file" 		# save the error message to logs
                    		main_menu						# return to main menu
                	else
                    		auto "specific"						# call auto() function
                	fi
            	fi
            	;;
            	
        	"Daily")	# if daily option is chosen
        	# create a menu to input time to create a backup
            	backup_time=$(zenity --entry --title="Select backup time" --text="Enter the backup time (HH:MM)" --entry-text="00:00")
            	
            	if [ $? -eq 1 ]; then
                	main_menu
            	elif [ -z "$backup_time" ]; then				# if no time was input
                	zenity --error --text="No backup time selected."	# error message
                	echo "No backup time selected." >> "$log_file"		# save the error message to logs
                	main_menu						# return to main menu
            	else
                	auto "daily"						# call auto() function
            	fi
            	;;
            	
        	"Weekly")	# if weekly option is chosen
        	# create a menu to input time to create a backup
            	backup_time=$(zenity --entry --title="Select backup time" --text="Enter the backup time (HH:MM)" --entry-text="00:00")
            	
            	if [ $? -eq 1 ]; then
                	main_menu
            	elif [ -z "$backup_time" ]; then				# if no time was input
                	zenity --error --text="No backup time selected."	# error message
                	echo "No backup time selected." >> "$log_file"		# save the error message to logs
                	main_menu						# return to main menu
            	else
                	auto "weekly"						# call auto() function
            	fi
            	;;
            	
        	"Monthly")	# if monthly function is chosen
        	# create a menu to input time to create a backup
            	backup_time=$(zenity --entry --title="Select backup time" --text="Enter the backup time (HH:MM)" --entry-text="00:00")
            	
            	if [ $? -eq 1 ]; then
                	main_menu
            	elif [ -z "$backup_time" ]; then				# if no time was input
                	zenity --error --text="No backup time selected."	# error message
                	echo "No backup time selected." >> "$log_file"		# save the error message to logs
                	main_menu						# return to main menu
            	else
                	auto "monthly"						# call auto() function
            	fi
            	;;
            	
        	*)	# other undentified cases
            	main_menu	# return to main menu
            	;;
    	esac
}

# function that restores data
restore() {

    	restoration=("Restore a file or .zip" "Restore a folder")	# button options
    	restoration_menu=$(zenity --list --column=menu "${restoration[@]}" --height 300 --title="Restore files")	# create a menu

    	case "$restoration_menu" in
    	
        	"Restore a file or .zip")	# if a user wants to restore a file/.zip
        	
        	# create a window to choose a path to the file
        	FILE=$(zenity --file-selection --title="Select a backup file" --filename="$HOME" --file-filter="*.*" --file-filter="*")
        	
        	if [ -z "$FILE" ]; then							# if no path was chosen
            		zenity --error --text="No backup file or folder selected."	# error message
            		echo "No backup file or folder selected." >> "$log_file" 	# save the error message to logs
            		main_menu							# return to main menu
        	fi
        	;;
        	
    		"Restore a folder")	# if a user wants to restore a folder
    		
    		# create a window to choose path to the folder
        	FILE=$(zenity --file-selection --title="Select a backup folder" --filename="$HOME" --directory)
        	
        	if [ -z "$FILE" ]; then					# if no path was chosen
            		zenity --error --text="No folder selected."	# error message
            		echo "No folder selected." >> "$log_file"	# save the error message to logs
            		main_menu					# return to main menu
        	fi
        	;;
        	
    	esac 

    	SAVE_PATH=$(zenity --file-selection --title="Select a destination folder" --directory) # choose a path to save files in
    	
    	if [ -z "$SAVE_PATH" ]; then						# if no path was chosen
        	zenity --error --text="No destination folder selected."		# error message
        	echo "No destination folder selected." >> "$log_file" 		# save the error message to logs
        	main_menu							# return to main menu
    	fi

    	if [[ "$FILE" == *.zip ]]; then						# if chosen file is compressed to zip
        	unzip -d "$SAVE_PATH" "$FILE"					# unzip it 
    	else									# if chosen file is not compressed
        	cp -r "$FILE" "$SAVE_PATH"					# copy it to a chosen path
    	fi

    	zenity --info --text="Backup restored to: $SAVE_PATH"			# info message
}

# function that creates main menu
main_menu() {

    	OPTION=$(zenity --list --column=menu "Manual backup" "Automatic Backup" "Restore" --height 200)	# create a menu

    	case "$OPTION" in
    
        	"Manual backup")	
            	choose			
            	zipping
            	save
            	main_menu
            	;;
            	
        	"Automatic Backup")
            	automatic_backup
            	main_menu
            	;;
            	
        	"Restore")
            	restore
            	main_menu
            	;;
            	
        	*)	# other undentified cases
            	exit 0	# end program
    	esac
}

main_menu	# start script here
