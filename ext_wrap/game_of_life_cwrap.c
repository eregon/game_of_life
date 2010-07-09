#include "ruby.h"

#define BOOL(b) ((b) ? Qtrue : Qfalse)
#define CBOOL(b) ((b) ? 1 : 0)

static VALUE gol_set_state(VALUE self, VALUE state);

static VALUE EMPTY_ARGS[] = {};
extern VALUE EMPTY_ARGS[];

static VALUE gol_implementation() {
  return rb_str_new2("CWrap");
}

typedef struct Grid {
  int height;
  int width;
  int size;
  char* grid;
} Grid;

static VALUE gol_alloc(VALUE klass) {
  Grid *grid;
  return Data_Make_Struct(klass, Grid, 0, free, grid);
}

static VALUE gol_initialize_block_char(VALUE v, VALUE data2, int argc, VALUE argv) {
  char c = *RSTRING_PTR(v);
  return BOOL(c == 'X' || c == 'x');
}

static VALUE gol_initialize_block_line(VALUE line, VALUE data2, int argc, VALUE argv) {
  line = rb_funcall(line, rb_intern("chomp"), 0);
  line = rb_funcall(line, rb_intern("chars"), 0);
  return rb_block_call(line, rb_intern("map"), 0, EMPTY_ARGS, gol_initialize_block_char, Qnil);
}

static VALUE gol_initialize(int argc, VALUE *argv, VALUE self) {
  VALUE first, second;
  rb_scan_args(argc, argv, "11", &first, &second);
  if(NIL_P(second))
    second = first;
  if(rb_obj_is_kind_of(first, rb_cArray)) {
    gol_set_state(self, first);
  } else if(rb_obj_is_kind_of(first, rb_cString)) {
    VALUE ary = rb_funcall(first, rb_intern("lines"), 0);
    gol_set_state(self, rb_block_call(ary, rb_intern("map"), 0, EMPTY_ARGS, gol_initialize_block_line, Qnil));
  } else {
    int width  = NUM2INT(first), height = NUM2INT(second);
    VALUE grid = rb_ary_new2(height), row;
    int i, j;
    for(i = 0; i < height; ++i) {
      row = rb_ary_new2(width);
      for(j = 0; j < width; ++j) {
        rb_ary_store(row, j, BOOL(rb_genrand_real() < 0.5));
      }
      rb_ary_store(grid, i, row);
    }
    gol_set_state(self, grid);
  }
  return self;
}

static VALUE gol_state(VALUE self) {
  int i, j;
  Grid *grid;
  Data_Get_Struct(self, Grid, grid);
  int height = grid->height, width = grid->width;
  VALUE state = rb_ary_new2(height);
  VALUE row;
  for(i = 0; i < height; ++i) {
    row = rb_ary_new2(width);
    for(j = 0; j < width; ++j) {
      rb_ary_store(row, j, BOOL(grid->grid[i*width+j]));
    }
    rb_ary_store(state, i, row);
  }
  return state;
}

static VALUE gol_set_state(VALUE self, VALUE state) {
  Grid *grid;
  Data_Get_Struct(self, Grid, grid);
  int height = (int) RARRAY_LEN(state);
  int width = (int) RARRAY_LEN(RARRAY_PTR(state)[0]);

  grid->height = height;
  grid->width = width;
  grid->size = height*width;
  grid->grid = ALLOC_N(char, grid->size);

  VALUE row;
  int i, j;
  for(i = 0; i < height; i++) {
    row = RARRAY_PTR(state)[i];
    for(j = 0; j < width; j++) {
      grid->grid[i*width+j] = CBOOL(rb_funcall(RARRAY_PTR(row)[j], rb_intern("=="), 1, INT2FIX(1)));
    }
  }
  return Qnil;
}

static VALUE gol_evolve(VALUE self) {
  Grid *cgrid;
  Data_Get_Struct(self, Grid, cgrid);
  int width = cgrid->width;
  int size  = cgrid->size;
  char *grid = cgrid->grid;
  char *new_grid = ALLOC_N(char, size);

  int i, n, p, neighbors;
  int neighbors_delta[] = {1, 1-width, -width, -1-width, -1, width-1, width, width+1};
  int three_width = 3*width, width_1 = width-1;

  for(i = 0; i < size; ++i) {
    neighbors = 0;
    for(n = 0; n < 8; ++n) {
      p = i + neighbors_delta[n];
      if(n == 3 && i % width == 0) {
        p += three_width;
      } else if(n == 7 && i % width == width_1) {
        p -= three_width;
      }

      if(p < 0) {
        p += size;
      } else if(p >= size) {
        p -= size;
      }

      if(grid[p])
        ++neighbors;
    }
    new_grid[i] = (neighbors == 3 || (neighbors == 2 && grid[i]));
  }

  cgrid->grid = new_grid;
  return gol_state(self);
}

static VALUE gol_aref(VALUE self, VALUE x, VALUE y) {
  Grid *grid;
  Data_Get_Struct(self, Grid, grid);
  int height = grid->height, width = grid->width;
  //(y+height)%height is needed because in C, -n % d < 0
  return BOOL(grid->grid[((FIX2INT(y)+height) % height) * width + ((FIX2INT(x)+width) % width)]);
}

static VALUE gol_to_s(VALUE self) {
  Grid *grid;
  Data_Get_Struct(self, Grid, grid);
  int height = grid->height, width = grid->width, size = grid->size;
  int x, y;
  char s[size+height];
  for(y = 0; y < height; ++y) {
    for(x = 0; x < width; ++x) {
      s[y*(width+1) + x] = (grid->grid[y*width + x] ? '#' : ' ');
    }
    if(y != height-1)
      s[y*(width+1)+width] = '\n';
  }
  s[size+height-1] = '\0';
  return rb_str_new2(s);
}

static VALUE true_equal(VALUE self, VALUE other) {
  return BOOL(other == self || (FIXNUM_P(other) && FIX2INT(other) == 1));
}

static VALUE false_equal(VALUE self, VALUE other) {
  return BOOL(other == self || (FIXNUM_P(other) && !FIX2INT(other)));
}

void Init_game_of_life_cwrap() {
  VALUE cGameOfLife = rb_define_class("GameOfLife", rb_cObject);
  rb_define_alloc_func(cGameOfLife, gol_alloc);
  rb_define_module_function(cGameOfLife, "implementation", gol_implementation, 0);
  rb_define_method(cGameOfLife, "initialize", gol_initialize, -1);
  rb_define_method(cGameOfLife, "state", gol_state, 0);
  rb_define_method(cGameOfLife, "state=", gol_set_state, 1);
  rb_define_method(cGameOfLife, "evolve", gol_evolve, 0);
  rb_define_method(cGameOfLife, "[]", gol_aref, 2);
  rb_define_method(cGameOfLife, "to_s", gol_to_s, 0);

  rb_define_method(rb_cTrueClass, "==", true_equal, 1);
  rb_define_method(rb_cFalseClass, "==", false_equal, 1);
}
