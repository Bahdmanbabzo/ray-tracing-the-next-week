struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) color: vec4f,
};

@vertex
fn vs_main(
    @location(0) position: vec2f,
) -> VertexOutput {
    var output: VertexOutput;
    // Transform the position to clip space
    output.position = vec4f(position, 0.0, 1.0);
    output.color = vec4f((position + 1.0) * 0.5, 0.3, 1.0); // Pass color to fragment
    return output;
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4f {

    let aspect_ratio = 16.0 / 9.0;
    let image_width = 400.0; 

    //calculate image height and ensure it is at least one
    var image_height = image_width / aspect_ratio;
    image_height = max(image_height, 1.0);

    //Viewport dimensions
    let viewport_height = 2.0; 
    let viewport_width = viewport_height * (image_width / image_height); 

    // Camera setup
    let focal_length = 1.0;
    let camera_position = vec3f(0.0, 0.0, 0.0);

    // Convert input.color.xy to screen space
    let ndc = (input.color.xy * 2.0) - 1.0; // Convert to NDC (-1 to 1)

    // Map to viewport coordinates
    let viewport_x = ndc.x * (viewport_width * 0.5 );
    let viewport_y = ndc.y * (viewport_height * 0.5 );

    // Calculate ray direction
    let ray_direction = normalize(vec3f(viewport_x, viewport_y, -focal_length));
    let ray_color = ray_direction * 0.5 + 0.5; // Map to [0, 1] range for color
    return vec4f(ray_color, 1.0); 


}