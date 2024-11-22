#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define PORT 8080
#define BUFFER_SIZE 1024

char board[3][3] = {{' ', ' ', ' '}, {' ', ' ', ' '}, {' ', ' ', ' '}};
int current_player = 0;
int client_sockets[2];

void resetGame()
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            board[i][j] = ' ';
        }
    }
    current_player = 0;
}

int check_winner()
{
    for (int i = 0; i < 3; i++)
    {
        if (board[i][0] != ' ' && board[i][0] == board[i][1] && board[i][1] == board[i][2])
            return 1;
        if (board[0][i] != ' ' && board[0][i] == board[1][i] && board[1][i] == board[2][i])
            return 1;
    }

    if (board[0][0] != ' ' && board[0][0] == board[1][1] && board[1][1] == board[2][2])
        return 1;
    if (board[0][2] != ' ' && board[0][2] == board[1][1] && board[1][1] == board[2][0])
        return 1;

    return 0;
}

int checkDraw()
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (board[i][j] == ' ')
                return 0;
        }
    }
    return 1;
}

void send_message(int socket, char *message)
{
    if (send(socket, message, strlen(message), 0) < 0)
    {
        perror("Send failed");
    }
}

void sendBoardToClients()
{
    char buffer[BUFFER_SIZE];
    snprintf(buffer, sizeof(buffer),
             " %c | %c | %c\n---|---|---\n %c | %c | %c\n---|---|---\n %c | %c | %c\n",
             board[0][0], board[0][1], board[0][2],
             board[1][0], board[1][1], board[1][2],
             board[2][0], board[2][1], board[2][2]);

    for (int i = 0; i < 2; i++)
    {
        send(client_sockets[i], buffer, strlen(buffer), 0);
    }
}

int main()
{
    int server_fd;
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    char buffer[BUFFER_SIZE] = {0};
    int response_from_p1 = 0, response_from_p2 = 0;

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0)
    {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    printf("Waiting for players to connect...\n");

    if (listen(server_fd, 2) < 0)
    {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < 2; i++)
    {
        if ((client_sockets[i] = accept(server_fd, (struct sockaddr *)&address, (socklen_t *)&addrlen)) < 0)
        {
            perror("Accept failed");
            exit(EXIT_FAILURE);
        }
        printf("Player %d connected\n", i + 1);
        sprintf(buffer, "Welcome to Tic-Tac-Toe! You are Player %d. Your symbol is %c. Type 'ready' when you're ready to play.\n", i + 1, (i == 0) ? 'X' : 'O');
        send_message(client_sockets[i], buffer);
    }

    while (!response_from_p1 || !response_from_p2)
    {
        for (int i = 0; i < 2; i++)
        {
            if (i == 0)
            {
                if (!response_from_p1)
                {
                    int bytes_read = recv(client_sockets[i], buffer, BUFFER_SIZE, 0);
                    if (bytes_read > 0)
                    {
                        buffer[bytes_read] = '\0';
                        if (strcmp(buffer, "ready\n") == 0)
                        {
                            response_from_p1 = 1;
                            printf("Player %d is ready\n", i + 1);
                        }
                    }
                }
            }
            else
            {
                if (!response_from_p2)
                {
                    int bytes_read = recv(client_sockets[i], buffer, BUFFER_SIZE, 0);
                    if (bytes_read > 0)
                    {
                        buffer[bytes_read] = '\0';
                        if (strcmp(buffer, "ready\n") == 0)
                        {
                            response_from_p2 = 1;
                            printf("Player %d is ready\n", i + 1);
                        }
                    }
                }
            }
        }
    }

    while (1)
    {
        resetGame();

        send_message(client_sockets[0], "Game is starting!\n");
        send_message(client_sockets[1], "Game is starting!\n");

        char buffer[BUFFER_SIZE] = {0};

        while (1)
        {
            sendBoardToClients(client_sockets);

            sprintf(buffer, "Enter your move (row col): ");
            send_message(client_sockets[current_player], buffer);
            sprintf(buffer, "Waiting for opponent's move\n");
            send_message(client_sockets[1 - current_player], buffer);

            int bytes_read = recv(client_sockets[current_player], buffer, BUFFER_SIZE, 0);
            if (bytes_read <= 0)
                continue;

            int row, col;
            if (sscanf(buffer, "%d %d", &row, &col) == 2)
            {
                if (row >= 1 && row <= 3 && col >= 1 && col <= 3 && board[row - 1][col - 1] == ' ')
                {
                    board[row - 1][col - 1] = (current_player == 0) ? 'X' : 'O';
                    if (check_winner())
                    {
                        sendBoardToClients(client_sockets);
                        sprintf(buffer, "Player %d wins!\n", current_player + 1);
                        send_message(client_sockets[0], buffer);
                        send_message(client_sockets[1], buffer);
                        break;
                    }
                    if (checkDraw())
                    {
                        sendBoardToClients(client_sockets);
                        send_message(client_sockets[0], "The game is a draw!\n");
                        send_message(client_sockets[1], "The game is a draw!\n");
                        break;
                    }
                    current_player = (current_player + 1) % 2;
                }
                else
                {
                    send_message(client_sockets[current_player], "Invalid move. Try again.\n");
                }
            }
            else
            {
                send_message(client_sockets[current_player], "Invalid input. Use the format row col.\n");
            }
        }

        int rp1 = 0, rp2 = 0;

        printf("Asking players if they want to continue...\n");

        for (int i = 0; i < 2; i++)
        {
            char *msg = "Do you want to play again? (yes/no): ";
            send_message(client_sockets[i], msg);

            int bytes_read = recv(client_sockets[i], buffer, BUFFER_SIZE, 0);
            if (bytes_read <= 0)
            {
                printf("Error receiving response from Player %d\n", i + 1);
                continue;
            }
            buffer[bytes_read] = '\0';
            printf("Received response from Player %d: %s", i + 1, buffer);
            if (i == 0)
            {
                if (strncmp(buffer, "yes", 3) == 0)
                    rp1 = 1;
            }
            else
            {
                if (strncmp(buffer, "yes", 3) == 0)
                    rp2 = 1;
            }
        }

        if (rp1 && rp2)
        {
            char *msg = "Starting a new game!\n";
            send_message(client_sockets[0], msg);
            send_message(client_sockets[1], msg);
            printf("Both players agreed to continue\n");
            continue;
        }
        else
        {
            char *msg = "Ending the game as your opponent don't want to play.\n";
            if (rp2)
                send_message(client_sockets[1], msg);
            else if (rp1)
                send_message(client_sockets[0], msg);
            printf("Game ended\n");
            break;
        }
    }

    close(client_sockets[0]);
    close(client_sockets[1]);
    close(server_fd);
    return 0;
}
