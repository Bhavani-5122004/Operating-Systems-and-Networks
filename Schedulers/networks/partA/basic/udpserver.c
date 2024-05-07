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
 

  while(1){
 bzero(buffer, 1024);
  addr_size = sizeof(client_addr);
  int r = recvfrom(server_sock, buffer, 1024, 0, (struct sockaddr*)&client_addr, &addr_size);
  if (r == -1) {
            perror("Error receiving data");
            close(server_sock);
            close(client_sock);
            exit(1);
        }
  printf("Client: %s\n", buffer);
 
  bzero(buffer, 1024);
printf("Enter message to send to client: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';
  int s = sendto(server_sock, buffer, 1024, 0, (struct sockaddr*)&client_addr, sizeof(client_addr));
   if (s == -1) {
            perror("Error sending data");
            close(server_sock);
            close(client_sock);
            exit(1);
        }
  
 
  }
  close(server_sock);
  return 0;
}