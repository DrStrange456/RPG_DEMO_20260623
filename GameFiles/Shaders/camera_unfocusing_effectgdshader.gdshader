// FADE AND DESATURATE - LIKE

shader_type canvas_item;

uniform float fade : hint_range(0.0, 1.0) = 0.7; // How much to fade background
uniform float desaturate : hint_range(0.0, 1.0) = 0.8;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec3 desat(vec3 color, float amt) {
    float g = dot(color, vec3(0.299, 0.587, 0.114)); // luminance
    return mix(color, vec3(g), amt);
}

void fragment() {
    vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);

    // desaturate
    bg.rgb = desat(bg.rgb, desaturate);

    // fade toward a light panel color
    vec4 target = vec4(0.85, 0.85, 0.85, 1.0);

    COLOR = mix(bg, target, fade);
}



