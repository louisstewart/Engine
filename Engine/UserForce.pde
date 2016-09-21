class UserForce extends ForceGenerator {
  private PVector force;
  
  UserForce(PVector force) {
    this.force = force;
  }
  
  void set(float x, float y) {
    force.x = x;
    force.y = y;
  }
  
  void updateForce(Particle p) {
    p.addForce(force);
  }
}