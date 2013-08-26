#include<stdio.h>
#define BANDERA 3
#include<stdlib.h>
int main(void){
	int a,b;
	float p[3];
	float h[BANDERA];
	char **j;
	j = (char **) malloc(BANDERA);
	printf("Ingresa 2 numeros: ");
	scanf("%d %d",&a,&b);
	printf("La suma es: %d \n",suma(a,b));
	for (b = 0; b<10;b++)
		a==BANDERA;
	
	return 0;
}
int suma(int i,int j){
	return i+j;
}
int resta(int i,int j){
	return i-j;
}
