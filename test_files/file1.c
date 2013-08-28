#include<stdio.h>
#define BANDERA 5
#include<stdlib.h>
#define UNUSED 6
#define test 3
int resta(int,int);
int main(void){//void specification is mandatory
	double a,b,c;//Support for  multiple variable declarations
	float p[3];float h[BANDERA];int a;
	char **j,arr[2],dc[3];

	j = (char **) malloc(BANDERA); //Supports casting
	printf("Ingresa 2 numeros: ");
	scanf("%d %d",&a,&b);
	printf("La suma es: %d \n",suma(a,b));
	for (b = 0; b<10;b++)
		do
		{
			a==BANDERA;
		}while(0);
	switch (a)
		case "1":
			if (cond == 0)  //nested conditionals supported
				printf("Algo");
		  	else 
				printf("Otra");
	if (1)
		return 0;
	return 1;
}
int suma(int i,int j)//implicit function declarations allowed
{
	volatile char c;
	return i+j;
}
int resta(int i,int j)
{

	const signed short int (**d)[3];
	return &(i-j);
}
