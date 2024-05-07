#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <semaphore.h>

int B, K, N, order_in_prog = 0;
sem_t baristas[10];
int sim_time = 0;
int current_barista = 0;
int b_status[10];
int coffee_count = 0;
int wait_time = 0;
int cust_ind =0;
sem_t temp1;


// Mutex for accessing the order queue
pthread_mutex_t order_mutex = PTHREAD_MUTEX_INITIALIZER;

// Data structure for customer orders
typedef struct CustomerOrder {
    int cust_num;
    int ord_time;
    char order[100];
    int tol_time;
    int arr_time;
    int status;
} orders;

typedef struct menu {
    char item_name[200];
    int time;
} menu;

// Queue for managing customer orders
orders order_queue[100];
int order_count = 0;

time_t start_time;
sem_t temp;

// Initialize the timer
void initTimer() {
    start_time = time(NULL);
}

// Get the elapsed time in seconds
int getElapsedTime() {
    time_t current_time = time(NULL);
    return (int)(current_time - start_time);
}

// Function to simulate a customer
void *customer(void *arg) {

    char ord[100];
    int barista_id;
    // = (B % order_queue[order_count].cust_num);
            
    sem_wait(&temp1);
    printf("Customer %d arrives at %d second(s)\n", order_queue[cust_ind].cust_num, order_queue[cust_ind].arr_time);
    printf("\033[38;5;11mCustomer %d orders %s\033[0m\n",order_queue[cust_ind].cust_num, order_queue[cust_ind].order);
   // sleep(1);
    cust_ind++;
    wait_time++;
   // sleep(1);
    sem_post(&temp1);
    
    //pthread_mutex_lock(&order_mutex);
    sem_wait(&temp);
    int flag1 = 0;
    barista_id=-1;
    int cust_id = order_queue[order_count].cust_num;
    int arr_time = order_queue[order_count].arr_time;
    int threshold = order_queue[order_count].tol_time;
    int ord_time = order_queue[order_count].ord_time;
    strcpy(ord, order_queue[order_count].order);
    order_count++;

    //wait_time++;
    int f=0;
    while (barista_id == -1 && arr_time + threshold > getElapsedTime()) {
       // f =0;
       // sem_wait(&temp);
          sleep(0.1);
         // wait_time++;
        for (int h = 0; h < B; h++) {
            if (b_status[h] == 0) {
                f = 1;
                barista_id = h;
                b_status[h] = 1;
                sleep(1);
                break;
            }
        }

       // sem_post(&temp);

        if (f == 0) {
            // No available barista, wait for a short time and check again
            sleep(1); 
            sim_time++; // Adjust sim_time accordingly
          //  wait_time++; // Adjust wait_time accordingly
        }
    }
    sem_post(&temp);
   // pthread_mutex_unlock(&order_mutex);


if(barista_id!=-1){
   
    sem_wait(&baristas[barista_id]);
  //  pthread_mutex_lock(&order_mutex);
    printf("\033[36mBarista %d begins preparing the order of Customer %d at %d second(s)\033[0m\n",
           barista_id+1, cust_id, getElapsedTime());
           wait_time+=getElapsedTime() - arr_time-1;

    int flag = 1;
    int curr_time = 0;
    int leave_time = 0;

    while ((flag == 1 || flag == 2) && curr_time < ord_time) {
        sleep(1);
        curr_time++;
        sim_time++;
       // wait_time++;
        if (getElapsedTime() > threshold+arr_time) {
            flag = 2;
            leave_time = getElapsedTime()-1;
            
            
        }
    }
if(flag==2){
                 printf("\033[31mCustomer %d leaves without their order at %d second(s)\033[0m\n", cust_id, threshold+arr_time+1);
                 if(f == 0)
                 coffee_count++;
                 b_status[barista_id]=0;
}


    printf("\033[34mBarista %d completes the order of Customer %d at %d seconds(s)\033[0m\n",
           barista_id+1, cust_id, getElapsedTime());
   b_status[barista_id]=0;
    if (flag == 1) {
        printf("\033[32mCustomer %d leaves with their order at %d second(s)\033[0m\n", cust_id, getElapsedTime());
        b_status[barista_id]=0;
       // sleep(1);
    }
    sleep(1);

   // pthread_mutex_unlock(&order_mutex);
    sem_post(&baristas[barista_id]);
}
if(barista_id == -1){
    while(getElapsedTime()<=threshold+arr_time+1){
       
    }
     printf("\033[31mCustomer %d leaves without their order at %d second(s)\033[0m\n", cust_id, threshold+arr_time+1);
                 if(f == 0)
                 coffee_count++;
}


    return NULL;
}

int main() {
    char item[100];
    int t_comp;
    int order_ind = 0;
    menu menu_items[100];
    int menu_ind = 0;
  

   // printf("Enter the number of Baristas, Coffee types, and Customers:\n");
    scanf("%d %d %d", &B, &K, &N);

   // printf("Enter the Coffee type and its prep time:\n");
    for (int i = 0; i < K; i++) {
        scanf("%s %d", item, &t_comp);
        strcpy(menu_items[menu_ind].item_name, item);
        menu_items[menu_ind].time = t_comp;
        menu_ind++;
    }

  //  printf("Enter the Customer number, Order, Time of Arrival and Tolerance:\n");
    int c_num, t_arr, t_tol;
    char order[100];
    for (int i = 0; i < N; i++) {
        scanf("%d %s %d %d", &c_num, order, &t_arr, &t_tol);
        order_queue[order_ind].cust_num = c_num;
        strcpy(order_queue[order_ind].order, order);
        order_queue[order_ind].arr_time = t_arr;
        order_queue[order_ind].tol_time = t_tol;
        for (int j = 0; j < menu_ind; j++) {
            if (strcmp(menu_items[j].item_name, order) == 0) {
                order_queue[order_ind].ord_time = menu_items[j].time;
                break;
            }
        }
        order_ind++;
    }
sem_init(&temp,0,1);
sem_init(&temp1,0,1);
    for (int i = 0; i < B; i++) {
        // Initialize each semaphore with an initial value of 1
        b_status[i]=0;
        if (sem_init(&baristas[i], 0, 1) != 0) {
            perror("Failed to initialize semaphore");
            exit(1);
        }
    }

  
    pthread_t customer_threads[N];
  initTimer();
    int current_customer = 0;

   while (current_customer < N) {
    int elapsed_time = getElapsedTime();

    // Create threads for all customers with the same arrival time
    while (current_customer < N && order_queue[current_customer].arr_time == elapsed_time) {
        pthread_create(&customer_threads[current_customer], NULL, customer, NULL);
        current_customer++;
    }
}

    // Wait for customer threads to finish
    for (int i = 0; i < N; i++) {
        pthread_join(customer_threads[i], NULL);
    }
    printf("\n%d coffee wasted\n",coffee_count);
    //wait_time+=N;
    printf("Average Wait Time: %f seconds\n",(float)wait_time/N);
    return 0;
}
