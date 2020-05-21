
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// function prototypes

void getDimensions(double* length, double *width);
double calculateArea( double length, double width);
void calculateCircumference(double, double, double*);
void DisplayRectInformation(double, double, double, double);

int main () {
  
  double length, width, area, circumference;

  getDimensions(&length, &width);

  area =  calculateArea(length, width);

  calculateCircumference(length, width, &circumference);

  DisplayRectInformation(length, width, area, circumference);

}
//end main

void getDimensions( double * length, double * width) {  

  printf("Enter the length of a rectangle: ");
  scanf("%lf", length);

  printf("Enter the width of a rectangle: ");
  scanf("%lf", width);

  
} //end dimensions

double calculateArea( double length, double width){
  double area;

  area = length * width;
  return area;

    } //end calulateAreaandCircumference

void calculateCircumference(double length, double width, double *circumference) {
  *circumference = 2.0 * (length + width);
}
//end
void DisplayRectInformation( double length, double width, double area, double circumference) {
  
  printf("A rectangle with a length of %3.2f and a width of %3.2f has an area of %3.2f\n",
	 length, width, area);
  printf("and a circumference of %3.2.\n", circumference);

} //end DisplayRectInformation
