/*
 * A simple force generator for wind.
 * Wind will only affect particles in the horizontal axis - which is quite a large simplification,
 * but accurately modelling the wind interacting with the surroundings to produce force in anything 
 * other than just the horizontal would be very complex
 */
class Wind extends ForceGenerator {
  
  private PVector wind; // Gravity vector. 
  
  Wind(PVector wind) {
    if(wind.y > 0) wind.y = 0; // Wind only operates in the horizontal axis.
    this.wind = wind;
  }
  
  /*
   * Set the wind vector to a user defined value.
   */
  void setWind(PVector wind) {
    if(wind.y > 0) wind.y = 0;
    this.wind = wind;
  }
  
  /*
   * Set the wind vector to a new random value.
   */
  void randomWind() {
    this.wind = new PVector(random(-.009f, .009f), 0f);
  }
  
  /*
   * Return a human friendly read out of the wind.
   */
  String toString() {
    return wind.x < 0 ? (int)((-wind.x)*1000)+" mph"+" <--" : (int)((wind.x)*1000)+" mph"+" -->";
  }
  
  void updateForce(Particle p) {
    // Check for infinite mass, if so don't apply force.
    if(p.getInvMass() <= 0f) return;
    
    // f = ma, so use getMass function to multiply g by mass.
    PVector resF = wind.get();
    resF.mult(p.getMass());
    p.addForce(resF); // Update p's forces.
  }
}