/*
 * Webcam 'Newsprint' effect by Ben Wheatley - 2018
 * License MIT License
 * Contact: github.com/BenWheatley
 */

const float ROOT_3 = sqrt(3.);
const float BLOCK = 75.;
const vec2 OFFSET = vec2(0.5/BLOCK, 0.5/BLOCK);
const vec3 PAPER = vec3(250.0, 242.0, 228.0)/256.0;

float avgGrey(vec2 uv, out vec2 begin, out vec2 end) {
    vec2 scaled_uv = uv*BLOCK;
    begin = floor(scaled_uv)/BLOCK;
    end = ceil(scaled_uv)/BLOCK;
    
    return length(texture(iChannel0, begin).rgb) / ROOT_3;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime;
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 pixelSize = vec2(1,1) / iResolution.xy;
    
    vec2 begin, end;
    float grey = pow(avgGrey(uv, begin, end), 0.66);
    
    grey = 1.0-grey;
    
    grey = BLOCK*distance(uv, begin+OFFSET)>grey? 1.0: 0.0;
    
    fragColor = vec4(PAPER*grey, 1.);
}
