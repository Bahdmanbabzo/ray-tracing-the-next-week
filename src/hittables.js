export class Hittable {
    constructor(position, radius,material, albedo, fuzz) {
    this.position = position;
    this.radius = radius; 
    this.material = material; 
    this.albedo = albedo;
    this.fuzz = fuzz;
    }

    get arrayFormat() {
        return [
            ...this.position, 
            this.radius, 
            this.material,
            0.0, 0.0,
            ...this.albedo, 
            this.fuzz,
            0.0, 0.0, 0.0
        ];
    }
}

