#include<stdio.h>
int suma(int,int);
int main(){
	int a,b;
	printf("Ingresa 2 numeros: ");
	scanf("%d %d",&a,&b);
	printf("La suma es: %d \n",suma(a,b));
	return 0;
}
int suma(int i,int j){
	return i+j;
}
