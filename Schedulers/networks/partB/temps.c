#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
 
 typedef struct data{
    int num;
    int ack;
    char info[200];
}data;

int portion(data** arr,int arrind,char* buffer){
    char* temp = (char*)malloc(sizeof(char)*15);
    srand(time(NULL));
    int tempind = 0;
    for(int i=0;i<strlen(buffer);i++){
        if(i%7==0 && i!=0){
            temp[tempind]=buffer[i];
            tempind++;
            temp[tempind]='\0';
            arr[arrind]->num = arrind;
            strcpy(arr[arrind]->info,temp);
            int randnum = rand();
            if(randnum % 3 == 0){
             arr[arrind]->ack == 0;
            }
            else{
                arr[arrind]->ack = 1;
            }
           // printf("((**%s** ^ **%s**))\n",temp,arr[arrind]->info);
            arrind++;
            temp = (char*)malloc(sizeof(char)*11);
            tempind = 0;
            
        }
        else if (i == strlen(buffer)-1){
            temp[tempind]=buffer[i];
            tempind++;
            temp[tempind]='\0';
            arr[arrind]->num = arrind;
            strcpy(arr[arrind]->info,temp);
            if(rand() % 3 == 0){
             arr[arrind]->ack == 0;
            }
            else{
                arr[arrind]->ack = 1;
            }
            
            //  printf("((**%s** ^ **%s**))\n",temp,arr[arrind]->info);
            arrind++;

        }
        else{
            
            temp[tempind]=buffer[i];
            tempind++;
        }
    }
    
    return arrind;
}

int main(){
 
  // Defining variables for IP, port, etc.
  char *ip = "127.0.0.1";
  int port = 12347;
 
  int server_sock, client_sock;
  struct sockaddr_in server_addr, client_addr;
  socklen_t addr_size;
  char buffer[1024];
  int n;
 
  // Connecting the server socket
  server_sock = socket(AF_INET, SOCK_DGRAM, 0);
  if (server_sock == -1){
    perror("Error creating socket");
    exit(1);
  }
  

// Storing server address and port
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(ip);
    server_addr.sin_port = htons(port);


// Binding the socket to the port
  int b = bind(server_sock, (struct sockaddr*)&server_addr, sizeof(server_addr));
  if (b == -1){
    perror("Error while binding");
    exit(1);
  }

  char res[1024];
 int temparr[150];
    int temparrind = 0;
  while(1){
   temparrind = 0;
 bzero(buffer, 1024);
 int r;
  addr_size = sizeof(client_addr);

    data receivedData;
      char arr_len[10];
    r  = recvfrom(server_sock, arr_len, sizeof(arr_len), 0, (struct sockaddr*)&client_addr, &addr_size);
   
   int len = atoi(arr_len);
  
       char ack[10];
      bzero(ack,sizeof(ack));
    r  = recvfrom(server_sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&client_addr, &addr_size);
    if (r == -1) {
        perror("Error receiving data");
        close(server_sock);
        exit(1);
    }
    

 int h = 0;
 int count = 0;
int flag =0;
int elemcount =0;
printf("Total number of chunks: %d\n",len-1);
 for(h =0;h<len;h++){


// Checking if ack bit is 0
 if(receivedData.ack == 0 && h!=(len-1)){
 //  printf("No ack\n");
    strcpy(ack,"no");
// in that case send no
  int s = sendto(server_sock, "no", 3, 0,  (struct sockaddr*)&client_addr, sizeof(client_addr));
   if (s == -1) {
          
            perror("Error sending data");
            close(server_sock);
            
            exit(1);
        }
        flag = 1;
        count++;

 }
 else{
    elemcount++;
    strcpy(ack,"yes");
    // otherwise send yes
    int s = sendto(server_sock, "yes", 4, 0,  (struct sockaddr*)&client_addr, sizeof(client_addr));
   if (s == -1) {
            perror("Error sending data");
            close(server_sock);
            
            exit(1);
        }
      if(h!=(len-1)){
      //  printf("**%d\n",receivedData.num);
   // printf("%d %s\n",receivedData.num,receivedData.info);
      }
        
 }

 if(h!=(len - 1)){
 r  = recvfrom(server_sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&client_addr, &addr_size);
    if (r == -1) {
     
        perror("Error receiving data");
        close(server_sock);
        exit(1);
    }
 }

 

 }

 if(flag == 1){
 
  for(int h=0;h<count;h++){

      r  = recvfrom(server_sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&client_addr, &addr_size);
      printf("Retransmitting packet %d\n",receivedData.num);
    if (r == -1) {
        perror("Error receiving data");
        close(server_sock);
        exit(1);
    }

  //  printf("%d %s\n",receivedData.num,receivedData.info);
  }
flag = 0;
 }

 data receivedData1;
memset(&receivedData1, 0, sizeof(receivedData1));

 printf("Total number of chunks transmitted successfully the first time: %d\n",elemcount-1);
 for(int h=0;h<len;h++){
      r  = recvfrom(server_sock, &receivedData1, sizeof(receivedData1), 0, (struct sockaddr*)&client_addr, &addr_size);
    if (r == -1) {
        perror("Error receiving data");
        close(server_sock);
        exit(1);
    }
    if(receivedData1.num!=-1)
    printf("%d %s\n",receivedData1.num,receivedData1.info);
 }

 
 




 // Sending data
 

    printf("Enter message to send to client: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';


    data** arr = (data**)malloc(sizeof(data*) * 20);
for (int i = 0; i < 20; i++) {
    arr[i] = (data*)malloc(sizeof(data)*100);
}
int arrind = 0;
temparrind = 0;
 arrind = portion(arr, 0, buffer);
arr[arrind]->num = -1;
arr[arrind]->ack = 1;
strcpy(arr[arrind]->info,"done");
arrind++;
int size = arrind;
elemcount = 0;
char len_arr[10];
sprintf(len_arr, "%d", arrind);
int s = sendto(server_sock,len_arr, sizeof(len_arr), 0, (struct sockaddr*)&client_addr, sizeof(client_addr));

for (int k = 0; k < arrind; k++) {
 
    int s = sendto(server_sock, arr[k], sizeof(data), 0, (struct sockaddr*)&client_addr, sizeof(client_addr));

    if (s == -1) {
        perror("Error sending data");
        close(server_sock);
        exit(1);
    }
    r  = recvfrom(server_sock, ack, 10, 0, (struct sockaddr*)&client_addr, &addr_size);
     if (r == -1) {
        perror("Error receiving data");
        close(server_sock);
        exit(1);
        }
     
    if(strcmp(ack,"no")==0){
    temparr[temparrind]=k;
    temparrind++;

    }
    
   

}

     

for(int h=0;h<temparrind;h++){
   
  s = sendto(server_sock, arr[temparr[h]], sizeof(data), 0, (struct sockaddr*)&client_addr, sizeof(client_addr));
    if (s == -1) {
        perror("Error sending data");
        close(server_sock);
        exit(1);
    }
   // printf("stuck\n");



}


for (int h1 = 0; h1 < size; h1++) {
    int s = sendto(server_sock, arr[h1], sizeof(data), 0, (struct sockaddr*)&client_addr, sizeof(client_addr));
   // printf("**%s\n", arr[h1]->info);
    if (s == -1) {
        perror("Error sending data");
        close(server_sock);
        exit(1);
    }
}

 
// printf("done\n");
  

  }
  close(server_sock);
  return 0;
}