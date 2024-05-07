#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
 
int main(){
 
 // Defining variables for IP, port, etc.
  char *ip = "127.0.0.1";
  int port = 12350;
 
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
printf("Enter choice: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';
 int s = sendto(sock, buffer, 1024, 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
 if (s == -1) {
            perror("Error sending data");
            close(sock);
            exit(1);
        }
         // Create a separate address structure for receiving data
    struct sockaddr_in recvAddress;
    addr_size = sizeof(recvAddress);
  
  
 int r = recvfrom(sock, buffer, 1024, 0, (struct sockaddr*)&recvAddress, &addr_size);
  if (r == -1) {
            perror("Error receiving data");
            close(sock);
            exit(1);
        }
  printf("Winner: %s\n", buffer);
  printf("Do you wish to continue: ");
   fgets(buffer, sizeof(buffer), stdin);
  buffer[strcspn(buffer, "\n")] = '\0';
  s = sendto(sock, buffer, 1024, 0, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
  r = recvfrom(sock, buffer, 1024, 0, (struct sockaddr*)&recvAddress, &addr_size);
  
  if(strcmp("end",buffer)==0){
    
    exit(1);
  }
}
 
  close(sock);
 
 
  return 0;
}