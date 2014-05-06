//
//  Shader.vsh
//  urMus2
//
//  Created by gessl on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


attribute vec4 a_Position; // Attribute is data send with each vertex. Position 
attribute vec4 a_Color;    // color at vertex position
attribute vec2 a_TexCoord; // and texture coordinates is the example here

uniform mat4 u_ModelViewProjMatrix; // This is sent from within your program

varying mediump vec2 v_TexCoord; // varying means it is passed to next shader
varying vec4 v_Color;       // vertex shader color output

void main()
{ 
    // Multiply the model view projection matrix with the vertex position
    gl_Position = u_ModelViewProjMatrix * a_Position;
    v_Color = a_Color;
    v_TexCoord = a_TexCoord.xy; // Send texture coordinate data to fragment shader.
}
