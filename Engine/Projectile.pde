class Projectile extends Particle {
  public int radius; // Circular projectile fired from tank. Public so that access is snappy.
  
  Projectile(PVector pos, PVector vel, float inverse, int radius){
    super(pos, vel, inverse);
    this.radius = radius;
  }
}