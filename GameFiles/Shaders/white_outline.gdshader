shader_type canvas_item;

uniform bool hovered = false;
uniform float outline_size = 1.5; // in pixels
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 out_color = tex_color; // default output

    if (hovered) {
        float alpha = tex_color.a;
        float threshold = 0.1; // alpha threshold to consider transparent
        vec2 texel = 1.0 / vec2(textureSize(TEXTURE, 0)); // size of one texel

        if (alpha < threshold) {
            bool edge = false;
            // sample neighbors; no 'return' — set flags and break loops
            for (int x = -1; x <= 1; x++) {
                for (int y = -1; y <= 1; y++) {
                    if (x == 0 && y == 0) { continue; }
                    vec2 offset = vec2(float(x), float(y)) * outline_size * texel;
                    float n_alpha = texture(TEXTURE, UV + offset).a;
                    if (n_alpha > threshold) {
                        edge = true;
                        break;
                    }
                }
                if (edge) { break; }
            }

            if (edge) {
                out_color = outline_color;
            } else {
                // remain transparent (no visible pixel)
                discard;
            }
        }
    }

    COLOR = out_color;
}
