/** The 1D Haar Transform **/
/* the input should be 1D, only forward transform, n should be even number*/
/*detail coefficient and coarse coefficient is storage aparted*/

#include "bandelet.h"

void haar_1d(float *vec,float *result,int n)
{
	int i = 0;
	int width = n;
	float *vecp;
	/*use vecp to storage temporary result,do not forget copy to vecp*/
	vecp = (float *)malloc(width * sizeof(float));
	for(i=0;i<width;i++)
		vecp[i] = vec[i];

	while(width > 1) {
		width /= 2;
		for(i=0;i<width;i++) {
			result[i] = (vecp[2*i] + vecp[2*i+1]) / SQRT2;
			result[i+width] = (vecp[2*i] - vecp[2*i+1]) / SQRT2;
		}
		for(i=0;i<(width);i++)
			vecp[i] = result[i]; 
	}
	free(vecp);
}
