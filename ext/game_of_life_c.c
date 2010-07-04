#include "ruby.h"

#define BOOL(b) ((b) ? Qtrue : Qfalse)

VALUE gol_set_state(VALUE self, VALUE state);

VALUE EMPTY_ARGS[] = {};
extern VALUE EMPTY_ARGS[];

VALUE gol_implementation() {
  return rb_str_new2("C");
}

/* def initialize(width, height = width)
  case width
  when Array
    @height, @width = width.size, width.first.size
    @grid = width.map { |row| row.map { |i| i == 1 } }.flatten
  when String
    ary = width.lines.map { |line|
      line.chomp.chars.map { |v| (%w[x X].include? v) }
    }
    @height, @width = ary.size, ary.first.size
    @grid = ary.flatten
  else
    @width, @height = width, height
    @grid = Array.new(@height*@width) { rand(2) == 1 }
  end
  @size = @width*@height
end */

VALUE gol_initialize_block2(VALUE v, VALUE data2, int argc, VALUE argv) {
  char c = RSTRING_PTR(v)[0];
  return BOOL(c == 'X' || c == 'x');
}

VALUE gol_initialize_block(VALUE line, VALUE data2, int argc, VALUE argv) {
  line = rb_funcall(line, rb_intern("chomp"), 0);
  line = rb_funcall(line, rb_intern("chars"), 0);
  return rb_block_call(line, rb_intern("map"), 0, EMPTY_ARGS, gol_initialize_block2, Qnil);
}

VALUE gol_initialize(int argc, VALUE *argv, VALUE self) {
  VALUE first, second;
  rb_scan_args(argc, argv, "11", &first, &second);
  if(NIL_P(second))
    second = first;
  if(rb_obj_is_kind_of(first, rb_cArray)) {
    gol_set_state(self, first);
  } else if(rb_obj_is_kind_of(first, rb_cString)) {
    VALUE ary = rb_funcall(first, rb_intern("lines"), 0);
    gol_set_state(self, rb_block_call(ary, rb_intern("map"), 0, EMPTY_ARGS, gol_initialize_block, Qnil));
  } else {
    int width  = NUM2INT(first);
    int height = NUM2INT(second);
    int size = width*height;
    VALUE grid = rb_ary_new2(size);
    int i;
    for(i = 0; i < size; ++i)
      rb_ary_store(grid, i, BOOL(rb_genrand_real() < 0.5));
    rb_iv_set(self, "@width" , INT2FIX(width));
    rb_iv_set(self, "@height", INT2FIX(height));
    rb_iv_set(self, "@size"  , INT2FIX(size));
    rb_iv_set(self, "@grid"  , grid);
  }
  return Qnil;
}

// Array.new(@height) { |y| Array.new(@width) { |x| @grid[y * @width + x] } }
VALUE gol_state(VALUE self) {
  int i;
  int height = FIX2INT(rb_iv_get(self, "@height"));
  int width = FIX2INT(rb_iv_get(self, "@width"));
  VALUE grid = rb_iv_get(self, "@grid");
  VALUE state = rb_ary_new2(height);
  for(i = 0; i < height; ++i)
    rb_ary_store(state, i, rb_ary_subseq(grid, i*width, width));
  return state;
}

/* def state= state
  @height, @width = state.size, state.first.size
  @size = @width*@height
  @grid = state.map { |row| row.map { |i| i == 1 } }.flatten
end */
VALUE gol_set_state(VALUE self, VALUE state) {
  int height = (int) RARRAY_LEN(state);
  int width = (int) RARRAY_LEN(RARRAY_PTR(state)[0]);
  int size = width*height;
  VALUE grid = rb_ary_new2(size);
  VALUE row;
  int i, j;
  for(i = 0; i < height; i++) {
    row = RARRAY_PTR(state)[i];
    for(j = 0; j < width; j++)
      rb_ary_store(grid, i*width+j, rb_funcall(RARRAY_PTR(row)[j], rb_intern("=="), 1, INT2FIX(1)));
  }
  rb_iv_set(self, "@width", INT2FIX(width));
  rb_iv_set(self, "@height", INT2FIX(height));
  rb_iv_set(self, "@size", INT2FIX(size));
  rb_iv_set(self, "@grid", grid);
  return Qnil;
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
    rb_ary_store(new_grid, i, BOOL(neighbors == 3 || (neighbors == 2 && grid[i])));
  }

  rb_iv_set(self, "@grid", new_grid);

  return gol_state(self);
}

/* def [](x, y)
  @grid[(y % @height) * @width + (x % @width)]
end */
VALUE gol_aref(VALUE self, VALUE x, VALUE y) {
  int height = FIX2INT(rb_iv_get(self, "@height"));
  int width = FIX2INT(rb_iv_get(self, "@width"));
  VALUE grid = rb_iv_get(self, "@grid");
  //(y+height)%height is needed because in C, -n % d < 0
  return rb_ary_entry(grid, ((FIX2INT(y)+height) % height) * width + ((FIX2INT(x)+width) % width));
}

/* def []=(x, y, v)
  @grid[(y % @height) * @width + (x % @width)] = v
end */
VALUE gol_aset(VALUE self, VALUE x, VALUE y, VALUE v) {
  int height = FIX2INT(rb_iv_get(self, "@height"));
  int width = FIX2INT(rb_iv_get(self, "@width"));
  VALUE grid = rb_iv_get(self, "@grid");
  rb_ary_store(grid, ((FIX2INT(y)+height) % height) * width + ((FIX2INT(x)+width) % width), v);
  return v;
}

/* def to_s
  @height.times.map { |y|
    @width.times.map { |x|
      @grid[y * @width + x] ? '#' : ' '
    }.join
  }.join("\n")
end */
VALUE gol_to_s(VALUE self) {
  int height = FIX2INT(rb_iv_get(self, "@height"));
  int width = FIX2INT(rb_iv_get(self, "@width"));
  VALUE grid = rb_iv_get(self, "@grid");
  int x, y, size = height*width;
  char s[size+height-1];
  for(y = 0; y < height; ++y) {
    for(x = 0; x < width; ++x) {
      s[y*(width+1) + x] = (RARRAY_PTR(grid)[y*width + x] ? '#' : ' ');
    }
    if(y != height-1)
      s[y*(width+1)+width] = '\n';
  }
  return rb_str_new2(s);
}

VALUE true_equal(VALUE self, VALUE other) {
  return BOOL(other == self || (FIXNUM_P(other) && FIX2INT(other) == 1));
}

VALUE false_equal(VALUE self, VALUE other) {
  return BOOL(other == self || (FIXNUM_P(other) && !FIX2INT(other)));
}

void Init_game_of_life_c() {
  VALUE cGameOfLife = rb_define_class("GameOfLife", rb_cObject);
  rb_define_module_function(cGameOfLife, "implementation", gol_implementation, 0);
  rb_define_method(cGameOfLife, "initialize", gol_initialize, -1);
  rb_define_method(cGameOfLife, "state", gol_state, 0);
  rb_define_method(cGameOfLife, "state=", gol_set_state, 1);
  rb_define_method(cGameOfLife, "evolve", gol_evolve, 0);
  rb_define_method(cGameOfLife, "[]", gol_aref, 2);
  rb_define_method(cGameOfLife, "[]=", gol_aset, 3);
  rb_define_method(cGameOfLife, "to_s", gol_to_s, 0);

  rb_define_method(rb_cTrueClass, "==", true_equal, 1);
  rb_define_method(rb_cFalseClass, "==", false_equal, 1);
}
