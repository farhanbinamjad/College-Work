#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <time.h>
#include <pthread.h>

// Prototypes
void  * threadPartialSum(void * args);

// GLOBAL variables
double globalSum;
double * threadSums; 
int numberOfThreads;
long length;
float * myArray;

int main(int argc, char* argv[]) {
  long i;
  pthread_t * threadHandles;
  int errorCode;
  double seqSum;
  long startTime, endTime, seqTime, parallelTime;

  if (argc != 3) {
    printf("Usage: %s <# of floats to sum> <# of threads>\n", argv[0]);
    return(0);
  };

  sscanf(argv[1],"%d",&length);
  sscanf(argv[2],"%d",&numberOfThreads);

  // Generate arrays for threads handles
  threadHandles = (pthread_t *) malloc(numberOfThreads*sizeof(pthread_t));
  threadSums = (double *) malloc(numberOfThreads*sizeof(double));

  // Generate data array
  myArray=(float *) malloc(length*sizeof(float));
  srand(5);

  for (i=0; i < length; i++) {
    myArray[i] = rand() / (float) RAND_MAX;
  } // end for i

  time(&startTime);
  seqSum = 0.0;
  for (i=0; i < length; i++) {
    seqSum += myArray[i];
  } // end for i
  time(&endTime);
  seqTime = endTime - startTime;

  time(&startTime);
 
  for (i=0; i < numberOfThreads; i++) {
    if (errorCode = pthread_create(&threadHandles[i], NULL, threadPartialSum, (void *) i) != 0) {
      printf("pthread %d failed to be created with error code %d\n", i, errorCode);
    } // end if
  } // end for
    
  for (i=0; i < numberOfThreads; i++) {
    if (errorCode = pthread_join(threadHandles[i], (void **) NULL) != 0) {
      printf("pthread %d failed to be joined with error code %d\n", i, errorCode);
    } // end if
  } // end for

  // Sum up all the threadSums sequentially
  globalSum = 0.0;
  for (i=0; i < numberOfThreads; i++) {
    globalSum += threadSums[i];
  } // end for

  time(&endTime);
  parallelTime = endTime - startTime;
  
  printf( "Time to sum %ld floats using %d threads  %ld seconds (seq. %ld seconds)\n", 
	  length, numberOfThreads, parallelTime, seqTime);
  
  printf("Thread's Sum is %lf and seq. sum %lf\n\n", globalSum, seqSum);

  free(myArray);

  return 0;
} /* end main */

void * threadPartialSum(void * rank) {
  
  long myRank = (long) rank;
  long i, blockSize;
  long firstIndex, lastIndex;

  blockSize = length / numberOfThreads;
  firstIndex = blockSize * myRank;
  if (myRank == numberOfThreads-1) { // last thread gets the rest
    lastIndex = length-1;
  } else {
    lastIndex = blockSize * (myRank+1) - 1;
  } // end if

  threadSums[myRank] = 0.0;
  for (i=firstIndex; i <= lastIndex; i++) {
    threadSums[myRank] += myArray[i];
  } /* end for (i */

  return NULL;
} // end threadPartialSum
