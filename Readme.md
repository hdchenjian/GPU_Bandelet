### GPU实现Bandelet变换(Peyré G, Mallat S. Second Generation Bandelets and their Application to Image and 3D Meshes Compression)

```
目录结构:
C: C语言实现
GPU_CUDA: Nvidia CUDA 平台GPU实现
Matlab: Matlab版本(包含Bandelet逆变换)

对不同的大小的图片,Bandelet变换分别在 CPU 和 GPU 上运行的时间:
图像分辨率 256×256  512×512  1024×1024
CPU	    597.57   2661.75  10476.75
GPU  	     22.46    71.36    265.62
加速比	      26.61    37.30    39.44
```
