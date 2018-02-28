/*
 * "Moiré unreal" by Ben Wheatley - 2018
 * License MIT License
 * Contact: github.com/BenWheatley
 */

float wave(float x) {
    return (1.0+sin(x))/2.0;
}
float r(vec2 coordinate, vec2 offset) {
    float dx = coordinate.x - offset.x;
    float dy = coordinate.y - offset.y;
    return sqrt(dx*dx + dy*dy);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Centered pixel coordinates
    vec2 uv = fragCoord/iResolution.xy - vec2(0.5, 0.5);
    uv *= iResolution.xy;
    uv /= iResolution.y; 
	
    // Aliases for compact notation
    float t = iTime*0.4, t2 = iTime*2.0;
    float r1 = r(uv, 0.7*vec2(sin(0.66*t),		0.3*sin(0.5*t+0.9)));
    float r2 = r(uv, 0.2*vec2(sin(0.24*t+1.1),	0.4*sin(0.6*t+0.1)));
    
    float b = wave(30.0*r1-3.0*t2) + wave(20.0*r2-3.0*t2);
    b += wave(30.0*uv.x)/2.0;
    
    // Let it oversaturate; I experimented with other values, but my first guess was the best
    b /= 2.0;
	
    
    // Output to screen
    fragColor = vec4(b, b, b,1.0);
}
