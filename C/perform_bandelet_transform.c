#include"bandelet.h"

void perform_bandelet_transform(float *region,int width,int step,int *quadtree_seg, \
					float *theta,int *nbr_bits_code, int length, int *map_index, float *thetap){
	int i,j,k,n;
	int j_min,j_max;
	int square_wide;
	int nbr_square;
	int nbr_bits_geo;
	int total_bits = 0;
	//int * quadtreep;
	float *result = NULL;
	float theta_value;
	float *sub_region;
	j_min = j_max = *quadtree_seg;

	for(k=j_max;k>j_min-1;k--){
		square_wide = power2(k);
		nbr_square = width / square_wide;
		for(i=0;i<nbr_square;i++)
			for(j=0;j<nbr_square;j++){
				/*we do not transfor the first square, because it is the
				 * most coarse scale, be careful*/
				if(0 == i && 0 == j)	
					continue;
				/*this is a leaf, transform it*/
				if(quadtree_seg[i*square_wide*step + j*square_wide] ==k){
					sub_region = region + i*square_wide*step + j*square_wide;
					theta_value = theta[i*square_wide*step + j*square_wide];
					for(n = 0; n < length; n++){
						if(theta_value == thetap[n])
							break;
					}
					
					warp_wavelet(sub_region,result, square_wide, step, theta_value,map_index, n);
					if(theta_value > NO_GEO)
						nbr_bits_geo = 2*k - 1;
					else
						nbr_bits_geo =1;		//bits to code no geometry

					total_bits = total_bits + nbr_bits_geo;
					}
				else
					total_bits = total_bits + 1;		//add split cost: 1 bit
			}
	}
	*nbr_bits_code = total_bits;
}
