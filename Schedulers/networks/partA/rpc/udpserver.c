// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <unistd.h>
// #include <arpa/inet.h>
 
// int main(){
 
//   // Defining variables for IP, port, etc.
//   char *ip = "127.0.0.1";
//   int port = 12345;
 
 
//   int server_sock, client_sock_a,client_sock_b;
//   struct sockaddr_in server_addr,server_addr_b, client_addr_a,client_addr_b;
//   socklen_t addr_size_a,addr_size_b;
//   char buffer[1024];
//   int n;

  
 
//   // Connecting the server socket
//   server_sock = socket(AF_INET, SOCK_DGRAM, 0);
//   client_sock_a = socket(AF_INET, SOCK_DGRAM, 0);
//   client_sock_b = socket(AF_INET, SOCK_DGRAM, 0);
//   if (server_sock == -1 || client_sock_a == -1 || client_sock_b == -1){
//     perror("Error creating socket");
//     exit(1);
//   }
  
  

// // Storing server address and port
//     server_addr.sin_family = AF_INET;
//     server_addr.sin_addr.s_addr = inet_addr(ip);
//     server_addr.sin_port = htons(port);
    
    


// // Binding the socket to the port
//   int b = bind(server_sock, (struct sockaddr*)&server_addr, sizeof(server_addr));

//   if (b == -1){
//     perror("Error while binding");
//     exit(1);
//   }
 
//  addr_size_a = sizeof(client_addr_a);
// addr_size_b = sizeof(client_addr_b);

//   while(1){

// bzero(buffer, sizeof(buffer));
//  int r = recvfrom(server_sock, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_a, &addr_size_a);

//     if (r == -1) {
//         perror("Error receiving data from client");
//         close(client_sock_a);
//         close(server_sock);
//         exit(1);
//     }
//     if (r == 0) {
//             perror("Client disconnected");
//             close(client_sock_a);
//             close(server_sock);
//             exit(1);
//         }

//     buffer[r] = '\0';
//     char A[5];
//     strcpy(A,buffer);
//     printf("Client A: %s\n", buffer);
    

// bzero(buffer, sizeof(buffer));
//  r = recvfrom(server_sock, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_b, &addr_size_b);

//     if (r == -1) {
//         perror("Error receiving data from client");
//         close(client_sock_b);
//         close(server_sock);
//         exit(1);
//     }
//     if (r == 0) {
//             perror("Client disconnected");
//             close(client_sock_b);
//             close(server_sock);
//             exit(1);
//         }

//     buffer[r] = '\0';
//     char B[5];

//     strcpy(B,buffer);
//     printf("Client B: %s\n", buffer);

// char winner[1024];
// bzero(winner, sizeof(winner));
// if(strcmp(A,B)==0){
//     strcpy(winner,"draw");
//     winner[4]='\0';
   
// }
// // 0 for rock, 1 for paper, 2 for scissors
// else if((strcmp(A,"0")==0 && strcmp(B,"2")==0) || (strcmp(A,"2")==0 && strcmp(B,"1")==0) || (strcmp(A,"1")==0 && strcmp(B,"0")==0)){
//     strcpy(winner,"A");
//     winner[1]='\0';
// }
// else{
//     strcpy(winner,"B");
//     winner[1]='\0';
// }

//    r = sendto(client_sock_a, winner, strlen(winner), 0, (struct sockaddr*)&client_addr_a, sizeof(client_addr_a));
//     if (r == -1) {
//         perror("Error sending data to client");
//         close(client_sock_a);
//         close(server_sock);
//         exit(1);
//     }

// r = sendto(client_sock_b, winner, strlen(winner), 0, (struct sockaddr*)&client_addr_b, sizeof(client_addr_b));
//     if (r == -1) {
//         perror("Error sending data to client");
//         close(client_sock_b);
//         close(server_sock);
//         exit(1);
//     }

//     bzero(buffer, sizeof(buffer));
//  r = recvfrom(server_sock, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_a, &addr_size_a);

//     if (r == -1) {
//         perror("Error receiving data from client");
//         close(client_sock_a);
//         close(server_sock);
//         exit(1);
//     }
//     if (r == 0) {
//             perror("Client disconnected");
//             close(client_sock_a);
//             close(server_sock);
//             exit(1);
//         }

//     buffer[r] = '\0';
//     char A_dec[5];

//     strcpy(A_dec,buffer);

//     bzero(buffer, sizeof(buffer));
//  r = recvfrom(server_sock, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_b, &addr_size_b);

//     if (r == -1) {
//         perror("Error receiving data from client");
//         close(client_sock_b);
//         close(server_sock);
//         exit(1);
//     }
//     if (r == 0) {
//             perror("Client disconnected");
//             close(client_sock_b);
//             close(server_sock);
//             exit(1);
//         }

//     buffer[r] = '\0';
//     char B_dec[5];

//     strcpy(B_dec,buffer);
//     if(strcmp(A_dec,B_dec)==0 && strcmp(A_dec,"yes")==0){
//        r = sendto(client_sock_a,"yes", 4, 0, (struct sockaddr*)&client_addr_a, sizeof(client_addr_a));
//        r = sendto(client_sock_b,"yes", 4, 0, (struct sockaddr*)&client_addr_b, sizeof(client_addr_b));
        
//     }
//     else{
//        r = sendto(client_sock_a,"end", 4, 0, (struct sockaddr*)&client_addr_a, sizeof(client_addr_a));
//        r = sendto(client_sock_b,"end", 4, 0, (struct sockaddr*)&client_addr_b, sizeof(client_addr_b));
        
//         close(server_sock);
//         exit(1);
//     }
 
  
 
//   }
//   close(server_sock);
//   return 0;
// }




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
 
int main(){
 
  // Defining variables for IP, port, etc.
  char *ip = "127.0.0.1";
  int port = 12345;
 
 
  int server_sock_a,server_sock_b, client_sock_a,client_sock_b;
  struct sockaddr_in server_addr_a,server_addr_b, client_addr_a,client_addr_b;
  socklen_t addr_size_a,addr_size_b;
  char buffer[1024];
  int n;

  
 
  // Connecting the server socket
  server_sock_a = socket(AF_INET, SOCK_DGRAM, 0);
  server_sock_b = socket(AF_INET, SOCK_DGRAM, 0);
  client_sock_a = socket(AF_INET, SOCK_DGRAM, 0);
  client_sock_b = socket(AF_INET, SOCK_DGRAM, 0);
  if (server_sock_a == -1 || server_sock_b == -1 || client_sock_a == -1 || client_sock_b == -1){
    perror("Error creating socket");
    exit(1);
  }
  
  

// Storing server address and port
    server_addr_a.sin_family = AF_INET;
    server_addr_a.sin_addr.s_addr = inet_addr(ip);
    server_addr_a.sin_port = htons(12350);
    server_addr_b.sin_family = AF_INET;
    server_addr_b.sin_addr.s_addr = inet_addr(ip);
    server_addr_b.sin_port = htons(12351);
    
    


// Binding the socket to the port
  int b = bind(server_sock_a, (struct sockaddr*)&server_addr_a, sizeof(server_addr_a));
  int b1 = bind(server_sock_b, (struct sockaddr*)&server_addr_b, sizeof(server_addr_b));
  if (b == -1 || b1 == -1){
    perror("Error while binding");
    exit(1);
  }
 
 addr_size_a = sizeof(client_addr_a);
addr_size_b = sizeof(client_addr_b);

  while(1){

bzero(buffer, sizeof(buffer));
 int r = recvfrom(server_sock_a, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_a, &addr_size_a);

    if (r == -1) {
        perror("Error receiving data from client");
        close(client_sock_a);
        close(server_sock_a);
        exit(1);
    }
    if (r == 0) {
            perror("Client disconnected");
            close(client_sock_a);
            close(server_sock_a);
            exit(1);
        }

    buffer[r] = '\0';
    char A[5];
    strcpy(A,buffer);
    printf("Client A: %s\n", buffer);
    

bzero(buffer, sizeof(buffer));
 r = recvfrom(server_sock_b, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_b, &addr_size_b);

    if (r == -1) {
        perror("Error receiving data from client");
        close(client_sock_b);
        close(server_sock_b);
        exit(1);
    }
    if (r == 0) {
            perror("Client disconnected");
            close(client_sock_b);
            close(server_sock_b);
            exit(1);
        }

    buffer[r] = '\0';
    char B[5];

    strcpy(B,buffer);
    printf("Client B: %s\n", buffer);

char winner[1024];
bzero(winner, sizeof(winner));
if(strcmp(A,B)==0){
    strcpy(winner,"draw");
    winner[4]='\0';
   
}
// 0 for rock, 1 for paper, 2 for scissors
else if((strcmp(A,"0")==0 && strcmp(B,"2")==0) || (strcmp(A,"2")==0 && strcmp(B,"1")==0) || (strcmp(A,"1")==0 && strcmp(B,"0")==0)){
    strcpy(winner,"A");
    winner[1]='\0';
}
else{
    strcpy(winner,"B");
    winner[1]='\0';
}

   r = sendto(client_sock_a, winner, strlen(winner), 0, (struct sockaddr*)&client_addr_a, sizeof(client_addr_a));
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_a);
        close(server_sock_a);
        exit(1);
    }

r = sendto(client_sock_b, winner, strlen(winner), 0, (struct sockaddr*)&client_addr_b, sizeof(client_addr_b));
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_b);
        close(server_sock_b);
        exit(1);
    }

    bzero(buffer, sizeof(buffer));
 r = recvfrom(server_sock_a, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_a, &addr_size_a);

    if (r == -1) {
        perror("Error receiving data from client");
        close(client_sock_a);
        close(server_sock_a);
        exit(1);
    }
    if (r == 0) {
            perror("Client disconnected");
            close(client_sock_a);
            close(server_sock_a);
            exit(1);
        }

    buffer[r] = '\0';
    char A_dec[5];

    strcpy(A_dec,buffer);

    bzero(buffer, sizeof(buffer));
 r = recvfrom(server_sock_b, buffer, sizeof(buffer), 0, (struct sockaddr*)&client_addr_b, &addr_size_b);

    if (r == -1) {
        perror("Error receiving data from client");
        close(client_sock_b);
        close(server_sock_b);
        exit(1);
    }
    if (r == 0) {
            perror("Client disconnected");
            close(client_sock_b);
            close(server_sock_b);
            exit(1);
        }

    buffer[r] = '\0';
    char B_dec[5];

    strcpy(B_dec,buffer);
    if(strcmp(A_dec,B_dec)==0 && strcmp(A_dec,"yes")==0){
        r = sendto(client_sock_a, "yes",4, 0, (struct sockaddr*)&client_addr_a, sizeof(client_addr_a));
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_a);
        close(server_sock_a);
        exit(1);
    }
    r = sendto(client_sock_b, "yes", 4, 0, (struct sockaddr*)&client_addr_b, sizeof(client_addr_b));
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_b);
        close(server_sock_b);
        exit(1);
    }
    }
    else{
    r = sendto(client_sock_a, "end",4, 0, (struct sockaddr*)&client_addr_a, sizeof(client_addr_a));
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_a);
        close(server_sock_a);
        exit(1);
    }
    r = sendto(client_sock_b, "end", 4, 0, (struct sockaddr*)&client_addr_b, sizeof(client_addr_b));
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_b);
        close(server_sock_b);
        exit(1);
    }
        close(client_sock_a);
        close(client_sock_b);
        close(server_sock_a);
        close(server_sock_b);
        exit(1);
    }
 
  
 
  }
  close(server_sock_a);
  close(server_sock_b);
  return 0;
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

