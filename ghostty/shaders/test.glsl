void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 color = texture(iChannel0, uv).rgb;
    // Simple red tint - should be very obvious
    fragColor = vec4(color.r * 1.5, color.g * 0.5, color.b * 0.5, 1.0);
}
