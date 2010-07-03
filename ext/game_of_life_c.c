#include "ruby.h"

VALUE gol_implementation() {
  return rb_str_new2("C");
}

VALUE gol_state(VALUE self) {
  int i, j;
  int width = FIX2INT(rb_iv_get(self, "@width"));
  int height = FIX2INT(rb_iv_get(self, "@height"));
  VALUE rgrid = rb_iv_get(self, "@grid");
  VALUE *grid = RARRAY_PTR(rgrid);
  VALUE state = rb_ary_new2(height);
  VALUE row;
  for(i = 0; i < height; ++i) {
    row = rb_ary_new2(width);
    for(j = 0; j < width; ++j) {
      rb_ary_store(row, j, grid[i*width+j]);
    }
    rb_ary_store(state, i, row);
  }
  return state;
}

int gol_neighbors(VALUE self, int pos) {
  int width = FIX2INT(rb_iv_get(self, "@width"));
  int size = FIX2INT(rb_iv_get(self, "@size"));
  int neighbors[] = {1, 1-width, -width, -1-width, -1, width-1, width, width+1};
  int i, count = 0;
  int p;
  VALUE rgrid = rb_iv_get(self, "@grid");
  VALUE *grid = RARRAY_PTR(rgrid);

  for(i = 0; i < 8; ++i) {
    p = pos + neighbors[i];
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
  int i, b = 0;
  int size = FIX2INT(rb_iv_get(self, "@size"));
  VALUE rgrid = rb_iv_get(self, "@grid");
  VALUE *grid = RARRAY_PTR(rgrid);
  VALUE new_grid = rb_ary_new2(size);
  int neighbors;

  for(i = 0; i < size; ++i) {
    neighbors = gol_neighbors(self, i);
    if(grid[i]) {
      b = (neighbors == 2 || neighbors == 3);
    } else {
      b = (neighbors == 3);
    }
    rb_ary_store(new_grid, i, (b ? Qtrue : Qfalse));
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
