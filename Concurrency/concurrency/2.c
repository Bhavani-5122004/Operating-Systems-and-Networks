#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <semaphore.h>


int N, K, F, T;
sem_t machines[10];
int m_status[10];
sem_t temp1;
int cust_ind = 0;
int m_start[10];
int m_end[10];
int s_ind = 0;
int e_ind = 0;
int close_time = 0;
sem_t mt1;
int num = 0;
int order_ind = 0;
int freq[100];
int freq2[100];
sem_t temp2;
int freq3[100];
int sent = 0;
int curr_cust_count = 0;
int mach_count = 0;
int m_ind = 0;
int flav_ind = 0;
int top_ind = 0;


// Mutex for accessing the order queue
pthread_mutex_t order_mutex = PTHREAD_MUTEX_INITIALIZER;

// Data structure for customer orders
typedef struct CustomerOrder
{
    int cust_num;
    int arr_time;
    char orders[200];
    int ic_count;
    int flav_count;
    int ic_num;

} orders;

typedef struct timings
{
    int start;
    int end;
    int status;
} timings;

timings m_time[100];

typedef struct flavors
{
    char flavor[100];
    int t_make;
} flavors;

flavors flav[100];

typedef struct toppings
{
    char topping[100];
    int t_top;
} toppings;

toppings top[100];


orders order_queue[100];
int order_count = 0;

time_t start_time;
sem_t temp;


void initTimer()
{
    start_time = time(NULL);
}


int getElapsedTime()
{
    time_t current_time = time(NULL);
    return (int)(current_time - start_time);
}

int send_back(char *input)
{
    char *token = strtok(input, " ");

    while (token != NULL)
    {
     
        for (int j = 0; j < T; j++)
        {
            if (strcmp(token, top[j].topping) == 0)
            {

                if (top[j].t_top == 0 && top[j].t_top != -1)
                {
                    
                    return 0;
                }
                else if (top[j].t_top != -1)
                {
                    
                    top[j].t_top -= 1;
                    // Topping is available
                    return 1;
                }
            }
        }
        token = strtok(NULL, " ");
    }

    
    return 1;
}

int get_prep_time(char *input)
{
    char *token = strtok(input, " ");
    int count = 0;
    if (token != NULL)
    {
        for (int i = 0; i < F; i++)
        {
            if (strcmp(token, flav[i].flavor) == 0)
            {
                count = flav[i].t_make;
            }
        }
    }
    return count;
}
pthread_mutex_t machine_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t machine_condition = PTHREAD_COND_INITIALIZER;
sem_t mt;

void *machine_start(void *arg)
{
    int machine_id = *((int *)arg); // Extract the machine index
    int arrival_time = m_start[machine_id];
    int current_time;
    sem_wait(&mt);

    while (1)
    {
        current_time = getElapsedTime();
        if (current_time >= arrival_time)
        {
            printf("\e[38;2;255;85;0mMachine %d has started working at %d second(s)\033[0m\n", machine_id + 1, current_time);
            break;
        }
    }
    sem_post(&mt);
    free(arg);
    return NULL;
}

void *machine_end(void *arg)
{
    int machine_id = *((int *)arg);
    int end_time = m_end[machine_id];
    int current_time;
    sem_wait(&mt1);

    while (1)
    {
        current_time = getElapsedTime();
        if (current_time >= end_time)
        {
            printf("\e[38;2;255;85;0mMachine %d has stopped working at %d second(s)\033[0m\n", machine_id + 1, current_time);
            m_end[machine_id] = 0;
            break;
        }
    }
    sem_post(&mt1);
    free(arg);
    return NULL;
}

sem_t temp3;
int machine_ind = 0;

// Function to simulate a customer
void *customer(void *arg)
{

    char ord[100];
    int machine_id;
    char orde[100];
    // = (B % order_queue[order_count].cust_num);

    sem_wait(&temp1);

    if (freq[order_queue[cust_ind].cust_num] == 0)
    {
        curr_cust_count++;
        printf("Customer %d enters at %d second(s)\n", order_queue[cust_ind].cust_num, order_queue[cust_ind].arr_time);
        printf("\033[38;5;11mCustomer %d orders %d icecream(s)\033[0m\n", order_queue[cust_ind].cust_num, order_queue[cust_ind].ic_count);
        for (int g = 0; g < order_queue[cust_ind].ic_count; g++)
        {
            printf("\033[38;5;11mIcecream %d: %s\033[0m\n", g + 1, order_queue[cust_ind + g].orders);
        }
        freq[order_queue[cust_ind].cust_num]++;
        sleep(1);
    }

    cust_ind++;

    //    sem_wait(&temp);
    int flag1 = 0;
    machine_id = -1;
    int rej = 0;
    char run_ord[10][100];
    char run_ind = 0;
    int cust_id = order_queue[order_count].cust_num;
    int arr_time = order_queue[order_count].arr_time;
    int ic_count = order_queue[order_count].ic_count;
    strcpy(orde, order_queue[order_count].orders);
    int ic_num = order_queue[order_count].ic_num;

    int tem = order_count;

    if (freq2[cust_id] == 0)
    {
        while (order_queue[tem].cust_num == cust_id)
        {
            strcpy(ord, order_queue[tem].orders);

            if (send_back(ord) == 0)
            {
                rej = 1;
                break;
            }
            tem++;
        }
        freq2[cust_id]++;
    }

    order_count++;

    // sem_post(&temp1);

    // sem_wait(&temp);
    if (rej == 1)
    {

        printf("\033[31mCustomer %d left at %d second(s) with an unfulfilled order\033[0m\n", cust_id, arr_time);
        freq3[cust_id]++;
        m_status[machine_id] = 0;
        while (order_queue[order_count].cust_num == cust_id)
        {
            order_count++;
        }
        curr_cust_count--;
        sleep(1);
    }
    sem_post(&temp1);
    // else
    sem_wait(&temp);
    if (rej == 0)

    {

        machine_id = -1;
        int f = 0;

        while (machine_id == -1 && close_time >= getElapsedTime())
        {
            int f = 0;
            sleep(0.01);

            for (int h = 0; h < N; h++)
            {
                int tt = getElapsedTime();

                if (m_time[h].status == 0 && tt >= m_time[h].start && tt <= m_time[h].end && tt + get_prep_time(orde) < m_time[h].end)
                {
                    f = 1;
                    machine_id = h;
                    m_time[h].status = 1;
                    // sleep(1);
                    break;
                }
            }
            // sleep(1);

            if (f == 0)
            {
                sleep(1);
            }
        }
    }

    sem_post(&temp);

    if ((machine_id == -1 && rej == 0) && freq3[cust_id] == 0)
    {
        printf("\033[31mCustomer %d was not serviced due to unavailability of machines\033[0m\n", cust_id);
        curr_cust_count--;
        sent++;
    }

    if (machine_id != -1 && rej == 0 && freq3[cust_id] == 0)
    {
        sem_wait(&machines[machine_id]);
        int fail_flag = 0;
        // sleep(1);
        printf("\033[36mMachine %d starts preparing ice cream %d of customer %d at %d seconds(s)\033[0m\n", machine_id + 1, ic_num + 1, cust_id, getElapsedTime());
        int c = get_prep_time(orde);
        for (int j = 0; j < c; j++)
        {

            sleep(1);
            if (getElapsedTime() > m_time[machine_id].end)
            {
                fail_flag = 1;
                break;
            }
        }
        if (fail_flag == 0)
        {
            printf("\033[34mMachine %d completes preparing ice cream %d of customer %d at %d seconds(s)\033[0m\n", machine_id + 1, ic_num + 1, cust_id, getElapsedTime());
            // m_status[machine_id] = 0;
            // m_time[machine_id].status = 0;
            if (ic_count == ic_num + 1)
            {
                printf("\033[32mCustomer %d has collected their order(s) and left at %d second(s)\033[0m\n", cust_id, getElapsedTime());
               
                curr_cust_count--;
                sleep(1);
                
            }
             m_status[machine_id] = 0;
                 m_time[machine_id].status = 0;
        }
        else if (fail_flag == 1)
        {
            printf("\033[31mCustomer %d was not serviced due to unavailability of machines\033[0m\n", cust_id);
            curr_cust_count--;
            sent++;
            m_status[machine_id] = 0;
            m_time[machine_id].status = 0;
        }

        sem_post(&machines[machine_id]);
        //  m_status[machine_id] = 0;
    }

    return NULL;
}

int main()
{
    char item[100];

  //  printf("Enter the number of Machines,Customers,Flavors and Toppings:\n");
    scanf("%d %d %d %d", &N, &K, &F, &T);

   // printf("Enter the Machine Start and Stop Times:\n");
    for (int i = 0; i < N; i++)
    {
        scanf("%d %d", &m_start[s_ind], &m_end[e_ind]);
        s_ind++;
        e_ind++;
        m_time[m_ind].start = m_start[s_ind - 1];
        m_time[m_ind].end = m_end[e_ind - 1];
        m_time[m_ind].status = 0;
        m_ind++;
    }
    close_time = m_end[N - 1];
   // printf("Enter the Flavor name and Preparation Time:\n");

    for (int i = 0; i < F; i++)
    {
        scanf("%s %d", flav[flav_ind].flavor, &flav[flav_ind].t_make);
        flav_ind++;
    }

  //  printf("Enter the Toppings name and Quantity:\n");

    for (int i = 0; i < T; i++)
    {
        scanf("%s %d", top[top_ind].topping, &top[top_ind].t_top);
        top_ind++;
    }

    sem_init(&temp, 0, 1);
    sem_init(&temp1, 0, 1);
    sem_init(&mt, 0, 1);
    sem_init(&temp2, 0, 1);
    sem_init(&mt1, 0, 1);
    sem_init(&temp3, 0, 1);
    for (int h = 0; h < 100; h++)
    {
        freq[h] = 0;
        freq2[h] = 0;
        freq3[h] = 0;
    }
    for (int i = 0; i < N; i++)
    {

        if (sem_init(&machines[i], 0, 1) != 0)
        {
            perror("Failed to initialize semaphore");
            exit(1);
        }
    }
    int i = 0;

    while (1)
    {
      //  printf("Enter the details of customer %d:\n", i + 1);
        order_queue[order_ind].flav_count = 0;
        int ind = order_queue[order_ind].flav_count;
        int a, b, c;
        scanf("%d %d %d", &a, &b, &c);
        int nu = 0;
        for (int j = 0; j < c; j++)
        {
          //  printf("Enter order of ice cream %d:\n", j + 1);
            char order_string[1000];
            scanf(" %[^\n]", order_string);
            if (i < K)
            {
                order_queue[order_ind].cust_num = a;
                order_queue[order_ind].arr_time = b;
                order_queue[order_ind].ic_count = c;
                strcpy(order_queue[order_ind].orders, order_string);
                order_queue[order_ind].ic_num = nu;
                nu++;
                ind++;
                order_ind++;
                num++;
            }
            else
            {
                order_queue[order_ind].cust_num = a;
                order_queue[order_ind].arr_time = b;
                order_queue[order_ind].ic_count = c;
                strcpy(order_queue[order_ind].orders, order_string);
                order_queue[order_ind].ic_num = nu;
                nu++;
                ind++;
                order_ind++;
                num++;
                printf("Max Capacity Exceeded!\n");
            }
        }

        getchar();
        int nextChar = getchar(); // Read the next character

        if (nextChar == '\n')
        {
        }
        else
        {
            break;
        }
        i++;
    }

    for (int u = 0; u < 10; u++)
    {
        m_status[u] = 0;
    }
    pthread_t machines_ice[N];
    pthread_t machines_ice1[N];

    pthread_t customer_threads[num];
    initTimer();
    int current_customer = 0;
    for (int j = 0; j < N; j++)
    {
        int *machine_index = malloc(sizeof(int));
        *machine_index = j;
        pthread_create(&machines_ice[j], NULL, machine_start, machine_index);
    }

    for (int j = 0; j < N; j++)
    {
        int *machine_index1 = malloc(sizeof(int));
        *machine_index1 = j;
        pthread_create(&machines_ice1[j], NULL, machine_end, machine_index1);
    }

    while (current_customer < order_ind)
    {
        int elapsed_time = getElapsedTime();

        while (current_customer < order_ind && order_queue[current_customer].arr_time == elapsed_time && curr_cust_count <= K)
        {
            pthread_create(&customer_threads[current_customer], NULL, customer, NULL);
            current_customer++;
        }
    }

    for (int u = 0; u < order_ind; u++)
    {
        pthread_join(customer_threads[u], NULL);
    }

    if (getElapsedTime() <= close_time)
    {
        sleep(1);
    }
    printf("Parlor Closed\n");
    // printf("%d Customers were sent away due to limited resources\n",sent);

    return 0;
}
