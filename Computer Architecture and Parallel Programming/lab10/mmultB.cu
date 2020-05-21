/*  Programmer:  Mark Fienup
    File:        mmultB.cu
    Compile As:  nvcc -o mmultB mmultB.cu
    Run As:      ./mmultB <matrix size>
    Description:  A CUDA solution to the matrix multiplication
    Stores matrices in 1-D arrays in row-order.
*/

#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>

#define BLOCK_SIZE 16
#define TRUE 1
#define FALSE 0
#define BOOL int

static void HandleError( cudaError_t err,
                         const char *file,
                         int line ) {
  if (err != cudaSuccess) {
    printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
	    file, line );
    exit( EXIT_FAILURE );
  }
}
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))

typedef struct {
  int width;
  int height;
  int stride;
  float * elements;
} Matrix;


// Get a matrix element
__device__ float GetElement(const Matrix A, int row, int col) {
  return A.elements[row * A.stride + col];
} // end GetElement

// Set a matrix element
__device__ void SetElement(Matrix A, int row, int col, float value) {
  A.elements[row * A.stride + col] = value;
} // end SetElement

// Get the BLOCK_SIZE x BLOCK_SIZE sub-matrix Asub of A that is 
// located col sub-matrices to the right and row sub-matrices down
// from the upper-left corner of A
__device__ Matrix GetSubMatrix(Matrix A, int row, int col) {

  Matrix Asub;

  Asub.width = BLOCK_SIZE;
  Asub.height = BLOCK_SIZE;
  Asub.stride = A.stride;
  Asub.elements = &A.elements[A.stride*BLOCK_SIZE*row + BLOCK_SIZE*col];

  return Asub;
} // end GetSubMatrix

// function prototypes
Matrix initializeMatrix(int rows, int columns, float min, float max);
void printMatrix(Matrix M);
BOOL equalMatrices(const Matrix M1, const Matrix M2, float tolerance);
void seqMatrixMult(const Matrix A, const Matrix B, Matrix C);

__global__ void matrixMultKernel(const Matrix A, const Matrix B, Matrix C);


int main(int argc, char* argv[]) {
  Matrix A, B, C, seqC;
  int n;  // assume square
  size_t size;

  cudaDeviceProp prop;
  // fermi1 device #0 is Tesla C2070 has 2.0 Compute Capability
  HANDLE_ERROR(cudaGetDeviceProperties( &prop, 0));
  HANDLE_ERROR(cudaSetDevice(0));  
  
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  
  if (argc != 2) {
     printf("Usage: %s <matrix size>\n", argv[0]);
     exit(-1);  
  } // end if 

  sscanf(argv[1], "%d", &n);
  printf("n = %d\n",n);
  
  A = initializeMatrix(n, n, +1.0, -1.0);
  B = initializeMatrix(n, n, +1.0, -1.0);
  C = initializeMatrix(n, n, +1.0, -1.0);
  seqC = initializeMatrix(n, n, +1.0, -1.0);

  /* Do the actual work sequentially */
  cudaEventRecord(start,0);

  seqMatrixMult(A, B, seqC);

  cudaEventRecord(stop, 0);
  cudaEventSynchronize( stop);
  float elapsedTime;
  cudaEventElapsedTime( &elapsedTime, start, stop);
  printf( "Time perform seq. Matrix Multiplication on host: %3.1f ms\n", elapsedTime);
  
  // Do the work on GPU 
  cudaEventRecord(start,0);
  Matrix d_A, d_B, d_C;

  // Copy A and B to device memory
  d_A = A;
  d_A.stride = A.width;
  size = A.width * A.height * sizeof(float);
  cudaMalloc((void**) &d_A.elements, size);
  cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice);

  d_B = B;
  d_B.stride = B.width;
  size = B.width * B.height * sizeof(float);
  cudaMalloc((void**) &d_B.elements, size);
  cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);

  // Allocate storage for C in device memory
  d_C = C;
  d_C.stride = C.width;
  size = C.width * C.height * sizeof(float);
  cudaMalloc((void**) &d_C.elements, size);
  
  // Set-up dimensions of blocks and grid
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid((B.width + BLOCK_SIZE - 1) / BLOCK_SIZE, (A.height + BLOCK_SIZE - 1) / BLOCK_SIZE );

  // Invoke kernel
  matrixMultKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);
  
  // Copy GPU calculated C back to host memory
  cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost);
  
  cudaEventRecord(stop, 0);
  cudaEventSynchronize( stop);
  
  cudaEventElapsedTime( &elapsedTime, start, stop);
  printf( "Time perform Matrix Multiplication on CUDA device: %3.1f ms\n", elapsedTime);
  
  if (equalMatrices(C, seqC, 0.001)) {
    printf("Results match within a tolerance of %f\n", 0.001);
  } else {
    printf("Results wrong:  tolerance used %f\n", 0.001);
  } // end if

  // print if small enough
  if (C.width < 10 && C.height < 10) {
     printf("\nC from CUDA:\n");
     printMatrix(C);
     printf("\nseqC from host:\n");
     printMatrix(seqC);
  } // end if  

  cudaEventDestroy( start );
  cudaEventDestroy( stop );
  cudaFree( d_A.elements );
  cudaFree( d_B.elements );
  cudaFree( d_C.elements );
  
  free(A.elements);
  free(B.elements);
  free(C.elements);
  free(seqC.elements);
  
  return 0;
} /* end main */

// Each thread computes one element of C by accumulating results in local CValue
__global__ void matrixMultKernel(const Matrix A, const Matrix B, Matrix C) {

  // block row and column
  int blockRow = blockIdx.y;
  int blockCol = blockIdx.x;

  // Each thread block computes one sub-matrix Csub of C
  Matrix Csub = GetSubMatrix(C, blockRow, blockCol);

  // Each thread computes one element of Csub by
  // accumulating results into CValue
  float CValue = 0.0;

  // Thread row and column within Csub
  int row = threadIdx.y;
  int col = threadIdx.x;

  // Loop over all the sub-matrices of A and B that are required
  // to computer Csub
  // Multiply each pair of sub-matrices together and accumulate
  // the results
  for (int m=0; m < (A.width/BLOCK_SIZE); m++) {

     // Get sub-matrix of A
     Matrix Asub = GetSubMatrix(A, blockRow, m);

     // Get sub-matrix of B
     Matrix Bsub = GetSubMatrix(B, m, blockCol);

     // Shared memory used to store Asub and Bsub
     __shared__ float As[BLOCK_SIZE][BLOCK_SIZE];
     __shared__ float Bs[BLOCK_SIZE][BLOCK_SIZE];

     // Load Asub and Bsub from device memory to shared memory
     // Each thread loads one element of each sub-matrix
     As[row][col] = GetElement(Asub, row, col);
     Bs[row][col] = GetElement(Bsub, row, col);

     // Synchronize to make sure the sub-matrices are loaded 
     // before starting to computation of Csub
     __syncthreads();

     // Multiply Asub and Bsub together
     for (int k = 0; k < BLOCK_SIZE; k++) {
     	 CValue += As[row][k] * Bs[k][col];
     } // end for

     // Synchronize to make sure that the preceeding 
     // computation is done before loading two new 
     // sub-matrices of A and B in the next iteration
     __syncthreads();

  } // end for (m

  // Write Csub to device memory
  // Each thread writes one element
  SetElement(Csub, row, col, CValue);

} // end matrixMultKernel


/***************************************************************
 Allocate matrix of floats at 1D array and initialized elements
 randomly.
 ***************************************************************/
Matrix initializeMatrix(int rows, int columns, float min, float max) {
  int i;
  float range, div;
  Matrix M;

  M.width = columns;
  M.height = rows;
  M.elements = (float *) malloc(sizeof(float) * rows * columns);

  for (i=0; i < rows*columns; i++) {
      range = max - min;
      div = RAND_MAX / range;
      M.elements[i] = min + (rand() / div);
  } // end for

  return M;
} // end initializeMatrix


/***************************************************************
 Prints matrix to screen
****************************************************************/
void printMatrix(Matrix M) {
  int r, c;

  for (r=0; r < M.height; r++) {
    for (c=0; c < M.width; c++) {
    	printf("%8.4f ",M.elements[r * M.width + c]);
    } // end for (c... 
    printf("\n");
  } // end for (r... 

} // end printMatrix


/***************************************************************
 Compares elements of M1 and M2 to see whether all match within
 the given tolerance.  Returns TRUE or FALSE accordingly.
****************************************************************/
BOOL equalMatrices(const Matrix M1, const Matrix M2, float tolerance) {
  int i;

  if (M1.width != M2.width || M1.height != M2.height) {
     return FALSE;
  } // end if

  for (i=0; i < M1.width*M1.height; i++) {
      if (fabsf(M1.elements[i] - M2.elements[i]) > tolerance) {
printf("MISMATCH VALUES: %f %f\n", M1.elements[i],M2.elements[i]);
        return FALSE;
      } // end if
   } // end for
   return TRUE;

} // end equalMatrices


/***************************************************************
 Sequentially computes matrix multiplication of C = A * B with
 C being returned.
****************************************************************/
void seqMatrixMult(const Matrix A, const Matrix B, Matrix C) {
  int i, j, k;
  float CValue;

  for (i=0; i < C.height; i++) {
    for (j=0; j < C.width; j++) {
      CValue = 0.0;
      for (k=0; k < A.width; k++) {
        CValue += A.elements[i*A.width + k] * B.elements[k*B.width + j];
      } /* end for (k */
      C.elements[i*C.width + j] = CValue;
    } /* end for (j */
  } /* end for (i */
  
} // end seqMatrixMult