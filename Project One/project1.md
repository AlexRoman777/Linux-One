# Project One - Linux One

## Step 1: Connect to the server

Old server:

```bash
ssh alerom@51.120.19.77
```

New server:

```bash
ssh alerom@13.53.57.72
```

---

## Step 2: Password

```bash
passwd
```

<kbd>xxx😉</kbd>

---

## Step 3: Create a hidden folder in your home directory and give only your user rights to read, write and use that folder

```bash
mkdir .project1
chmod 700 .project1
```

---

## Step 4: Soft link to the folder you just created

```bash
mkdir /bin/linux1/alerom
```

```bash
ln -s /home/alerom/.project1 /opt/linux1/alerom/inlup1
```

---

## Step 5: syslog + syslog.sum

```bash
head -n 30 /var/log/syslog | tee ~/syslog && echo "Username: $(whoami)" | tee -a ~/syslog
```

```bash
sha256sum ~/syslog | tee ~/syslog.sum
```

---

## Step 6

```bash
# find all users except alerom and save it to a file called others
find /home/???? 2>&1 | grep -v "Permission denied" | grep -v "alerom" | sort -k2r -t/ > others # find all users except alerom
```

```bash
find /home -maxdepth 1 -type d -not -name $(whoami) -printf '%f\n' | sort -r > ~/.project1/others && echo "Command used: find /home -maxdepth 1 -type d -not -name $(whoami) -printf '%f\n' | sort -r > ~/.project1/others" >> ~/.project1/others
```

---

## Step 7

```bash
df -h | head -n 1 > rootspace : df -h | grep "/$" >> rootspace
```

```bash
df -h / > rootspace 
```

```bash
df -h / | awk 'NR==2{print $4}' > rootspace
```

## Show available space and save it to a file called rootspace like this: Available space: 1.8G

```bash
echo -n "Available space: " && df -h / | awk 'NR==2{print $4}' > rootspace && cat rootspace

```

```bash
df -h / | awk 'NR==2{print "Available space: "$4 /n"Total: "$2}' > rootspace
```

```bash
df -h / | awk 'NR==2{print "Available space: "$4"\nTotal space: "$2}' > rootspace
```

```bash
echo "Command used: df -h / | awk 'NR==2{print "Available space: "\$4}' > rootspace" > rootspace && df -h / | awk 'NR==2{print "Available space: "$4}' >> rootspace
```

---

## Problem 7

```bash
df -h / | awk 'NR==2{print "Available space: "$4}' > rootspace && echo "Command used: df -h / | awk 'NR==2{print "Available space: "\$4}' > rootspace" >> rootspace
```

---

## Problem 8

```bash
#!/bin/bash

# Set variables
userName=$(whoami)
# Set date and time
currentTime=$(date +"Date: %Y-%m-%d Time: %H:%M:%S")
# Set shell jobs. -l is for long format
shellJobs=$(jobs -l)
# Set processes
userProcesses=$(ps -u $userName) # -u is for user
# Set memory usage in human readable format
memoryUsage=$(free -h) # -h is for human readable format
# Set number of running processes
numberOfProcesses=$(ps aux | wc -l) # aux is for all processes and wc -l is for line count
# If there are no shell jobs, then i set the variable to "There are no runing shell jobs"
[ -z "$shellJobs" ] && shellJobs="There are no runing shell jobs" # -z is for checking if the variable is empty

cat <<END # Print the report starting from here to the END
######################################
        Custom System report        
######################################
                                          
a. Current user: $userName                
                                          
b. $currentTime                      
                                          
c. Shell jobs for $userName:      
$shellJobs                               
                                          
d. Processes for $userName:            
$userProcesses                           
                                          
e. Current memory usage:             
$memoryUsage                         
                                          
f. Number of processes running:       
$numberOfProcesses               
                                          
END
```
