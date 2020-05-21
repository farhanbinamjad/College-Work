#include <stdio.h>
#include <stdlib.h>
#include <time.h>  // use the time to seed the random # generator
#include <math.h>  // needed for fabs function

#define TRUE 1
#define FALSE 0
#define BOOL int

// function prototypes
double ** allocate2DArray(int rows, int columns);
void print2DArray(int rows, int columns, double ** array2D);
void generateRandom2DArray(int rows, int columns, 
			   double min, double max, double ** random2DArray);
void write2DArray(int rows, int columns, double ** random2DArray, 
		  FILE * outputFilePtr);
void read2DArray(int * rows, int * columns, double *** array2DRead, 
		 FILE * inputFilePtr);
BOOL equal2DArrays(int rows, int columns, double ** array1, double ** array2,
		   double tolerance);


int main(int argc, char ** argv) {
  FILE * outputFilePtr;
  FILE * inputFilePtr;
  double **  random2DArray;  // dynamically allocated array
  double ** array2DRead;
  double minRandom, maxRandom;
  int rows, columns;
  int rowsRead, columnsRead;
  
  if (argc !=6) {
    printf("Usage: %s <# rows> <# columns> <filename.dat> <min. random> <max. random>\n"
	   , argv[0]);
    exit(-1);     
  } // end if

  if ((outputFilePtr = fopen(argv[3], "wb")) == NULL) {
    printf("%s cannot be opened for writing\n", argv[3]);
    exit(-1);
  } // end if

  sscanf(argv[1], "%d", &rows);
  sscanf(argv[2], "%d", &columns);
  sscanf(argv[4], "%lf", &minRandom);
  sscanf(argv[5], "%lf", &maxRandom);

  random2DArray = allocate2DArray(rows, columns);
  generateRandom2DArray(rows, columns, minRandom, maxRandom, random2DArray);

  // if small enough, print to screen
  if (rows < 10 && columns < 10) {
    printf("Randomly generated 2D array of doubles:\n");
    print2DArray(rows, columns, random2DArray);
  } // end if

  write2DArray(rows, columns, random2DArray, outputFilePtr);

  fclose(outputFilePtr);  // close the file --> flush to disk

  /* COMMENTED OUT CODE TO USE IN PART B OF THE LAB

  if ((inputFilePtr = fopen(argv[3], "rb")) == NULL) {
    printf("%s cannot be opened for reading\n", argv[3]);
    exit(-1);
  } // end if

  read2DArray(&rowsRead, &columnsRead, &array2DRead, inputFilePtr);

  printf("\n2D array of doubles read from file:\n");
  print2DArray(rowsRead, columnsRead, array2DRead);

  fclose(inputFilePtr);

  if (equal2DArrays(rows, columns, random2DArray, array2DRead, 0.0)) {
    printf("Arrays match with tolerance of %.10f\n", 0.0);
  } else {
    printf("Arrays DON'T match with tolerance of %.10f\n", 0.0);
  } // end if

  */

  return 0;

} // end main


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
 * Function write2DArray is passed the # rows, the # columns,
 * 2D array, and the binary file pointer.  It writes the #row, #columns,
 * and the 2D array in row-order. 
 * See tutorial on files at: http://www.cprogramming.com/tutorial/cfileio.html
 ********************************************************************/
void write2DArray(int rows, int columns, double ** random2DArray, 
	     FILE * outputFilePtr) {
  int r;

  fwrite(&rows, sizeof(int), 1, outputFilePtr);
  fwrite(&columns, sizeof(int), 1, outputFilePtr);
  for (r=0; r < rows; r++) {
    // writes a whole row of the array
    fwrite(random2DArray[r], sizeof(double), columns, outputFilePtr);
  } // end for
} // end write2DArray




/*******************************************************************
 * Function read2DArray is passed a binary file pointer containing a
 * # rows, # columns, and the 2D array of doubles in row-order. 
 * It returns the # rows, the # columns, and the 2D array.
 * See tutorial on files at: http://www.cprogramming.com/tutorial/cfileio.html
 ********************************************************************/
void read2DArray(int * rows, int * columns, double *** array2DRead, 
	     FILE * inputFilePtr) {

  // ADD CODE HERE FOR PART B

} // end read2DArray




/*******************************************************************
 * Function generateRandom2DArray is passed the # rows, the # columns,
 * min. value, max. value, and returns random2DArray containing 
 * randomly generated doubles.
 ********************************************************************/
void generateRandom2DArray(int rows, int columns, 
			   double min, double max, double ** random2DArray) {
  int r, c;
  double range, div;

  // seed the random number generator
  srand( time(NULL) );
  for (r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      range = max - min;
      div = RAND_MAX / range;
      random2DArray[r][c] = min + (rand() / div);
    } // end for (c...
  } // end for (r...
} // end generateRandom2DArray


/*******************************************************************
 * Function print2DArray is passed the # rows, # columns, and the
 * array2D.  It prints the 2D array to the screen.
 ********************************************************************/
void print2DArray(int rows, int columns, double ** array2D) {
  int r, c;
  for(r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      printf("%8.5lf", array2D[r][c]);
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

  // ADD CODE HERE FOR PART B --> HINT: USE THE fabs FUNCTION TO WHEN
  // COMPARING CORRESPONDING ELEMENTS

} // end equal2DArray





