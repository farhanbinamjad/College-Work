/* Program to demonstrate functions and parameter passing
   compile with math library: gcc -o rectangle displayRectangleInfo.c
   Run by: ./rectangle
*/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

void getDimensions();
void calculateAreaAndCircumference(double, double, double*, double*);
void displayRectangleInformation(double, double, double, double);

int main()
{
  double length, width, area, circumference;

  getDimensions(&length, &width);
  calculateAreaAndCircumference(length, width, &area, &circumference);
  displayRectangleInformation(length, width, area, circumference);
}

void getDimensions(double * length, double * width)
{
  
  printf("Enter the length of a rectangle: " );
  scanf("%f", length);
  
  printf("Enter the width of a rectangle:  ");
  scanf("%f", width);

}

void calculateAreaAndCircumference(double length, double width, double * area, double * circumference)
{
  *area = length * width;
  *circumference= 2.0 * (length + width);
}

void displayRectangleInformation(double length, double width, double area, double circumference)
{
  printf("A rectangle with a length of %3.2f and a width of %3.2f has an area of %3.2f and circumference of %3.2f.\n", length, width, area, circumference);
 
}