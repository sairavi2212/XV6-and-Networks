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
struct sockaddr_in client_addrs[2];
int num_players = 0;
int server_fd;

void resetGame()
{
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            board[i][j] = ' ';
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
        for (int j = 0; j < 3; j++)
            if (board[i][j] == ' ')
                return 0;
    return 1;
}

void send_message(struct sockaddr_in *client_addr, const char *message)
{
    sendto(server_fd, message, strlen(message), 0, (struct sockaddr *)client_addr, sizeof(*client_addr));
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
        send_message(&client_addrs[i], buffer);
}

int main()
{
    struct sockaddr_in server_addr, client_addr;
    socklen_t addrlen = sizeof(client_addr);
    char buffer[BUFFER_SIZE];

    if ((server_fd = socket(AF_INET, SOCK_DGRAM, 0)) == 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
    {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    printf("Waiting for players to connect...\n");

    while (num_players < 2)
    {
        int bytes_received = recvfrom(server_fd, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&client_addr, &addrlen);
        if (bytes_received > 0)
        {
            buffer[bytes_received] = '\0';
            if (strcmp(buffer, "ready\n") == 0)
            {
                client_addrs[num_players] = client_addr;
                num_players++;
                printf("Player %d connected\n", num_players);
                snprintf(buffer, BUFFER_SIZE, "Welcome to Tic-Tac-Toe! You are Player %d. Your symbol is %c.\n", num_players, (num_players == 1) ? 'X' : 'O');
                send_message(&client_addr, buffer);
            }
        }
    }

    while (1)
    {
        resetGame();
        send_message(&client_addrs[0], "Game is starting!\n");
        send_message(&client_addrs[1], "Game is starting!\n");

        while (1)
        {
            sendBoardToClients();

            snprintf(buffer, BUFFER_SIZE, "Enter your move (row col): ");
            send_message(&client_addrs[current_player], buffer);
            snprintf(buffer, BUFFER_SIZE, "Waiting for opponent's move\n");
            send_message(&client_addrs[1 - current_player], buffer);

            int bytes_received = recvfrom(server_fd, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&client_addr, &addrlen);
            if (bytes_received <= 0)
                continue;

            buffer[bytes_received] = '\0';
            int row, col;
            if (sscanf(buffer, "%d %d", &row, &col) == 2)
            {
                if (row >= 1 && row <= 3 && col >= 1 && col <= 3 && board[row - 1][col - 1] == ' ')
                {
                    board[row - 1][col - 1] = (current_player == 0) ? 'X' : 'O';
                    if (check_winner())
                    {
                        sendBoardToClients();
                        snprintf(buffer, BUFFER_SIZE, "Player %d wins!\n", current_player + 1);
                        send_message(&client_addrs[0], buffer);
                        send_message(&client_addrs[1], buffer);
                        break;
                    }
                    if (checkDraw())
                    {
                        sendBoardToClients();
                        send_message(&client_addrs[0], "The game is a draw!\n");
                        send_message(&client_addrs[1], "The game is a draw!\n");
                        break;
                    }
                    current_player = (current_player + 1) % 2;
                }
                else
                {
                    send_message(&client_addrs[current_player], "Invalid move. Try again.\n");
                }
            }
            else
            {
                send_message(&client_addrs[current_player], "Invalid input. Use the format row col.\n");
            }
        }

        snprintf(buffer, BUFFER_SIZE, "Do you want to play again? (yes/no)\n");
        send_message(&client_addrs[0], buffer);
        send_message(&client_addrs[1], buffer);

        int ready_count = 0;
        while (ready_count < 2)
        {
            int bytes_received = recvfrom(server_fd, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&client_addr, &addrlen);
            if (bytes_received > 0)
            {
                buffer[bytes_received] = '\0';
                if (strcmp(buffer, "yes\n") == 0)
                {
                    ready_count++;
                }
                else if (strcmp(buffer, "no\n") == 0)
                {
                    // End the server if any player chooses not to replay
                    snprintf(buffer, BUFFER_SIZE, "Thanks for playing!\n");
                    send_message(&client_addrs[0], buffer);
                    send_message(&client_addrs[1], buffer);
                    close(server_fd);
                    return 0;
                }
            }
        }
    }

    close(server_fd);
    return 0;
}
