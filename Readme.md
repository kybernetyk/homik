#Homik - ncurses server monitor
So this is essentially my "let's learn ncurses" project. When (if) this project is finished it's intended to be a server monitor like pingdom or uptimerobot. Only local and in your tmux ;)

Of course not intended for mission critical stuff. But useful to track local machines, etc. (And running stuff in your terminal gives you extra hacker cred of course).

#Current Status
Currently it's barely a prototype... the UI code is non-existent, the network code is comically broken. The only thing that works is concurrency (thanks to the great libdispatch - best piece of software engineering in the last 10 years or so!).

#Screenshots
See the screenshots folder. But here's one (the upper left window):

![Homik Screenshot](/screenshots/screen-4.png?raw=true "Homik Screenshot")

#License
Affero GPL 3
