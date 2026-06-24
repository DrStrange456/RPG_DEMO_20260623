shader_type canvas_item;

uniform vec2 streak_dir = vec2(1.0, 0.0); // normalized direction of streak
uniform float streak_length = 0.12;       // how far the streak extends (in UV units)
uniform float streak_strength = 0.6;      // brightness of streak

const int SAMPLES = 6; // number of extra texture samples

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    if (base.a < 0.01) {
        COLOR = base;
    } else {
        vec4 accum = base;
        float total_weight = 1.0;

        for (int i = 1; i <= SAMPLES; i++) {
            float t = float(i) / float(SAMPLES);
            vec2 offset = streak_dir * streak_length * t;
            vec4 samp = texture(TEXTURE, UV - offset);
            float weight = 1.0 - t; // fade out later samples
            accum += samp * weight;
            total_weight += weight;
        }

        accum /= total_weight;

        // brighten
        vec3 boosted = accum.rgb * (1.0 + streak_strength);
        vec3 final_rgb = mix(base.rgb, boosted, streak_strength);

        float final_a = max(base.a, accum.a);

        COLOR = vec4(final_rgb, final_a);
    }
}
