/*
 * "Hyperspace" by Ben Wheatley - 2025
 * License MIT License
 * Contact: github.com/BenWheatley
 */

precision highp float;
precision highp int;

// constants
const int MAX_OCTAVE = 8;
const float NOISE_GRID_SIZE = 64.0;
const float PI = 3.14159265359;
const float centerToCorner = sqrt((0.5*0.5) + (0.5*0.5));
const float tangentScale = PI / (2.0*centerToCorner);

float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float interpolate(float a, float b, float x) {
    return mix(a, b, fade(x));
}

float seededRandom(float seed) {
    return fract(sin(seed) * 43758.5453123);
}

// The magic constants are essentially arbitary:
// they define the scale of the largest component of the Perlin noise
float perlinNoise(float perlinTheta, float r, float time) {
    float sum = 0.0;
    for (int octave=0; octave<MAX_OCTAVE; ++octave) {
        float sf = exp2(float(octave - 1));
        float sf8 = sf * NOISE_GRID_SIZE;
        
        float new_theta = sf*perlinTheta;
        float new_r = sf*r/4.0 + time;
        
        float new_theta_floor = floor(new_theta);
        float new_r_floor = floor(new_r);
        float fraction_r = new_r - new_r_floor;
        float fraction_theta = new_theta - new_theta_floor;
        
        float t1 = seededRandom( new_theta_floor + sf8 *  new_r_floor      );
        float t2 = seededRandom( new_theta_floor + sf8 * (new_r_floor+1.0) );
        
        new_theta_floor += 1.0;
        float maxVal = sf*2.0;
        if (new_theta_floor >= maxVal) {
            new_theta_floor -= maxVal;
        }
        
        float t3 = seededRandom( new_theta_floor + sf8 *  new_r_floor      );
        float t4 = seededRandom( new_theta_floor + sf8 * (new_r_floor+1.0) );
        
        float i1 = interpolate(t1, t2, fraction_r);
        float i2 = interpolate(t3, t4, fraction_r);
        
        sum += interpolate(i1, i2, fraction_theta) / sf;
    }
    return 2.0*sum;
}

// main
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 aspectCorrectedUV = (fragCoord.xy / iResolution.xy - 0.5) * vec2(1.0, iResolution.y / iResolution.x);
    
    float dx = -aspectCorrectedUV.x;
    float dy = -aspectCorrectedUV.y;
    
    float perlinTheta = (PI + atan(dy, -dx)) / PI;
    
    float r = centerToCorner - length(vec2(dx, dy));
    r = tan(tangentScale * r);
    
    float c = perlinNoise(perlinTheta, r, iTime)/8.0;
    c -= 0.3;
    c *= 2.0;
    
    fragColor = vec4(c, 0, 0, 0);
}