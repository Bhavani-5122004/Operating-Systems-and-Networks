#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
 
int main(){
 
  // Defining variables for IP, port, etc.
  char *ip = "127.0.0.1";
  int port = 12345;
 
  int server_sock, client_sock;
  struct sockaddr_in server_addr, client_addr;
  socklen_t addr_size;
  char buffer[1024];
  int n;
 
  // Connecting the server socket
  server_sock = socket(AF_INET, SOCK_STREAM, 0);
  if (server_sock == -1){
    perror("Error creating socket");
    exit(1);
  }
  

// Storing server address and port
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(ip);
    server_addr.sin_port = htons(port);

int reuse = 1;
if (setsockopt(server_sock, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(int)) == -1) {
    perror("Error setting SO_REUSEADDR");
    exit(1);
}
// Binding the socket to the port
  int b = bind(server_sock, (struct sockaddr*)&server_addr, sizeof(server_addr));
  if (b == -1){
    perror("Error while binding");
    exit(1);
  }
 

// Listening for incoming connections - taking 5 as the maximum number of connections waiting to be served - only one client can be served at a time
 int l = listen(server_sock, 5);
 if( l == -1){
  perror("Error while listening");
  exit(1);
 }

// Establishing a connection

struct sockaddr_in clientAddress;
socklen_t clientAddressLength = sizeof(clientAddress);

client_sock = accept(server_sock, (struct sockaddr *)&clientAddress, &clientAddressLength);
if (client_sock == -1) {
    perror("Connection Failed");
    exit(EXIT_FAILURE);
}

  while(1){
 int r = recv(client_sock, buffer, sizeof(buffer), 0);
    if (r == -1) {
        perror("Error receiving data from client");
        close(client_sock);
        close(server_sock);
        exit(1);
    }
    if (r == 0) {
            perror("Client disconnected");
            close(client_sock);
            close(server_sock);
            exit(1);
        }

    buffer[r] = '\0';
    printf("Client: %s\n", buffer);
    char response[1024];
   bzero(buffer, sizeof(buffer));
     printf("Enter message to send to client: ");
        fgets(buffer, sizeof(buffer), stdin);
        buffer[strcspn(buffer, "\n")] = '\0';
    r = send(client_sock, buffer, sizeof(buffer), 0);
    if (r == -1) {
        perror("Error sending data to client");
        close(client_sock);
        close(server_sock);
        exit(1);
    }
 
  }
  close(server_sock);
  return 0;
}