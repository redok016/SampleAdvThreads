//
//  request_queue.c
//  SampleAdvThreads
//
//  Created by JungHoyon on 13. 5. 27..
//  Copyright (c) 2013년 JungHoyon. All rights reserved.
//
#include "request_queue.h"

static void* mainloop( void* arg ){
    
    queue_t* queue = (queue_t*)arg;
    
    while (1) {
        pthread_mutex_lock(&queue->lock);
        while (queue->current_queue_size == 0) {
            pthread_cond_wait(&queue->queue_not_empty, &queue->lock);
        }
        queue_element_t* worker = queue->first;
        queue->current_queue_size--;
        
        if (queue->current_queue_size == 0) {
            queue->first = queue->last = NULL;
            queue->current_queue_size = 0;
        } else{
            queue->first = worker->next;
        }
        
        if (queue->current_queue_size == 0) {
            pthread_cond_signal(&queue->queue_empty);
        }
        if (queue->current_queue_size ==
            (queue->max_queue_size-1)) {
            pthread_cond_broadcast(&queue->queue_not_full);
        }
        pthread_mutex_unlock(&queue->lock);
        (*(worker->worker))(worker->worker_param);
        free(worker);
    }
    
    pthread_exit(0);
    //return NULL;
}

extern void initialize_queue( queue_t* queue, int max_queue_size){
    
    int i = 0;
    
    queue->first = queue->last = NULL;
    queue->max_queue_size = max_queue_size;
    queue->current_queue_size = 0;
    
    queue->threads = (pthread_t*)malloc(sizeof(pthread_t) * NUM_THREADS);
    
    pthread_mutex_init(&queue->lock, NULL);
    pthread_cond_init(&queue->queue_empty, NULL);
    pthread_cond_init(&queue->queue_not_empty, NULL);
    pthread_cond_init(&queue->queue_full, NULL);
    pthread_cond_init(&queue->queue_not_full, NULL);
    
    for (i = 0; i < NUM_THREADS; i++) {
        pthread_create(&queue->threads[i], NULL, mainloop, (void*)queue);
    }

}

extern void add_queue( queue_t* queue, void*(*worker)(void*), void* worker_param){
    
    pthread_mutex_lock(&queue->lock);
    
    while (queue->current_queue_size == queue->max_queue_size) {
        pthread_cond_wait(&queue->queue_not_full, &queue->lock);
    }
    queue_element_t* item = (queue_element_t*)malloc(sizeof(queue_element_t));
    item->next = NULL;
    item->worker = worker;
    item->worker_param = worker_param;
    
    if (queue->current_queue_size == 0) {
        queue->first = queue->last = item;
    }else{
        queue->last->next = item;
        queue->last = item;
    }
    queue->current_queue_size++;
    if (queue->current_queue_size == 1) {
        pthread_cond_broadcast(&queue->queue_not_empty);
    }
    pthread_mutex_unlock(&queue->lock);
}

extern void wait_queue( queue_t* queue){
    
    int i = 0;
    for (i = 0; i < NUM_THREADS; i++) {
        pthread_join(queue->threads[i], NULL);
    }
}
extern void finish_queue( queue_t* queue){
    
}
