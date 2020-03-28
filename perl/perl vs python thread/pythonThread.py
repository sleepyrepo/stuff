
#!/usr/bin/python

import threading

thrs = []
count = 3                       #number of threads to create

def dosth():
  sth = ""
  for i in range(1, 0xffffff):
    sth += "%d"%i

for i in range(1, count):
  t = threading.Thread(target=dosth)
  t.start()
  thrs.append(t)

for t in thrs:
  t.join


#run with
#time python ./perlVsPyThread.py
#real -> tome start to finish
#user -> CPU time in user mode
#sys -> CPU time in kernel mode
