#include<stdio.h>
#include"myfile.h"
//Support for single and multi-line macros
 #define getc(p) (--(p)->cnt >= 0 \
           ? (unsigned char) \
             *(p)->ptr++ : _fillbuf(p))
#define BANDERA 3
void foo(int**, float (*)[], unsigned long int);
void boo(int**, float (*)[], unsigned long float);
int main(void)
{
	int a=3,b=5;//Support for variable initialization
	char d[BANDERA];
	char **j2;
	double po;

	//Support for  bizarre variable declarations

	volatile unsigned double *vud,vud2,vud3,vud4; 
	const signed short int (**point)[10], **some_var;

	vud = (volatile unsigned double *)malloc(BANDERA*3);
	boo(arg,arg,arg)
	printf("Ingresa 2 numeros tipo int: "); //int keyword is ignored
	boo(arg,arg,arg)
	scanf("%d %d",&a,&b);
	printf("La suma es: %d \n",suma(a,b)); //This function call won't be ignored

	//Everything that is a comment will be ignored
	/*	long long int THIS,WONT,SHOW,UP;
		float ,TAMPOCO;
	*/

	foo(arg,arg2,arg3);
	while (true)
	{
		for ( ; ; ) //empty for supported
			b = 2
		a=1;
	}
	return 0;
}
int suma(int i,int j)
{
	too(arg,arg,arg);

	return i+j;
}
void foo(int** a, float (*some)[BANDERA], unsigned long int omg)
{
	suma(ad,as);
	boo(args);
	return NULL;
}

void boo(int** b, float (*bome)[], signed short float d){
	char x,y;
	return NULL;
}
//long function declarations won't mess up the final report
long long int too(long long int a, long long int b, long long int b, long long int d, long long int f, long long int g){
	return 0
}
long double roo(unsigned long int fd, signed short int b, unsigned short double b, long int d, char int f, int (*g)[][][], float **d){
	return 0
}
