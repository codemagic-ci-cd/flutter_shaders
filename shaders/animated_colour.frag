// ref: https://thebookofshaders.com/02/
// learn about uniforms
// ref: https://thebookofshaders.com/03/

uniform float u_time; // Time in seconds since load

out vec4 fragColor; // output colour for Flutter, like gl_FragColor

void main() {
    float r = abs(sin(u_time * 0.8));
    float g = abs(sin(u_time * 1.5));
    float b = abs(sin(u_time * 0.3));

	fragColor = vec4(r,g,b,1.0);
}