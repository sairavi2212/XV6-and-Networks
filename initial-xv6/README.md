# xv6

# SYSCOUNT
### I have added an entry in the usys.pl file and also defined in the syscall.h with a #define.

### In syscall.c I have added the prototype of the function that handles this system call and mapped the syscall numbers to the function that handles this system call.

### In sysproc.c I have added a function for syscount which is called from the syscount.c which returns the number of times the system call with mask as mask is called in the execution of the command given.

### In user.h also I have added a function for the system call.

### I have modified the proc.h by adding a new array syscall_cnt where syscall_cnt[i] denotes the number of times ith system call has been called. Since we have to account for counting in the child process generated the command given we will add the syscall_cnt[i] of child to the parent in the exit function since every child would exit. I initialised the syscall_cnt[i] to 1 in void syscall function in syscall.c file since this is the function which calls the function that handles the system call getSysCount.

### Finally I have returned the syscall_cnt[i] where mask is the mask of ith system call in sysproc.c .

# SIGALARM AND SIGRETURN

### Defining the prototypes and adding the entries for this system call is done in similar manner as above.

### When we get a timer interrupt I am incrementing the ticks it has consumed and if it becomes equal to the desired ticks then just set the program counter of the trpaframe of process to the handler function. All these happen in usertrap function in the proc.c .

### In case of sigreturn, Just restore the stored backup trapframe and set its ticks to 0.

### Added feilds in proc.h are a backup trapframe so that when it returns from the handler function we restore the process trapframe with this backup , alarm_state for checking whether the process is in sigalarm, total_ticks is the given ticks after which handler is called and a handler for the function to be called after total_ticks , ticks for counting the number of ticks passed in this process.

### Initialised all the attributes in allocproc and freed the backup trapframe in freeproc

## For both the implementation of the scheduler, I am having a global variable system_time which is set to 0 initially. Whenever a process arrives (with respect to the implementation like changing the queue is also considered as arrival in case of MLFQ), I am marking the arrival time of the process to be this variable and incrementing the variable.  

## We can use the ticks in the inbuilt xv6 code as the arrival time of a process but since multiple process can arrive in the same tick then we cannot distinguish between their arrival times. If we use ticks are their arrival time then they all would be marked with same arrival time since they all occur in a single tick. But if we use the global variable then every time a process is created we assign this variable to the arrival time of the process and increment the variable so though multiple process arrive within in a single tick still we can distinguish between the process by their actual order of arriving.

# LBS

### Added settickets function where this function would just set the tickets for a process and initialised number of tickets to 1 in allocproc. Everytime we call settickets it just overwrites the tickets currently present for the process.   

### In proc.c, in the scheduler function I am calculating total number of tickets and then using a random function I took a winning ticket so now I will be chosing the process with least arrival time and having tickets more than equal to winning ticket and then just context switch to this process.


# MLFQ

### I have implemented it using the queues and defined the functions required for implementing the queues in proc.h.

### I have queue_num,arrival_time_queue,ticks_in_queue into the proc structure where first one is the queue number in which the process currently resides and next is the time when the process entered a certain queue and last one is the number of ticks passed since it entered a certain queue.

### When we get a clock interrupt then we increment ticks_in_queue for every process and check if the ticks_in_queue equals the time slice of the queue the process is present in, if so then just move the process to the next queue and set arrival_time_queue to the sys_time variable and set ticks_in_queue to 0.

### If we get any other interrupt which inturn means in between two clock interrupts, we just enqueue it to the end of the same queue and mark its ticks_in_queue to be 0 and its arrival time to the current sys_time and increment the sys_time.

### For every 48 ticks i.e. (ticks % 48 = 0), we set all processes from the queues to highest priority i.e. set their queue_num to 0 and set the arrival time and ticks_in_queue appropriately.

### In the scheduler function, iterate through all the processes and enqueue them appropriately in the queues. Starting from the topmost queue, get the process having the least arrival time (and least queue_num) and context switch to that process basically schedule that process.

# MLFQ GRAPH

![Graph](./src/Screenshot%20from%202024-10-15%2002-17-35.png)

# TIME COMPARISION

## ROUND ROBIN (Format -> Number of total processes : I/O Processes )

### 10:5  --->  18 , 120
### 20:10  ---> 16 , 142
### 20:5  ----> 24 , 153

## LBS (Format -> Number of total processes : I/O Processes )

### 10:5  ---> 7 , 116
### 20:10  ---> 10 , 132
### 20:5  ----> 9 , 140

## MLFQ (Format -> Number of total processes : I/O Processes )

### 10:5  ---> 13 , 120 (rtime,wtime)
### 20:10  ---> 15 , 138 
### 20:5  ----> 23 , 143

### LBS wait time is less and performs better in this case because the schedulertest code spawns I/O process first and frees the CPU early and hence it finishes faster than other processes which means shorter process arrive first and finish early which means shorter processes arrive early and finish early which is the best case for FCFS. So FCFS i.e. LBS with arrival times performs better.

# IMPLICATION OF ADDING ARRIVAL TIME TO LBS

### When we add arrival time to lbs where all the processes have same tickets, we are essentially increasing the overhead and this is actually FCFS since the scheduling in LBS happens through the arrival times. The scheduling happens based on arrival times so first the first process that comes would be scheduled and so on.

### If there is a process with longer running time and it is the first process to arrive then the further coming processes would starve which is the main disadvantage of FCFS.

### PITFALLS: This is called convoy effect which means if a long running process arrives first then it would starve the later coming processes. These all would apply when all processes have same number of tickets. The user can game the scheduler by setting the process he wants to run with more number of tickets. If there are processes with same number of tickets and a long running process among such process arrives first then all processes with same number of tickets arriving after the long running process would starve.

### If different processes have different number of tickets then we chose a process randomly based on their ticket distribution and this process would be scheduled. If there is a process with high number of tickets then it is most probable that this process would be scheduled and would monopolise the scheduler. So if tickets are not too high then this method would ensure fairness. So this is better than FCFS since it ensures fairness.

### Hence if the shorter processes arrive first then LBS with arrive times is the best since it is best case for FCFS.


 
