#include<stdio.h>
#include<math.h>
#include<stdlib.h>
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
#include<cuda_runtime.h>

#define HEIGHT 1024
#define JMIN 4		//the smallest size of square(width = w^2) of wavelet transform
//#define SQUARE_WIDTH 8
#define SQRT2 1.414214F
#define NO_GEO 0.0F	//we use 0.0F stand for no geometry that do not need transform
#define PI 3.141593F
// conversion multiplier nbr_coefs<->nbr_bits
#define GAMMA 7
// lagrange multiplier
#define LAMBDA (3.0F / (4 * GAMMA))
//#define SCALE 6		//the scale of haar transform, default set 6
void compute_quadtree(float *image_dev, int width, int step, float threshold, int j_min, int j_max, int s, \
	 int *quadtree_seg_dev, float *theta_dev, float *time_quadtree, float *thetap_dev, int *map_index_dev);
__global__ void compute_best_direction(float threshold,int step,int width, float *thetap_dev, \
		float *image_dev, float *theta_dev, int num_theta, int *map_index_dev);
__global__ void merge_quadtree(float *theta_dev, float *theta_next_dev, float threshold, \
		float *lag, float *lag_next, float *lag_new, int lag_step, int min_side, int step, \
		int width, int *quadtree_seg_dev, int scale);
__global__ void transform(int step, int width, float *image_dev, float *theta_dev, int *quadtree_seg_dev, int scale, int length, float *thetap_dev, int *map_index_dev);
extern void perform_bandelet_transform(float *image, int j_min, float *image_dev, int width, int step, \
		int *quadtree_seg_dev, float *theta_dev, int *total_bits, float *time_transform, int length, float *thetap_dev, int *map_index_dev);
//extern void draw_quadtree(IplImage *image, int *quadtree, float *theta, int width, int j_min, int step);
extern void haar_2d(float *image_dev, int step, int rows, int cols, int scale, float *cost_time);
extern int power2(int power);
extern void sort(float *vec,float *result,int width);
extern void mapping(float *vec,float *result,int *map,int width);
