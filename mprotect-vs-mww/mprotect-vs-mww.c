#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/mman.h>
#include <signal.h>
#include <sys/syscall.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <inttypes.h>

#define PAGE_SHIFT 12
#define PAGE_SIZE (1L << PAGE_SHIFT)
#define OUT_BUF_LENGTH 1024
#define MAX_PAGE_COUNT ((1L << 32) / PAGE_SIZE)

uint8_t card_table[MAX_PAGE_COUNT / 8];

void *allocate_heap(size_t);
void write_to_heap(void*, size_t, uint32_t, uint32_t*);
void handler(int, siginfo_t*, void*);
bool registerSignalHandler();
bool protect_heap(void*, size_t, uint32_t);
bool mwritten_heap(void*, size_t, uint32_t);
void shuffle(uint32_t*, size_t);

void *heap_start = 0;

int main(int argc, char** argv)
{
    if (argc != 5) {
        printf("Usage: %s [p|w|n] [heapsize] [# pages to write] [fragment heap into n regions]\n", argv[0]);
        printf("p: Use mprotect write-watch\n");
        printf("w: Use mwritten syscall\n");
        printf("n: Don't track writes (measure baseline)\n");
        printf("Heapsize must be a multiple of system page size\n");
        printf("Heap fragments must be a factor of heap size\n");
        return 0;
    }

    // 'p' for mprotect; 'w' for mwritten; 'n' for none
    char mode = argv[1][0];
    size_t heap_size = atoi(argv[2]);
    uint32_t modify_page_target = atoi(argv[3]);
    uint32_t heap_fragments = atoi(argv[4]);

    // Check constraints
    if (heap_size % PAGE_SIZE != 0) {
        printf("Heap size must be multiple of system page size\n");
        return -1;
    }

    if (heap_size % heap_fragments != 0) {
        printf("Heap fragment count must be factor of heap size\n");
        return -1;
    }

    if (modify_page_target > heap_size / PAGE_SIZE) {
        printf("Can't modify more pages than there are in the heap!\n");
        return -1;
    }

    // We make heavy use of this later.
    time_t t;
    srand((unsigned) time(&t));

    // Set everything up
    heap_start = allocate_heap(heap_size);

    if (!heap_start) {
        return -1;
    }
    
    if (mode == 'p') {
        if (registerSignalHandler() == false) {
            return -1;
        }

        if (protect_heap(heap_start, heap_size, heap_fragments) == false) {
            return -1;
        }
    }

    uint32_t page_count = heap_size / PAGE_SIZE;

    // Produce an array of every possble page index
    uint32_t *page_indices = malloc(page_count * sizeof(uint32_t));

    for (uint32_t i = 0; i < page_count; i++) {
        page_indices[i] = i;
    }

    for (int i = 0; i < 100; i++) {
        // Randomise the order of pages we are to visit
        shuffle(page_indices, page_count);

        // Start the timer
        struct timeval stop, start;
        gettimeofday(&start, NULL);

        // Now write to the heap in the manner requested.
        write_to_heap(heap_start, heap_size, modify_page_target, page_indices);

        if (mode == 'w') {
            mwritten_heap(heap_start, heap_size, heap_fragments);
        } else if (mode == 'p') {
            protect_heap(heap_start, heap_size, heap_fragments);
        }

        // End the timer
        gettimeofday(&stop, NULL);

        // Output time taken (us)
	uint64_t start_usec = start.tv_sec * 1000000 + start.tv_usec;
	uint64_t stop_usec = stop.tv_sec * 1000000 + stop.tv_usec;

        printf("%"PRId64"\t", stop_usec - start_usec);
    }

    free(page_indices);
    munmap(heap_start, heap_size);
    printf("\n");

    return 0;
}

/**
 * Allocates the 'heap' we are testing on, touching every page to ensure
 * we don't hit page faults later on during the benchmark.
 */
void *allocate_heap(size_t heap_size)
{
    /** Allocate the 'heap' */
    void *heap = mmap((void*)0, heap_size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON|MAP_PREFAULT_READ, -1, 0);

    if (heap == MAP_FAILED) {
        printf("mmap failed. Abort!\n");
        return 0;
    }

    /** Touch every page. */
    for (int i = 0; i < heap_size; i += PAGE_SIZE) {
        *((uint8_t*)(heap + i)) = 42;
    }

    return heap;
}

/**
 * Writes to modified_page_target pages in the heap of size heap_size starting 
 * at heap. Provide a list of the pages to be visited in the order they will
 * be visited.
 */
void write_to_heap(void *heap, size_t heap_size, uint32_t modify_page_target, uint32_t *page_indices)
{
    for (uint32_t i = 0; i < modify_page_target; i++) {
        uint32_t page_index = page_indices[i];
        uint32_t *ptr = (uint32_t *)(heap + (page_index * PAGE_SIZE));

        // Write to this page.
        for (uint16_t j = 0; j < 256; j++) {
            *ptr &= 5;
            ptr++;
        }
    }
}

void handler(int sig, siginfo_t *si, void *unused)
{
    void *addr = si->si_addr;
    if (mprotect(addr, PAGE_SIZE, PROT_READ|PROT_WRITE) != 0) {
        printf("mprotect: unprotecting pages failed\n");
        return;
    }

    int page_index = (addr - heap_start) >> PAGE_SHIFT;

    // Record the page write in the card-table
    card_table[page_index / 8] |= (0x80 >> (page_index % 8));
}

bool registerSignalHandler()
{
    struct sigaction sa;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);

    sa.sa_sigaction = handler;

    if (sigaction(SIGSEGV, &sa, NULL) == -1) {
        printf("sigaction: failed to set signal handler\n");
        return false;
    }

    return true;
}

bool protect_heap(void *heap, size_t heap_size, uint32_t fragments)
{
    size_t fragment_size = heap_size / fragments;

    for (uint32_t i = 0; i < fragments; i++) {
        void *fragment_start = (void*)(heap + (fragment_size * i));
        if (mprotect((void*)fragment_start, fragment_size, PROT_READ) != 0) {
            printf("mprotect: failed to write protect heap\n");
            return false;
        }
    }

    return true;
}

bool mwritten_heap(void *heap, size_t heap_size, uint32_t fragments)
{
    uintptr_t mww_addr_buf[OUT_BUF_LENGTH];
    size_t fragment_size = heap_size / fragments;

    // Heap fragments.
    for (uint32_t i = 0; i < fragments; i++) {
        void *fragment_start = heap + (fragment_size * i);
        size_t count = OUT_BUF_LENGTH;
        size_t gran = -1;

        do {
            if (mwritten((void*)fragment_start, fragment_size, MWRITTEN_CLEAR, &mww_addr_buf, &count, &gran) != 0) {
                printf("mwritten: failed\n");
                return false;
            }
        } while (count == OUT_BUF_LENGTH);
    }

    return true;
}

// Randomise ordering of pages to visit.
void shuffle(uint32_t *array, size_t n) {
    for (uint32_t i = 0; i < n; i++) {
        uint32_t x = (rand() * rand()) % n;
	uint32_t t = array[i];
	array[i] = array[x];
	array[x] = t;
    }
}
