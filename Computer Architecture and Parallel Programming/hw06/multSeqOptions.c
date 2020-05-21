#include <stdio.h>
#include <stdlib.h>
#include <time.h>  // use the time to seed the random # generator
#include <math.h>  // needed for fabs functioni
#include <pthread.h>

#define TRUE 1
#define FALSE 0
#define BOOL int

double ** allocate2DArray(int rows, int columns);
void print2DArray(int rows, int columns, double ** array2D);
void generateRandom2DArray(int rows, int columns, 
			   double min, double max, double ** random2DArray);
BOOL equal2DArrays(int rows, int columns, double ** array1, double ** array2,
		   double tolerance);
void matrixMultiplication(int rows1, int columns1, double ** array1, 
			  int rows2, int columns2, double ** array2,
			  double ** product);
void matrixMultiplicationAlt(int rows1, int columns1, double ** array1, 
			     int rows2, int columns2, double ** array2,
			     double ** product);

void *threadParMult(void * args);

int numberOfThreads;
int rows, columns;
double ** threadMult;
double ** A;
double ** B;
double ** array2_transpose;

int main(int argc, char ** argv) {
  double ** C;
  double ** C_alt;
  long startTime, endTime,seqTime,threadTime;
  int errorCode;
  pthread_t * threadHandles;
  if (argc !=3) {
    printf("Usage: %s <# integer matrix size>, <# cores you want to use>", argv[0]);
    exit(-1);     
  } // end if

  sscanf(argv[1], "%d", &rows);
  sscanf(argv[2], "%d",&numberOfThreads);
  columns = rows;

  // seed the random number generator
  srand( time(NULL) );
  //thread handles init
  threadHandles = (pthread_t *) malloc(numberOfThreads * sizeof(pthread_t)); 

  A = allocate2DArray(rows, columns);
  B = allocate2DArray(rows, columns);
  C = allocate2DArray(rows, columns);
  C_alt = allocate2DArray(rows, columns);
  //thread array  init
  threadMult = allocate2DArray(rows,columns);	

  generateRandom2DArray(rows, columns, -1.0, +1.0, A);
  generateRandom2DArray(rows, columns, -1.0, +1.0, B);

  printf("after initializing matrices\n");

  time(&startTime);

  matrixMultiplication(rows, columns, A, rows, columns, B, C);

  time(&endTime);
  seqTime = endTime-startTime;
  printf("Matrix Multiplication time = %ld\n",seqTime);

  time(&startTime);

  matrixMultiplicationAlt(rows, columns, A, rows, columns, B, C_alt);

  time(&endTime);
  seqTime = endTime-startTime;
  printf("Matrix Multiplication Alt. time = %ld\n",seqTime);
	
  if (equal2DArrays(rows, columns, C, C_alt, 0.0)) {
    printf("Arrays match with tolerance of %.10f\n", 0.0);
  } else {
    printf("Arrays DON'T match with tolerance of %.10f\n", 0.0);
  } // end if

  // if small enough, print to screen
  if (rows < 10 && columns < 10) {
    printf("C 2D array of doubles:\n");
    print2DArray(rows, columns, C);
    printf("\nC_alt 2D array of doubles:\n");
    print2DArray(rows, columns, C);
  } // end if
  time(&startTime);
  for(long i=0; i<numberOfThreads;i++){
  	if (errorCode = pthread_create(&threadHandles[i], NULL,threadParMult, (void *)i)!=0){
		printf("pthread %d failed to be created with error code %d\n",errorCode);
	}//end if
  }//end for
  for (long i = 0; i<numberOfThreads; i++){
	  if (errorCode = pthread_join(threadHandles[i],(void**) NULL) !=0){
	  	printf("pthread %d failed to be joined with error code %d\n",errorCode);
	  
	  }//end if
  }//end for
  time(&endTime);
  threadTime=endTime - startTime;
  printf("parrallel time = %d\n",threadTime);
  
  if (equal2DArrays(rows, columns, threadMult, C_alt, 0.0)){
 	printf("Arrays threadMult and C_alt match with the tolerance of %.10f\n",0.0);

	}//end if 
  else{
  	printf("Arrays threadMult and C_alt doesn't match with the tolerance of %.10f\n",0.0);
	}//end else

	
  return 0;

} // end main


void matrixMultiplication(int rows1, int columns1, double ** array1, 
			  int rows2, int columns2, double ** array2,
			  double ** product) {
  int i, j, k;

  if (columns1 != rows2) {
    printf("Matrices cannot be multiplied -- incompatible dimensions!\n");
    exit(-1);
  } // end if

  for (i=0; i < rows1; i++) {
    for (j=0; j < columns2; j++) {
      product[i][j] = 0.0;
      for (k=0; k < columns1; k++) {
        product[i][j] += array1[i][k]*array2[k][j];
      } /* end for (k */
    } /* end for (j */
  } /* end for (i */

} // end matrixMultiplication



void matrixMultiplicationAlt(int rows1, int columns1, double ** array1, 
			     int rows2, int columns2, double ** array2,
			     double ** product) {
  int i, j, k;
  
  if (columns1 != rows2) {
    printf("Matrices cannot be multiplied -- incompatible dimensions!\n");
    exit(-1);
  } // end if

  // Transposes array2
  array2_transpose = allocate2DArray(columns2, rows2);
  for (i=0; i < rows2; i++) {
    for (j=0; j < columns2; j++) {
      array2_transpose[j][i] = array2[i][j];
    } /* end for (j */
  } /* end for (i */

  // Matrix Multiplication uses array1 and array2_transpose
  for (i=0; i < rows1; i++) {
    for (j=0; j < columns2; j++) {
      product[i][j] = 0.0;
      for (k=0; k < columns1; k++) {
        product[i][j] += array1[i][k]*array2_transpose[j][k];
      } /* end for (k */
    } /* end for (j */
  } /* end for (i */

} // end matrixMultiplicationAlt



double ** allocate2DArray(int rows, int columns) {
  double ** local2DArray;
  int r;

  local2DArray = (double **) malloc(sizeof(double *)*rows);

  for (r=0; r < rows; r++) {
    local2DArray[r] = (double *) malloc(sizeof(double)*columns);
  } // end for

  return local2DArray;
} // end allocate2DArray


void generateRandom2DArray(int rows, int columns, 
			   double min, double max, double ** random2DArray) {
  int r, c;
  double range, div;

  for (r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      range = max - min;
      div = RAND_MAX / range;
      random2DArray[r][c] = min + (rand() / div);
    } // end for (c...
  } // end for (r...
} // end generateRandom2DArray

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


void print2DArray(int rows, int columns, double ** array2D) {
  int r, c;
  for(r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      printf("%10.5lf", array2D[r][c]);
    } // end for (c...
    printf("\n");
  } // end for(r...

} // end print2DArray


void * threadParMult(void * rank){
	int i,j,k;
	long myRank = (long) rank;
	long  blockSize;
	long firstIndex, lastIndex;

	blockSize = rows / numberOfThreads;
	firstIndex = blockSize * myRank;
	if (myRank == numberOfThreads-1){
		lastIndex = rows-1;
	}//end if 
	else{
		lastIndex = blockSize * (myRank+1)-1;
	}//end else
	for(i = firstIndex; i<=lastIndex;i++){
		for (j = 0; j<columns;j++){
			threadMult[i][j] == 0.0;
				for (k = 0; k<columns; k++){
					threadMult[i][j]+=A[i][k]*array2_transpose[j][k];
				}
		}
	}
	return NULL;
}





