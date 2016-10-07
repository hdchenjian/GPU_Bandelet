#include"bandelet.h"

int main(void){
    int i,j, k;			//use k to stand for scale
    int rows,cols;		//it should be a square image
    int step;
    int total_nbr_bits_code = 0;		 //the number of bits need to code 
	
    rows = cols = HEIGHT;
    int width = cols;
    step = cols;
    //int Jmax = log2(cols) -1;		//the range of scale
	
    int Jmin = JMIN;  //the smallest size of square(width = w^2) of wavelet transform
    int scale = log2(cols) - Jmin;		//the scale of haar transform
    float *image = (float *)malloc(rows * cols *sizeof(float));
    int *quadtree_seg = (int *)malloc(width * width * sizeof(int));
    float *theta = (float *)malloc(width * width * sizeof(float));
    int s = 2;		//super-resolution factor	
    float threshold = 10.0F;  //%the threshold to evalue the best direction
    int j_min = JMIN;			//%the minimum scale for quadtree segment
    int j_max = JMIN;			//%the maximum scale for quadtree segment
    //cvNamedWindow("load image",CV_WINDOW_AUTOSIZE);
    //cvShowImage("load image", src_image);
    //cvWaitKey(2000);
	
    float *thetap;			//the array that contain sampling direction
    int *map_index;		/*map_index is a 2D array map_index[length][min_side * min_side]*/
	
    int min_side = power2(j_min);		//the length of size of the min square
    int length = 2 * power2(j_min) * s + 1;	/*the number of theta value*/
		
    map_index = (int *)malloc(length * min_side * min_side * sizeof(int));		
    thetap = (float *)malloc(length * sizeof(float));

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
	mapping(grid_sort,gridp,map_index + i * min_side * min_side,min_side * min_side);
    }
	
    printf("rows is %d, cols is %d\n",rows, cols);
    printf("image row step in bytes is %d, be careful to use it \n", step);
	
    FILE *image_matrix;
    if ((image_matrix = fopen("image_matrix", "r+")) != NULL){
	i = fread(image, sizeof(float), rows * cols, image_matrix);
	printf("the number of element of fread is %d\n", i);
	fclose(image_matrix);
    }
    else
	printf("fail opening the file\n");
	
    //cvReleaseImage(&src_image);
    //cvDestroyWindow("load image");
    printf("released the opencv source\n");

    /*initial the theta to NO_GEO*/	
    for(i=0;i<rows;i++)
	for(j=0;j<cols;j++)
	    *(theta + i*step + j) = NO_GEO;
    /*initial the quadtree_seg to j_min*/	
    for(i=0;i<rows;i++)
	for(j=0;j<cols;j++)
	    *(quadtree_seg + i*step + j) = j_min;

    /*perform 2D haar transform */
    float time_use=0; 
    struct timeval start;
    struct timeval temp_start, temp_end;
    struct timeval end; 
    gettimeofday(&start,NULL);
    printf("start.tv_sec:%ld\n",start.tv_sec);         
    printf("start.tv_usec:%ld\n",start.tv_usec);      
													
    haar_2d(image, rows, cols, scale, step);

    gettimeofday(&temp_end,NULL);                      
    time_use=(temp_end.tv_sec-start.tv_sec)*1000000+(temp_end.tv_usec-start.tv_usec);
    printf("time use of haar transform is %f ms\n",time_use / 1000.0F);

    gettimeofday(&temp_start,NULL);
    compute_quadtree(image, width, step, threshold, j_min, j_max, s, quadtree_seg, theta,length,map_index, thetap);
    gettimeofday(&temp_end,NULL);                      
    time_use=(temp_end.tv_sec-temp_start.tv_sec)*1000000+(temp_end.tv_usec-temp_start.tv_usec);
    printf("time use of compute_quadtree is %f ms\n",time_use / 1000.0F);

    /*perform bandelet transform for each square*/
    gettimeofday(&temp_start,NULL);
    perform_bandelet_transform(image,width,step,quadtree_seg,theta,&total_nbr_bits_code,length,map_index, thetap);
    gettimeofday(&temp_end,NULL);                      
    time_use=(temp_end.tv_sec-temp_start.tv_sec)*1000000+(temp_end.tv_usec-temp_start.tv_usec);
    printf("time use of perform_bandelet_transform is %f ms\n",time_use / 1000.0F);

    gettimeofday(&end,NULL);
    time_use=(end.tv_sec-start.tv_sec)*1000000+(end.tv_usec-start.tv_usec);
    printf("the total time use is %f ms\n",time_use / 1000.0F);

    printf("the total_nbr_bits_code is %d\n",total_nbr_bits_code);

    //save the result as binary file
    int volume = rows * cols;
    FILE *bandelet_coefficient;
    FILE *quadtree_result;
    FILE *theta_result;
    if ((bandelet_coefficient = fopen("result/bandelet_coefficient", "w+")) != NULL){
	fwrite(image, sizeof(float), volume, bandelet_coefficient);
	fclose(bandelet_coefficient);
    }
    else
	printf("fail opening the file\n");

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

    free(image);
    free(quadtree_seg);
    free(theta);
	
    return 0;
}
