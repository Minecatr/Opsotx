shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec3 screen_pixel = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0).xyz;
    float screen_brightness = (screen_pixel.r + screen_pixel.g + screen_pixel.b) / 3.0;
    vec3 a1 = vec3(screen_brightness, screen_brightness, screen_brightness);
    vec4 col = vec4((vec3(1.0) - round(a1)), 1.0);
     COLOR = col * textureLod(TEXTURE, UV, 0.0);
}