shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 col = vec4((vec3(1.0) - round(textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0).xyz)), 1.0);
    COLOR = col * textureLod(TEXTURE, UV, 0.0);
}