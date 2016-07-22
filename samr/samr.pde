/**
 * samr.pde
 *   Sketches a picture of SamR
 */

// General approach
// * We keep track of the frame number (global variable `frame`).
// * The `draw` method decides what part of the face to draw based on the
//   frame number.
//     * To "simplify" things, we have a separate variable, `step`, which keeps
//       track of where in the current face-part we are.  So, while `frame` varies
//       from 0 to some large number, `step` is supposed to vary from 0 to the number
//       of frames for that particular face part.
//     * To animate a line, we break it up into shorter segments and draw one per
//       frame.
//     * To animate an ellipse (or arc), we break it up into shorter segments and
//       draw one per frame.
//     * The curly parts (hair and beard) are hand-written Bezier curves.  I should
//       probably find a way to simplify them.
// * Some constants affect how many steps we allow for the various segments.

// Constants

final int EYE_STEPS = 20; 
final float EYE_INCREMENT = 2*PI/EYE_STEPS;

final int SMILE_STEPS = 20;
final float SMILE_START = -PI/32;
final float SMILE_INCREMENT = 7.0/8*PI/SMILE_STEPS;

final int LINE_STEPS = 20;

final int CURVE_PAUSE = 3;

final int[][] HAIR_SEGMENTS = {
  {60, 75, 30, 75, 35, 40, 60, 55}, 
  {60, 55, 75, 64, 60, 75, 55, 50}, 
  {55, 50, 50, 25, 105, 30, 95, 55}, 
  {95, 55, 87, 75, 70, 80, 80, 60}, 
  {80, 60, 86, 48, 120, 35, 110, 60}, 
  {110, 60, 100, 85, 60, 30, 110, 30}, 
  {110, 30, 130, 30, 150, 70, 125, 60}, 
  {125, 60, 100, 50, 100, 30, 120, 30}, 
  {120, 30, 170, 30, 160, 90, 135, 70}, 
};
final int HAIR_STEPS = CURVE_PAUSE*HAIR_SEGMENTS.length;

final int[][] BEARD_SEGMENTS = {
  {145, 155, 150, 145, 180, 220, 150, 180}, 
  {150, 180, 135, 160, 170, 150, 160, 190}, 
  {160, 190, 155, 210, 145, 220, 125, 200}, 
  {125, 200, 115, 190, 140, 190, 130, 200}, 
  {130, 200, 125, 205, 70, 230, 80, 205}, 
  {80, 205, 84, 195, 120, 200, 100, 205}, 
  {100, 205, 90, 210, 20, 190, 60, 185}, 
  {60, 185, 68, 183, 100, 200, 70, 195}, 
  {70, 195, 40, 190, 30, 130, 50, 160}, 
  {50, 160, 70, 190, 30, 130, 60, 140}, 
  {60, 140, 90, 150, 100, 180, 80, 170}, 
  {80, 170, 70, 165, 80, 130, 100, 150}, 
  {100, 150, 120, 170, 90, 200, 100, 170}, 
  {100, 170, 110, 140, 140, 155, 130, 165}, 
  {130, 165, 110, 185, 155, 110, 145, 155}
};
final int BEARD_STEPS = CURVE_PAUSE*BEARD_SEGMENTS.length;

// Globals
int frame = 0;

void setup() {
  size(200, 250);
  background(255);
  noFill();
  stroke(0);
  strokeWeight(3);
}

void draw() {
  int step = frame;
  frame++;
  strokeWeight(5);

  // Left lens
  if (step < EYE_STEPS) {
    arc(75, 100, 43, 41, step*EYE_INCREMENT, (step+1)*EYE_INCREMENT);
    return;
  }
  step -= EYE_STEPS;

  // Right lens
  if (step < EYE_STEPS) {
    arc(125, 100, 39, 41, step*EYE_INCREMENT, (step+1)*EYE_INCREMENT);
    return;
  }
  step -= EYE_STEPS;


  // Bridge
  if (step < LINE_STEPS) {
    partialLine(step, LINE_STEPS, 95, 100, 105, 100);
    return;
  }
  step -= LINE_STEPS;

  // Left temple
  if (step < LINE_STEPS) {
    partialLine(step, LINE_STEPS, 55, 93, 35, 80);
    return;
  }
  step -= LINE_STEPS;

  // Right temple
  if (step < LINE_STEPS) {
    partialLine(step, LINE_STEPS, 145, 94, 165, 77);
    return;
  }
  step -= LINE_STEPS;

  // Smile
  if (step < SMILE_STEPS) {
    strokeWeight(5);
    arc(100, 140, 80, 60, SMILE_START+step*SMILE_INCREMENT, SMILE_START+(step+1)*SMILE_INCREMENT);
    return;
  }
  step -= SMILE_STEPS;

  // Hair
  if (step < HAIR_STEPS) {
    strokeWeight(3);
    if (step % CURVE_PAUSE == 0) {
      int[] vals = HAIR_SEGMENTS[step / CURVE_PAUSE];
      bezier(vals[0], vals[1], vals[2], vals[3], vals[4], vals[5], vals[6], vals[7]);
    }
    return;
  }
  step -= HAIR_STEPS;

  // Beard
  if (step < BEARD_STEPS) {
    strokeWeight(2);
    if (step % CURVE_PAUSE == 0) {
      int[] vals = BEARD_SEGMENTS[step / CURVE_PAUSE];
      int x1 = vals[0];
      int y1 = vals[1];
      int cx1 = vals[2];
      int cy1 = vals[3];
      int cx2 = vals[4];
      int cy2 = vals[5];
      int x2 = vals[6];
      int y2 = vals[7];
      
      // Sam moved the smile after drawing the Beard.  This fixes things.
      cy1 -= 20;
      cy2 -= 20;
      y1 -= 20;
      y2 -= 20;

      // Sam drew the bottom of the beard too close.  THis fixes things.
      if (y1 >= 170) {
        y1 += 5;
        cy1 += 5;
      }
      if (y2 >= 170) {
        y2 += 5;
        cy2 += 5;
      }
      bezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2);
    }
    return;
  }
  step -= BEARD_STEPS;

  // Left eye
  if (step < EYE_STEPS) {
    strokeWeight(3);
    arc(77, 102, 3, 5, step*EYE_INCREMENT, (step+1)*EYE_INCREMENT);
    return;
  }
  step -= EYE_STEPS;

  // Right eye
  if (step < EYE_STEPS) {
    strokeWeight(3);
    arc(120, 101, 3, 6, step*EYE_INCREMENT, (step+1)*EYE_INCREMENT);
    return;
  }
  step -= EYE_STEPS;
  
  // Save
  if (step == 0) {
    save("samr.png");
  }
} // draw

void partialLine(int step, int steps, float startx, float starty, float endx, float endy)
{
  float deltax = (endx-startx)/steps;
  float deltay = (endy-starty)/steps;
  line(startx + step*deltax, starty + step*deltay, 
    startx + (step+1)*deltax, starty + (step+1)*deltay);
} // partialLine