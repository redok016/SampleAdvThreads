//
//  request_queue.h
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//

#ifndef SampleAdvThreads_request_queue_h
#define SampleAdvThreads_request_queue_h

#include <pthread.h>
#include <stdlib.h>

#define NUM_THREADS 1


typedef struct queue_element_tag{
    
    struct queue_element_tag* next;
    void* (*worker)(void*);
    void* worker_param;
    
}queue_element_t;

typedef struct queue_tag{
    
    struct queue_element_tag* first;
    struct queue_element_tag* last;
    
    pthread_t* threads;
    pthread_mutex_t lock;
    pthread_cond_t queue_empty;
    pthread_cond_t queue_not_empty;
    pthread_cond_t queue_full;
    pthread_cond_t queue_not_full;
    
    int max_queue_size;
    int current_queue_size;
    
}queue_t;

extern void initialize_queue( queue_t* queue, int max_queue_size);
extern void add_queue( queue_t* queue, void*(*worker)(void*), void* worker_param);
extern void wait_queue( queue_t* queue);
extern void finish_queue( queue_t* queue);

#endif
