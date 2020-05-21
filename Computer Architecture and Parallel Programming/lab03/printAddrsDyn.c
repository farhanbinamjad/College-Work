#include <stdio.h>
#include <stdlib.h>

// function prototypes
void  allocate2DArray(int rows, int columns, int *** multiplicationTable);
void calculateProducts(int rows, int columns, int ** multiplicationTable);
void printTableHeading(int value1, int value2);
void printRow(int row, int maxColumn, int * rowProducts);

int main(int argc, char ** argv) {
  int ** multiplicationTable;
  int value1, value2, row, column;

  sscanf(argv[1], "%d", &value1);
  sscanf(argv[2], "%d", &value2);

  allocate2DArray(value1, value2, &multiplicationTable);

  calculateProducts(value1, value2, multiplicationTable);

  printTableHeading(value1,  value2);

  for (row = 1; row <= value1; row++) {
    printRow(row, value2, multiplicationTable[row-1]);
  } // end for (row...

  printf("\n\nmultiplicationTable value: %p\n\n", (void *) multiplicationTable);
  for (row = 1; row <= value1; row++) {
    printf("multiplicationTable[%d] pointers to: %p\n", row-1,
	   (void *) multiplicationTable[row-1]);
    printf("addr. of multiplicationTable[%d] pointers to: %p\n", row-1,
	   (void *) &(multiplicationTable[row-1]));
  } // end for (row...

} // end main



void allocate2DArray(int rows, int columns, int *** multiplicationTable) {
  int ** local2DArray;
  int r;

  local2DArray = (int **) malloc(sizeof(int *)*rows);

  for (r=0; r < rows; r++) {
    local2DArray[r] = (int *) malloc(sizeof(int)*columns);
  } // end for
	  *multiplicationTable = local2DArray ;
} // end allocate2DArray




void calculateProducts(int rows, int columns, int ** multiplicationTable) {
  int r, c;

  for (r = 0; r < rows; r++) {
    for (c = 0; c < columns; c++) {
      multiplicationTable[r][c] = (r+1) * (c+1);
    } // end for (c...
  } // end for (r...
} // end calculateProducts



void printTableHeading(int value1, int value2) {
  int column;

  printf("\nThe multiplication table from 1 x 1 up to %d x %d\n\n",value1, value2);

  printf("  X  |");
  for (column = 1; column <= value2; column++) {
    printf("%5d", column);
  } // end for (column...
  printf("\n");

  printf("-----|");
  for (column = 1; column <= value2; column++) {
    printf("-----");
  } // end for (column...
  printf("\n");

} // end printTableHeading


void printRow(int row, int maxColumn, int * rowProducts) {
  int column;
  
  printf("%-5d|", row);
  for (column = 0; column < maxColumn; column++) {
    printf("%5d", *(rowProducts+column));
  } // end for (column...
  printf("\n");
 /* printf("addrs: ");
  for (column = 0; column < maxColumn; column++) {
    printf("%p ", (void *) &(rowProducts[column]));
  } // end for (column...
  printf("\n\n");*/
} // end printRow8
