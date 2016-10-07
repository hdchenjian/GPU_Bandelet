/*compute the best direction of the region, the best_theta is the output of
 * best direction, the min_lag is the minimum Lagrangian, the function return
 * the coefficient of warp wavelet transform
 * s is a super-resolution factor,(default 2)
 */

#include"bandelet.h"

void compute_best_direction(float *region,float threshold,int step,int width,\
			float s,float *min_lag,float *best_theta, int *map_index, float *thetap, int length){
	int i,j;		
	// Number of bit for coding geometry / no geometry	// +1 for no geometry
	int nbr_bits_geom = 1;
	int nbr_bits_nogeom = 1;
	int nbr_coefficient;		//the number of coefficient above threshold
	//estimate the number of bits needed to code the coefficients
	int nbr_bits_coefficient;
	int nbr_bits_geo = ceil(log2f(length)); //number of bits for geometry
	int total_bits;		//coefficient + geo
	int min_index;
	float theta;
	float coefficient;
	float error = 0.0F;		//compute the approximation error
	float *lagrangian = (float *)malloc(length * sizeof(float));
	float *region_seq = (float *)malloc(width * width * sizeof(float));
	float *region_seq_quantization = (float *)malloc(width * width * sizeof(float));
	float quantization_error;
	
	for(i=0;i<length;i++){
		theta = thetap[i];		//for every possible direction
		nbr_coefficient = 0;
		error = 0.0F;
		warp_wavelet(region,region_seq,width,step,theta,map_index,i);
		perform_quantization(region_seq, region_seq_quantization, threshold, width);
		for(j=0;j<width * width;j++){
				coefficient = region_seq[j];
				if(coefficient > threshold)
					nbr_coefficient++;
				quantization_error = (region_seq_quantization[j] - region_seq[j]);
				error = error + quantization_error * quantization_error; 
		}
		nbr_bits_coefficient = nbr_coefficient * GAMMA;
		if(theta > NO_GEO)
			total_bits = nbr_bits_coefficient + nbr_bits_geom + nbr_bits_geo;
		else
			total_bits = nbr_bits_coefficient + nbr_bits_nogeom;
		lagrangian[i] = error + LAMBDA * total_bits * threshold * threshold;
	}

	float min = lagrangian[0];
	min_index =0;
	for(i=1;i<length;i++)
		if(min > lagrangian[i]){
			min = lagrangian[i];
			min_index = i;
		}
	
	*best_theta = thetap[min_index];
	*min_lag = lagrangian[min_index];
	//free(thetap);
	free(lagrangian);
	free(region_seq);
	free(region_seq_quantization);
}
