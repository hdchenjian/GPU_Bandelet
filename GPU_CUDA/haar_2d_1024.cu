#include"bandelet.h"

/*perform haar wavelet transform using gpu, not consider rows > 512 condition,
  for image's row > 512, we can implemetn haar transform by not using share memory,
  just using global memory, but that is slow, see another_version_haar for detail.
  a threads block computing a row of image, and a thread computing a pixel of that row
  */

__global__ void haar_2d_rows(float *image_dev, int width, int step);
__global__ void haar_2d_cols(float *image_dev, int height, int step);

void haar_2d(float *image_dev, int step, int rows, int cols, int scale, float *cost_time){
	int i;
	printf("the haar 2d transform scale is %d\n", scale);
	/*prepare data for gpu computing, do not consider rows > 512 condition*/
	int block_num, thread_num;
	int width = cols;
	int height = rows;
	block_num = rows;		/*every block compute a row or colum*/
	/*every thread load a pixel of a row, only half of thread is used to compute*/
	thread_num = cols;		
	if(1024 == cols)
		thread_num = 512;


	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);
	for(i = scale; i > 0; i--){
		//printf("performing haar transform scale is	%d\n", scale + 1 - i);
		haar_2d_rows<<<block_num, thread_num, thread_num * 4>>>(image_dev,width,step);
		haar_2d_cols<<<block_num, thread_num, thread_num * 4>>>(image_dev,height,step);
		block_num /= 2;
		thread_num /= 2;
		width /= 2;
		height /= 2;
	}
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	/*计算两次事件之间相差的时间（以毫秒为单位，精度为0.5微秒)*/
	cudaEventElapsedTime(cost_time,start,stop);
	printf("the cost_time of haar 2d transform is %f\n", *cost_time);

	//cudaFreeHost(image);
	//cudaFree(image_dev);
}

/*width define the region need to compute,they are change*/
/*perform the row haar transform*/
__global__ void haar_2d_rows(float *image_dev, int width, int step){
	extern __shared__ float cache[];

	int i;
	//int size = width / 2;		/*the width of next scale coarse coefficient*/
	float cache_low, cache_high;
	float coarse_coeff, detail_coeff;	/*the temporal coarse and detail coefficient*/

	for(i = 0; threadIdx.x + i * blockDim.x < width; i++){
		cache[threadIdx.x + i * blockDim.x] = image_dev[blockIdx.x * step + threadIdx.x + i * blockDim.x];
	}
	__syncthreads();		/*synchronize the threads, to get correct data*/
	
	/*we can save cache[2 * threadIdx.x] in register variable*/
	i = width / 2;
	if(threadIdx.x < i){
		cache_low = cache[2 * threadIdx.x];
		cache_high = cache[2 * threadIdx.x + 1];
		coarse_coeff = (cache_low + cache_high ) / SQRT2;
		detail_coeff = (cache_low - cache_high  ) / SQRT2;
		image_dev[blockIdx.x * step + threadIdx.x] = coarse_coeff;
		image_dev[blockIdx.x * step + threadIdx.x + i] = detail_coeff;
	}
}

/*height define the region need to compute,they are change*/
/*perform the colum haar transform*/
__global__ void haar_2d_cols(float *image_dev, int height, int step){
	extern __shared__ float cache[];

	int i;
	//int size = height / 2;		/*the width of next scale coarse coefficient*/
	float cache_low, cache_high;
	float coarse_coeff, detail_coeff;	/*the temporal coarse and detail coefficient*/

	for(i = 0; threadIdx.x + i * blockDim.x < height; i++){
		cache[threadIdx.x + i * blockDim.x] = image_dev[blockIdx.x * step + threadIdx.x + i * blockDim.x];
	}

	__syncthreads();		/*synchronize the threads, to get correct data*/
	
	i = height / 2;
	/*we can save cache[2 * threadIdx.x] in register variable*/
	if(threadIdx.x < i){
		cache_low = cache[2 * threadIdx.x];
		cache_high = cache[2 * threadIdx.x + 1];
		coarse_coeff = (cache_low + cache_high ) / SQRT2;
		detail_coeff = (cache_low - cache_high  ) / SQRT2;
		image_dev[blockIdx.x + threadIdx.x * step] = coarse_coeff;
		image_dev[blockIdx.x + threadIdx.x * step + i * step] = detail_coeff;
	}
}
