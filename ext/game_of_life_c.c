#include "ruby.h"

VALUE gol_implementation() {
  return rb_str_new2("C");
}

VALUE gol_state(VALUE self) {
  int i;
  int width = FIX2INT(rb_iv_get(self, "@width"));
  int height = FIX2INT(rb_iv_get(self, "@height"));
  VALUE grid = rb_iv_get(self, "@grid");
  VALUE state = rb_ary_new2(height);
  for(i = 0; i < height; ++i)
    rb_ary_store(state, i, rb_ary_subseq(grid, i*width, width));
  return state;
}

int gol_neighbors(int neighbors_delta[], int pos, int grid[], int size) {
  int i, count = 0;
  int p;

  for(i = 0; i < 8; ++i) {
    p = pos + neighbors_delta[i];
    if(p < 0) {
      p += size;
    } else if(p >= size) {
      p -= size;
    }

    if(grid[p])
      ++count;
  }
  return count;
}

VALUE gol_evolve(VALUE self) {
  int i, neighbors, b = 0;
  int width = FIX2INT(rb_iv_get(self, "@width"));
  int size = FIX2INT(rb_iv_get(self, "@size"));
  VALUE rgrid = rb_iv_get(self, "@grid");
  VALUE new_grid = rb_ary_new2(size);
  int neighbors_delta[] = {1, 1-width, -width, -1-width, -1, width-1, width, width+1};

  int grid[size];
  for(i = 0; i < size; ++i)
    grid[i] = (int) RARRAY_PTR(rgrid)[i];

  for(i = 0; i < size; ++i) {
    neighbors = gol_neighbors(neighbors_delta, i, grid, size);
    rb_ary_store(new_grid, i, (
      (neighbors == 3 || (neighbors == 2 && grid[i])) ? Qtrue : Qfalse)
    );
  }

  rb_iv_set(self, "@grid", new_grid);

  return gol_state(self);
}

void Init_game_of_life_c() {
  VALUE cGameOfLife = rb_define_class("GameOfLife", rb_cObject);
  rb_define_module_function(cGameOfLife, "implementation", gol_implementation, 0);
  rb_define_method(cGameOfLife, "evolve", gol_evolve, 0);
  rb_define_method(cGameOfLife, "state", gol_state, 0);
}
