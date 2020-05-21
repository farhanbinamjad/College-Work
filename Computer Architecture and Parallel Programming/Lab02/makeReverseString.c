#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char * argv[]){
  char * string;
  int a;
  a = argc - 1;
  string=(char*)malloc(sizeof(char)*a);
  for (a; a > 0; a = a - 1){
    // string=(char*)malloc(sizeof(char)*(strlen(argv[a])+1));
    strcpy(string,argv[a]);
    printf("%s ",string);
  }
  free(string);
  return 0;
}
