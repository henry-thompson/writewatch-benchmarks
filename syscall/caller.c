#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/mman.h>

/** Calls the mwritten system call to scan a given heapsize. */
int main(int argc, char *argv[]) {
    if (argc < 3) {
        printf("Usage: caller heapsize bufsize [-touchpages] [-selftime]\n");
        printf("- heapsize: Size of the heap to scan in bytes.\n");
        printf("- bufsize: Size of the output buffer in uintptr_t\n\n");
        printf("Run with UNIX time command to get results.\n");
        return -1;
    }

    size_t heapsize = strtol(argv[1], NULL, 10);
    size_t bufsize  = strtol(argv[2], NULL, 10);
    int argToParse = 3;

    if (heapsize < bufsize) {
        printf("Heapsize cannot be less than buffer size\n");
        return -1;
    }

    char *heap = malloc(heapsize * sizeof(char));
    uintptr_t *buffer = malloc(bufsize * sizeof(uintptr_t));

    size_t gran = 0;

    if (argToParse < argc && strcmp("-touchpages", argv[argToParse]) == 0) {
        argToParse++;

        // Touch parts of the heap
        // Ensure we fill the output buffer whilst forcing the system call to
        // traverse the entire heap.
        if (bufsize > 1) {
            uint32_t step = heapsize / (bufsize - 1);
            for (int i = heapsize - 1; i >= 0; i -= step) {
                heap[i] &= 0xDEADBEEF;
            }
        } else {
            heap[heapsize - 1] &= 0xDEADBEEF;
        }
    }

    struct timeval stop, start;

    gettimeofday(&start, NULL);
    mwritten(heap, heapsize, 0, buffer, &bufsize, &gran);
    gettimeofday(&stop, NULL);

    if (argToParse < argc && strcmp("-selftime", argv[argToParse]) == 0) {
        printf("%zu\n", stop.tv_usec - start.tv_usec, argToParse, argc);
    }
}