/* compute the quadtree that optimize the Lagrangian
 * j_min is the depth minimum of the QT,
		 * (ie 2^j_min is the size minimum of the square).
 * j_max is the depth maximum of the QT        [default : min(5,log2(n))]
 * (ie 2^j_max is the size maximum of the square).
 * s is the super-resolution for the geometry [default 2]
 * quadtree_seg and theta is the output
 * quadtree_seg is an image representing the levels of the quadtree.
 * theta is an image representing the optimal angle choosed on each
 */

#include"bandelet.h"

void compute_quadtree(float *image_dev, int width, int step, float threshold, int j_min,\
		int j_max, int s, int *quadtree_seg_dev, float *theta_dev, float *time_quadtree, float *thetap_dev, int *map_index_dev){

	int min_side = power2(j_min);		//the length of size of the min square
	/*sample (2 * power(j_min) * s) theta value, so a thread block have (2 * power(j_min) * s)
	 * threads, and we can not sample more than power(j_min)^2 direction, because when
	 * j_min=5, length=1024 > 512, and length should be multiplier of 32*/
	int length = 2 * power2(j_min) * s + 1;	/*the number of theta value*/	
					
	dim3 grid_num(width / min_side, width / min_side, 1);
	dim3 block(min_side * min_side, 1, 1);

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	/* a threads block compute a square region which size is (2^j_min),and we use
	 * a for loop * compute all direction, one loop compute a direction, the 
	 * number of thread of a tread block is the number of pixel of a square region*/
	compute_best_direction<<<grid_num, block, min_side * min_side * 4 * 4 + 24>>>(threshold, step, min_side,thetap_dev, image_dev, theta_dev, length, map_index_dev);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(time_quadtree, start, stop);
	printf("compute_quadtree consume time is %f ms\n", *time_quadtree);

}
