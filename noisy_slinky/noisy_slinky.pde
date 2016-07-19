   // Initial values
    float startX = 40;  // The starting x value
    float startY = 50;  // The starting y value
    float startW = 20;  // The starting width
    float startH = 10;  // The starting height
    float startWeight = 1; // The "weight" of lines
    float startColor = 0;  // 0-255, 0 is black, 255 is white
    
    // Maximum values
    float maxWidth = 50;
    float maxHeight = 50;
    
    // How values might changes
    float deltaX = 22;
    float deltaY = 10;
    float deltaW = 1;
    float deltaH = 2;
    float deltaWeight = 0.3;
    float deltaColor = 1;

    // Values that change
    float x;            // The current x value
    float y;            // The current y value
    float w;            // The current width
    float h;            // The current height
    float weight;       // The current weight
    float lineColor;
    
    // Noise stuff
    float xnoise;
    float ynoise;
    
    void setup() {
      // Set the size of the window
      size(500,300);
      // Set the number of frames per second (ignore for now)
      frameRate(32);

      // Initialize x, y, w, and h
      x = startX;
      y = startY;
      w = startW;
      h = startH;
      weight = startWeight;
      lineColor = startColor;
      xnoise = random(0,1);
      ynoise = random(0,1);
    } // setup()

    void draw() {
      // Set the background
      // background(128);
      
      // Use a black, thin, pen
      stroke(lineColor);
      strokeWeight(weight);

      // Don't fill shapes
      fill(255, 100);

      // Whatever
      float wprime = maxWidth - abs(maxWidth - w);
      float hprime = maxHeight - abs(maxHeight - h);
      
      // Draw an ellipse
      ellipse(x,y,w,h);
      
      if (true) {
        x = x + deltaX*noise(xnoise);
        y = y + deltaY*noise(ynoise);
        w = w + deltaW*(0.5 - noise(xnoise));
        h = h + deltaH*(0.5 - noise(ynoise));
      }
      else {
       x = x + deltaX*random(0,1);
       y = y + deltaY*random(0,1);
       w = w + deltaW*(0.5 - random(0,1));
       h = h + deltaH*(0.5 - random(0,1));
      }
      
      x = x % 500;
      y = y % 300;
      w = w % (maxWidth*2);
      h = h % (maxHeight*2);
      
      xnoise += 0.2;
      ynoise += 0.1;
   } // draw()