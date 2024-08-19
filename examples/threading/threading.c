#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{
    struct thread_data* tdata;
    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    tdata = (struct thread_data*)thread_param;
    
    //sleep would not work
    usleep(tdata->wait_to_obtain_ms);
    DEBUG_LOG(sleep_1)
    pthread_mutex_lock(tdata->mutex);
    DEBUG_LOG(mutex_1)
    usleep(tdata->wait_to_release_ms);
    DEBUG_LOG(speep_2)
    pthread_mutex_unlock(tdata->mutex);
    DEBUG_LOG(mutex_2)
    
    tdata->thread_complete_success = true;
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    struct thread_data* tdata;	

    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
     
    //tdata = calloc(1, sizeof(tdata));
    tdata = (struct thread_data *)malloc(sizeof(struct thread_data));
    if (tdata == NULL)
    {
	ERROR_LOG("Failed to allocate memory for thread");
	//handle_error("calloc"); 
	return false;   
    }
    
    tdata->mutex = mutex;
    tdata->wait_to_obtain_ms = wait_to_obtain_ms;
    tdata->wait_to_release_ms = wait_to_release_ms;   
    
    if(pthread_create(thread, NULL, threadfunc, (void*)tdata) == 0)
    {
 	return true;
    }
    else
    {
    	ERROR_LOG("Create thread failure: %s", strerror(errno));
    	free(tdata);
        return false;
    }
}

