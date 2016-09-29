/*
 * There are several ways that blocks could be implemented.
 * 
 * They could be stored as a group of 4 particles which represent the 4 corners,
 * that are joined together by ROD constraints. However this is quite complicated 
 * and requires a lot of calculations to make sure the blocks stay together using 
 * the force generators for rods.
 *
 * Instead a block will be a subclass of Particle.
 * The block will be represented by a particle in the TOP LEFT corner of the area,
 * and the block's height and width will be stored in the class.
 *
 */
class Block extends Particle {
  public int height, width; // Public for easy access.
  
  Block(PVector pos, int w, int h, float iMass) {
    super(pos, new PVector(0,0), iMass);
    this.width = w;
    this.height = h;
  }
}
  