#include"bandelet.h"

/*compute the best direction of a image square, the maximum thread of a block is 512,
 * so the width < 5, for compute capability >= 2.0 devices, the maximum thread of a 
 * block is 1024, so width < 6, and a thread need to process more than one data
 * the best_theta is the best direction,
 * the min_lag is the minimum Lagrangian, the x coordinate of a thread block is horizontal
 * the width is the length of min_side. nbr_coefficient, total_error, min_lag, and
 * best_theta parameters passed by share memory, so we can store some
 * variable in share memory, and that can save some register, initial parameters :
 * nbr_coefficient = 0, total_error = 0.0F, min_lag = 1000000.0F(a big float number)
 * best_theta = NO_GEO
 * The method for passing kernel parameters varies with architecture. Compute capability
 * 1.* devices put the values in shared memory. Compute capability >= 2.0 put the values
 * in constant memory, the share memory is min_side * min_side * 4 * 4 + 16, be careful*/

/*shared memory map cache[0]: grid_sort; cache[width *width] : grid; cache[width *width * 2] :
  region_data; cache[width *width * 3] : coefficient_save */
/*this function combine the findind direction and perform bandelet transform*/

__global__ void compute_best_direction(float threshold,int step,int width, float *thetap_dev, \
		float *image_dev, float *theta_dev, int length, int *map_index_dev){
	/*use for warp wavelet translation */
	extern __shared__ float cache[];
	
	int j, k;
	//float theta_value;
	//int region_element_num = width * width;
	float temp;
	//float *warp_wavelet_coeff;
	
	//float *region = image_dev + blockIdx.y * width * step + blockIdx.x * width;
	//float *region_data = cache;		//we can save this share mem by using a register variable
	float *gridp = cache + blockDim.x;
	//int *index_of_map = (int *)(cache  + 4 * blockDim.x + 0);
	//float *gridp_sort = cache + 2 * blockDim.x;
	//int *coefficient_save = (int *)(cache + 3 * blockDim.x);
	//int *nbr_coefficient = (int *)(cache  + 4 * blockDim.x);
	//float *total_error = (float *)((cache  + 4 * blockDim.x) + 1);
	//float *min_lag = total_error + 1;
	//float *best_theta = min_lag + 1;
	//int *mapping;

	//we do not transform the most coarse scale wavelet coefficient
	if(0 == blockIdx.x && 0 == blockIdx.y)
		return;

	if(0 == threadIdx.x){
		//*nbr_coefficient = 0;
		//*total_error = 0.0F;
		//*min_lag = 1000000.0F;

		//*((cache  + 4 * blockDim.x) + 0) = 0.5F;	//the index of thetap that save best_theta
		//*((cache  + 4 * blockDim.x) + 1)	//the number of coefficient that above threshold
		*((cache  + 4 * blockDim.x) + 2) = 1000000.0F; //error + LAMBDA * T * threshold * threshold
		*((cache  + 4 * blockDim.x) + 3) = NO_GEO;		//best_theta
		//theta_value = *((cache  + 4 * blockDim.x) + 4)	//the theta_value of current loop
	}

	/*load the region data to share memory */
	(cache + 2 * blockDim.x)[threadIdx.x] = (image_dev + blockIdx.y * width * step + blockIdx.x * width)[threadIdx.x / width * step + threadIdx.x % width];
	__syncthreads();		/*synchronize the threads, to get correct data*/

/*perform warp wavelet transform */
for(k = 0; k < length; k++){
	//mapping = map_index_dev + k * blockDim.x;
	if(0 == threadIdx.x){
		*((cache  + 4 * blockDim.x) + 4) = thetap_dev[k];	//get the theta_value of current loop
	}
	__syncthreads(); 

	if(*((cache  + 4 * blockDim.x) + 4) != NO_GEO){

		/*mapping region data to a sequence based on map_index, use gridp store mapping data*/
		//for every colums, using colums order
		//gridp[map[threadIdx.x]] = region_data[threadIdx.x / width + (threadIdx.x % width)*width];
		//have a bug, changed
		//gridp[threadIdx.x] = region_data[map[threadIdx.x] % width*step + map[threadIdx.x] / width];
		j = (map_index_dev + k * blockDim.x)[threadIdx.x];
		gridp[threadIdx.x] = (cache + 2 * blockDim.x)[j % width * width + j / width];

		__syncthreads();		/*synchronize the threads, to get correct data*/
		/*perform haar 1D transform, gridp is input data, use gridp_sort store result*/
		j = blockDim.x / 2;		/*the width of next scale coarse coefficient*/
		while(j > 1){
			if(threadIdx.x < j){
				cache[threadIdx.x] = 
					(gridp[2 * threadIdx.x] + gridp[2 * threadIdx.x + 1 ]) / SQRT2;
				cache[threadIdx.x + j] = 
					(gridp[2 * threadIdx.x] - gridp[2 * threadIdx.x + 1 ]) / SQRT2;
			}
			if(threadIdx.x < j)		/*prepare data for next scale wavelet transform*/
				gridp[threadIdx.x] = cache[threadIdx.x];
			j /= 2;
			__syncthreads();		/*synchronize the threads, to get correct data*/
		}

		//warp_wavelet_coeff = cache;
		/*perform_quantization, the input data store at gridp_sort or region_data,
		 * the output data store at gridp
		 * The quantizer is defined by y=Q_T(x) where:
		 *Q_T(x) = 0    if  |x|<T
		 *Q_T(x) = sign(x) * ([|x| / T]+0.5)*T      where [.]=floor
		 *(i.e. a nearly uniform quantizer with twice larger zero bin)*/
		temp = cache[threadIdx.x];
		if(fabsf(temp) < threshold){
			gridp[threadIdx.x] = 0.0F;
			cache[threadIdx.x] = 0.0F;
		}
		else{ 
			gridp[threadIdx.x] = ((temp < 0.0F)? (-1.0F) : (1.0F)) * 
				(floorf( fabsf(temp) / threshold ) + 0.5F) * threshold;
			cache[threadIdx.x] = 1.0F;
		}
		__syncthreads();		/*synchronize the threads, to get correct data*/

		/*compute the number of coefficient above threshold and the approximation error*/
		j = blockDim.x / 2;
		while (j != 0) {  /*reduce algorithem compute the number of coefficient above threshold*/
			if(threadIdx.x < j)
				cache[threadIdx.x] += cache[threadIdx.x + j];
			j /= 2;
			__syncthreads();
		}

		/*as we have got the value that store at gridp[threadIdx.x], so we can use gridp
		 * store the error that we cover the gridp content, be careful*/
		temp -= gridp[threadIdx.x];
		gridp[threadIdx.x] = temp * temp;		// error = temp * temp;
		__syncthreads();        /*synchronize the threads, to get correct data*/
		j = blockDim.x / 2;	//store at share memory pass by parameter
		while (j != 0) {  /*reduce algorithem compute the total error*/
			if(threadIdx.x < j)
				gridp[threadIdx.x] += gridp[threadIdx.x + j];
			j /= 2;
			__syncthreads();
		}
	}
	else{	//for no geometry stream, just copy region to region_data
		//warp_wavelet_coeff = (cache + 2 * blockDim.x);

		/*perform_quantization, the input data store at gridp_sort or region_data,
		 * the output data store at gridp
		 * The quantizer is defined by y=Q_T(x) where:
		 *Q_T(x) = 0    if  |x|<T
		 *Q_T(x) = sign(x) * ([|x| / T]+0.5)*T      where [.]=floor
		 *(i.e. a nearly uniform quantizer with twice larger zero bin)*/
		temp = (cache + 2 * blockDim.x)[threadIdx.x];
		if(fabsf(temp) < threshold){
			gridp[threadIdx.x] = 0.0F;
			cache[threadIdx.x] = 0.0F;
		}
		else{ 
			gridp[threadIdx.x] = ((temp < 0.0F)? (-1.0F) : (1.0F)) * 
				(floorf( fabsf(temp) / threshold ) + 0.5F) * threshold;
			cache[threadIdx.x] = 1.0F;
		}
		__syncthreads();		/*synchronize the threads, to get correct data*/

		/*compute the number of coefficient above threshold and the approximation error*/
		j = blockDim.x / 2;
		while (j != 0) {  /*reduce algorithem compute the number of coefficient above threshold*/
			if(threadIdx.x < j)
				cache[threadIdx.x] += cache[threadIdx.x + j];
			j /= 2;
			__syncthreads();
		}

		/*as we have got the value that store at gridp[threadIdx.x], so we can use gridp
		 * store the error that we cover the gridp content, be careful*/
		//temp = gridp[threadIdx.x] - (cache + 2 * blockDim.x)[threadIdx.x];
		temp -= gridp[threadIdx.x];
		gridp[threadIdx.x] = temp * temp;		// error = temp * temp;
		__syncthreads();        /*synchronize the threads, to get correct data*/
		j = blockDim.x / 2;	//store at share memory pass by parameter
		while (j != 0) {  /*reduce algorithem compute the total error*/
			if(threadIdx.x < j)
				gridp[threadIdx.x] += gridp[threadIdx.x + j];
			j /= 2;
			__syncthreads();
		}
	}


	/* use the first thread compute the min_lag and best_theta*/
	if(0 == threadIdx.x){
		/*do not forget the nbr_coefficient and total_error*/
		*(cache  + 4 * blockDim.x + 1) = cache[0];	//nbr_coefficient above threshold	
		if(*((cache  + 4 * blockDim.x) + 4) != NO_GEO){ 
		//*total_error = gridp[0],	temp save the Lagrangian = ERROR + LAMBDA * (Rg + Rb) * T^2
			temp = gridp[0] + LAMBDA * (*(cache  + 4 * blockDim.x + 1) * GAMMA + 1 + \
					ceilf(log2f(length))) * threshold * threshold;
		}
		else{
			temp = gridp[0] + \
				   LAMBDA * (*(cache  + 4 * blockDim.x + 1) * GAMMA + 1) * threshold * threshold;
		}
		if(*((cache  + 4 * blockDim.x) + 2) > temp){
			*((cache  + 4 * blockDim.x) + 2) = temp;
			*((cache  + 4 * blockDim.x) + 3) = *((cache  + 4 * blockDim.x) + 4);
			//save the index of thetap to get the map_index used by perform_bandelet_transform
			*(((int *)cache)  + 4 * blockDim.x ) = k;
		}
	}
}

	__syncthreads();
	*( theta_dev + (blockIdx.y * width * step + blockIdx.x *width) + //start address
		( threadIdx.x / width * step + threadIdx.x % width ) ) =	//offset address 
								*((cache  + 4 * blockDim.x) + 3);
								
	/*perform_bandelet_transform*/
	temp = *((cache  + 4 * blockDim.x) + 3);	//the best theta of this region
	if(temp == NO_GEO)
		return ;

	j = *(((int *)cache)  + 4 * blockDim.x ); //save the index of thetap to get the map_index
	k = (map_index_dev + j * blockDim.x)[threadIdx.x];	//k save the map_index of current thread
	
	//map region data to a sequence based on map_index
	gridp[threadIdx.x] = *((cache + 2 * blockDim.x) + k % width * width + k / width);
	__syncthreads();		/*synchronize the threads, to get correct data*/

	/*perform haar 1D transform, gridp is input data, use gridp_sort store result*/
	j = blockDim.x;		/*the width of next scale coarse coefficient*/
	while(j > 1){
		j /= 2;
		if(threadIdx.x < j){
			cache[threadIdx.x] = 
				(gridp[2 * threadIdx.x] + gridp[2 * threadIdx.x + 1 ]) / SQRT2;
			cache[threadIdx.x + j] = 
				(gridp[2 * threadIdx.x] - gridp[2 * threadIdx.x + 1 ]) / SQRT2;
		}
		if(threadIdx.x < j)		/*prepare data for next scale wavelet transform*/
			gridp[threadIdx.x] = cache[threadIdx.x];
		__syncthreads();		/*synchronize the threads, to get correct data*/
	}

	/* map haar coefficient based map index*/
	*(image_dev + blockIdx.y * width * step + blockIdx.x * width		//start address
			 + (k % width) * step + k / width) = cache[threadIdx.x];
}
