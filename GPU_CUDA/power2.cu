#include"bandelet.h"

int power2(int power){
	int i;
	int result = 1;
	for(i=power;i>0;i--){
		result = result * 2;
	}
	return result;
}
