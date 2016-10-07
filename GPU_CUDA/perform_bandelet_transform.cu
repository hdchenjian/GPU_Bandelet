/*perform bandelet transform for a region*/

#include"bandelet.h"

void perform_bandelet_transform(float *image, int j_min, float *image_dev, int width, int step, \
		int *quadtree_seg_dev, float *theta_dev, int *total_bits, float *time_transform, int length, float *thetap_dev, int *map_index_dev){

	int square_wide;
	int nbr_square;
	int *total_bits_dev;

	dim3 grid, block;
	square_wide = power2(j_min);
	nbr_square = width / square_wide;
	grid.x = nbr_square;
	grid.y = nbr_square;
	block.x = square_wide * square_wide;
	
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	//cudaMalloc((void **)&total_bits_dev, sizeof(int));
	//cudaMemset(total_bits_dev, 0, sizeof(int));
  
	transform<<<grid, block, square_wide * square_wide * 4 * 4>>>(step, square_wide, image_dev,  theta_dev, quadtree_seg_dev, j_min, length, thetap_dev, map_index_dev);

	//cudaMemcpy(total_bits, total_bits_dev, sizeof(int), cudaMemcpyDeviceToHost);
	//printf("the total_nbr_bits_code is %d\n", *total_bits);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(time_transform, start, stop);
	printf("perform_bandelet_transform consume time is %f ms\n", *time_transform);

}
