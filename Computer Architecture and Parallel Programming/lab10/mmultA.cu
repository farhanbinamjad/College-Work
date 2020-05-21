/*  Programmer:  Mark Fienup
    File:        mmultA.cu
    Load Module: module load cudatoolkit
    Compile As:  nvcc -o mmultA mmultA.cu
    Run As:      qsub qsub.mmultA
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
  float * elements;
} Matrix;

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
  size = A.width * A.height * sizeof(float);
  cudaMalloc((void**) &d_A.elements, size);
  cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice);

  d_B = B;
  size = B.width * B.height * sizeof(float);
  cudaMalloc((void**) &d_B.elements, size);
  cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);

  // Allocate storage for C in device memory
  d_C = C;
  size = C.width * C.height * sizeof(float);
  cudaMalloc((void**) &d_C.elements, size);
  
  // Set-up dimensions of blocks and grid
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid((C.width + BLOCK_SIZE - 1) / BLOCK_SIZE, (C.height + BLOCK_SIZE - 1) / BLOCK_SIZE );

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
  int row = threadIdx.y + blockIdx.y * blockDim.y;
  int col = threadIdx.x + blockIdx.x * blockDim.x;
  int k;
  float CValue;

  if (row < C.height && col < C.width) {
     CValue = 0.0;
     for (k = 0; k < A.width; k++) {
     	 CValue += A.elements[row * A.width + k] * B.elements[k * B.width + col];
     } // end for
     C.elements[row * C.width + col] = CValue;
  } // end if
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
