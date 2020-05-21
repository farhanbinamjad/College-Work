#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <pthread.h>
#include <stdlib.h>
#include "timer.h"

#define MAXTHREADS 16	/* Assume max. # threads */
#define TRUE 1
#define FALSE 0
#define BOOL int

double ** allocate2DArray(int rows, int columns);
void print2DArray(int rows, int columns, double ** array2D);
BOOL equal2DArrays(int rows, int columns, double ** array1, double ** array2,
		   double tolerance);
void * thread_main(void *);
void initializeData(double ** val, int n);
void sequential2D_SOR();

/* BARRIER prototype, mutex, condition variable, if needed */
void barrier();
pthread_mutex_t update_lock;
pthread_mutex_t barrier_lock;	/* mutex for the barrier */
pthread_cond_t all_here;	/* condition variable for barrier */
int count=0;			/* counter for barrier */

/* Global SOR variables */
int n, t;
double threshold;
double **val, **new,**temp;
double delta = 0.0;
double deltaNew = 0.0;


/* Command line args: matrix size, threshold, number of threads */
int main(int argc, char * argv[]) {

  /* thread ids and attributes */
  pthread_t tid[MAXTHREADS];
  pthread_attr_t attr;
  long i, j;
  float myThreshold;
  double startTime, endTime, seqTime, parTime, seqDelta;
  int errorCode;
  
  /* set global thread attributes */
  pthread_attr_init(&attr);
  pthread_attr_setscope(&attr, PTHREAD_SCOPE_SYSTEM);
  
  /* initial mutex and condition variable */
  pthread_mutex_init(&update_lock, NULL);
  pthread_mutex_init(&barrier_lock, NULL);
  pthread_cond_init(&all_here, NULL);
  
  /* read command line arguments */
  if (argc != 4) {
    printf("usage: %s <matrix size> <threshold> <number of threads>\n",
	   argv[0]);
    exit(1);
  } // end if
  
  sscanf(argv[1], "%d", &n);
  sscanf(argv[2], "%f", &myThreshold);
  sscanf(argv[3], "%d", &t);
  threshold = (double) myThreshold;

  val = allocate2DArray(n+2, n+2);
  new = allocate2DArray(n+2, n+2);
  initializeData(val, n);
  initializeData(new, n);
  printf("InitializeData done\n");

  /* Time sequential SOR */
  GET_TIME(startTime);
  sequential2D_SOR();
  GET_TIME(endTime);
  printf("Sequential Time = %1.5f\n", endTime-startTime);
  printf("maximum difference:  %e\n\n", delta);
  seqDelta = delta;
  if (n <= 10) {
    printf("Sequential result:\n");
    for (i = 0; i < n+2; i++) {
      for (j = 0; j < n+2; j++) {
	printf("%6.5f  ", val[i][j]);
      } // end for j
      printf("\n");
    } //end for i
  } // end if
  
  
  /* Time parallel SOR using pthreads */
  initializeData(val, n);
  initializeData(new, n);
  GET_TIME(startTime);
  for(i=0; i<t; i++) {
    pthread_create(&tid[i], NULL, thread_main, (void *) i);
  } // end for
  
  for (i=0; i < t; i++) {
    if (errorCode = pthread_join(tid[i],(void **) NULL)!=0){
	    printf("pthread %d" ,i);
    }
  } // end for
  GET_TIME(endTime);
  printf("Parallel Time with %d threads = %1.5f\n", t, endTime-startTime);
  printf("maximum difference:  %e\n\n", delta);
  if (seqDelta == delta) {
    printf("Deltas match!!!\n");
  }
  if (n <= 10) {
    printf("Parallel result:\n");
    for (i = 0; i < n+2; i++) {
      for (j = 0; j < n+2; j++) {
	printf("%6.5f  ", val[i][j]);
      } // end for j
      printf("\n");
    } //end for i
  } // end if
  
  
} // end main

void sequential2D_SOR() {
  double average, maxDelta, thisDelta;
  double ** temp;
  int i, j;
  
  do {
    maxDelta = 0.0;
    
    for (i = 1; i <= n; i++) {
      for (j = 1; j <= n; j++) {
	average = (val[i-1][j] + val[i][j+1] + val[i+1][j] + val[i][j-1])/4;
	thisDelta = fabs(average - val[i][j]);
	if (maxDelta < thisDelta) {
	  maxDelta = thisDelta;
	} // end if

	new[i][j] = average; // store into new array

      } // end for j
    } // end for i
    
    temp = new; /* prepare for next iteration */
    new = val;
    val = temp;
    //printf("%e\n", maxDelta);
    
    // printf("maxDelta = %8.6f\n", maxDelta);
  } while (maxDelta > threshold);  // end do-while

  delta = maxDelta; // sets global delta

} // end sequential2D_SOR


void* thread_main(void * arg) {
  int startrow,endrow,BS;
  long id=(long) arg;
  double average,thisDelta,localDelta;
  
  
  //ADD CODE HERE FOR PTHREADS TO CALCULATE 2D SOR 
  BS = n/t;
  startrow = BS*id+1;
  if (id == t-1){
    endrow = n;
    printf("thread t-1: startrow %d endrow %d threshold %6.5lf\n", startrow, endrow, threshold);
  }
  else{
    endrow = ((id+1)*BS);
  }
  do{
    localDelta = 0.0;
    barrier(id);
    if (id == 0){
      deltaNew =0.0;
    }
    barrier(id);
    for (int i =startrow; i<=endrow; i++){
      for (int j=1; j<=n; j++){
	average = (val[i-1][j] + val[i][j+1] + val[i+1][j] + val[i][j-1])/4;
	thisDelta = fabs(average-val[i][j]);
	if (localDelta<thisDelta){
	  localDelta = thisDelta;
	}
	new[i][j] = average;
      }
      
    }
    
    barrier(id);
    if (id == 0){
      temp = new;
      new = val;
      val = temp;
    }
    pthread_mutex_lock(&update_lock);
    if (localDelta>deltaNew){
      deltaNew=localDelta;
      //printf("%e\n",deltaNew);
    }
    pthread_mutex_unlock(&update_lock);
    barrier(id);
    
  }while (deltaNew>threshold); 
  if (id ==0){
    delta = deltaNew;
  }
}
// end thread_main


double ** allocate2DArray(int rows, int columns) {
  double ** local2DArray;
  int r;

  local2DArray = (double **) malloc(sizeof(double *)*rows);

  for (r=0; r < rows; r++) {
    local2DArray[r] = (double *) malloc(sizeof(double)*columns);
  } // end for

  return local2DArray;
} // end allocate2DArray

void initializeData(double ** array, int n) {
  int i, j;
  
  /* initialize to 0.0 except for 1.0s along the left boundary */
  for (i = 0; i < n+2; i++) {
    array[i][0] = 1.0;
  } // end for i

  for (i = 0; i < n+2; i++) {
    for (j = 1; j < n+2; j++) {
      array[i][j] = 0.0;
    } // end for j
  } // end for i

} // end initializeData



void print2DArray(int rows, int columns, double ** array2D) {
  int r, c;
  for(r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      printf("%10.5lf", array2D[r][c]);
    } // end for (c...
    printf("\n");
  } // end for(r...

} // end print2DArray

BOOL equal2DArrays(int rows, int columns, double ** array1, double ** array2,
		   double tolerance) {

  int r, c;

  for(r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      if (fabs(array1[r][c] - array2[r][c]) > tolerance) {
        return FALSE;
      } // end if
    } // end for (c...
  } // end for(r...
  return TRUE;

} // end equal2DArray


void barrier(long id) {
  pthread_mutex_lock(&barrier_lock);
  count++;
  //printf("count %d, id %d\n", count, id);
  if (count == t) {
    count = 0;
    pthread_cond_broadcast(&all_here);
    //printf("I'm out of here\n");
  } else {
    while(pthread_cond_wait(&all_here, &barrier_lock) != 0);
   //printf("stuck\n");	
  } // end if
  pthread_mutex_unlock(&barrier_lock);
} // end barrier
