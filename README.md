# COP4600 -- Nutshell term project -- Spring 2021
# FAREED KHAMITOV & DANIEL WINTERS


## DESCRIPTION
The goal of this project was to create a Korn shell-like interface.

## DESIGN
Lexxer/Parser tools were utilized to facilitate input.  Pretty colors were used in the development of this project in order to more clearly see different input and output data.  They were left in and slightly modified to reflect similar styles in established shell programs.

### Programming language
Despite the option to use c++, we chose to build our project in c to gain more experience in a language we were both less practiced in.

### Lexxer / Parser
Flexx and Bison were used as the lexxer and parser tools respectively.  There still exist some bugs that have the effect of leaving a word/token from the previous command in the input buffer causing unexpected behavior in subsequent commands. Majority of the bugs that we ahve encountered are due to the counter logic that checks if the argument is the first or not. While some commands like alias and cd are relying on it due to their nature, it can also produce bugs i.e.  Sometimes a command will not work correctly unless another (usually single-word) command has been executed before it. Due to the counter issue.  Executing "cd" with no arguments and then "ls" as the next command does not work -- immediately executing "ls" again does work however.
### Not implemented 
These were not implemented because the "developers" were lazy, did not want to learn. But we simply ran out of time. Once we hit the wall with pipes, we realized that either our logic of executing commands is flawed or we have been doing the whole project wrong. Starting over was definetly not a choice. 

1.Pipes 


3.Redirection


5.Command table


6.'?' wildcard matching


8.~tilde expansion


10.file name completion


### Built-in commands
1. **setenv variable word**: This command sets the value of the variable variable to be word. Works as intended
2. **unsetenv variable**: This command will remove the binding of variable.
3. **printenv**: This command prints out the values of all the environment variables, in the formatvariable=value, one entry per line. Works as intended
4. **cd**: Works as expected.  Notes:  "cd" without any arguments returns to the home directory (a built-in command, "home" also achieves this).  "cd ." politely ignores a meaningless command.  "cd .." changes to the current directory's parent directory.  While in the home directory the current user and dollar sign prompt only are given.  While in any other directory the path is printed also.  This was done to replicate currently established shells.  Was able to implement this in such a way that a space did not require quotes to execute (only one space can be handled however, although this could have been expanded with more time).
5. **alias name word**: Adds a new alias to the shell. Works as expected. Will give error message if trying to create a loop or self alias.  
6. **unalias name**: deletes selected alias
7.  **alias**:prints all aliases, prints name = word
8. **bye**: Works as expected.
9. **wipe** (not specified in instructions -- added as an additional tool during development):  Performs the equivalent of the common, "clear" command.

### Non-built-in commands
Most non-built-in commands work mostly as expected.  Many work exactly as they should, while some require input assistance to achieve proper execution.  The general bug here, aside from the buffer problems noted in Lexxer/Parser section, is that some commands require double quotes around the arguments and some do not.  A few re-creatable examples:  "touch" works fine without double quotes, "ls" works fine without double quotes (unless the first argument is a regular character -- "ls -l" and "ls /mnt" work fine, but "ls Public" does not).  Those that do not work:  "rm", "cat", "nano" (if file already exists, otherwise fine).  In both cases, working and not working, there are many more -- these were offered as, what is believed to be, more commonly used and easily re-creatable instances.

### Environment Variable Expansion
Achieved by the start condition that begins at the "${" and ends at "}" That check the var table if found and returns the word for it as a string. 
Has a bug when going through "" first e.g. alias a "jj ${this}"
### Wildcard Matching
Wildcard matching is achieved using glob() function. Currently only '?' wildcard matching is not working, however the '*' works as intended. 

### File Name Completion
Not implemented

### I/O Redirection
The command "./nutshell < commands.txt" is working. However, not throughly tested since we dont have sample text file that we can test with and make sure it runs accordingly. 

## WORK DISTRIBUTION
Both developers started the day the project was released and contributed an equal amount of time,  effort, and blood-&-tears.  But, Fareed did complete most of the components of the project, including Flexx and Bison.  Daniel completed the provided cd starter code, the bulk of non-built-in command processing (which became a massive time sink), pwd, home, and wipe commands.  Daniel also began with a proof-of-concept work that eased both developers into the project by means of a simple c-code while loop that called various command functions, although none of this actually remained in the final deliverable.  Fareed built the Flexx and Bison implementation and took the proof of concept together to get the very beginnings of our deliverable started with the sample code that was provided. As well as supporting functions for the wildcard matching. The shell, of the shell -- the command prompt itself -- was formatted and tweaked over the course of the whole project by both developers.  Daniel wound up having to start all over on his contributions a few weeks in as compiling, using the Makefile, and other various problems were just not able to be overcome within the IDE he was using.  After switching to the text editing feature of the IDE only and running make commands, as well as nutshell testing, in Ubuntu he was able to get back up to speed and make more contributions to the final work.  Fareed made strong advancements during this time, as evidenced by most of the built-in commands and other specifications being completed by him. Both members contributed their all free time and attention to this project.

Both developers communicated constantly via MS Teams and Zoom.  Both were very prompt in replies, very receptive to concerns expressed and questions asked, and generally enjoyed working with each other.

## TESTING
Testing was done extensively on both developer's systems; one a Mac, the other a PC, which introduced a unique quandary:  a particular variable on one system would throw a warning if it had an ampersand dereferencing it while it would throw a warning on the other's system if the ampersand was not present.  The curious grader is invited to review functions "runCommand" and "runGlobal" towards the end of the "thatHalf.c" file for variable, "status."
