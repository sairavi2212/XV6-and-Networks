#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        printf("Usage: syscount <mask> command [args]\n");
        exit(1);
    }

    int mask = atoi(argv[1]);
    int pid = fork();

    if (pid == 0)
    {
        // Child process: Run the command
        exec(argv[2], &argv[2]);
        printf("exec failed\n");
        exit(1);
    }
    else if (pid > 0)
    {
        // Parent process: Wait for the command to complete
        wait(0);
        // Get the syscall count
        int count = getSysCount(mask);
        if (count < 0)
        {
            printf("Invalid syscall mask\n");
        }
        else
        {
            int syscall_index = 0;
            while (mask > 1)
            {
                syscall_index++;
                mask >>= 1;
            }
            char *syscall_names[] = {"fork", "exit", "wait", "pipe", "read", "kill", "exec", "fstat", "chdir", "dup", "getpid", "sbrk", "sleep", "uptime", "open", "write", "mknod", "unlink", "link", "mkdir", "close", "getSysCount"};
            printf("PID %d called %s %d times.\n", pid, syscall_names[syscall_index - 1], count);
        }
    }
    else
    {
        printf("fork failed\n");
        exit(1);
    }

    exit(0);
}
