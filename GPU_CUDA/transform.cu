/*perform bandeletization for a small square, width is the width of current scale 
  *square, this have a difference using of share memory, cache's last
  *4byte(cache[region_element_num * 4]) is used for distingushing
  *whether have same element in gridp_sort, be careful*/

#include"bandelet.h"

__global__ void transform(int step, int width, float *image_dev, float *theta_dev, int *quadtree_seg_dev, int scale, int length, float *thetap_dev, int *map_index_dev){

	extern __shared__ float cache[];

	int j, k;
	float theta_value;
	int region_element_num = width * width;
	float *region = image_dev + blockIdx.y * width * step + blockIdx.x * width;
	float *region_data = cache;		//we can save this share mem by using a register variable
	float *gridp = region_data + region_element_num;
	float *gridp_sort = region_data + 2 * region_element_num;
	int *map = (int *)(region_data + 3 * region_element_num);

	if(0 == threadIdx.x){		//note:can not use temp, because only thread 1 's temp is change
		cache[1] = 0.0F;		//a sign bit that mean whether perform bandeletization
		map[0] = 0;				//a sign bit that mean whether have same element in gridp_sort
		cache[0] = theta_dev[blockIdx.y * width * step + blockIdx.x * width];
		if(cache[0] != NO_GEO){
			cache[1] = 1.0F;
		}
	}
	__syncthreads();		/*synchronize the threads, to get correct data*/

	if(1.0F == cache[1]){		//need to perform bandeletization
		theta_value = cache[0];
	}
	else						//square scale < current scale or theta_value == NO_GEO
		return ;

	/*load the region data to share memory */
	region_data[threadIdx.x] = region[threadIdx.x / width * step + threadIdx.x % width];
	__syncthreads();		/*synchronize the threads, to get correct data*/
	
	for(j = 0; j < length; j++){
			if(theta_value == thetap_dev[j]){
				break;
			}
		}
		
	k = (map_index_dev + j * blockDim.x)[threadIdx.x];
	//map[threadIdx.x] = (map_index_dev + j * blockDim.x)[threadIdx.x];

	/*mapping region data to a sequence based on map_index, use gridp store mapping data*/
	//for every colums, using colums order
	//have a bug, changed
	gridp[threadIdx.x] = region_data[k % width * width + k / width];
	__syncthreads();		/*synchronize the threads, to get correct data*/

	/*perform haar 1D transform, gridp is input data, use gridp_sort store result*/
	j = region_element_num;		/*the width of next scale coarse coefficient*/
	while(j > 1){
		j /= 2;
		if(threadIdx.x < j){
			gridp_sort[threadIdx.x] = 
				(gridp[2 * threadIdx.x] + gridp[2 * threadIdx.x + 1 ]) / SQRT2;
			gridp_sort[threadIdx.x + j] = 
				(gridp[2 * threadIdx.x] - gridp[2 * threadIdx.x + 1 ]) / SQRT2;
		}
		__syncthreads();		/*synchronize the threads, to get correct data*/
		if(threadIdx.x < j)		/*prepare data for next scale wavelet transform*/
			gridp[threadIdx.x] = gridp_sort[threadIdx.x];
		__syncthreads();		/*synchronize the threads, to get correct data*/
	}

	/* map haar coefficient based map index*/
	*(region + (k % width) * step + k / width) =
													gridp_sort[threadIdx.x];
}
