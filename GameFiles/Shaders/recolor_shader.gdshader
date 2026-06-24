shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Preserve transparency
    float alpha = tex_color.a;

    // Multiply the base pixel brightness by the selected color
    float brightness = tex_color.r; // works best if spritesheet is grayscale
    vec3 tinted = target_color.rgb * brightness;

    COLOR = vec4(tinted, alpha);
}
