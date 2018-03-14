const float PI = 3.14159265359;
const int MIN_OCTAVE = 1;
const int MAX_OCTAVE = 8;

// Perlin noise functions

float cosineInterpolate(float a, float b, float x) {
	float ft = x * PI;
	float f = (1.0 - cos(ft)) * 0.5;
	
	return a*(1.0-f) + b*f;
}

float seededRandom(float seed) {
    int x = int(seed);
    x = x << 13 ^ x;
    x = (x * (x * x * 15731 + 789221) + 1376312589);
    x = x & 0x7fffffff;
    return float(x)/1073741824.0;
}

// The magic constants are essentially arbitary:
// they define the scale of the largest component of the Perlin noise
float perlinNoise(float time) {
    float sum = 0.0;
    for (int octave=MIN_OCTAVE; octave<MAX_OCTAVE; ++octave) {
        float sf = pow(2.0, float(octave));
        
		float new_t = sf*time*16.0;
        
        float new_t_floor = floor(new_t);
		float fraction_t = new_t - new_t_floor;
        
        float t1 = seededRandom( sf *  new_t_floor      );
		float t2 = seededRandom( sf * (new_t_floor+1.0) );
        
        float i1 = cosineInterpolate(t1, t2, fraction_t);
		
        sum += i1/sf;
    }
    return sum/2.0;
}

// Basic sound functions

float sinWave(float pitch, float time) {
    return sin( (2.0*PI*pitch) * time);
}

float simpleHarmonics(float primePitch, float regularPowerDivision, int numberOfDivisions, float time) {
    float sum = 0.0;
    for (int i=0; i<numberOfDivisions; ++i) {
        sum += sinWave(primePitch * pow(2.0, float(i)), time) * pow(regularPowerDivision, float(i));
    }
    return sum;
}

float squareWave(float pitch, float time) {
    if (sinWave(pitch, time)>0.0) {
        return 1.0;
    }
    return -1.0;
}

// Misc functions

float logBase(float base, float x) {
    return log(x)/log(base);
}

float quantizePitch(float pitch) {
    return pow(0.943874, floor(logBase(0.943874, pitch)));
    return pitch;
}

float frequencyFromMIDINoteNumber(int p) {
    return 440.0 * pow(2.0, float(p-69)/12.0);
}

int MIDINumberFromBlackNote(int i) {
    int octave = i/5;
    int offset = i - (octave*5);
    
    switch (offset) {
    case 0: offset = 1; break;
    case 1: offset = 3; break;
    case 2: offset = 6; break;
    case 3: offset = 8; break;
    case 4: offset = 10; break;
    }
    
    return (octave*12) + offset;
}

// Main function

vec2 mainSound(float t) {
    float fast_t = 3.0*t;
    float qt = floor(fast_t);
    float emphasis = 1.0;
    if (mod(qt, 4.0)>=0.5) {
       emphasis = 0.5; 
    }
    
    vec2 o = vec2(0, 0);
    
    const float harmonies = 4.0;
        
    for (float i=0.0; i<harmonies; i+=1.0) {
        float harmony_offset = i*2.0;
        int blackNoteNumber = int(20.0 + 10.0*perlinNoise(qt+harmony_offset) + i);
        float f = frequencyFromMIDINoteNumber( MIDINumberFromBlackNote(blackNoteNumber) );

        float qf = quantizePitch(f);
        float a = 1.0-(fast_t-qt);

        float voltage = a*simpleHarmonics(f, 0.33, 8, t);
        voltage *= emphasis;
        float position = perlinNoise(100.0+t*2.0);
        o += vec2( voltage*position, voltage*(1.0-position) );
    }
    
    return o/harmonies;
    
    /* Examples:
    	random MIDI note:
    float f = frequencyFromMIDINoteNumber(int(36.0 + 24.0*perlinNoise(qt)));
    	Wave generators:
    return vec2( sinWave(f, t), sinWave(f, -t) );
    return vec2( simpleHarmonics(440.0, 0.5, 8, t)*exp(-t) );
    return vec2( squareWave(440.0, t)*exp(-t) );
	*/
}
