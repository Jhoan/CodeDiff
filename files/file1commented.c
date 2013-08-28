#include<stdio.h>
#define BANDERA 3
#include<stdlib.h>
int main(void){//void specification is mandatory
	int a,b;//Support for  multiple variable declarations
	float p[3];
	float h[BANDERA];
	char **j;
	j = (char **) malloc(BANDERA); //It supports casting
	printf("Ingresa 2 numeros: ");
	scanf("%d %d",&a,&b);
	printf("La suma es: %d \n",suma(a,b));
	for (b = 0; b<10;b++)
		a==BANDERA;
	switch (a)
		case "1":
			if cond == true  //nested conditionals supported
				printf("Algo");
		  	else if
				printf("Otra");
	return 0;
}
int suma(int i,int j){//implicit function declarations allowed
	return i+j;
}
int resta(int i,int j){
	return i-j;
}
