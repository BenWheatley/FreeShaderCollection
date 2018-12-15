/*
 * "Menger tartan" by Ben Wheatley - 2018
 * License MIT License
 * Contact: github.com/BenWheatley
 */

int inSet(float x) {
    for (int i=0; i<8; ++i) {
	    if (int(x * pow(3.0, float(i))) % 3 == 1) {
    		return i;
        }
    }
    return 0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
	
    float b = 1.0;
    
    int x = inSet(uv.x);
    int y = inSet(uv.y);
    if (x>0) {
    	b /= float(x);
    }
    if (y>0) {
    	b /= float(y);
    }
    b = 1.0-b;
    
    // Output to screen
    fragColor = vec4(b, b, b, 1.0);
}
