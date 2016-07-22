// Global constants
int WIDTH;
int HEIGHT;
final int RADIUS = 15;
final int DELTA = 2;
int HISTORY = 30;
int MAX_PEOPLE = 23;
boolean active = true;
boolean trace = false;
boolean hidden = false;
boolean crazy = false;
int rate = 32;
int rainbowPeople = 1;

// Global variables
Person[] people = new Person[MAX_PEOPLE];

void reset() {
  active = true;
  trace = false;
  hidden = false;
  crazy = false;
  MAX_PEOPLE = 23;
  people = new Person[MAX_PEOPLE];
  setup0();
  active = true;
}

// Set up the world
void setup() {
  size(720, 400);
  WIDTH = 720;
  HEIGHT = 400;
  frameRate(rate);
  reset();
  active = true;
  colorMode(HSB, 360, 100, 100, 100);
}

void draw() {
  if (active) {
    if (! trace) {
      background();
    }
    checkCollisions();
    for (int i = 0; i < MAX_PEOPLE; i++) {
      people[i].update();
    } // for
    int displayPeople = MAX_PEOPLE;
    if (hidden) { 
      displayPeople = rainbowPeople;
    }
    for (int i = 0; i < displayPeople; i++) {
      people[i].display();
    }
  }
}

void keyPressed() {
  switch (key) {
  case 'r':
    reset();
    break;
  case 'c':
    crazy = !crazy;
    break;
  case ' ':
    active = !active;
    break;
  case '>':
    for (int i = 0; i < rainbowPeople; i++) {
      people[i].xspeed += 1;
    }
    break;
  case '<':
    for (int i = 0; i < rainbowPeople; i++) {
      people[i].xspeed -= 1;
    }
    break;
  case 't':
    background();
    trace = !trace;
    break;
  case '0':
    setup0();
    break;
  case '1':
    setup1();
    break;
  case 'h':
    hidden = !hidden;
    break;
  case '+':
    MAX_PEOPLE += 2;
    Person[] newPeople = new Person[MAX_PEOPLE];
    for (int i = 0; i < MAX_PEOPLE-2; i++) {
      newPeople[i] = people[i];
    }
    newPeople[MAX_PEOPLE - 2] = greyPerson();
    newPeople[MAX_PEOPLE - 1] = greyPerson();
    people = newPeople;
    break;
  case '-':
    MAX_PEOPLE -= 2;
    Person[] oldPeople = new Person[MAX_PEOPLE];
    for (int i = 0; i < MAX_PEOPLE; i++) {
      oldPeople[i] = people[i];
    }
    people = oldPeople;
    break;
  }
}

// Classes
class Person {
  // Fields
  float x;
  float y;
  float[] xhistory = new float[HISTORY];
  float[] yhistory = new float[HISTORY];
  float xprev;
  float yprev;
  float xspeed;
  float yspeed;
  float hue;
  float saturation;
  float value;

  // Constructor
  Person(float _hue, float _saturation, float _value, 
    float _x, float _y, float _xspeed, float _yspeed) {
    hue = _hue;
    saturation = _saturation;
    value = _value;
    x = _x;
    y = _y;
    xprev = x;
    yprev = y;
    yspeed = _xspeed;
    xspeed = _yspeed;
    for (int i = 0; i < HISTORY; i++) {
      xhistory[i] = x;
      yhistory[i] = y;
    } // for
  } // Person

  int bound(int val) 
  {
    if (val < 0)
      return 0;
    else if (val > 255)
      return 255;
    else
      return val;
  } // bound

  // Show the person
  void display() {
    if (trace) {
      stroke(hue, saturation, value, 100);
      line(xprev, yprev, x, y);
    } else {
      stroke(0, 0, 0, 0);
      for (int i = 0; i < HISTORY; i++) {
        displayAt(xhistory[i], yhistory[i], 50.0*i*i/((HISTORY-1)*(HISTORY-1)));
      }
      stroke(0, 0, 100, 100);
      displayAt(x, y, 100);
    }
  } // display

  void displayAt(float xpos, float ypos, float opacity) {
    fill(hue, saturation, value, opacity);
    ellipse(xpos, ypos, 2*RADIUS, 2*RADIUS);
    if (xpos > WIDTH-RADIUS) {
      ellipse(xpos-WIDTH, ypos, 2*RADIUS, 2*RADIUS);
    }
    if (x < RADIUS) {
      ellipse(xpos+WIDTH, ypos, 2*RADIUS, 2*RADIUS);
    }
  } // displayAt

  // Update the position of the person
  void update() {
    // Update the position
    xprev = x;
    yprev = y;
    x += xspeed;
    y += yspeed;
    // Update the history
    for (int i = 1; i < HISTORY; i++) {
      xhistory[i-1] = xhistory[i];
      yhistory[i-1] = yhistory[i];
    } // for
    xhistory[HISTORY-1] = x;
    yhistory[HISTORY-1] = y;
    // Bounce at the floor and ceiling
    if (y+RADIUS >= HEIGHT) {
      yspeed = -abs(yspeed);
    }
    if (y-RADIUS < 0) {
      yspeed = abs(yspeed);
    }
    // Wrap at the left and right margins
    while (x > WIDTH) {
      x -= WIDTH;
    }
    while (x < 0) {
      x += WIDTH;
    }
  }

  float distance(Person other) {
    float deltax = distanceX(other);
    float deltay = distanceY(other);

    return sqrt(deltax*deltax + deltay*deltay);
  }

  float angleTo(Person other) {
    return computeAngle(distanceX(other), distanceY(other));
  }

  float distanceX(Person other) {    
    if ((x < RADIUS) && (other.x > WIDTH-RADIUS-x)) {
      return x - (other.x - WIDTH);
    } else if ((other.x < RADIUS) && (x > WIDTH-RADIUS-other.x)) {
      return x - (other.x + WIDTH);
    } else {
      return x - other.x;
    }
  }

  float distanceY(Person other) {
    return y - other.y;
  }
}

// Functions

void setup0() {
  rainbowPeople = min(MAX_PEOPLE, WIDTH/(2*RADIUS)-1);
  float angle = 360.0/rainbowPeople;
  float offset = WIDTH/rainbowPeople;
  float halfOffset = offset/2;

  for (int i = 0; i < rainbowPeople; i++) {
    people[i] = new Person(angle*i, 100, 100, halfOffset + i*offset, HEIGHT/2, 4, 0);
  } // for
  for (int i = rainbowPeople; i < MAX_PEOPLE; i++) {
    people[i] = greyPerson();
  } // for
  finishSetup();
} // setup0

void setup1() {
  finishSetup();
}

Person greyPerson() {
  return new Person(0, 0, 50, random(WIDTH), random(HEIGHT), 
    4-random(9), 4-random(9));
}

void finishSetup() {
  fix_overlaps();
  background();
  active = true;
  draw();
  active = false;
}

void background() {
  background(0, 0, 100);
}

void fix_overlaps() {
  for (int i = 0; i < MAX_PEOPLE; i++) {
    for (int j = i+1; j < MAX_PEOPLE; j++) {
      Person a = people[i];
      Person b = people[j];
      // See if they collide
      if (a.distance(b) < 2*RADIUS) {
        separate(a, b);
        i = 0;
        j = 0;
      } // if
    } // for j
  } // for i
} // fix_overlaps

void separate(Person a, Person b) {  
  float angle = a.angleTo(b);
  float xcenter; 
  float ycenter;
  if (crazy) {
    xcenter = a.x + a.distanceX(b)/2;
    ycenter = a.y + a.distanceY(b)/2;
  } else {
    xcenter = a.x - a.distanceX(b)/2;
    ycenter = a.y - a.distanceY(b)/2;
  }
  if (a.distanceX(b) > 0) {
    angle += PI;
  }
  a.x = xcenter - (RADIUS+1)*cos(angle);
  a.y = ycenter - (RADIUS+1)*sin(angle);
  b.x = xcenter + (RADIUS+1)*cos(angle);
  b.y = ycenter + (RADIUS+1)*sin(angle);
  if (a.x == b.x) {
    if (int(random(2)) == 0) {
      ++a.x;
    } else {
      ++b.x;
    }
  } // if the x values are the same
} // separate

// Check for collisions and update
void checkCollisions() {
  for (int i = 0; i < MAX_PEOPLE; i++) {
    for (int j = i+1; j < MAX_PEOPLE; j++) {
      Person a = people[i];
      Person b = people[j];
      // See if they collide
      float distance = a.distance(b);
      if (distance < 2*RADIUS) {
        separate(a, b);
      } // If they collide
    } // for
  } // for
} // checkCollisions

// Compute the angle from (0,0) to (x,y)
float computeAngle(float x, float y) {
  if (x == 0) {
    if (y < 0)
      return PI/2;
    else
      return 3*PI/2;
  } else {
    return atan(y/x);
  }
} // computeAngle