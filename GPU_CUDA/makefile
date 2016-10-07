objects = bandelet_transform.o compute_best_direction.o compute_quadtree.o power2.o haar_2d.o sort.o mapping.o
#objects = bandelet_transform.o compute_best_direction.o compute_quadtree.o power2.o draw_quadtree.o transform.o perform_bandelet_transform.o haar_2d.o sort.o mapping.o

#cvflag = -I/usr/include/opencv  -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_ml -lopencv_video -lopencv_features2d -lopencv_calib3d -lopencv_objdetect -lopencv_contrib -lopencv_legacy -lopencv_flann

NVCCFLAG = -use_fast_math -O3
all : bandelet

bandelet : $(objects)
	nvcc $(NVCCFLAG) -o bandelet $(objects) -lm 
bandelet_transform.o : bandelet_transform.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o bandelet_transform.o bandelet_transform.cu -lm
compute_best_direction.o : compute_best_direction.cu bandelet.h
	nvcc $(NVCCFLAG) -maxrregcount=20 --ptxas-options=-v -c -o compute_best_direction.o compute_best_direction.cu
compute_quadtree.o : compute_quadtree.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o compute_quadtree.o compute_quadtree.cu
power2.o : power2.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o power2.o power2.cu
draw_quadtree.o : draw_quadtree.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o draw_quadtree.o draw_quadtree.cu
perform_bandelet_transform.o : perform_bandelet_transform.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o perform_bandelet_transform.o perform_bandelet_transform.cu
transform.o : transform.cu bandelet.h
	nvcc $(NVCCFLAG) -maxrregcount=20 --ptxas-options=-v -c -o transform.o transform.cu
haar_2d.o : haar_2d.cu bandelet.h
	nvcc $(NVCCFLAG) -maxrregcount=20 --ptxas-options=-v -c -o haar_2d.o haar_2d.cu
sort.o : sort.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o sort.o sort.cu
mapping.o : mapping.cu bandelet.h
	nvcc $(NVCCFLAG) -c -o mapping.o mapping.cu
	
clean:
	rm bandelet $(objects) result/bandelet_coefficient result/quadtree_result result/theta_result
