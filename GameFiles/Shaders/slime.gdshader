shader_type canvas_item;

uniform bool hovered = false;
uniform float outline_size = 1.5;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // When not hovered, render normally
    if (!hovered) {
        COLOR = tex_color;
        discard;
    }

    // Check neighboring pixels for transparency to find edges
    float alpha = tex_color.a;
    if (alpha < 0.1) {
        // Sample in 8 directions to detect outline edges
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                if (x == 0 && y == 0) continue;
                vec2 offset = vec2(float(x), float(y)) * outline_size / vec2(textureSize(TEXTURE, 0));
                float neighbor_alpha = texture(TEXTURE, UV + offset).a;
                if (neighbor_alpha > 0.1) {
                    COLOR = outline_color;
                    discard;
                }
            }
        }
        discard;
    }

    COLOR = tex_color;
}
