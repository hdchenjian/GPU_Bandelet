/* perform haar 2D transform,input a image, heigh, width and scale J */

#include "bandelet.h"

void haar1(float *vec, int width, int w);

void haar_2d(float *image,int rows,int cols,int J,int step){
	int i=0,j=0,k=0;
	int w = cols, h = rows;
	float *temp_row = (float *)malloc(cols * sizeof(float));
	float *temp_col = (float *)malloc(rows * sizeof(float));
	
	for(k=0;k<J;k++){
		if(w>1) {						//for every rows
			for(i=0;i<h;i++) {
				for(j=0;j<cols;j++)
					temp_row[j] = *(image + i*step +j);
				haar1(temp_row,cols,w);
				for(j=0;j<cols;j++)
					*(image + i*step +j) = temp_row[j];
			}
		}

		if(h>1) {						//for every colums, i stand for colums
			for(i=0;i<w;i++) {
				for(j=0;j<rows;j++)
					temp_col[j] = *(image + i + j*step);
				
				haar1(temp_col, rows, h);
				for(j=0;j<rows;j++)
					*(image + i + j*step) = temp_col[j];
			}
		}
		if(w > 1 && h > 1){
			w/=2;
			h/=2;
		}
	}

	free(temp_row);
	free(temp_col);
}

/*A Modified version of 1D Haar Transform,used by the 2D Haar Transform*/
void haar1(float *vec, int width, int w)
{
	int i=0;
	float *vecp = (float *)malloc(width * sizeof(float));

	w /= 2;
	for(i=0;i<w;i++)
	{
		vecp[i] = (vec[2*i] + vec[2*i+1]) / SQRT2;
		vecp[i+w] = (vec[2*i] - vec[2*i+1]) / SQRT2;
	}

	for(i=0;i<(w*2);i++)
		vec[i] = vecp[i];

	free(vecp);
}
