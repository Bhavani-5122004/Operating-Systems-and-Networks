#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
 
// int main(){
 
// char *ip = "127.0.0.1";
// int port = 12345;

//     int server_sock;
//     int client_sock_a, client_sock_b; 
//     struct sockaddr_in server_addr;
//     socklen_t addr_size;
//     char buffer[1024];

//     // Creating the server socket
//       server_sock = socket(AF_INET, SOCK_STREAM, 0);
//       client_sock_a = socket(AF_INET, SOCK_STREAM, 0);
//       client_sock_b = socket(AF_INET, SOCK_STREAM, 0);
//     if (server_sock == -1 || client_sock_a == -1 || client_sock_b == -1){
//     perror("Error creating socket");
//     exit(1);
//   }

//     int reuse = 1;
//     if (setsockopt(server_sock, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(int)) == -1) {
//         perror("Error setting SO_REUSEADDR");
//         exit(1);
//     }

//     server_addr.sin_family = AF_INET;
//     server_addr.sin_addr.s_addr = inet_addr(ip);
//     server_addr.sin_port = htons(port); 


//     // Binding the server socket to the port and IP
//     if (bind(server_sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1) {
//         perror("Error while binding");
//         exit(1);
//     }

//     // Listening for incoming connections
//     if (listen(server_sock, 2) == -1) { 
//         perror("Error while listening");
//         exit(1);
//     }

 
//     socklen_t addr_size_a, addr_size_b;
//     struct sockaddr_in client_addr_a, client_addr_b;

//     addr_size_a = sizeof(client_addr_a);
//     addr_size_b = sizeof(client_addr_b);

//     client_sock_a = accept(server_sock, (struct sockaddr *)&client_addr_a, &addr_size_a);
//     client_sock_b = accept(server_sock, (struct sockaddr *)&client_addr_b, &addr_size_b);

//     if (client_sock_a == -1 || client_sock_b == -1) {
//         perror("Connection Failed");
//         exit(1);
//     }

//   while(1){


//  int r = recv(client_sock_a, buffer, sizeof(buffer), 0);
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


//  r = recv(client_sock_b, buffer, sizeof(buffer), 0);
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
// if(strcmp(A,B)==0){
//     strcpy(winner,"Draw");
// }
// // 0 for rock, 1 for paper, 2 for scissors
// else if((strcmp(A,"0")==0 && strcmp(B,"2")==0) || (strcmp(A,"2")==0 && strcmp(B,"1")==0) || (strcmp(A,"1")==0 && strcmp(B,"0")==0)){
//     strcpy(winner,"A");
// }
// else{
//     strcpy(winner,"B");
// }
//     r = send(client_sock_a, winner, sizeof(winner), 0);
//     if (r == -1) {
//         perror("Error sending data to client");
//         close(client_sock_a);
//         close(server_sock);
//         exit(1);
//     }

// r = send(client_sock_b, winner, sizeof(winner), 0);
//     if (r == -1) {
//         perror("Error sending data to client");
//         close(client_sock_b);
//         close(server_sock);
//         exit(1);
//     }

//  r = recv(client_sock_a, buffer, sizeof(buffer), 0);
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

//      r = recv(client_sock_b, buffer, sizeof(buffer), 0);
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
//         r = send(client_sock_a, "yes", 4, 0);
//         r = send(client_sock_b, "yes", 4, 0);
        
//     }
//     else{
//         r = send(client_sock_a, "end", 4, 0);
//         r = send(client_sock_b, "end", 4, 0);
//         close(server_sock);
        
//         exit(1);
//     }
 
//   }
//   close(server_sock);
//   return 0;
// }




int main() {
char *ip = "127.0.0.1";
int port = 12345;

   int server_sock_a,server_sock_b;
    int client_sock_a, client_sock_b; 
    struct sockaddr_in server_addr_a,server_addr_b;
    socklen_t addr_size;
    char buffer[1024];

    // Creating the server socket
      server_sock_a = socket(AF_INET, SOCK_STREAM, 0);
      server_sock_b = socket(AF_INET, SOCK_STREAM, 0);
      client_sock_a = socket(AF_INET, SOCK_STREAM, 0);
      client_sock_b = socket(AF_INET, SOCK_STREAM, 0);
    if (server_sock_a == -1 || server_sock_b == -1 || client_sock_a == -1 || client_sock_b == -1){
    perror("Error creating socket");
    exit(1);
  }

    int reuse = 1;
    if (setsockopt(server_sock_a, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(int)) == -1 || 
    setsockopt(server_sock_b, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(int)) == -1) {
        perror("Error setting SO_REUSEADDR");
        exit(1);
    }

    server_addr_a.sin_family = AF_INET;
    server_addr_a.sin_addr.s_addr = inet_addr(ip);
    server_addr_a.sin_port = htons(12360); 
    server_addr_b.sin_family = AF_INET;
    server_addr_b.sin_addr.s_addr = inet_addr(ip);
    server_addr_b.sin_port = htons(12361); 


    // Binding the server socket to the port and IP
    if (bind(server_sock_a, (struct sockaddr *)&server_addr_a, sizeof(server_addr_a)) == -1 || 
    bind(server_sock_b, (struct sockaddr *)&server_addr_b, sizeof(server_addr_b)) == -1) {
        perror("Error while binding");
        exit(1);
    }

    // Listening for incoming connections
    if (listen(server_sock_a, 2) == -1 || listen(server_sock_b, 2) == -1) { 
        perror("Error while listening");
        exit(1);
    }

 
    socklen_t addr_size_a, addr_size_b;
    struct sockaddr_in client_addr_a, client_addr_b;

    addr_size_a = sizeof(client_addr_a);
    addr_size_b = sizeof(client_addr_b);

    client_sock_a = accept(server_sock_a, (struct sockaddr *)&client_addr_a, &addr_size_a);
    client_sock_b = accept(server_sock_b, (struct sockaddr *)&client_addr_b, &addr_size_b);

    if (client_sock_a == -1 || client_sock_b == -1) {
        perror("Connection Failed");
        exit(1);
    }

  while(1){


 int r = recv(client_sock_a, buffer, sizeof(buffer), 0);
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


 r = recv(client_sock_b, buffer, sizeof(buffer), 0);
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
if(strcmp(A,B)==0){
    strcpy(winner,"Draw");
}
// 0 for rock, 1 for paper, 2 for scissors
else if((strcmp(A,"0")==0 && strcmp(B,"2")==0) || (strcmp(A,"2")==0 && strcmp(B,"1")==0) || (strcmp(A,"1")==0 && strcmp(B,"0")==0)){
    strcpy(winner,"A");
}
else{
    strcpy(winner,"B");
}
    r = send(client_sock_a, winner, sizeof(winner), 0);
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_a);
        close(server_sock_a);
        exit(1);
    }

r = send(client_sock_b, winner, sizeof(winner), 0);
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock_b);
        close(server_sock_b);
        exit(1);
    }

 r = recv(client_sock_a, buffer, sizeof(buffer), 0);
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

     r = recv(client_sock_b, buffer, sizeof(buffer), 0);
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
        r = send(client_sock_a, "yes", 4, 0);
         r = send(client_sock_b, "yes", 4, 0);
    }
    else{
        r = send(client_sock_a, "end", 4, 0);
         r = send(client_sock_b, "end", 4, 0);
        close(server_sock_a);
        close(server_sock_b);
        exit(1);
    }
 
  }
  close(server_sock_a);
  close(server_sock_b);
    return 0;
}