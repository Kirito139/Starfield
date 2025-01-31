ArrayList <Particle> particles = new ArrayList <Particle>();
// int[] particles = new int[1000];
AimCursor reticule;
boolean upPressed, downPressed, leftPressed, rightPressed;
int reticuleVX, reticuleVY;
float aimX, aimY; // where the system is aiming
float bulletSpeed = 20;
float aimSpeed = 0.9; // how fast the aimpoint moves, 1 is instantaneous
float reloadTime = 5; // frames between shots
int framesSinceLastShot = 0;
int shotsSinceLastTracer = 0;
float anchorX, anchorY;
PVector prevMousePos, prevReticulePos;
PVector avgVelocity = new PVector(0, 0);
int velocitySampleSize = 20; // number of frames to average velocity over
float jitterAmount = 4.0; // Adjust this value for more or less jitter
float jitterX, jitterY;
boolean aimLine, cursorAim;

class Particle {
  float x, y, vx, vy;
  float angle = atan2(vy, vx);
  int[] colo = new int[3];

  Particle(float x, float y, float angle) {
    this.x = x;
    this.y = y;
    this.vx = bulletSpeed * cos(angle);
    this.vy = bulletSpeed * sin(angle);
    this.colo[0] = 55;
    this.colo[1] = 55;
    this.colo[2] = 55;
  }

  void move() {
    x += vx;
    y += vy;
  }

  void show() {
    stroke(colo[0], colo[1], colo[2]);
    strokeWeight(2);
    noFill();
    line(x, y, x - vx / 2, y - vy / 2);
  }
  // setter for color
  void setColor(int r, int g, int b) {
    colo[0] = r;
    colo[1] = g;
    colo[2] = b;
  }

  boolean isOffScreen() { return x < 0 || x > width || y < 0 || y > height; }
  boolean isNearMouse() { return dist(x, y, mouseX, mouseY) < 10; }
  boolean isNearReticule() {
    return dist(x, y, reticule.getX(), reticule.getY()) < 15;
  }
}

// class Oddball extends Particle {
//   Oddball(float x, float y, float angle) { super(x, y, angle); }
// 
//   void show() {
//     stroke(0, 255, 0);
//     strokeWeight(2);
//     noFill();
//     line(x - vx / 1.5, y - vy / 1.5, x, y); // Draw tracer round
//   }
// }

void setup() {
  frameRate(120);
  size(960, 540);
  anchorX = 50;
  anchorY = height - 50;
  aimX = anchorX; // initialize aim point to anchor point
  aimY = anchorY;
  prevMousePos = new PVector(mouseX, mouseY);
  reticule = new AimCursor();
  prevReticulePos = new PVector(reticule.getX(), reticule.getY());
  aimLine = false;
  cursorAim = false;
}

void draw() {
  background(0);

  text("Aim speed: " + aimSpeed, 10, 20);
  text("Bullet speed: " + bulletSpeed, 10, 40);
  text("Jitter: " + jitterAmount, 10, 60);

  PVector mouse = new PVector(mouseX, mouseY);
  PVector mouseVelocity = new PVector(mouse.x - prevMousePos.x, mouse.y -
      prevMousePos.y);

  PVector reticulePos = new PVector(reticule.getX(), reticule.getY());
  PVector reticuleVelocity = new PVector(reticule.getX() - prevReticulePos.x,
      reticule.getY() - prevReticulePos.y);

  if (!cursorAim) { // calculate average mouse velocity
    avgVelocity.x += (mouseVelocity.x - avgVelocity.x) * (1.0/
        velocitySampleSize);
    avgVelocity.y += (mouseVelocity.y - avgVelocity.y) * (1.0 /
        velocitySampleSize);
  } else { // calculate average reticule velocity
    avgVelocity.x += (reticule.getX() - prevReticulePos.x - avgVelocity.x) *
      (1.0 / velocitySampleSize);
    avgVelocity.y += (reticule.getY() - prevReticulePos.y - avgVelocity.y) *
      (1.0 / velocitySampleSize);
    // avgVelocity.x += (reticule.getX() - avgVelocity.x) * (1.0 /
    // velocitySampleSize);
    // avgVelocity.y += (reticule.getY() - avgVelocity.y) * (1.0 /
    // velocitySampleSize);
  }

  prevMousePos.set(mouse);
  prevReticulePos.set(reticulePos);

  if (cursorAim) {
    keyCheck();
  }

  float distanceToMouse, distanceToReticule;
  float leadTime, leadX, leadY;

  if (!cursorAim) {
    distanceToMouse = dist(anchorX, anchorY, mouseX, mouseY);
    leadTime = distanceToMouse / bulletSpeed; // how far to lead by
    leadX = mouseX + avgVelocity.x * leadTime;
    leadY = mouseY + avgVelocity.y * leadTime;
  } else {
    distanceToReticule = dist(anchorX, anchorY, reticule.getX(),
        reticule.getY());
    leadTime = distanceToReticule / bulletSpeed;
    leadX = reticule.getX() + avgVelocity.x * leadTime;
    leadY = reticule.getY() + avgVelocity.y * leadTime;
  }


  // calculate aim point coords
  aimX += (leadX - aimX) * aimSpeed;
  aimY += (leadY - aimY) * aimSpeed;
  aimX += jitterX;
  aimY += jitterY;

  // draw aim line
  if (aimLine) {
    stroke(255, 0, 0);
    strokeWeight(1);
    line(anchorX, anchorY, aimX, aimY);
  }

  if (framesSinceLastShot >= reloadTime) {
    fire();
    framesSinceLastShot = 0;
  }

  framesSinceLastShot++;

  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.move();
    p.show();

    if (p.isOffScreen()) particles.remove(i);
    if (!cursorAim) {
      if (p.isNearMouse()) p.setColor(10, 10, 10);
    } else {
      if (p.isNearReticule()) p.setColor(10, 10, 10);
    }
  }
  if (cursorAim) {
    reticule.show();
  }
}

void fire() {
  float angle = atan2(aimY - anchorY, aimX - anchorX);
  jitterX = random(-jitterAmount, jitterAmount);
  jitterY = random(-jitterAmount, jitterAmount);

  Particle newParticle = new Particle(anchorX, anchorY, angle);
  newParticle.setColor(0, 255, 255);
  particles.add(newParticle);
  // if (shotsSinceLastTracer >= 5) {
  //     Oddball newOddball = new Oddball(anchorX, anchorY, angle);
  //     newOddball.setColor(0, 255, 255);
  //     particles.add(newOddball);
  //     shotsSinceLastTracer = 0;
  // } else {
  //     Particle newParticle = new Particle(anchorX, anchorY, angle);
  //     particles.add(newParticle);
  //     shotsSinceLastTracer++;
  // }
}

public void keyCheck() {
  if (upPressed) reticule.up();
  if (downPressed) reticule.down();
  if (leftPressed) reticule.left();
  if (rightPressed) reticule.right();
}

public void keyPressed() {
  if (key == 'a') aimLine = !aimLine;
  if (key == '=') bulletSpeed++;
  if (key == '-') bulletSpeed--;
  if (key == '.') aimSpeed += 0.1;
  if (key == ',') aimSpeed -= 0.1;
  if (key == ';') jitterAmount += 0.1;
  if (key == '/') jitterAmount -= 0.1;
  if (key == 't') {
    cursorAim = !cursorAim;
    if (cursorAim) {
      aimX = reticule.getX();
      aimY = reticule.getY();
      reticuleVX = 0;
      reticuleVY = 0;
    }
  }

  if (cursorAim) {
    if (key == 'k') {
      upPressed = true;
      reticuleVY -= 5;
    }
    if (key == 'j') {
      downPressed = true;
      reticuleVY += 5;
    }
    if (key == 'h') {
      leftPressed = true;
      reticuleVX -= 5;
    }
    if (key == 'l') {
      rightPressed = true;
      reticuleVX += 5;
    }
  }
}

public void keyReleased() {
  if (cursorAim) {
    if (key == 'k') {
      upPressed = false;
      reticuleVY += 5;
    }
    if (key == 'j') {
      downPressed = false;
      reticuleVY -= 5;
    }
    if (key == 'h') {
      leftPressed = false;
      reticuleVX += 5;
    }
    if (key == 'l') {
      rightPressed = false;
      reticuleVX -= 5;
    }
  }
}
