//
//  Shader.fsh
//  urMus2
//
//  Created by gessl on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//#extension GL_OES_EGL_image_external : require
precision mediump float; // Mandatory OpenGL ES float precision

varying vec2 v_TexCoord; // Sent in from Vertex Shader
varying lowp vec4 v_Color;   // vertex shader output

//uniform samplerExternalOES s_Texture;
uniform sampler2D u_Texture; // The texture to use sent from within your program.
uniform lowp vec4 colour;

void main()
{
    // The pixel colors are set to the texture according to texture coordinates.
    gl_FragColor =   gl_FragColor = v_Color * texture2D(u_Texture, v_TexCoord);
}
