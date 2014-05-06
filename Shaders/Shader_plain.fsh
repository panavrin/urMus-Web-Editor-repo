//
//  Shader.fsh
//  urMus2
//
//  Created by gessl on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

precision mediump float; // Mandatory OpenGL ES float precision

varying lowp vec4 v_Color;   // vertex shader output

void main()
{
    // The pixel colors are set to the texture according to texture coordinates.
    gl_FragColor =  v_Color;
}
