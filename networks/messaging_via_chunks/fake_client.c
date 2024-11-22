#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <errno.h>
#include <fcntl.h>

#define SERVER_PORT 6969
#define CHUNK_SIZE 8
#define TIMEOUT 100000 // Timeout for ACK in microseconds
#define MAX_RETRIES 100  // Maximum retries for each chunk
#define MAX_CHUNKS 10  // Adjust based on message length
#define BUFFER_SIZE 80
socklen_t addrlen;
struct sockaddr_in address;
struct sockaddr_in client_addr;

struct data_packet
{
    int sequence_number;
    int total_chunks;
    char data[CHUNK_SIZE + 1];
};

struct ack_packet
{
    int sequence_number;
};

void set_non_blocking(int sockfd)
{
    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);
}

int receive_ack(int sockfd, int *num, int addr_len)
{
    struct timeval start_time, curr_time;
    gettimeofday(&start_time, NULL);
    int recv_sz = 0;
    socklen_t add = sizeof(client_addr);
    recv_sz = recvfrom(sockfd, num, sizeof(int), 0, (struct sockaddr *)&client_addr, &add);
    if (recv_sz >= 0)
    {
        gettimeofday(&curr_time, NULL);
        printf("Recieved ACK for packet number: %d at time: %ld.%06ld\n", *num, (long)curr_time.tv_sec, curr_time.tv_usec);
        return 1;
    }
    else
    {
        if (errno == EAGAIN || errno == EWOULDBLOCK)
        {
            gettimeofday(&curr_time, NULL);
            long elapsed_time = (curr_time.tv_sec - start_time.tv_sec) * 1000000 + (curr_time.tv_usec - start_time.tv_usec);
            if (elapsed_time >= TIMEOUT)
            {
                return 0;
            }
        }
        else
        {
            perror("recvfrom() error");
            return 0;
        }
    }
}

void send_chunks(int sockfd, char *message)
{
    int total_chunks = (strlen(message) + CHUNK_SIZE - 1) / CHUNK_SIZE;
    struct data_packet chunks[MAX_CHUNKS];
    struct timeval sent_times[MAX_CHUNKS] = {0};
    int len = strlen(message);

    int ack_recv[MAX_CHUNKS] = {0};

    for (int i = 0; i < total_chunks; i++)
    {
        strncpy(chunks[i].data, message + i * CHUNK_SIZE, CHUNK_SIZE);
        chunks[i].sequence_number = i + 1;
        chunks[i].total_chunks = total_chunks;

        if (i == total_chunks - 1)
            chunks[i].data[len - i * CHUNK_SIZE] = '\0';
        else
            chunks[i].data[CHUNK_SIZE] = '\0';
    }

    for (int i = 0; i < total_chunks; i++)
    {
        gettimeofday(&sent_times[i], NULL);
        if (sendto(sockfd, &chunks[i], sizeof(struct data_packet), 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) < 0)
        {
            perror("sendto() Packet");
            continue;
        }
        printf("Sent new packet with id: %d at time: %ld.%06ld\n", chunks[i].sequence_number,
               (long)sent_times[i].tv_sec, (long)sent_times[i].tv_usec);
    }

    int retries = 0;
    int ack_cnt = 0;

    while (retries < MAX_RETRIES && ack_cnt < total_chunks)
    {
        ack_cnt = 0;
        struct timeval current_time;

        int id;
        if (receive_ack(sockfd, &id, sizeof(client_addr)))
        {
            if (id >= 1 && id <= total_chunks) 
            {
                ack_recv[id - 1] = 1; 
            }
        }

        for (int i = 0; i < total_chunks; i++)
        {
            gettimeofday(&current_time, NULL); 

            if (ack_recv[i] == 0)
            {
                long elapsed_time = (current_time.tv_sec - sent_times[i].tv_sec) * 1000000L +
                                    (current_time.tv_usec - sent_times[i].tv_usec);

                if (elapsed_time >= TIMEOUT)
                {
                    gettimeofday(&sent_times[i], NULL); 
                    if (sendto(sockfd, &chunks[i], sizeof(struct data_packet), 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) < 0)
                    {
                        perror("sendto() Resend");
                        continue;
                    }
                    printf("Resent packet with id: %d at time: %ld.%06ld\n", chunks[i].sequence_number,
                           (long)sent_times[i].tv_sec, (long)sent_times[i].tv_usec);
                }
            }
            else
            {
                ack_cnt++;
            }
        }

        retries++;
    }

    if (ack_cnt == total_chunks)
    {
        printf("All packets are sent and acknowledged.\n");
    }
    else
    {
        printf("Some packets were not acknowledged after maximum retries.\n");
    }
}

void receive_chunks(int sockfd, char *rec_buf)
{
    int recv_packets = 0; 
    struct data_packet recv_data;
    int total_chunks = -1; 
    int ack_chunk[MAX_CHUNKS + 1] = {0}; 

    while ((total_chunks == -1) || (recv_packets < total_chunks))
    {
        socklen_t add = sizeof(client_addr);
        int recv_sz = recvfrom(sockfd, &recv_data, sizeof(struct data_packet), 0, (struct sockaddr *)&client_addr, &add);
        if (recv_sz >= 0)
        {
            printf("Received packet %d\n", recv_data.sequence_number);

            if (total_chunks == -1)
            {
                total_chunks = recv_data.total_chunks;
            }

            if (ack_chunk[recv_data.sequence_number] == 0)
            {
                ack_chunk[recv_data.sequence_number] = 1;
                recv_packets++;

                strncpy(rec_buf + (recv_data.sequence_number - 1) * CHUNK_SIZE, recv_data.data, CHUNK_SIZE);

                if (sendto(sockfd, &recv_data.sequence_number, sizeof(int), 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) < 0)
                {
                    perror("sendto() ack");
                }
                else
                {
                    printf("Sent ACK for Packet %d\n", recv_data.sequence_number);
                }
            }
        }
        else
        {
            if (errno == EAGAIN || errno == EWOULDBLOCK)
            {
                continue;
            }
            else
            {
                perror("recvfrom() error");
                continue;
            }
        }
    }

    rec_buf[recv_packets * CHUNK_SIZE] = '\0';
    printf("Received full message: %s\n", rec_buf);
}


int main()
{
    int sockfd;
    socklen_t addr_len = sizeof(client_addr);

    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    set_non_blocking(sockfd);

    memset(&client_addr, 0, sizeof(client_addr));
    client_addr.sin_family = AF_INET;
    client_addr.sin_port = htons(SERVER_PORT);
    client_addr.sin_addr.s_addr = INADDR_ANY;
    // Message to be sent
    char send_msg[BUFFER_SIZE];
    char recieve_msg[BUFFER_SIZE];
    while (1)
    {
        printf("Enter a message to send : ");
        fgets(send_msg, BUFFER_SIZE, stdin);
        send_chunks(sockfd, send_msg);
        printf("\n");
        printf("Waiting for the message...\n");
        receive_chunks(sockfd, recieve_msg);
    }

    close(sockfd);
    return 0;
}
