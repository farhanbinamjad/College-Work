#include <stdlib.h>
#include <sys/types.h>
#include <time.h>
#include <stdio.h>
#include <mpi.h>
#include "timer.h"

#define RootProcess 0

const int tag = 1;

int main(int argc, char* argv[]) {
  int myID, value, numProcs, i, p;
  float * myArray;
  float * localArray;
  double seqSum, parallelSum, localSum, recvSum;
  int * counts;
  int * displacements;
  int length;
  int length_per_process;
  double clockStart, clockEnd;
  
  GET_TIME(clockStart);

  MPI_Status status;
  
  MPI_Init(&argc, &argv);  /* Initialize MPI */
  MPI_Comm_size(MPI_COMM_WORLD, &numProcs); /* Get rank */
  MPI_Comm_rank(MPI_COMM_WORLD, &myID); /* Get rank */

  // all processes have access to argc and argv
  sscanf(argv[1],"%d",&length);
  length_per_process = length/numProcs;
  
  if ( myID == RootProcess ) { 
    if (argc != 2) {
      printf("Usage: %s <# of floats to sum>\n", argv[0]);
      return(0);
    };
    
    // Generate data array   length = SIZE;
    printf("length = %d\n", length);
    myArray=(float *) malloc(length*sizeof(float));
    srand(5);
    for (i=0; i < length; i++) {
      myArray[i] = rand() / (float) RAND_MAX;
    } // end for i
    
  }  // end if (myID == RootProcess

  // code for all MPI processes 

  localArray = (float *) malloc(length_per_process*sizeof(float));
  printf("myID %d\n", myID);

  int * displs;
  int * scounts;

  displs = (int *)malloc(numProcs*sizeof(int));
  scounts = (int *)malloc(numProcs*sizeof(int));

  for(i=0;i<numProcs;i++){
    if(i==(numProcs-1)){
      displs[i] = i * length_per_process;
      scounts[i] = length - ((numProcs-1) * length_per_process);
    }
    else{
      displs[i] = i * length_per_process;
      scounts[i] = length_per_process;
    }
  }
  // distributes same sized chucks of data to all processes
  MPI_Scatterv( myArray, scounts, displs, MPI_FLOAT, localArray,
	       scounts[i], MPI_FLOAT, RootProcess,  MPI_COMM_WORLD );
  
  /* Do the actual work */
  localSum = 0.0;
  for (i=0; i < scounts[myID]; i++) {
    localSum += localArray[i];
  } // end for i

  MPI_Reduce(&localSum, &parallelSum, 1, MPI_DOUBLE, MPI_SUM, RootProcess, MPI_COMM_WORLD);
  
  GET_TIME(clockEnd);
  
  if (myID == RootProcess) {
    printf( "Time to sum %d floats with MPI in parallel  %3.5f seconds\n", length,
	    (clockEnd - clockStart));
    GET_TIME(clockStart);
    seqSum = 0.0;
    for (i=0; i < length; i++) {
      seqSum += myArray[i];
    } // end for i
    GET_TIME(clockEnd);
    printf( "Time to sum %d floats sequentially  %3.5f seconds\n", length,
            (clockEnd - clockStart));

    printf("The parallel sum:   %f\n", parallelSum);
    printf("The sequential sum: %f\n", seqSum);
    free(myArray);
    
  } // end if
  free(localArray);
  
  MPI_Finalize();
  return 0;
} /* end main */ 

