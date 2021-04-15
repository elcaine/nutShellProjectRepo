# COP4600 -- Nutshell term project -- Spring 2021
# FAREED KHAMITOV & DANIEL WINTERS


## DESCRIPTION
The goal of this project was to create a Korn shell-like interface.

## DESIGN
Lexxer/Parser tools were utilized to facilitate input.  Pretty colors were used in the development of this project in order to more clearly see different input and output data.  They were left in and slightly modified to reflect similar styles in established shell programs.

### Programming language
Despite the option to use c++, we chose to build our project in c to gain more experience in a language we were both less practiced in.

### Lexxer / Parser
Flexx and Bison were used as the lexxer and parser tools respectively.  There still exist some bugs that have the effect of leaving a word/token from the previous command in the input buffer causing unexpected behavior in subsequent commands.  Sometimes a command will not work correctly unless another (usually single-word) command has been executed before it.  Executing "cd" with no arguments and then "ls" as the next command does not work -- immediately executing "ls" again does work however.

### Built-in commands
1. **setenv**: blah blah blah
2. **printenv**: blah blah blah
3. **cd**: Works as expected.  Notes:  "cd" without any arguments returns to the home directory (a built-in command, "home" also achieves this).  "cd ." politely ignores a meaningless command.  "cd .." changes to the current directory's parent directory.  While in the home directory the current user and dollar sign prompt only are given.  While in any other directory the path is printed also.  This was done to replicate currently established shells.  Was able to implement this in such a way that a space did not require quotes to execute (only one space can be handled however, although this could have been expanded with more time).
4. **alias**: blah blah blah
5. **bye**: Works as expected.
6. **wipe** (not specified in instructions -- added as an additional tool during development):  Performs the equivalent of the common, "clear" command.

### Non-built-in commands
Most non-built-in commands work mostly as expected.  Many work exactly as they should, while some require input assistance to achieve proper execution.  The general bug here, aside from the buffer problems noted in Lexxer/Parser section, is that some commands require double quotes around the arguments and some do not.  A few re-creatable examples:  "touch" works fine without double quotes, "ls" works fine without double quotes (unless the first argument is a regular character -- "ls -l" and "ls /mnt" work fine, but "ls Public" does not).  Those that do not work:  "rm", "cat", "nano" (if file already exists, otherwise fine).  In both cases, working and not working, there are many more -- these were offered as, what is believed to be, more commonly used and easily re-creatable instances.

### Environment Variable Expansion
blah blah blah

### Wildcard Matching
blah blah blah

### File Name Completion
blah blah blah

### I/O Redirection
To be excruciatingly honest, despite reading the entirety of the project pdf instructions numerous times, it never really caught the attention of the "developers" of this project that this, as noted in the last section of the noted document, was to be an instrumental part of testing.  Considerable effort was made to throw this in as the deadline approached, but it is not implemented.

## WORK DISTRIBUTION
Both developers started the day the project was released and contributed an equal amount of time,  effort, and blood-&-tears.  But, Fareed did complete most of the components of the project, including Flexx and Bison.  Daniel completed the provided cd starter code, the bulk of non-built-in command processing (which became a massive time sink), pwd, home, and wipe commands.  Daniel also began with a proof-of-concept work that eased both developers into the project by means of a simple c-code while loop that called various command functions, although none of this actually remained in the final deliverable.  Fareed built the Flexx and Bison implementation and took the proof of concept together to get the very beginnings of our deliverable started with the sample code that was provided.  The shell, of the shell -- the command prompt itself -- was formatted and tweaked over the course of the whole project by both developers.  Daniel wound up having to start all over on his contributions a few weeks in as compiling, using the Makefile, and other various problems were just not able to be overcome within the IDE he was using.  After switching to the text editing feature of the IDE only and running make commands, as well as nutshell testing, in Ubuntu he was able to get back up to speed and make more contributions to the final work.  Fareed made strong advancements during this time, as evidenced by most of the built-in commands and other specifications being completed by him.

Both developers communicated constantly via MS Teams and Zoom.  Both were very prompt in replies, very receptive to concerns expressed and questions asked, and generally enjoyed working with each other.

## TESTING
Testing was done extensively on both developer's systems; one a Mac, the other a PC, which introduced a unique quandary:  a particular variable on one system would throw a warning if it had an ampersand dereferencing it while it would throw a warning on the other's system if the ampersand was not present.  The curious grader is invited to review functions "runCommand" and "runGlobal" towards the end of the "thatHalf.c" file for variable, "status."
  
