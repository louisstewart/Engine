public final class UserForce extends ForceGenerator {
  
  PVector force ;
  
  // Make the Force
  UserForce(PVector force) {
    this.force = force ;
  }

  // Allow the user to set this force
  void set(float x) {
    force.x = x ;
    force.y = 0 ; 
  }

  // Applies the user force to the given particle
  void updateForce(Particle particle) {
    particle.addForce(force) ;
  }
}