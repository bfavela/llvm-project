#include <stdio.h>

extern "C" {
int dx_bufferload_impl(int index) {
  printf("foo");
  return index * 2;
}
}
