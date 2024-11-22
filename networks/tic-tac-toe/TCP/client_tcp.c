#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define BUFFER_SIZE 1024

void send_message(int socket, const char *message)
{
    if (send(socket, message, strlen(message), 0) < 0)
    {
        perror("Send failed");
    }
}

int main()
{
    int sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[BUFFER_SIZE] = {0};

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0)
    {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        printf("\nConnection Failed \n");
        return -1;
    }

    int bytes_read = recv(sock, buffer, BUFFER_SIZE, 0);
    if (bytes_read > 0)
    {
        buffer[bytes_read] = '\0';
        printf("%s", buffer);
    }

    printf("Type 'ready' when you're ready to play: ");
    fgets(buffer, BUFFER_SIZE, stdin);
    send_message(sock, buffer);

    while (1)
    {
        while (1)
        {
            memset(buffer, 0, BUFFER_SIZE);
            bytes_read = recv(sock, buffer, BUFFER_SIZE, 0);
            if (bytes_read <= 0)
            {
                printf("Server disconnected\n");
                close(sock);
                return 0;
            }
            buffer[bytes_read] = '\0';
            printf("%s", buffer);

            if (strstr(buffer, "Enter your move"))
            {
                fgets(buffer, BUFFER_SIZE, stdin);
                send_message(sock, buffer);
            }

            if (strstr(buffer, "wins") || strstr(buffer, "draw"))
            {
                break;
            }

            if (strstr(buffer, "Do you want to play again?"))
            {
                fgets(buffer, BUFFER_SIZE, stdin);
                send_message(sock, buffer);
                break;
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