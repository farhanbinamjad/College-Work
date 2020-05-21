/* Program to generate two square 2D arrays of random doubles using
   threads and time their addition sequentially and using pthreads.
   The resulting sum matrix is assigned to threads by blocks of
   whole rows.  
   Compile by:  gcc -O5 -o maddB maddB.c -lm -lpthread
   Run by:  ./mmultB 1000 2000 8
*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>  // use the time to seed the random # generator
#include <math.h>  // needed for fabs function
#include <pthread.h>

#define TRUE 1
#define FALSE 0
#define BOOL int

typedef struct {
  int threadId;
  int start_row;
  int end_row;
  int start_col;
  int end_col;
  double ** array;
  double min;
  double max;
} BLOCK;


// function prototypes
double ** allocate2DArray(int rows, int columns);
void print2DArray(int rows, int columns, double ** array2D);
BOOL equal2DArrays(int rows, int columns, double ** array1, double ** array2,
		   double tolerance);
void matrixAddition(int rows1, int columns1, double ** array1, double ** array2,
                    double ** arraySum);
void * threadGenerate2DBlock(void * block);
void * threadMAdd(void * rank);


// Global variables
double ** A;
double ** B;
double ** Sum;
int numberOfThreads;
int rows, columns;


int main(int argc, char ** argv) {
  double ** C_seq;
  long i, initializationTime, startTime, endTime, seqTime, parallelTime;
  pthread_t * threadHandles;
  int errorCode, threadsA, threadsB;
  double ** Sum_seq;
  double tolerance;
  BLOCK * blocksOfWork;
  BLOCK * blocksA;
  BLOCK * blocksB;

  
  if (argc !=4) {
    printf("Usage: %s <# rows> <# columns> <# threads>\n", argv[0]);
    exit(-1);     
  } // end if

  sscanf(argv[1], "%d", &rows);
  sscanf(argv[2], "%d", &columns);
  sscanf(argv[3], "%d", &numberOfThreads);

  threadsA = numberOfThreads / 2;
  threadsB = numberOfThreads - threadsA;

  // seed the random number generator
  srand( 5 );

  A = allocate2DArray(rows, columns);
  B = allocate2DArray(rows, columns);
  Sum = allocate2DArray(rows, columns);
  Sum_seq = allocate2DArray(rows, columns);

  time(&startTime);
   // Generate arrays for threads handles
  threadHandles = (pthread_t *) malloc(numberOfThreads*sizeof(pthread_t));
  blocksA = (BLOCK *) malloc(threadsA*sizeof(BLOCK));
  blocksB = (BLOCK *) malloc(threadsB*sizeof(BLOCK));

  // create threads to randomly generate A
  for (i=0; i < threadsA; i++) {
    blocksA[i].threadId = i;
    blocksA[i].start_row = i*rows/threadsA;
    blocksA[i].end_row = (i+1)*rows/threadsA - 1;
    blocksA[i].start_col = 0;
    blocksA[i].end_col = columns - 1;
    blocksA[i].array = A;
    blocksA[i].min = 0.0;
    blocksA[i].max = +5.0;
    pthread_create(&threadHandles[i], NULL, threadGenerate2DBlock, &blocksA[i]);
  } // end for

  // create threads to randomly generate B
  for (i=0; i < threadsB; i++) {
    blocksB[i].threadId = i+threadsA; // +threadsA makes all threadId's unique
    blocksB[i].start_row = i*rows/threadsB;
    blocksB[i].end_row = (i+1)*rows/threadsB - 1;
    blocksB[i].start_col = 0;
    blocksB[i].end_col = columns - 1;
    blocksB[i].array = B;
    blocksB[i].min = 0.0;
    blocksB[i].max = +5.0;
    pthread_create(&threadHandles[threadsA+i], NULL, threadGenerate2DBlock, &blocksB[i]);
  } // end for

  for (i=0; i < numberOfThreads; i++) {
    pthread_join(threadHandles[i], (void **) NULL);
  } // end for

  time(&endTime);
  initializationTime = endTime-startTime;
  printf("Matrix Initialization time = %ld\n", initializationTime);

 
  time(&startTime);

  matrixAddition(rows, columns, A, B, Sum_seq);

  time(&endTime);
  seqTime = endTime-startTime;
  printf("Seq. Matrix Addition time = %ld\n", seqTime);

  time(&startTime);
  // Generate arrays for blocks of work for each thread 
  blocksOfWork = (BLOCK *) malloc(numberOfThreads*sizeof(BLOCK));

  // allocate block of work for each thread
  for (i=0; i < numberOfThreads; i++) {
    blocksOfWork[i].threadId = i;
    blocksOfWork[i].start_row = i*rows/numberOfThreads;
    if (i == numberOfThreads - 1) {
      blocksOfWork[i].end_row = rows - 1;  // last thread gets the rest
    } else {
      blocksOfWork[i].end_row = (i+1)*rows/numberOfThreads - 1;
    } // end if
    blocksOfWork[i].start_col = 0;
    blocksOfWork[i].end_col = columns - 1;
  } // end for


  for (i=0; i < numberOfThreads; i++) {
    if (errorCode = pthread_create(&threadHandles[i], NULL, threadMAdd, &blocksOfWork[i]\
				   ) != 0) {
      printf("pthread %d failed to be created with error code %d\n", i, errorCode);
    } // end if
  } // end for

  for (i=0; i < numberOfThreads; i++) {
    if (errorCode = pthread_join(threadHandles[i], (void **) NULL) != 0) {
      printf("pthread %d failed to be joined with error code %d\n", i, errorCode);
    } // end if
  } // end for


  time(&endTime);
  parallelTime = endTime-startTime;
  printf("Parallel Matrix Addition time = %ld\n", parallelTime);

  tolerance = 0.0000001;
  if (equal2DArrays(rows, columns, Sum, Sum_seq, tolerance)) {
    printf("Arrays match with tolerance of %.10f\n", tolerance);
  } else {
    printf("Arrays DON'T match with tolerance of %.10f\n", tolerance);
  } // end if

  // if small enough, print to screen
  if (rows < 10 && columns < 10) {
    printf("Matrix Sum sequential:\n");
    print2DArray(rows, columns, Sum_seq);
    printf("\nMatrix Sum parallel:\n");
    print2DArray(rows, columns, Sum);
  } // end if

  return 0;

} // end main

/*******************************************************************
 * Function threadGenerate2DBlock - each thread is passed a BLOCK structure
 * define the block of an array to randomly generate.
 * NOTE:  rand_r is used to generate random #'s because it is "thread safe"
 ********************************************************************/
void * threadGenerate2DBlock(void * arg) {
  BLOCK * block = (BLOCK *) arg;
  int threadId = block->threadId;
  int startRow = block->start_row;
  int endRow = block->end_row;
  int startCol = block->start_col;
  int endCol = block->end_col;
  double ** array = block->array;
  double min = block->min;
  double max = block->max;
  int r, c;
  double range, div;
  int seed = (threadId+1)*1000;

  for (r = startRow; r <= endRow; r++) {
    for (c = startCol; c <= endCol; c++) {
      range = max - min;
      div = RAND_MAX / range;
      array[r][c] = min + (rand_r(&seed) / div);
    } // end for (c...
  } // end for (r...


} // threadGenerate2DBlock



/*******************************************************************
 * Function matrixAddition - passed the dimenstions of two 2D arrays,
 * two 2D arrays, and returns the resulting 2D sum array.
 ********************************************************************/
void matrixAddition(int rows, int columns, double ** array1, double ** array2,
                    double ** arraySum) {
  int r, c;

  for (r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      arraySum[r][c] = array1[r][c] + array2[r][c];
    } // end for (c...
  } // end for (r...

} // end matrixAddition



/*******************************************************************
 * Function threadMAdd - each thread is passed a BLOCK structure
 * define the block of the Sum array to calculate.
 ********************************************************************/
void * threadMAdd(void * arg) {
  BLOCK * block = (BLOCK *) arg;
  int threadId = block->threadId;
  int startRow = block->start_row;
  int endRow = block->end_row;
  int startCol = block->start_col;
  int endCol = block->end_col;
  int r, c;

  for (r = startRow; r <= endRow; r++) {
    for (c = startCol; c <= endCol; c++) {
      Sum[r][c] = A[r][c] + B[r][c];
    } // end for (c...
  } // end for (r...

} // threadMAdd



/*******************************************************************
 * Function allocate2DArray dynamically allocates a 2D array of
 * size rows x columns, and returns it.
 ********************************************************************/
double ** allocate2DArray(int rows, int columns) {
  double ** local2DArray;
  int r;

  local2DArray = (double **) malloc(sizeof(double *)*rows);

  for (r=0; r < rows; r++) {
    local2DArray[r] = (double *) malloc(sizeof(double)*columns);
  } // end for

  return local2DArray;
} // end allocate2DArray


/*******************************************************************
 * Function print2DArray is passed the # rows, # columns, and the
 * array2D.  It prints the 2D array to the screen.
 ********************************************************************/
void print2DArray(int rows, int columns, double ** array2D) {
  int r, c;
  for(r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      printf("%10.5lf", array2D[r][c]);
    } // end for (c...
    printf("\n");
  } // end for(r...

} // end print2DArray



/*******************************************************************
 * Function equal2DArrays is passed the # rows, # columns, two 
 * array2Ds, and tolerance.  It returns TRUE if corresponding array
 * elements are equal within the specified tolerance; otherwise it
 * returns FALSE.
 ********************************************************************/
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





