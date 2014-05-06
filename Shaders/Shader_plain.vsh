//
//  Shader.vsh
//  urMus2
//
//  Created by gessl on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


attribute vec4 a_Position; // Attribute is data send with each vertex. Position 
attribute vec4 a_Color;    // color at vertex position

uniform mat4 u_ModelViewProjMatrix; // This is sent from within your program

varying vec4 v_Color;       // vertex shader color output

void main()
{ 
    // Multiply the model view projection matrix with the vertex position
    gl_Position = u_ModelViewProjMatrix * a_Position;
    v_Color = a_Color;
}
