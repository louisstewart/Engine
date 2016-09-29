/*
 * This class is for representing planes in 2D - a.k.a. lines
 * This is useful for simulating the ground in the game, 
 * without having to hardcode in some value for the ground in the particles.
 */
final class Plane extends Particle {
  PVector normal; // Normal vector to plane - vector which is perpendicular to it.
  PVector cnorm; // The contact normal for an object interacting with this line (2D plane) - public easy access
  PVector n; // Vector representation of this line.
  int x1, y1, x2, y2;
  
  /*
   * Construct the plane object, using the 2 vectors representing either end of the line.
   * 
   * The vectors representing the ends are passed in to the constructor as cartesian points
   * instead of as PVectors.
   */
  Plane(int x1, int y1, int x2, int y2) {
    super( new PVector(x2-x1, y2-y1), new PVector(0,0), 0);
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.n = new PVector(x2-x1, y2-y1);
    this.normal = n.copy().rotate(-HALF_PI).normalize();
    cnorm = n.copy().rotate(HALF_PI).normalize(); // Calculate the contact normal.
  }
  
  PVector getNormal() {
    return this.normal;
  }
  
  /*
   * Project a vector onto the normal of this plane.
   *
   * This calculates the distance between the point vector and the line, so is useful for
   * collision detection between a particle and a point.
   */
  int projectOntoNormal(PVector p) {
    return int(normal.dot(p));
  }
  
}