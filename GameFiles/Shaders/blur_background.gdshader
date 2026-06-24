shader_type canvas_item;

uniform float radius : hint_range(0.0, 30.0) = 12.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    float r = radius / 1000.0;

    // Gaussian weights (5-tap symmetrical)
    float w0 = 0.227027;
    float w1 = 0.316216;
    float w2 = 0.070270;

    vec4 sum = texture(SCREEN_TEXTURE, uv) * w0;

    sum += texture(SCREEN_TEXTURE, uv + vec2( r, 0.0)) * w1;
    sum += texture(SCREEN_TEXTURE, uv - vec2( r, 0.0)) * w1;

    sum += texture(SCREEN_TEXTURE, uv + vec2(2.0*r, 0.0)) * w2;
    sum += texture(SCREEN_TEXTURE, uv - vec2(2.0*r, 0.0)) * w2;

    COLOR = sum;
}
