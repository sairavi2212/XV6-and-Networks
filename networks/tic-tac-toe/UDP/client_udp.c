#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define BUFFER_SIZE 1024

void send_message(int socket, struct sockaddr_in *server_addr, const char *message)
{
    sendto(socket, message, strlen(message), 0, (struct sockaddr *)server_addr, sizeof(*server_addr));
}

int main()
{
    int sock;
    struct sockaddr_in serv_addr;
    socklen_t addrlen = sizeof(serv_addr);
    char buffer[BUFFER_SIZE];

    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);
    serv_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

    // Send initial "ready" message
    printf("Type 'ready' when you're ready to play: ");
    fgets(buffer, BUFFER_SIZE, stdin);
    send_message(sock, &serv_addr, buffer);
    while (1)
    {
        while (1)
        {
            memset(buffer, 0, BUFFER_SIZE);
            int bytes_received = recvfrom(sock, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&serv_addr, &addrlen);
            if (bytes_received <= 0)
            {
                printf("Server disconnected\n");
                close(sock);
                return 0;
            }
            buffer[bytes_received] = '\0';
            printf("%s", buffer);

            if (strstr(buffer, "Enter your move"))
            {
                fgets(buffer, BUFFER_SIZE, stdin);
                send_message(sock, &serv_addr, buffer);
            }
            if (strstr(buffer, "wins") || strstr(buffer, "draw"))
            {
                break;
            }
            if (strstr(buffer, "Do you want to play again?"))
            {
                fgets(buffer, BUFFER_SIZE, stdin);
                send_message(sock, &serv_addr,buffer);
                break;
            }
            if(strstr(buffer,"Thanks for playing!")){
                close(sock);
                return 0;
            }
        }
        if (strstr(buffer, "Game ended") || strstr(buffer, "Ending the game"))
        {
            break;
        }
    }
    close(sock);
    return 0;
}
