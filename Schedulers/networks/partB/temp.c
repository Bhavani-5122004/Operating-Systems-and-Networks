#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <time.h>
 
typedef struct data{
    int num;
    int ack;
    char info[200];
}data;

 

int portion(data** arr,int arrind,char* buffer){
    char* temp = (char*)malloc(sizeof(char)*11);
    srand(time(NULL));
    int tempind = 0;
    for(int i=0;i<strlen(buffer);i++){
        if(i%7==0 && i!=0){
            temp[tempind]=buffer[i];
            tempind++;
            temp[tempind]='\0';
            arr[arrind]->num = i;
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
            arr[arrind]->num = i;
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
 
 srand(time(NULL));
 // Defining variables for IP, port, etc.
  char *ip = "127.0.0.1";
  int port = 12347;
 
  int sock;
 
  struct sockaddr_in serverAddress;
  socklen_t addr_size;
  char buffer[1024];
  int n;
 
 // Connecting the socket
  sock = socket(AF_INET, SOCK_DGRAM, 0);
  if (sock == -1){
    perror("Error while creating socket");
    exit(1);
  }

// Connecting socket to port and IP
serverAddress.sin_family = AF_INET;
serverAddress.sin_addr.s_addr = inet_addr(ip);
serverAddress.sin_port = htons(port);

 
while(1){
bzero(buffer, 1024);

int s;


  addr_size = sizeof(serverAddress);
  // int r = recvfrom(sock, buffer, 1024, 0, (struct sockaddr*)&serverAddress, &addr_size);
  // if (r == -1) {
  //           perror("Error receiving data");
  //           close(sock);
  //           exit(1);
  //       }
    
  // printf("Server: %s\n", buffer);
      data receivedData;
      char arr_len[10];
    int  r  = recvfrom(sock, arr_len, sizeof(arr_len), 0, (struct sockaddr*)&serverAddress, &addr_size);
   
    int len = atoi(arr_len);
      char ack[10];
      bzero(ack,sizeof(ack));
    r  = recvfrom(sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&serverAddress, &addr_size);
    if (r == -1) {
        perror("Error receiving data");
        close(sock);
        exit(1);
    }
    
  
 int h = 0;
 int count = 0;
int flag =0;
 //printf("Received Data:\n");
 for(h =0;h<len;h++){
// if(h!=(len-1))
//printing the data chunk with ack bit
//printf("%s",receivedData.info);
// printf("Ack: %d  Data: %s\n",receivedData.ack,receivedData.info);

// Checking if ack bit is 0
 if(receivedData.ack == 0 && h!=(len-1)){
 //  printf("No ack\n");
    strcpy(ack,"no");
// in that case send no
  int s = sendto(sock, ack, sizeof(ack), 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
   if (s == -1) {
            perror("Error sending data");
            close(sock);
            
            exit(1);
        }
        flag = 1;
        count++;
    // get the retransmission
    //  r  = recvfrom(sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&serverAddress, &addr_size);
    //  printf("Retransmission recieved\n");
    // if (r == -1) {
    //     perror("Error receiving data");
    //     close(sock);
    //     exit(1);
    // }
    // printf("%s",receivedData.info);
 }
 else{
    // if(h!=(len-1))
    //  printf("Ack\n");
    strcpy(ack,"yes");
    // otherwise send yes
    int s = sendto(sock, ack, sizeof(ack), 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
   if (s == -1) {
            perror("Error sending data");
            close(sock);
            
            exit(1);
        }
      if(h!=(len-1)){
    // printf("**%d %d\n",receivedData.num,receivedData.ack);
    printf("%s",receivedData.info);
      }
        
 }

 if(h!=(len - 1)){
 r  = recvfrom(sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&serverAddress, &addr_size);
    if (r == -1) {
        perror("Error receiving data");
        close(sock);
        exit(1);
    }
 }

 

 }

 if(flag == 1){
 
  for(int h=0;h<count;h++){
   // printf("jjhere\n");
      r  = recvfrom(sock, &receivedData, sizeof(receivedData), 0, (struct sockaddr*)&serverAddress, &addr_size);
    // printf("Retransmission recieved\n");
    if (r == -1) {
        perror("Error receiving data");
        close(sock);
        exit(1);
    }
   // printf("**%d %d\n",receivedData.num,receivedData.ack);
    printf("%s",receivedData.info);
  }
 // printf("done\n");
 }
printf("\n");
printf("Enter message to send to server: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';
 
 s = sendto(sock, buffer, 1024, 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));

 if (s == -1) {
            perror("Error sending data");
            close(sock);
            exit(1);
        }


//   data** arr = (data**)malloc(sizeof(data*) * 20);
// for (int i = 0; i < 20; i++) {
//     arr[i] = (data*)malloc(sizeof(data));
// }

// int arrind = portion(arr, 0, buffer);
// arr[arrind]->num = -1;
// strcpy(arr[arrind]->info,"done");
// arrind++;
// for (int k = 0; k < arrind; k++) {
 
//     int s = sendto(sock, arr[k], sizeof(data), 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
//     if (s == -1) {
//         perror("Error sending data");
//         close(sock);
//         exit(1);
//     }
// }
//   char ack[10];
 
//     sprintf(ack, "%ld", strlen(buffer));
//   s = sendto(sock, ack, sizeof(ack), 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
//    if (s == -1) {
//             perror("Error sending data");
//             close(sock);
//             exit(1);
//         }

       


  

}
 
  close(sock);
 
 
  return 0;
}