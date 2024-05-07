[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/76mHqLr5)
# Description

 - prompt.c: the function prompt prints the username and system name in the given format as the prompt. It also prints the current directory or time taken (if it is called after a foreground process taking more than 2s to run) conditionally (using flags)

 - A_2.c: the function trim takes the input given by the user and trims it based on leading whitespaces (' ' and '\t'), trailing whitespaces and middle whitespaces

 - A_3.c: the function warp splits all the arguments of the warp command and redirects them (performs the warp command/functionality) one by one

 - A_4.c: the function permstring returns a string of the permissions of each stat struct passed into it
       <br> the function is_exec returns 1 if the stat struct has executable permissions (executable permission for the owner)
       <br> the function compare_entries is the comparator function to sort the files and directories in alphabetical order
       <br> the function printfileinfo prints all the file info (the same info as displayed by ls -l in the terminal) of a given path
       <br> the function b_count is used to count the total block size
       <br> the function peek is used to perform the functionality of peek using flags
       <br> the function peekonly is used when there is no argument for peek

 - A_5.c: <br> the function pasteventsfunc adds the passed argument into pastevents array as well as the pastevents file
          <br> the function purge clears the array and file and sets the array index to 0
          <br>the function execute finds the command at the index from the end of the pastevents array and executes it

 - A_6.c: <br> the function syscom is used to run foreground processes and returns the time taken to run the process
          <br>the function bgupdate updates the array of structs storing details of the completed background processes
          <br> the function bgcom is used to run background processes and update the array of structs storing details of the completed background     processes after the process is complete

 - A_7.c: the function process_info prints the required information the the given pid

- A_8.c:  <br> the function satisfies_dir checks if the passed entry is a directory
          <br> the function satisfies_file checks if the passed entry is a file
          <br> the function checkboth prints the relative paths of both directories and files
          <br> the function checkdir prints the relative paths of only directories
          <br> the function checkfile prints the relative paths of only files
          <br> the function countdir counts the number of directories in the given path
          <br> the function countfile counts the number of files in the given path
          <br> the function getdir gets the path of the directory so that we can redirect into that directory
          <br>the function checkfilep is used to check the permissions of the given file
          <br>the function findfile is used to implement the seek functionality using flags



# Assumptions
 - Erroneous commands are being added to the pastevents file
 - Both executable files and directories (which have executable permissions for owner) are being displayed in green
 - For commands like sleep 5 ; echo hi the time taken (and displayed in the next prompt) is that of echo so the next prompt will not display any time, so 5 will not be displayed in the next prompt
 - Commands with the word 'pastevents' in them, like pastevents ; sleep 5 are not added to the pastevents file
 - I assumed peek - gives an error
 - Commands like sleep 5; pastevents execute 2 will execute the 2 commands but not add the input to the pastevents array because the input has the string 'pastevents' in it
- -al ,-la, -a -l, and -l -a display the same output
- proclore prints '+' for a foreground process
- for just peek only unhidden files and directory names are displayed