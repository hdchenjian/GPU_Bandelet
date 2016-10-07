#include"bandelet.h"

int main(void){

	int i, j, k;			//use k to stand for scale
	//int total_nbr_bits_code;
	float elapsed_time = 0.0F;
	//int total_nbr_bits_code = 0;		 //the number of bits need to code 
	//int square_wide;
	//as src_image->imageData is char type,so need to convert it
	int rows, cols;		//it should be a square image	
	int step;
	rows = cols = HEIGHT;
	int width = cols;
	step = cols;
	
	int Jmax = log2((float)cols) -1;		//the range of scale
	int Jmin = JMIN;			//the smallest size of square(width = w^2) of wavelet transform
	int scale = log2((float)cols) - Jmin;		//the scale of haar transform			
	int s = 2;		//super-resolution factor	
	float threshold = 10.0F;  //%the threshold to evalue the best direction
	int j_min = JMIN;			//%the minimum scale for quadtree segment
	int j_max = JMIN;			//%the maximum scale for quadtree segment
	float *image;
	int *quadtree_seg;
	float *theta;
	float *thetap, *thetap_dev;			//the array that contain sampling direction
	int *map_index, *map_index_dev;		/*map_index is a 2D array map_index[length][min_side * min_side]*/
	
	int min_side = power2(j_min);		//the length of size of the min square
	int length = 2 * power2(j_min) * s + 1;	/*the number of theta value*/
	
	cudaHostAlloc((void **)&image, rows * cols *sizeof(float), cudaHostAllocDefault);
	cudaHostAlloc((void **)&quadtree_seg, width * width * sizeof(int), cudaHostAllocDefault);	
	cudaHostAlloc((void **)&theta, width * width * sizeof(float), cudaHostAllocDefault);	
	cudaHostAlloc((void **)&map_index,length*min_side*min_side*sizeof(int),cudaHostAllocDefault);		
	cudaHostAlloc((void **)&thetap, length * sizeof(float), cudaHostAllocDefault);

	float adder = PI / (length - 1);	
	for(i = 0; i < length - 1; i++){
		thetap[i] = (adder / 2) + i * adder;
	}
	thetap[i] = NO_GEO;		//add no geometry stream direction
		
	float theta_value;
	float x_direct, y_direct;
	float *grid = (float *)malloc(min_side * min_side * sizeof(float));
	float *gridp = grid;
	float *grid_sort = (float *)malloc(min_side * min_side * sizeof(float));
	/*we need to keep grid,because we need free it,so we can not change it*/	
	
	for(i = 0; i < length; i++){
		theta_value = thetap[i];
		x_direct = -sinf(theta_value);
		y_direct = cosf(theta_value);
		/*projection on orthogonal direction*/
		/*this grid was created using matlab colums order, not C's row order, be careful,
		 * x coordinate is vertical, and y coordinate is horizontal, as an image coordinate*/

		for(j=1;j<min_side+1;j++)			//y_direct
			for(k=1;k<min_side+1;k++){ 	//x_direct
				*gridp = x_direct * k + y_direct * j;
				gridp++;
			}
		gridp = grid;
		sort(gridp,grid_sort,min_side * min_side);	/*sort points in increasing order*/
		/*map gridp to grid_sort, get the index of sorting wavelet coefficient*/
		mapping(grid_sort,gridp,map_index + i * min_side * min_side,min_side * min_side); //have a bug
	}
	
	FILE *image_matrix;
	if ((image_matrix = fopen("image_matrix", "r+")) != NULL){
		i = fread(image, sizeof(float), rows * cols, image_matrix);
		printf("the number of element of fread is %d\n", i);
		fclose(image_matrix);
	}
	else
		printf("fail opening the file\n");	

	printf("get the processed image\n");
	printf("rows is %d, cols is %d\n",rows, cols);
	printf("image row step in bytes is %d, be careful to use it \n", step);
	

	/*initial the theta to NO_GEO*/	
	for(i=0;i<rows;i++)
		for(j=0;j<cols;j++)
			*(theta + i*step + j) = NO_GEO;
	/*initial the quadtree_seg to j_min*/	
	for(i=0;i<rows;i++)
		for(j=0;j<cols;j++)
			*(quadtree_seg + i*step + j) = j_min;

	/*prepare data for gpu computing, do not consider rows > 512 condition*/
	float *image_dev;
	int *quadtree_seg_dev;
	float *theta_dev;

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	
	cudaMalloc((void **)&theta_dev, rows * cols * sizeof(float));
	cudaMalloc((void **)&image_dev, rows * cols * sizeof(float));
	cudaMalloc((void **)&quadtree_seg_dev, rows * cols * sizeof(int));
	cudaMalloc((void **)&thetap_dev, length * sizeof(float));
	cudaMalloc((void **)&map_index_dev, length * min_side * min_side * sizeof(int));
	
	cudaMemcpy(image_dev, image, rows * cols * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(quadtree_seg_dev, quadtree_seg, rows *cols* sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(theta_dev, theta, rows * cols * sizeof(float),  cudaMemcpyHostToDevice);
	cudaMemcpy(thetap_dev, thetap, length  * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(map_index_dev, map_index, length* min_side* min_side * sizeof(int), cudaMemcpyHostToDevice);
	
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsed_time, start, stop);
	printf("copy data to GPU consume time is %f ms\n", elapsed_time);
	
	float time_temp;
	haar_2d(image_dev, step, rows, cols, scale, &time_temp);
	elapsed_time += time_temp;
	printf("2D haar transform over\n");
	
	compute_quadtree(image_dev, width, step, threshold, j_min, j_max, s, quadtree_seg_dev,\
			theta_dev, &time_temp, thetap_dev, map_index_dev);
	elapsed_time += time_temp;
	//printf("compute_quadtree consume time is %f ms\n", elapsed_time);
	
	printf("compute_quadtree over \n");
			
	/*perform bandelet transform for each square*/
	time_temp = 0.0F;
	//perform_bandelet_transform(image, j_min, image_dev, width, step, quadtree_seg_dev, theta_dev, &total_nbr_bits_code, &time_temp, length, thetap_dev, map_index_dev);
	//elapsed_time += time_temp;
	//printf("the total_nbr_bits_code is %d\n",total_nbr_bits_code);
	cudaEventRecord(start, 0);
	cudaMemcpy(quadtree_seg, quadtree_seg_dev, rows * cols*sizeof(int),cudaMemcpyDeviceToHost);
	cudaMemcpy(theta, theta_dev, rows * cols * sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpy(image, image_dev, rows * cols * sizeof(float), cudaMemcpyDeviceToHost);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time_temp, start, stop);
	printf("copy back data to CPU consume time is %f ms\n", time_temp);
	elapsed_time += time_temp;
	printf("the total elapsed_time is %f ms\n", elapsed_time);
	
	/*save the result as binary file*/
	int volume = rows * cols;
	FILE *quadtree_result;
	FILE *theta_result;
	FILE *bandelet_coefficient;
	if ((quadtree_result = fopen("result/quadtree_result", "w+")) != NULL){
		fwrite(quadtree_seg, sizeof(int), volume, quadtree_result);
		fclose(quadtree_result);
	}
	else
		printf("fail opening the file\n");

	if ((theta_result = fopen("result/theta_result", "w+")) != NULL){
		fwrite(theta, sizeof(float), volume, theta_result);
		fclose(theta_result);
	}
	else
		printf("fail opening the file\n");

	if ((bandelet_coefficient = fopen("result/bandelet_coefficient", "w+")) != NULL){
		fwrite(image, sizeof(float), volume, bandelet_coefficient);
		fclose(bandelet_coefficient);
	}
	else
		printf("fail opening the file\n");

	printf("draw the quadtree segment\n");
	printf("the width is %d, the j_min is %d, the step is %d\n", cols, j_min, step);
	/*adjust the theta value, so plot the correct geometry stream*/
	for(i = 0; i < rows; i++)
		for(j = 0; j < cols; j++){
			if(theta[i * step + j] < PI /2)
				theta[i * step + j] = PI / 2 + theta[i * step + j];
			else
				theta[i * step + j] = theta[i * step + j] - PI / 2;
		}
	
	//draw_quadtree(src_image, quadtree_seg, theta, cols, j_min, step);
	
	free(grid);
	free(grid_sort);
	
	cudaFreeHost(thetap);
	cudaFreeHost(map_index);
	cudaFreeHost(image);
	cudaFreeHost(quadtree_seg);
	cudaFreeHost(theta);

	cudaFree(thetap_dev);
	cudaFree(map_index_dev);
	cudaFree(image_dev);
	cudaFree(quadtree_seg_dev);
	cudaFree(theta_dev);
	//cudaFree(theta_next_scale_dev);
	//cvReleaseImage(&src_image);

	return 0;
}
