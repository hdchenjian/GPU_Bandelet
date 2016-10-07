objects = haar1d.o warp_wavelet.o compute_best_direction.o compute_quadtree.o  bandelet_transform.o power2.o perform_bandelet_transform.o perform_quantization.o haar_2d.o warp_wavelet_transform.o sort.o mapping.o

#cvflag = -I/usr/include/opencv  -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_ml -lopencv_video -lopencv_features2d -lopencv_calib3d -lopencv_objdetect -lopencv_contrib -lopencv_legacy -lopencv_flann

CFLAGS=-c -Wall -g

all : bandelet

bandelet : $(objects)
	gcc -O3 -Wall -o bandelet $(objects) -lm

wavelet_bandelet_transform.o : bandelet.h wavelet_bandelet_transform.c
	gcc -O3 -Wall -c -o wavelet_bandelet_transform.o wavelet_bandelet_transform.c $(cvflag)	

haar1d.o : bandelet.h haar1d.c
	gcc -O3 -Wall -c -o haar1d.o haar1d.c
warp_wavelet.o : bandelet.h warp_wavelet.c
	gcc -O3 -Wall -c -o warp_wavelet.o warp_wavelet.c
warp_wavelet_transform.o : warp_wavelet_transform.c bandelet.h
	gcc -O3 -Wall -c -o warp_wavelet_transform.o warp_wavelet_transform.c
compute_best_direction.o : bandelet.h compute_best_direction.c
	gcc -O3 -Wall -c -o compute_best_direction.o compute_best_direction.c
compute_quadtree.o : bandelet.h compute_quadtree.c
	gcc -O3 -Wall -c -o compute_quadtree.o compute_quadtree.c
bandelet_transform.o : bandelet.h bandelet_transform.c
	gcc -O3 -Wall -c -o bandelet_transform.o bandelet_transform.c
perform_bandelet_transform.o : bandelet.h perform_bandelet_transform.c
	gcc -O3 -Wall -c -o perform_bandelet_transform.o perform_bandelet_transform.c
power2.o : power2.c
	gcc -O3 -Wall -c -o power2.o power2.c
perform_quantization.o : perform_quantization.c bandelet.h
	gcc -O3 -Wall -c -o perform_quantization.o perform_quantization.c
haar_2d.o : haar2d.c bandelet.h
	gcc -O3 -Wall -c -o haar_2d.o haar2d.c
sort.o : sort.c
	gcc -O3 -Wall -c -o sort.o sort.c
mapping.o : mapping.c
	gcc -O3 -Wall -c -o mapping.o mapping.c


.PHONY : clean 
clean:
	rm bandelet $(objects)
