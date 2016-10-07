/* The quantizer is defined by y=Q_T(x) where:
      Q_T(x) = 0    if  |x|<T
      Q_T(x) = sign(x) * ([x/T]+0.5)*T      where [.]=floor
  (i.e. a nearly uniform quantizer with twice larger zero bin)*/

#include"bandelet.h"
float get_sign(float x);

void perform_quantization(float *seq, float *seq_quantization, float threshold, int width){
	int i;
	float coefficient;

	for(i=0;i<width * width;i++){
		coefficient = seq[i];
		if(fabsf(seq[i]) < threshold)
			seq_quantization[i] = 0.0F;
		else{
			seq_quantization[i] = get_sign(coefficient) * (floorf(fabsf(coefficient) / threshold) + 0.5F) * threshold;
		}
	}
}

/*get the sign of x */				
float get_sign(float x){
	if(x > 0.0F)
		return 1.0F;
	else if(x < 0.0F)
		return -1.0F;
	else
		return 0.0F;
}
