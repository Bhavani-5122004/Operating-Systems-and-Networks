# Testing system calls

## Running Tests for getreadcount

Running tests for this syscall is easy. Just do the following from
inside the `initial-xv6` directory:

```sh
prompt> ./test-getreadcounts.sh
```

If you implemented things correctly, you should get some notification
that the tests passed. If not ...

The tests assume that xv6 source code is found in the `src/` subdirectory.
If it's not there, the script will complain.

The test script does a one-time clean build of your xv6 source code
using a newly generated makefile called `Makefile.test`. You can use
this when debugging (assuming you ever make mistakes, that is), e.g.:

```sh
prompt> cd src/
prompt> make -f Makefile.test qemu-nox
```

You can suppress the repeated building of xv6 in the tests with the
`-s` flag. This should make repeated testing faster:

```sh
prompt> ./test-getreadcounts.sh -s
```

---

## Running Tests for sigalarm and sigreturn

**After implementing both sigalarm and sigreturn**, do the following:
- Make the entry for `alarmtest` in `src/Makefile` inside `UPROGS`
- Run the command inside xv6:
    ```sh
    prompt> alarmtest
    ```

---

## Getting runtimes and waittimes for your schedulers
- Run the following command in xv6:
    ```sh
    prompt> schedulertest
    ```  
---

## Running tests for entire xv6 OS
- Run the following command in xv6:
    ```sh
    prompt> usertests
    ```

---

Networking:

1. How is your implementation of data sequencing and retransmission different from traditional TCP? 

Ans: Since my implementation of TCP is based on the UDP protocol, like UDP and unlike traditional TCP, it is connectionless

     Traditional TCP has mechanisms to account for flow control, but my implementation does not account for flow control and has no mechanisms to deal with it
     
     Similarly, unlike traditional TCP, my implementation has no mechanisms to account for congestion.

     Traditional TCP has mechanisms to account for erroneous and duplicate packets, which my implementation does not check for.

     Traditional TCP will wait to recieve an ACK bit from the receiver before sending the next chunk of data but my implementation does
     not wait for an ack bit to be recieved and rather retransmits the chunks for which no ACK bit was recieved, after transmitting
     all the data chunks.

     Traditional TCP does not inform the reciever how many data chunks it will be sending, but in my implementation, the sender 
     informs the reciever about the number of data chunks it will be sending. 



2. How can you extend your implementation to account for flow control?

Ans: Flow control involves implementing mechanisms to avoid having the sender send data too fast for the TCP receiver to receive and
     process it reliably. In order to account for flow control in my implementation, I can set a threshold for the number of packets that
     can be sent to the sender (server) without recieving an ack bit. If the number of packets exceed the threshold, I can wait and stop transmission
     until enough ack bits are recieved such that the number of packets with no ack bit is less than the threshold.
     In the case of the receiver (client), I can set a range for packet transmission such that whenever a packet is recieved, if the 
     packet is out of that range, it gets discarded since it is either a duplicate, too old, or out of order.



Scheduling:

Comparisons:

RR vs FCFS (1 CPU):

        Average runtime                                   Average waittime


RR:         28                                                 212
            29                                                 214
            28                                                 211
            28                                                 210
            29                                                 214

FCFS:       26                                                 205
            27                                                 207
            26                                                 205
            27                                                 209
            26                                                 205

MLFQ:       26                                                 202
            24                                                 197
            27                                                 206
            26                                                 205
            28                                                 210            



Average rtime for RR: 28.4
Average wtime for RR: 212.2

Average rtime for FCFS: 26.4
Average wtime for FCFS: 206.2

Average rtime for MLFQ: 26.2
Average wtime for MLFQ: 204


Description:

FCFS: In order to implement FCFS scheduling, I added a field to the proc struct called arrival which I set as the number of ticks when the process was created ( this is the arrival time of the process ). Then I created a function called minproc() which loops through the proc array and finds the process with the minimum arrival time and returns it. I modified the RR scheduler code to not yield and to run processes that are in the running state and which are the output of the minproc function ( the process which arrived first ).

MLFQ: In order to implement MLFQ I added a field to the proc struct called priority which stores the priority of the process, a field called numticks to keep track of the time slice, and a field called boost which keeps track of the priority boost time. I ran a while loop that runs until the proc array is empty and inside the loop, I looped through all the processes in the proc array and ran them if the priority was 0. I keep track of the number of processes left in the proc array of each priortiy after the running process either completes, gets pushed to the lower queue ( In this case I am changing the priority of the process if the time slice ( if numticks has exceeded the time slice value ) has been exceeded ), or gets a priority boost ( 2 ticks in my case ). Then, I check if there are no processes with priority 0. In that case I loop through the proc array and similarly run all processes with priority 1. If there are left over processes with priority 0, I reiterate through the whole loop and run processes with priority 0. I repeat the same and loop through the array again and run processes with priority 2 only if there are no more processes with priority 0 or 1. The if there are no processes with priority 0,1 or 2, I loop through the array and run all processes with priority 3. I repeat this until all the processes have finished running ( if the proc array is empty ).


