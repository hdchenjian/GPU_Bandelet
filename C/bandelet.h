#include<stdio.h>
#include<math.h>
#include<stdlib.h>
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
#include <sys/time.h>

//#define ROWS 512
//#define COLS 512
#define HEIGHT 1024
#define JMIN 4
#define SQRT2 1.414214F
#define NO_GEO (0.0F)	//we use 0.0F stand for no geometry that do not need transform
#define PI 3.141593F
// conversion multiplier nbr_coefs<->nbr_bits
#define GAMMA 7
// lagrange multiplier
#define LAMBDA (3.0F / (4 * GAMMA))
//#define SCALE 6		//the scale of haar transform, default set 6

extern void haar_1d(float *vec,float *result,int n);
void warp_wavelet(float *region,float *result,int width,int step,float theta,int *mapping,int index);
//used by perform_bandelet_transform.c
void warp_wavelet_transform(float *region,float *result,int width,int step,float theta);
extern void perform_bandelet_transform(float *region,int width,int step,int *quadtree_seg, \
					float *theta,int *nbr_bits_code, int length, int *map_index, float *thetap);
extern void compute_best_direction(float *region,float threshold,int step,int width,\
						float s,float *min_lag,float *best_theta, int *map_index, float *thetap, int length);
extern void compute_quadtree(float *region,int width,int step,float threshold,int j_min,\
			int j_max,int s,int *quadtree_seg,float *theta, int length, int *map_index, float *thetap);
extern int power2(int power);
//extern void draw_quadtree(IplImage *image, int *quadtree, float *theta, int width, int j_min, int step);
extern void perform_quantization(float *seq, float *seq_quantization, float threshold, int width);
extern void haar_2d(float *image,int rows,int cols,int J,int step);
extern void sort(float *vec,float *result,int width);
extern void mapping(float *vec,float *result,int *map,int width);
