#include<stdio.h>
//Suport for single and multi-line macros
 #define getc(p) (--(p)->cnt >= 0 \
           ? (unsigned char) \
             *(p)->ptr++ : _fillbuf(p))
#define BANDERA 3
void foo(int**, float (*)[], unsigned long int);
void boo(int**, float (*)[], unsigned long float);
int main(void){
	int a,b;
	float p2[3];
	float h2[3];
	char **j2;
	volatile unsigned double *vud,vud2,vud3,vud4; 
	//Support for  bizarre variable declarations
	const signed short int (**point)[10], **some_var;
	vud = (volatile unsigned double *)malloc(BANDERA*3);
	boo(arg,arg,arg)
	printf("Ingresa 2 numeros tipo int: "); //int keyword is ignored
	boo(arg,arg,arg)
	scanf("%d %d",&a,&b);
	printf("La suma es: %d \n",suma(a,b)); //This function call won't be ignored
	/*	int NO,DEBE,SALIR
		float ESTE,TAMPOCO
	*/
	foo(arg,arg2,arg3);
	while (true){
		for ( ; ; ) //empty for supported
			b = 2
		a=1;
	}
	return 0;
}
int suma(int i,int j){
	too(arg,arg,arg);

	return i+j;
}
void foo(int** a, float (*some)[BANDERA], unsigned long int omg)
{
	suma(ad,as);
	return NULL;
}

void boo(int** b, float (*bome)[], unsigned long float d){
	return NULL;
}
//long function declarations won't mess up the final report
long long int too(long long int a, long long int b, long long int b, long long int d, long long int f, long long int g){
	return 0
}
long double roo(unsigned long int dfdsdfsdfsda, signed short int b, long long int b, long long int d, long long int f, long long int g, float **d){
	return 0
}
