export class Hittable {
    constructor(material, position, radius, albedo, fuzz) {
    this.material = material;
    this.position = position;
    this.radius = radius;
    this.albedo = albedo;
    this.fuzz = fuzz;
    }

    get arrayFormat() {
        return [
            ...this.position, 
            this.radius, 
            this.material,
            ...this.albedo, 
            this.fuzz
        ];
    }
}

