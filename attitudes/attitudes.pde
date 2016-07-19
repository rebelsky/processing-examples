// Global constants
int WIDTH;
int HEIGHT;
final int RADIUS = 15;
final int MAX_PEOPLE = 20;
final int DELTA = 2;
boolean active = true;
boolean trace = false;
int rate = 32;

// Global variables
Person[] people = new Person[MAX_PEOPLE];

// Set up the world
void setup() {
  size(700, 400);
  WIDTH = 700;
  HEIGHT = 400;
  frameRate(rate);
  background(255);
  biased_setup();
  active = true;
}

void draw() {
  if (active) {
    if (! trace) {
      background(255);
    }
    check_collisions();
    for (int i = 0; i < MAX_PEOPLE; i++) {
      people[i].update();
      people[i].display();
    } // for
  }
}

void keyPressed()
{
  switch (key) {
  case 'b':
    biased_setup();
    break;
  case 'u':
    unbiased_setup();
    break;
  case 's':
    active = false;
    break;
  case 'g':
    active = true;
    break;
  case ' ':
    active = !active;
    break;
  case '>':
    rate += 4;
    frameRate(rate);
    break;
  case '<':
    rate -= 4;
    frameRate(rate);
    break;
  case 'r':
    rate = 32;
    frameRate(rate);
    break;
  case 't':
    background(255);
    trace = !trace;
    break;
  case '0':
    setup_0();
    break;
  }
}

// Classes
class Person {
  // Fields
  float x;
  float y;
  float xprev;
  float yprev;
  float xspeed;
  float yspeed;
  int red;   // How red the person is

  // Constructor
  Person(float _x, float _y, int _red) {
    x = _x;
    y = _y;
    xprev = x;
    yprev = y;
    red = _red;
    yspeed = random(9) - 4;
    xspeed = random(9) - 4;
  } // Person

  // Show the person
  void display() {
    if (red < 0) { 
      red = 0;
    }
    if (red > 255) { 
      red = 255;
    }
    if (red > 127) {
      int blue = int((255-red)*(255-red)/127);
      fill(red, 0, blue, 63+int(1.5*abs(red-127.5)));
      stroke(red, 0, blue, 127);
    } else {
      fill(red*red/127, 0, 255-red, 63+int(1.5*abs(red-127.5)));
      stroke(red*red/127, 0, 255-red, 127);
    }
    if (trace) {
      line(xprev, yprev, x, y);
    } else {
      ellipse(x, y, 2*RADIUS, 2*RADIUS);
    }
  } // display

  // Update the position of the person
  void update() {
    // Update the position
    xprev = x;
    yprev = y;
    x += xspeed;
    y += yspeed;
    // Bounce at the walls
    if (x+RADIUS >= WIDTH) {
      xspeed = -abs(xspeed);
    }
    if (x-RADIUS < 0) {
      xspeed = abs(xspeed);
    }
    if (y+RADIUS >= HEIGHT) {
      yspeed = -abs(yspeed);
    }
    if (y-RADIUS < 0) {
      yspeed = abs(yspeed);
    }
    // Update politics randomly
    red += 5 - int(random(11));
  }

  float distance(Person other) {
    float distance = sqrt((x - other.x)*(x - other.x) + (y - other.y)*(y - other.y));
    return distance;
  }
}

// Functions

// A setup that puts reds on one side and blues on the other.
void biased_setup() {
  for (int i = 0; i < MAX_PEOPLE; i++) {
    int red = initial_red();
    int x;
    if (red > 127) {
      x = int(WIDTH/2 + random(WIDTH/2));
    } else {
      x = int(random(WIDTH/2));
    }
    people[i] = new Person(x, random(HEIGHT), red);
  } // for
  finish_setup();
} // biased_setup

// A setup that puts things in random places
void unbiased_setup() {
  for (int i = 0; i < MAX_PEOPLE; i++) {
    int red = initial_red(); 
    int(random(256));
    people[i] = new Person(random(WIDTH), random(HEIGHT), red);
  } // for
  finish_setup();
} // unbiased_setup

void setup_0() {
  int biased = MAX_PEOPLE/5;
  for (int i = 0; i < biased; i++) {
    people[i] = new Person(random(WIDTH/10)+RADIUS, random(HEIGHT), 255);
  }
  for (int i = biased; i < 2*biased; i++) {
    people[i] = new Person(WIDTH-random(WIDTH/10)-RADIUS, random(HEIGHT), 0);
  }
  for (int i = 2*biased; i < MAX_PEOPLE; i++) {
    people[i] = new Person(random(WIDTH), random(HEIGHT), 127 + int(random(1)));
  }
  finish_setup();
}

void finish_setup() {
  fix_overlaps();
  background(255);
  active = true;
  draw();
  active = false;
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
  while (a.distance(b) < 2*RADIUS) {
    if (a.x < b.x) {
      a.x -= DELTA;
      b.x += DELTA;
    } else {
      a.x += DELTA;
      b.x -= DELTA;
    }
    if (a.y < b.y) {
      a.y -= DELTA;
      b.y += DELTA;
    } else {
      a.y += DELTA;
      b.y -= DELTA;
    }
  } // while
}

// Check for collisions and update
void check_collisions() {
  for (int i = 0; i < MAX_PEOPLE; i++) {
    for (int j = i+1; j < MAX_PEOPLE; j++) {
      Person a = people[i];
      Person b = people[j];
      // See if they collide
      float distance = a.distance(b);
      if (distance < 2*RADIUS) {
        update_bias(a, b);
        update_velocity(a, b);
        separate(a, b);
      } // If they collide
    } // for
  } // for
} // check_collisions

// Update the biases of these two people.
void update_bias(Person a, Person b) {
  update_bias_1(a, b);
}

// Mechanism 1 for updating biases.  If the other person is red, become more
// red.  If the other preson is blue, become more blue.  If the other person
// is neutral, become more neutral.
void update_bias_1(Person a, Person b) {
  // Determine current bias
  float abias = a.red - 127.5;
  float bbias = b.red - 127.5;

  // Update colors
  if (abias > 40) {
    b.red += DELTA;
  } else if (abias < -40) {
    b.red -= DELTA;
  } else {
    if (b.red > 127.5) {
      b.red -= DELTA;
    } else {
      b.red += DELTA;
    }
  }
  if (bbias > 40) {
    a.red += DELTA;
  } else if (bbias < -40) {
    a.red -= DELTA;
  } else {
    if (a.red > 127.5) {
      a.red -= DELTA;
    } else {
      a.red += DELTA;
    }
  }
} // update_bias_1

// Mechanism 2 for updating biases.  Weighted average with the other person
// then bias toward common factor.
void update_bias_2(Person a, Person b) {
  int total_red = a.red + b.red;
  a.red = round((4*a.red + total_red)/6.0);
  b.red = round((4*b.red + total_red)/6.0);
  int bias = total_red - 255;
  if (bias > 64) {
    a.red += DELTA;
    b.red += DELTA;
  } else if (bias < -64) {
    a.red -= DELTA;
    b.red -= DELTA;
  } else {
    if (a.red > 127) { 
      a.red -= DELTA;
    } else {
      a.red += DELTA;
    }
    if (b.red > 127) {
      b.red -= DELTA;
    } else {
      b.red += DELTA;
    }
  }
} // update_bias_2

// Determine a "random" red color for a person.
int initial_red() {
  return initial_red_1();
}

int initial_red_0() {
  return 32 + int(random(192));
}

int initial_red_1() {
  return 64 + 127*int(random(2));
}

int initial_red_2() {
  return int(random(256));
}

void update_velocity(Person a, Person b)
{
  update_velocity_3(a, b);
}

// A dumb way to update velocity.  No Physics 
// involved.
void update_velocity_0(Person a, Person b)
{
  // Update velocity
  float combinedx = abs(a.xspeed) + abs(b.xspeed);
  float combinedy = abs(a.yspeed) + abs(b.yspeed);
  if (a.x > b.x) {
    a.xspeed = combinedx/2;
    b.xspeed = -combinedx/2;
  } else {
    a.xspeed = -combinedx/2;
    b.xspeed = combinedx/2;
  }
  if (a.y > b.y) {
    a.yspeed = combinedy/2;
    b.yspeed = -combinedy/2;
  } else {
    a.yspeed = -combinedy/2;
    b.yspeed = combinedy/2;
  }
}

// A failed attempt at using physics
void update_velocity_1(Person a, Person b) {
  float bx = b.xspeed;
  float by = b.yspeed;
  float xspeed = a.xspeed - b.xspeed;
  float yspeed = a.yspeed - b.yspeed;
  float speed = sqrt(xspeed*xspeed + yspeed*yspeed);
  float init_angle = compute_angle(xspeed, yspeed);
  float bangle = compute_angle(b.x-a.x, b.y-a.y);
  float aangle = cleanup_angle(bangle + PI/2);
  float theta = cleanup_angle(init_angle - aangle);
  float aspeed = speed * cos(theta);
  float bspeed = speed * sin(theta);
  a.xspeed = aspeed * cos(aangle);
  a.yspeed = aspeed * sin(aangle);
  b.xspeed = bspeed * cos(bangle);
  b.yspeed = bspeed * sin(bangle);
} // update_velocity_1

// Yet another alternate attempt at using physics, based on
// http://williamecraver.wix.com/elastic-equations
// (found from http://williamecraver.wix.com/elastic-equations)
// Note that the two masses are the same, so we can simplify.
// This doesn't currently work.
void update_velocity_2(Person a, Person b) {
  float aspeed = sqrt(a.xspeed*a.xspeed + a.yspeed*a.yspeed);
  float bspeed = sqrt(b.xspeed*b.xspeed + b.yspeed*b.yspeed);
  float atheta;
  float btheta;
  float phi;
  if (a.x < b.x) {
    atheta = compute_angle(a.xspeed, a.yspeed);
    btheta = compute_angle(-b.xspeed, b.yspeed);
    phi = compute_angle(b.x-a.x, b.y-a.y);
  } else {
    atheta = compute_angle(-a.xspeed, a.yspeed);
    btheta = compute_angle(b.xspeed, b.yspeed);
    phi = compute_angle(a.x-b.x, a.y-b.y);
  }
  a.xspeed = bspeed*cos(btheta-phi)*cos(phi) + aspeed*sin(atheta-phi)*cos(phi+PI/2);
  a.yspeed = bspeed*cos(btheta-phi)*sin(phi) + aspeed*sin(atheta-phi)*sin(phi+PI/2);
  b.xspeed = aspeed*cos(atheta-phi)*cos(phi) + bspeed*sin(btheta-phi)*cos(phi+PI/2);
  b.yspeed = aspeed*cos(atheta-phi)*sin(phi) + bspeed*sin(btheta-phi)*sin(phi+PI/2);
}

// A hack.  But perhaps a good hack.
void update_velocity_3(Person a, Person b) {
  float xtmp = b.xspeed;
  float ytmp = b.yspeed;
  b.xspeed = a.xspeed;
  b.yspeed = a.yspeed;
  a.xspeed = xtmp;
  a.yspeed = ytmp;
}

float cleanup_angle(float angle) {
  while (angle < 0) {
    angle += TWO_PI;
  }
  while (angle > TWO_PI) {
    angle -= TWO_PI;
  }
  return angle;
}

float compute_angle(float deltax, float deltay) {
  if (deltax == 0) {
    if (deltay < 0)
      return PI/2;
    else
      return 3*PI/2;
  } else {
    return atan(deltay/deltax);
  }
} // compute_angle