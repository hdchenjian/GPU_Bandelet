#include"bandelet.h"

void draw_rectangle( IplImage *image, CvPoint start, CvPoint end );
void draw_line( IplImage *image, CvPoint start, CvPoint end );

void draw_quadtree(IplImage *image, int *quadtree, float *theta, int width, int j_min, int step){
	int i,j,k;
	CvPoint line_start, line_end;
	CvPoint rect_start, rect_end;
	CvPoint center;
	int coord_x, coord_y;		//coordinate of x y
	int square_wide;
	int nbr_min_side;			//the number of minmum square in a direction
	float theta_value;

	for(k = log2f(width); k >= j_min; k--){
		square_wide = power2(k);			//the width of the region that will be draw
		nbr_min_side = width / square_wide; 
		for(i = 0; i < nbr_min_side; i++)		//y direction
			for(j = 0; j < nbr_min_side; j++){	//x direction
				/*this is a leaf, transform it*/
				if(quadtree[i*square_wide*step + j*square_wide] == k){
					coord_x = j * square_wide;
					coord_y = i * square_wide;
					rect_start.x = coord_x;
					rect_start.y = coord_y;
					rect_end.x = coord_x + square_wide;
					rect_end.y = coord_y + square_wide;
					draw_rectangle(image, rect_start, rect_end );
					theta_value = theta[i*square_wide*step + j*square_wide];
					center.x = coord_x + square_wide / 2;
					center.y = coord_y + square_wide / 2;
					line_start.x = center.x - (square_wide / 2) * cos(theta_value);
					line_start.y = center.y + (square_wide / 2) * sin(theta_value);
					line_end.x = center.x + (square_wide / 2) * cos(theta_value);
					line_end.y = center.y - (square_wide / 2) * sin(theta_value);
					draw_line(image, line_start, line_end );
				}
			}
	}
	cvNamedWindow("Display Image",CV_WINDOW_AUTOSIZE);
	cvShowImage("Display Image",image);
	while( 1 ) { if( cvWaitKey( 1000 ) == 27 ) break; }
}

void draw_line( IplImage *image, CvPoint start, CvPoint end ){
	int thickness = 1;
	int lineType = 8;
	CvScalar color = {{255}};
	cvLine( image,			//line is displayed in the image 
			start,		//start point, vertical is y coordinate, horizontal is x coordinat
			end,		//end point
			color,		//RGB values of line color
			thickness,				//line thickness
			lineType,				//line is a 8-connected one
			0);
}

void draw_rectangle( IplImage *image, CvPoint start, CvPoint end ){
	int thickness = 1;
	int lineType = 8;
	CvScalar color = {{60}};
	cvRectangle(image,
			start,	//Two opposite vertices of the rectangle
			end,
			color,		//The color of the rectangle
			thickness,					//the thickness value, if is -1, the rectangle will be filled
			lineType,
			0);
}
