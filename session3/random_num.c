#include <stdio.h>

int min = 0;
int max = 1;

int get_random_target() {
  return min + rand() / (RAND_MAX / (max - min + 1) + 1);
}
