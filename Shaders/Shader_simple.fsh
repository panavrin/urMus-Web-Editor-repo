uniform lowp vec4 colour;
varying mediump vec4 position2;
varying lowp vec4 v_Color;       // vertex shader color output

void main()
{
//	gl_FragColor = colour * position2;
//    gl_FragColor = colour;
    gl_FragColor = v_Color;
}