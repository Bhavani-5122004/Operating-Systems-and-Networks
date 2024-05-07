#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
 
int main(){
 
 // Defining variables for IP, port, etc.
  char *ip = "127.0.0.1";
  int port = 12360;
 
  int sock;
 
  struct sockaddr_in serverAddress;
  socklen_t addr_size;
  char buffer[1024];
  int n;
 
 // Connecting the socket
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock == -1){
    perror("Error while creating socket");
    exit(1);
  }

// Connecting socket to port and IP
serverAddress.sin_family = AF_INET;
serverAddress.sin_addr.s_addr = inet_addr(ip);
serverAddress.sin_port = htons(port);
 
  int c = connect(sock, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
  if (c == -1){
    perror("Error while connecting to server");
    exit(1);
  }
 
 
while(1){
      bzero(buffer, sizeof(buffer));
  printf("Enter choice: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';
  int s = send(sock, buffer, strlen(buffer), 0);
  if(s == -1){
    perror("Error while sending");
    exit(1);
  }
  recv(sock, buffer, sizeof(buffer), 0);
  printf("Winner: %s\n", buffer);
    printf("Do you wish to continue: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';

 s = send(sock, buffer, strlen(buffer), 0);

 if(s == -1){
    perror("Error while sending");
    exit(1);
  }
  recv(sock, buffer, sizeof(buffer), 0);

  if(strcmp("end",buffer)==0){
    
    exit(1);
  }
}
 
  close(sock);
 
 
  return 0;
}