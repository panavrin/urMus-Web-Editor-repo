attribute vec4 position;
uniform mat4 mvp;
varying mediump vec4 position2;
attribute lowp vec4 a_Color;    // color at vertex position
varying lowp vec4 v_Color;       // vertex shader color output

void main()
{
    position2 = position;
    v_Color = a_Color;
    gl_Position = mvp * position;
}
