#include"bandelet.h"

/*map gridp to grid_sort, get the index of sorting wavelet coefficient*/
void mapping(float *vec,float *result,int *map,int length){
	int i,j;
	float element;
	for(i=0;i<length;i++){
		element = vec[i];
		for(j=0;j<length;j++){
			if(result[j] == element){	
				/*there is a problem when two result element is equal,two map element 
				 * will equal, so we need to set the result[j] to a big number as a sign*/
				map[i] = j;
				result[j] = 100000.0F;
				break;
			}
		}
	}
}
