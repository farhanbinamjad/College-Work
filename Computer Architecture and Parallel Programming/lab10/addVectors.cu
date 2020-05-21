/*  Programmer:  Mark Fienup
    File:        addVectors.cu
    Compile As:  nvcc -o addVectors addVectors.cu
    Run As:      qsub qsub.addVectors
    Description:  A CUDA solution to the add two 1-D vectors.
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

// function prototypes
float*  initializeVector(int length, float min, float max);
void printVector(int length, float *);
BOOL equalVectors(int length, float * vector1, float * vector2, float tolerance);
void seqVectorAddition(int length, float * a, float * b, float * c);

__global__ void vectorAdditionKernel(int length, float * a, float * b, float * c);

int main(int argc, char* argv[]) {
  float * a;
  float * b;
  float * c;
  float * seqC;
  int length;  // assume square
  size_t size;

  cudaDeviceProp prop;
  // fermi1 device #0 is Tesla C2070 has 2.0 Compute Capability
  HANDLE_ERROR(cudaGetDeviceProperties( &prop, 0));
  HANDLE_ERROR(cudaSetDevice(0));  
  
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  
  if (argc != 2) {
     printf("Usage: %s <length>\n", argv[0]);
     exit(-1);  
  } // end if 

  sscanf(argv[1], "%d", &length);
  printf("vector length = %d\n",length);
  
  a = initializeVector(length, +1.0, -1.0);
  b = initializeVector(length, +1.0, -1.0);
  c = initializeVector(length, +1.0, -1.0);
  seqC = initializeVector(length, +1.0, -1.0);

  /* Do the actual work sequentially */
  cudaEventRecord(start,0);

  seqVectorAddition(length, a, b, seqC);

  cudaEventRecord(stop, 0);
  cudaEventSynchronize( stop);
  float elapsedTime;
  cudaEventElapsedTime( &elapsedTime, start, stop);
  printf( "Time perform seq. vector addition on host: %3.1f ms\n", elapsedTime);

  // Do the work on GPU 
  cudaEventRecord(start,0);
  float * d_a;
  float * d_b;
  float * d_c;

  // Copy a and b to device memory
  size = length * sizeof(float);
  cudaMalloc((void**) &d_a, size);
  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);

  cudaMalloc((void**) &d_b, size);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

  // Allocate storage for c in device memory
  cudaMalloc((void**) &d_c, size);
  
  // Invoke kernel with 128 blocks, each with 128 threads
  vectorAdditionKernel<<<128, 128>>>(length, d_a, d_b, d_c);
  
  // Copy GPU calculated c back to host memory
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
  
  cudaEventRecord(stop, 0);
  cudaEventSynchronize( stop);
  
  cudaEventElapsedTime( &elapsedTime, start, stop);
  printf( "Time perform vector addition on CUDA device: %3.1f ms\n", elapsedTime);
  
  if (equalVectors(length, c, seqC, 0.001)) {
    printf("Results match within a tolerance of %f\n", 0.001);
  } else {
    printf("Results wrong:  tolerance used %f\n", 0.001);
  } // end if

  // print if small enough
  if (length < 10) {
     printf("\nc from CUDA:\n");
     printVector(length, c);
     printf("\nseqC from host:\n");
     printVector(length, seqC);
  } // end if  

  cudaEventDestroy( start );
  cudaEventDestroy( stop );
  cudaFree( d_a );
  cudaFree( d_b );
  cudaFree( d_c );
  
  free(a);
  free(b);
  free(c);
  free(seqC);
  
  return 0;
} /* end main */


// Each thread might compute many elements with each stride apart
__global__ void vectorAdditionKernel(int length, float * a, float * b, float * c) {
  int tid = threadIdx.x + blockIdx.x * blockDim.x;
  int stride = gridDim.x * blockDim.x;

  while ( tid < length ) {
     c[tid] = a[tid] + b[tid];
     tid += stride;
  } // end while
} // end vectorAdditionKernel


/***************************************************************
 Allocate vector of floats and initialized elements
 randomly.
 ***************************************************************/
float* initializeVector(int length, float min, float max) {
  int i;
  float range, div;
  float * temp;

  temp = (float *) malloc(sizeof(float) * length);

  for (i=0; i < length; i++) {
      range = max - min;
      div = RAND_MAX / range;
      temp[i] = min + (rand() / div);
  } // end for

  return temp;
} // end initializeVector


/***************************************************************
 Prints vector to screen
****************************************************************/
void printVector(int length, float * v) {
  int i;

  for (i=0; i < length; i++) {
      printf("%8.4f ", v[i]);
  } // end for
    printf("\n");
} // end printVector



/***************************************************************
 Compares elements of vector1 and vector2 to see whether all match within
 the given tolerance.  Returns TRUE or FALSE accordingly.
****************************************************************/
BOOL equalVectors(int length, float * vector1, float * vector2, float tolerance) {
  int i;

  for (i=0; i < length; i++) {
      if (fabsf(vector1[i] - vector2[i]) > tolerance) {
      	 printf("MISMATCH VALUES: %f %f\n", vector1[i], vector2[i]);
         return FALSE;
      } // end if
   } // end for
   return TRUE;

} // end equalVectors


/***************************************************************
 Sequentially computes vector addition of c = a + b with
 c being returned.
****************************************************************/
void seqVectorAddition(int length, float * a, float * b, float * c) {
  int i;

  for (i=0; i < length; i++) {
     c[i] = a[i] + b[i];
  } /* end for (i */
  
} // end seqVectorAddition
