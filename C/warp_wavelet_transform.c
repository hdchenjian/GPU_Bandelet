/*perform warp haar wavelet transform,the region should be square,
 * and be careful to reorder the input region, and map the warp wavelet coefficient,
 * we can get step by opencv. using step, point to next row.
 * be care with opencv step,as we use float,using step/4 point to next row.
 * when result==NULL,result storage on region,
 * otherwise,return result,it is a region sequence
 */

#include"bandelet.h"

void warp_wavelet_transform(float *region,float *result,int width,int step,float theta){

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
	float x_direct, y_direct;
	x_direct = -sinf(theta);
	y_direct = cosf(theta);
	float element;
	int map_index,row_index,col_index;
	float *grid = (float *)malloc(length * sizeof(float));
	float *grid_sort = (float *)malloc(length * sizeof(float));
	float *region_sort = (float *)malloc(length * sizeof(float));
	float *region_sort_seq = (float *)malloc(length * sizeof(float));
	int *map = (int *)malloc(length * sizeof(int));
	/*we need to keep grid,because we need free it,so we can not change it*/	
	float *gridp = grid;	
	/*projection on orthogonal direction*/
	/*this grid was created using matlab colums order, not C's row order, be careful,
	 * x coordinate is vertical, and y coordinate is horizontal, as an image coordinate*/

	for(i=1;i<width+1;i++)			//y_direct
		for(j=1;j<width+1;j++){ 	//x_direct
			*gridp = x_direct * j + y_direct * i;
			gridp++;
		}
	gridp = grid;
	sort(gridp,grid_sort,length);	/*sort points in increasing order*/
	/*map gridp to grid_sort, get the index of sorting wavelet coefficient*/
	mapping(grid_sort,gridp,map,length);		//have a bug, changed
	/*mapping region data to a sequence based on map_index*/
	/*
	for(i=0;i<width;i++)
		for(j=0;j<width;j++){
			element = region[i + j*step];		//for every colums, using colums order
			map_index = map[i*width + j];
			//row_index = map_index / width;
			//col_index = map_index % width;		//we need transpose region_sort
			//  *(region_sort + col_index*step + row_index) = element;
			*(region_sort + map_index) = element;
		}
	*/
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

	free(grid);
	free(grid_sort);
	free(region_sort);
	free(region_sort_seq);
	free(map);
}
