precision mediump float;

varying vec3 vVerCol;
varying vec2 vTexPos;

uniform sampler2D uSampler;

void main(void) {
    gl_FragColor = texture2D(uSampler, vTexPos);
}
