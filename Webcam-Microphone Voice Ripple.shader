/*
 * Webcam-Microphone Voice Ripple by Ben Wheatley - 2018
 * License MIT License
 * Contact: github.com/BenWheatley
 */


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime;
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 pixelSize = vec2(1,1) / iResolution.xy;
    
    vec2 fromMid = uv - vec2(0.5, 0.5);
    float dFromMid = sqrt(fromMid.x*fromMid.x + fromMid.y*fromMid.y);
    
    float sound = texture(iChannel1, vec2(0, 1.0)).x;
    sound -= 0.25;
    
    vec2 delta = fromMid * -0.5*sound*(1.0+sin(90.0*dFromMid-15.0*iTime));
    
    vec3 col = texture(iChannel0, uv+delta).rgb; 
    
   	
    fragColor = vec4(col,1.);
}
