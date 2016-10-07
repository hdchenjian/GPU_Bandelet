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

void compute_quadtree(float *region,int width,int step,float threshold,int j_min,\
			int j_max,int s,int *quadtree_seg,float *theta, int length, int *map_index, float *thetap){
	int i,j,m,n;
	int min_side = power2(j_min);		//the length of size of the min square
	int nbr_min_side = width / (min_side);//the number of min square ia a direction


	float min_lag,best_theta;
	float *sub_region;
	float *sub_theta;

	
	/*for every min square,compute the best theta and min lagrangian*/
	for(i=0;i<nbr_min_side;i++){
		for(j=0;j<nbr_min_side;j++){
			/*we do not transfor the first square, because it is the
			 * most coarse scale, be careful*/
			if(0 == i && 0 == j)	
				continue;				
			sub_region = region + (i*step + j)*min_side;
			compute_best_direction(sub_region,threshold,step,min_side,s,\
										&min_lag,&best_theta,map_index,thetap, length);			
			/*the theta of minimum region is same*/
			sub_theta = theta + (i*step + j)*min_side;
			for(m=0;m<min_side;m++)
				for(n=0;n<min_side;n++)
					*(sub_theta + m*step + n) = best_theta;
		}
	}	
}
