#include"bandelet.h"

/*sort the result of grid mapping*/
void sort(float *vec,float *result,int length){
	int i,j;
	float temp;
	for(i=0;i<length;i++){
		result[i] = vec[i];
	}
	for(i=0;i<length;i++)
		for(j=i+1;j<length;j++){
			if(result[i]>result[j]){
				temp = result[i];
				result[i] = result[j];
				result[j] = temp;
			}
		}
}
