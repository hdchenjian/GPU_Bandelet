/*perform warp haar wavelet transform,the region should be square,
 * and be careful to reorder the input region, and map the warp wavelet coefficient,
 * we can get step by opencv. using step, point to next row.
 * be care with opencv step,as we use float,using step/4 point to next row.
 * when result==NULL,result storage on region,
 * otherwise,return result,it is a region sequence
 * index is the row number of map_index, namely the nth theta of thetap
 */

#include"bandelet.h"

void sort(float *vec,float *result,int width);
void mapping(float *vec,float *result,int *map,int width);

void warp_wavelet(float *region,float *result,int width,int step,float theta, int *mapping, \
		int index){

	int i,j;

	if(theta > NO_GEO)	
		;
	else{		//when no geometry stream, just copy region to result
		if(result != NULL){
			for(i = 0; i < width; i++){
				for(j = 0; j < width; j++){
					*(result + i * width + j ) = *(region + i * step + j );
				}
			}
		}
		else
			;
		return;
	}
	int length = width * width;
	float element;
	int *map = mapping + index * length;
	int map_index,row_index,col_index;
	float *region_sort = (float *)malloc(length * sizeof(float));
	float *region_sort_seq = (float *)malloc(length * sizeof(float));
	
	//have a bug, changed
	for(i=0;i<width * width;i++){
		map_index = map[i];
		row_index = map_index / width;
		col_index = map_index % width;		//we need transpose region_sort
		region_sort[i] = region[col_index*step + row_index];
	}

	
	/*used by compute_best_direction.c */
	if(result != NULL) 
		haar_1d(region_sort,result,length);
	else{			
		/* used by perform_bandelet_transform.c, the result of haar_1d is saved in image, and
		 * the image data is covered*/
		haar_1d(region_sort,region_sort_seq,length);
		for(i=0;i<width;i++) 
			for(j=0;j<width;j++){
				element = region_sort_seq[i*width +j];
				map_index = map[i*width + j];
				row_index = map_index / width;
				col_index = map_index % width;
				/*for every colums, using colums order, we need transpose region_sort */
				*(region + col_index*step + row_index) = element;
			}
	}

	free(region_sort);
	free(region_sort_seq);
}
