struct VertexOutput {
    @builtin(position) position: vec4f,
};
@group(0) @binding(0) var<uniform> canvas_size: vec2f; 
@group(0) @binding(1) var<storage, read_write> random_number: array<f32,1>;

@vertex
fn vs_main(
    @location(0) position: vec2f,
) -> VertexOutput {
    var output: VertexOutput;
    // Transform the position to clip space
    output.position = vec4f(position, 0.0, 1.0);
    return output;
};

fn is_front_facing(ray_direction: vec3f, normal: vec3f) -> bool {
    return dot(ray_direction, normal) > 0.0; 
};
// https://dekoolecentrale.nl/wgsl-fns/rand11Sin
// Generates a random float
fn rand11(n: f32) -> f32 { 
    return fract(sin(n) * 43758.5453123); 
};
// Generates a random vec3 
fn randVec3(p:f32) -> vec3<f32> {
    return vec3<f32>(
        fract(sin(p * 12.9898) * 43758.5453),
        fract(sin(p * 78.233) * 24634.6345),
        fract(sin(p * 45.164) * 12345.6789)
    );
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

};

fn ray_color(ray_direction: vec3f, ray_origin: vec3f) -> vec3f {
    var hit_point: vec3f;
    var normal: vec3f;
    let sphere_count = 1; 
    let spheres = array<vec3f, 1>(
        vec3f(0.0, 0.0, -3.0)
    );
    var i = 0u;
    for(var i: i32; i < sphere_count; i++) {
        let t = hit_sphere(spheres[i], 1.0, ray_origin, ray_direction);
        if (t > 0.0) {
            hit_point = ray_origin + t * ray_direction; 
            normal = normalize(hit_point - spheres[i]);
            return 0.5 * (normal + vec3f(1.0, 1.0, 1.0) * random_number[0]); // Simple shading based on normal
        };
        
    };
    
    let a = 0.5 *(ray_direction.y + 1.0); 
    let white = vec3f(1.0, 1.0, 1.0); 
    let blue = vec3f(0.5, 0.7, 1.0); 

    return mix(white, blue, a); 
};

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4f {

    let aspect_ratio = canvas_size.x/ canvas_size.y;

    // Camera setup
    let fov = 30.0; 
    let focal_length = 1.0 / tan(radians(fov) * 0.5);
    let camera_position = vec3f(0.0, 0.0, 0.0);

    // Convert input.color.xy to screen space
    let pixel_coords = input.position.xy / canvas_size; 
    let ndc = pixel_coords * 2.0 - 1.0; 
    // Map to viewport coordinates
    let viewport_x = ndc.x * aspect_ratio; 
    let viewport_y = ndc.y ; 

    let n = ndc.x * 12.9898 + ndc.y * 78.233 + 0.1234;
    let rnd = rand11(n); 
    random_number[0] = rnd; 

    // Calculate ray direction
    let ray_direction = normalize(vec3f(viewport_x, viewport_y, -focal_length));
    let pixel_color = ray_color(ray_direction, camera_position); 
    return vec4f(pixel_color, 1.0); 

}