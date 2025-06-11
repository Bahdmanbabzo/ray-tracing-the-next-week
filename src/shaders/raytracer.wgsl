struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) color: vec4f,
};
@group(0) @binding(0) var<uniform> canvas_size: vec2f; 
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

fn hit_sphere(sphere_center: vec3f, radius: f32, ray_origin: vec3f, ray_direction: vec3f) -> f32 {
    let oc = sphere_center - ray_origin; 
    let a = dot(ray_direction, ray_direction);
    let b = -2.0 * dot(oc, ray_direction);
    let c = dot(oc, oc) - radius * radius;
    let discriminant = b * b - 4.0 * a * c;

    if (discriminant < 0.0) {
        return -1.0; // No intersection
    } else {
        return (-b - sqrt(discriminant)) / (2.0 * a); // Return the nearest intersection point
    }; 

}

fn ray_color(ray_direction: vec3f, ray_origin: vec3f) -> vec3f {

    let t = hit_sphere(vec3f(0.0, 0.0, -1.0), 0.5, ray_origin, ray_direction);
    if (t > 0.0) {
        let hit_point = ray_origin + t * ray_direction; 
        let normal = normalize( hit_point - vec3f(0.0, 0.0, -1.0));
        return 0.5 * (normal + vec3f(1.0, 1.0, 1.0)); // Simple shading based on normal
    }
    
    let a = 0.5 *(ray_direction.y + 1.0); 
    let white = vec3f(1.0, 1.0, 1.0); 
    let blue = vec3f(0.5, 0.7, 1.0); 

    return mix(white, blue, a); 
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4f {

    let aspect_ratio = canvas_size.x/ canvas_size.y;
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
    let ndc = (input.color.xy * 2.0) - 1.0;

    // Map to viewport coordinates
    let viewport_x = ndc.x * (viewport_width * 0.5 );
    let viewport_y = ndc.y * (viewport_height * 0.5 );

    // Calculate ray direction
    let ray_direction = normalize(vec3f(viewport_x, viewport_y, -focal_length));
    let pixel_color = ray_color(ray_direction, camera_position); 
    return vec4f(pixel_color, 1.0); 

}