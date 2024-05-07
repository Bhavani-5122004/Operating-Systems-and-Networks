[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/JH3nieSp)
# OSN Monsoon 2023 mini project 3
## xv6 revisited and concurrency

*when will the pain and suffering end?*

## Some pointers/instructions
- main xv6 source code is present inside `initial_xv6/src` directory.
- Feel free to update this directory and add your code from the previous assignment here.
- By now, I believe you are already well aware on how you can check your xv6 implementations. 
- Just to reiterate, make use of the `procdump` function and the `usertests` and `schedulertest` command.
- work inside the `concurrency/` directory for the Concurrency questions (`Cafe Sim` and `Ice Cream Parlor Sim`).

- Answer all the theoretical/analysis-based questions (for PBS scheduler and the concurrency questions) in a single `md `file.
- You may delete these instructions and add your report before submitting. 

CONCURRENCY:

Cafe Sim:

Waiting Time: If there are infinite baristas, the order of each customer will start getting made as soon as he comes in, as in the waiting time will only be 1 second per customer, so the waiting time will decrease significantly.

Ice Cream Parlor Sim:

Minimizing Incomplete Orders:

In order to minimize incomplete orders, we can reject the customer if there is a topping shortage, as soon as they arrive. So as soon as we 
calculate whether they should be rejected, we can send them away rather than make them wait until a machine is available and then
notify them. This will ensure that there is no negative effect on the reputation of the parlour due to topping shortages.



Ingredient Replenishment:

On the placing of an order, we can check to see if all the ingredients required for the order are available, if not we can immediately place
an order to replenish the ingredients



Unserviced Orders:

We can reduce the number of unserviced orders or customers having to wait until the parlor closes by prioritizing the orders based on their
arrival time and preparation time, so that we can efficiently use all the machines. A machine can prioritize an order that either arrives
first or has a lower preparation time. We can also calculate the chances of the customer leaving due to a machine not servicing them by calculating the average time that it will take for a machine to free up
and if this time is greater than a certain threshold value, we can send the customer away immediately

PBS REPORT:

                     Runtime              Waittime

RR                     30                    129
                       28                    130
                       28                    130
                       28                    129
                       28                    129

PBS                    22                    137
                       22                    133
                       24                    131
                       23                    135
                       23                    135

Average runtime for RR:   28.4
Average waittime for RR:  129.4

Average runtime for PBS:  22.8
Average waittime for PBS: 134.2



Description:


PBS:

Getting the process with highest priority: I have a process called get_proc() that loops through all the current processes and finds the one with the highest dynamic priority. I have a temp proc that I replace with the proc with the highest priority in every iteration of the loop. In the case of a tie between the temp proc and the current process in dynamic prioirty, I choose the one with higher number of times scheduled (I increment the number of times scheduled whenever I schedule the process in the scheduler function). If there is further a tie between these number of times scheduled, I choose the process with the higher start time. I have a function called get_dp() which gets the dynamic priority of a process using the formula given in the question. In the shceduler function, I check if the process is RUNNABLE and if it is the resultant process of the get_proc() function. If so, I am running the process. In schedulertest.c, I call the setpriority() function if the process is I/O bound and in this function I check if the passed priority is greater than the current static priority, and if so, I reshcedule by using the process of my get_proc() function. I also update the static priority of the process with the passed pid with the new priority.

Assumptions - A process with higher dynamic priority, less number of times scheduled and lower start time is prioritized.

COW:

Reference Links:
https://github.com/relaxcn/xv6-labs-2022-solutions/commit/d79e00a630a3944c76cf92cffc0d43f31a4ad7ee
https://blog.csdn.net/passenger12234/article/details/117912131
https://xiayingp.gitbook.io/build_a_os/labs/lab-5-copy-on-write-fork-for-xv6


In the usertrap() function in trap.c that deals with interrupts, I added a condition that deals with a page fault, if that is the interrupt that occurs. In the case the interrupt is a page fault, I first check if the virtual address at which the fault occurred is valid. If it is invalid (if it is out of bounds), I kill the process. I also check the validity of the PTE (it must have valid bit, user bit and read-shared-write bit set). If the PTE is invalid, I kill the process. If the PTE is valid, I allocate some memory for the contents of the old physical address space, move it into the new memory, and free the old physical address space. I also get the flags from the old physical address space and assign them to the new physical address space and set the write bit to 1 (to make it writable). In order to map one copy read/write in the child’s address space and the other copy read/write in the parent’s address space, I modified the uvmcopy() function to take care of it. I am first setting all the valid PTEs to read-only. Then I loop through all the PTEs of the pagetable and if the PTE is valid, I get its physical address and its corresponding flags (only the page faulted PTE will be in write mode now) and update my reference array to keep track of the number of copies of that page and then map a copy to the child's address space. To update the PTE in the kernel, I have updated the copyout() function in a similar way that I updated uvmcopy(). I check if the physical address corresponding to the virtual address is valid and if the virtual address itself is valid, if not I kill the process. If it is valid, I allocate some memory for the contents of the physical address space and move it into the new memory. I also get the flags from the old PTE, unmap the old virtual-to-physical mapping for va0 using uvmunmap and update the PTE to point to the new physical memory address (that I just allocated). 




CONCURRENCY:

Cafe Sim:
I have an array of threads, one for each customer and an array of semaphores, one for each barista. I also have an array for barista status to indicate if that barista is free or busy. I have an array of structs, with each struct corresponding to one order. I start a timer and loop through my customer array, if there is any order with the customer entering at that time, I create a thread for that customer and call the customer function on creation. Inside the customer function, I use a pair of semaphores to lock a section of code that prints that a customer has arrived along with their order. I then have another pair of semaphores to extract all the details of the order and loop through all the baristas to find an available one to make the order. If there exists no such available barista, then I wait for sometime (sleep(1)) and try again until I get an available barista - set the status of that barista to 1 aka busy - (then the loop is broken and the barista starts making the order) or the tolerance time of the customer has been exceeded (in which case the loop breaks but the customer leaves with an unfulfilled order). In the case the barista starts making the order, I run a loop to wait for the duration of the order preparation and if the tolerance time of the customer is up within that time, they leave, otherwise, they stay and they collect their order. The preparation and collection/leaving without the order is enclosed within a pair of semaphores which is the semaphore of my barista semaphore array. After the customer leaves in any case, i set the status of that barista to 0 aka available.


Ice Cream Parlor Sim:
I have an array of threads, one for each customer, an array of semaphores, one for each machine, an array of threads, one for each machine start time, an array of threads, one for each machine end times. I have an array of structs, one for each order of a customer as well as a machine status array, to keep track of the status of each machine and an array of sturcts for the machines to keep track of their information. I start a timer and I create the machine start threads which go into my machine_start function which spins the thread until its start time has been reached and prints so. Similarly, I also create the machine end threads which go into my machine_end function which spins the thread until its end time has been reached and prints so. I then create my customer threads and send them into the customer function only if the start time/ arrival time of that thread has been reached. Inside the customer function, I have a pair of semaphores to print the arrival of a customer and their orders (I use a frequency array becuase different orders may have the same customer so you do not want to print twice). Then I have a pair of semaphores to extract all the information of the order and calculate whether the order should get rejected (it checks the quantity of each topping). I then loop through all the machines and if I do not find an available machine (machine status must be 0 -free, machine start time should be >= current time, machine end time should be <= current time and time for preparation of the order from the current time should happen before the machine stops), I wait for some time (sleep(1)) and try again until a machine available - set machine status to 1 - or the parlour closes. Otherwise, I break out of the loop. I then check if the order is rejected, in that case I print so, make the machine status free and also update the order array to loop through all orders of that customer. If the order has not been rejected,  I run a loop to wait for the duration of the order preparation and if the machine breaks within that time, I print so and set the machine status to 0. Otherwise, I print that the order has been successfully completed and if that order is the last order of that particular customer, I say that the customer has left and I make that machine free.The preparation and collection/leaving without the order is enclosed within a pair of semaphores which is the semaphore of my machine semaphore array.
