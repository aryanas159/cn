#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <pthread.h>

#define PORT 8080
#define BUFFER_SIZE 1024
#define MAX_CLIENTS 8

void *handle_client(void *arg);

int main() {
    int server_socket, client_socket[MAX_CLIENTS];
    struct sockaddr_in server_address, client_address;
    char buffer[BUFFER_SIZE] = {0};
    pthread_t tid[MAX_CLIENTS];

    // Create socket
    if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("Socket creation error");
        exit(EXIT_FAILURE);
    }

    // Set up server address structure
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(PORT);

    // Bind the socket to the specified address and port
    if (bind(server_socket, (struct sockaddr*)&server_address, sizeof(server_address)) == -1) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    // Listen for incoming connections
    if (listen(server_socket, MAX_CLIENTS) == -1) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    printf("Server listening on port %d...\n", PORT);

    int num_clients = 0;

    while (1) {
        socklen_t client_address_len = sizeof(client_address);

        // Accept incoming connection
        if ((client_socket[num_clients] = accept(server_socket, (struct sockaddr*)&client_address, &client_address_len)) == -1) {
            perror("Accept failed");
            exit(EXIT_FAILURE);
        }

        printf("Client connected\n");

        // Create a new thread for each client
        if (pthread_create(&tid[num_clients], NULL, handle_client, (void*)&client_socket[num_clients]) != 0) {
            perror("Thread creation failed");
            exit(EXIT_FAILURE);
        }

        // Parent process keeps track of the number of connected clients
        num_clients++;

        // Prevent exceeding the maximum number of clients
        if (num_clients >= MAX_CLIENTS) {
            printf("Maximum number of clients reached. Ignoring new connections.\n");
            break;
        }
    }

    // Close sockets
    close(server_socket);

    return 0;
}

void *handle_client(void *arg) {
    int client_socket = *((int*)arg);
    char buffer[BUFFER_SIZE] = {0};

    // Receive and send messages
    while (1) {
        memset(buffer, 0, sizeof(buffer));

        // Receive message from client
        if (recv(client_socket, buffer, sizeof(buffer), 0) == -1) {
            perror("Receive failed");
            exit(EXIT_FAILURE);
        }

        if (strcmp(buffer, "exit") == 0) {
            printf("Client disconnected\n");
            break;
        }

        printf("Client: %s\n", buffer);

        // Send message to client
        printf("Server: ");
        fgets(buffer, sizeof(buffer), stdin);
        buffer[strlen(buffer) - 1] = '\0'; // Remove newline character

        if (send(client_socket, buffer, strlen(buffer), 0) == -1) {
            perror("Send failed");
            exit(EXIT_FAILURE);
        }

        if (strcmp(buffer, "exit") == 0) {
            printf("Server shutting down\n");
            break;
        }
    }

    // Close the socket in the thread
    close(client_socket);
    pthread_exit(NULL);
}

