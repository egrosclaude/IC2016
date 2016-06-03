#include <stdio.h>
main()
{
	int *p;
	int a=2;

	p = 0;
	printf("%p\n",&a);
	printf("%p\n",p);

	*p = 3;
	printf("%d\n",a);

}
