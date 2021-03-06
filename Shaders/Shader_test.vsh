attribute vec3 aVerPos;
attribute vec3 aVerCol;
attribute vec2 aTexPos;

varying vec3 vVerCol;
varying vec2 vTexPos;

void main(void) {
    vTexPos = aTexPos;
    vVerCol = aVerCol;
    gl_Position = vec4(aVerPos, 1.0);
}
