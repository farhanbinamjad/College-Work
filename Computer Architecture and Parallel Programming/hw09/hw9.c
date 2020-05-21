#define RootProcess 0
const int tag = 1;

#include <math.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <sys/types.h>
#include <mpi.h>

void initializeData(double * val, int n);
void printArray(double * val, int n);
double perform2D_SOR(int myID, int numProcs, double **resultValPtr, int n, 
		   int startRow, int endRow, double threshold, MPI_Comm comm );

int main(int argc, char * argv[])
{
  int myID, numProcs, n, rowsPerProcess, i;
  int startRow, endRow, recvCount;
  double threshold;
  double *val;      
  double *localVal;
  int * sendCounts;
  int * displacements;
  double globalDelta;
  float myThreshold;
  
  MPI_Status status;
  
  MPI_Init(&argc, &argv);  /* Initialize MPI */
  MPI_Comm_size(MPI_COMM_WORLD, &numProcs); /* Get rank */
  MPI_Comm_rank(MPI_COMM_WORLD, &myID); /* Get rank */

  
  sscanf(argv[1], "%d", &n);
  sscanf(argv[2], "%f", &myThreshold);
  threshold = (double) myThreshold;
  rowsPerProcess = n/numProcs;


  sendCounts = (int *) malloc(numProcs*sizeof(int));
  displacements = (int *) malloc(numProcs*sizeof(int));
  displacements[0] = 0;
  sendCounts[0] = (rowsPerProcess+1)*(n+2);
  for (i = 1; i < numProcs - 1; i++) {
    sendCounts[i] = (rowsPerProcess)*(n+2);
    displacements[i] = displacements[i-1] + sendCounts[i-1];
  } // end for
  displacements[numProcs-1] =  displacements[numProcs-2] + sendCounts[numProcs-2];
  sendCounts[numProcs-1] = (n+2)*(n+2) - displacements[numProcs-1];
  
  
  if ( myID == RootProcess ) {       

    printf("n=%d numProcs=%d threshold=%f\n",n, numProcs, threshold);      
    val = (double *) malloc((n+2)*(n+2)*sizeof(double));

    initializeData(val, n);
    if (n <= 16) {
      printf("Initial val:\n");
      printArray(val, n);
      
      for (i = 0; i < numProcs; i++) {
	printf("%d: sendCnt=%d displacements=%d\n",i,sendCounts[i], displacements[i]);
      } // end for
    } // end if
    
  } // end if

  startRow = 1;
  endRow = rowsPerProcess; 
  if (myID == numProcs - 1) {
    endRow = n - rowsPerProcess * (numProcs-1);
  } // end if
  recvCount = sendCounts[myID];

  if (myID == numProcs-1 || myID == 0) {
    recvCount += n + 2;
  } // end if

  localVal = (double *) malloc((endRow - startRow + 3)*(n+2)*sizeof(double));

  if (myID == 0) {
    MPI_Scatterv(val,sendCounts,displacements, MPI_DOUBLE, 
		 localVal, recvCount, MPI_DOUBLE, RootProcess, MPI_COMM_WORLD);
  } else {
    MPI_Scatterv(val,sendCounts,displacements, MPI_DOUBLE, 
		 localVal+(n+2), recvCount, MPI_DOUBLE, RootProcess, MPI_COMM_WORLD);
  } // end if

  globalDelta = perform2D_SOR(myID, numProcs, &localVal, n, startRow, endRow, threshold, MPI_COMM_WORLD);

  if (myID == numProcs - 1) {
    MPI_Gatherv(localVal + (n+2), (endRow-startRow+2)*(n+2), MPI_DOUBLE, val,
		sendCounts, displacements, MPI_DOUBLE, RootProcess,
		MPI_COMM_WORLD);
    
  } else if (myID == RootProcess) {
    MPI_Gatherv(localVal, (endRow-startRow+2)*(n+2), MPI_DOUBLE, val,
		sendCounts, displacements, MPI_DOUBLE, RootProcess,
		MPI_COMM_WORLD);
    
  } else {
    MPI_Gatherv(localVal + (n+2), (endRow-startRow+1)*(n+2), MPI_DOUBLE, val,
		sendCounts, displacements, MPI_DOUBLE, RootProcess,
		MPI_COMM_WORLD);
  } // end if

  if ( myID == RootProcess ) {       
    
    if (n <= 16) {
      printf("Final val:\n");
      printArray(val, n);
    } // end if
    printf("maximum difference:  %1.5f\n", globalDelta);
  } // end if
  
  MPI_Finalize();
  return 0;
  
} // end main

double perform2D_SOR(int myID, int numProcs, double **resultValPtr, int n, 
		   int startRow, int endRow, double threshold, MPI_Comm comm ) {
  double average, myDelta, globalDelta, thisDelta;
  double * myNew;
  double * myVal;
  double * temp;
  int i, j, step;
  int downNeighbor;
  int upNeighbor;
  MPI_Status status;
  
  myVal = *resultValPtr;
  myNew = (double *) malloc((endRow - startRow + 3)*(n+2)*sizeof(double));
  int k;


  for (k = 0; k < (endRow+2)*(n+2); k++) {
    myNew[k] = 0.0;
  } // end for i
  for (k = 0; k < (endRow+2)*(n+2); k = k + (n+2)) {
    myNew[k] = 1.0;
  } // end for i

  do {
    if (myID == RootProcess) {
      MPI_Send(myVal + endRow*(n+2), n + 2, MPI_DOUBLE, myID+1, tag, MPI_COMM_WORLD);
      MPI_Recv(myVal + (endRow+1)*(n+2), n + 2, MPI_DOUBLE, myID+1, tag, MPI_COMM_WORLD, &status);
    } else if (myID == (numProcs - 1)) {
      MPI_Send(myVal + startRow*(n+2), n + 2, MPI_DOUBLE, myID-1, tag, MPI_COMM_WORLD);
      MPI_Recv(myVal + (startRow-1)*(n+2), n + 2, MPI_DOUBLE, myID-1, tag, MPI_COMM_WORLD, &status);
    } else {
      MPI_Send(myVal + startRow*(n+2), n + 2, MPI_DOUBLE, myID-1, tag, MPI_COMM_WORLD);
      MPI_Send(myVal + endRow*(n+2), n + 2, MPI_DOUBLE, myID+1, tag, MPI_COMM_WORLD);
      MPI_Recv(myVal + (startRow-1)*(n+2), n + 2, MPI_DOUBLE, myID-1, tag, MPI_COMM_WORLD, &status);
      MPI_Recv(myVal + (endRow+1)*(n+2), n + 2, MPI_DOUBLE, myID+1, tag, MPI_COMM_WORLD, &status);
    }

    myDelta = 0.0;
    for (i = 1; i <= endRow; i++) {
      for (j = 1; j <= n; j++) {
	average = (myVal[(n+2)*i+j+1] + myVal[(n+2)*i+j-1] + myVal[(n+2)*(i+1)+j] + myVal[(n+2)*(i-1)+j])/4;
	thisDelta = fabs(average - myVal[(n+2)*i+j]);
	if (myDelta < thisDelta) {
	  myDelta = thisDelta;
	} // end if

	myNew[(n+2)*i+j] = average; 

      } // end for 
    } // end for 
    
    temp = myNew;
    myNew = myVal;
    myVal = temp;

    MPI_Allreduce(&myDelta, &globalDelta, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);

  } while(globalDelta > threshold);  

  *resultValPtr = myVal;
  return globalDelta;
} 

void initializeData(double *val, int n) {
  int i;


  for (i = 0; i < (n+2)*(n+2); i++) {
    val[i] = 0.0;
  } 
  for (i = 0; i < (n+2)*(n+2); i = i + (n+2)) {
    val[i] = 1.0;
  } 
} 


void printArray(double * val, int n) {

  int i;

  for( i = 0; i < (n+2)*(n+2); i++) {
    printf("%5.2f",val[i]);
    if ((i+1) % (n+2) == 0) {
      printf("\n");
    }
  } 
} 


