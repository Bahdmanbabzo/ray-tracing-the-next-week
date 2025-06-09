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
    let image_height = image_width / aspect_ratio;
    image_height = max(image_height, 1.0);

    //Viewport dimensions
    let viewport_height = 2.0; 
    let viewport_width = viewport_height * (image_width / image_height)
}